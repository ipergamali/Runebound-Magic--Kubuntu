#include "firebaseanalytics.h"

#include <QDateTime>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QRandomGenerator>
#include <QSettings>
#include <QString>
#include <QUrl>
#include <QUrlQuery>
#include <QtDebug>

namespace {
QString generateClientId()
{
    const quint64 high = QRandomGenerator::global()->generate64();
    const quint64 low = QRandomGenerator::global()->generate64();
    return QString::number(high) + QStringLiteral(".") + QString::number(low);
}
} // namespace

FirebaseAnalytics::FirebaseAnalytics(QObject *parent)
    : QObject(parent)
    , m_networkAccessManager(new QNetworkAccessManager(this))
{
    ensureClientId();
}

FirebaseAnalytics::~FirebaseAnalytics() = default;

QString FirebaseAnalytics::measurementId() const
{
    return m_measurementId;
}

void FirebaseAnalytics::setMeasurementId(const QString &measurementId)
{
    if (m_measurementId == measurementId)
        return;

    m_measurementId = measurementId;
    emit measurementIdChanged();
    emit readyChanged();
}

QString FirebaseAnalytics::appId() const
{
    return m_appId;
}

void FirebaseAnalytics::setAppId(const QString &appId)
{
    if (m_appId == appId)
        return;

    m_appId = appId;
    emit appIdChanged();
}

QString FirebaseAnalytics::apiSecret() const
{
    return m_apiSecret;
}

void FirebaseAnalytics::setApiSecret(const QString &apiSecret)
{
    if (m_apiSecret == apiSecret)
        return;

    m_apiSecret = apiSecret;
    emit readyChanged();
}

bool FirebaseAnalytics::ready() const
{
    return hasRequiredConfig();
}

void FirebaseAnalytics::logEvent(const QString &name, const QVariantMap &params)
{
    if (!hasRequiredConfig()) {
        qWarning() << "FirebaseAnalytics: missing measurementId or apiSecret; event not sent.";
        return;
    }

    if (name.isEmpty()) {
        qWarning() << "FirebaseAnalytics: event name cannot be empty.";
        return;
    }

    QUrl url(QStringLiteral("https://www.google-analytics.com/mp/collect"));
    QUrlQuery query;
    query.addQueryItem(QStringLiteral("measurement_id"), m_measurementId);
    query.addQueryItem(QStringLiteral("api_secret"), m_apiSecret);
    url.setQuery(query);

    QJsonObject root;
    root.insert(QStringLiteral("client_id"), ensureClientId());

    if (!m_appId.isEmpty())
        root.insert(QStringLiteral("firebase_app_id"), m_appId);

    QJsonObject event;
    event.insert(QStringLiteral("name"), name);

    QJsonObject paramsObject;
    for (auto it = params.cbegin(), end = params.cend(); it != end; ++it) {
        paramsObject.insert(it.key(), QJsonValue::fromVariant(it.value()));
    }

    if (!paramsObject.contains(QStringLiteral("engagement_time_msec")))
        paramsObject.insert(QStringLiteral("engagement_time_msec"), QStringLiteral("1"));

    event.insert(QStringLiteral("params"), paramsObject);
    event.insert(QStringLiteral("timestamp_micros"),
                 QString::number(QDateTime::currentDateTimeUtc().toMSecsSinceEpoch() * 1000));

    QJsonArray events;
    events.append(event);
    root.insert(QStringLiteral("events"), events);

    const QByteArray payload = QJsonDocument(root).toJson(QJsonDocument::Compact);

    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, QStringLiteral("application/json"));

    QNetworkReply *reply = m_networkAccessManager->post(request, payload);
    QObject::connect(reply, &QNetworkReply::finished, this, [reply]() {
        const auto error = reply->error();
        if (error != QNetworkReply::NoError) {
            qWarning() << "FirebaseAnalytics: event delivery failed:" << reply->errorString();
            const QByteArray body = reply->readAll();
            if (!body.isEmpty())
                qWarning() << "FirebaseAnalytics response body:" << body;
        }
#if defined(QT_DEBUG)
        else {
            qDebug() << "FirebaseAnalytics: event sent successfully.";
        }
#endif
        reply->deleteLater();
    });
}

QString FirebaseAnalytics::clientId() const
{
    if (m_clientId.isEmpty())
        const_cast<FirebaseAnalytics *>(this)->ensureClientId();
    return m_clientId;
}

bool FirebaseAnalytics::hasRequiredConfig() const
{
    return !m_measurementId.isEmpty() && !m_apiSecret.isEmpty();
}

QString FirebaseAnalytics::ensureClientId()
{
    if (!m_clientId.isEmpty())
        return m_clientId;

    QSettings settings;
    const QString key = QStringLiteral("firebase/client_id");
    m_clientId = settings.value(key).toString();
    if (m_clientId.isEmpty()) {
        m_clientId = generateClientId();
        settings.setValue(key, m_clientId);
        settings.sync();
    }

    return m_clientId;
}
