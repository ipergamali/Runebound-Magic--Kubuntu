#include "firebasefirestore.h"

#include <QDateTime>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonValue>
#include <QMetaType>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QPointer>
#include <QUrl>
#include <QUrlQuery>
#include <QtDebug>

namespace {

QString isoTimestamp(const QDateTime &dt)
{
    return dt.toUTC().toString(Qt::ISODateWithMs);
}

QJsonObject encodeVariant(const QVariant &value);

QJsonArray encodeArray(const QVariantList &list)
{
    QJsonArray array;
    for (const QVariant &item : list)
        array.append(encodeVariant(item));
    return array;
}

QJsonObject encodeMap(const QVariantMap &map)
{
    QJsonObject fields;
    for (auto it = map.cbegin(), end = map.cend(); it != end; ++it)
        fields.insert(it.key(), encodeVariant(it.value()));
    return fields;
}

QJsonObject encodeVariant(const QVariant &value)
{
    QJsonObject wrapper;

    switch (value.metaType().id()) {
    case QMetaType::Bool:
        wrapper.insert(QStringLiteral("booleanValue"), value.toBool());
        break;
    case QMetaType::Int:
    case QMetaType::LongLong:
    case QMetaType::UInt:
    case QMetaType::ULongLong:
        wrapper.insert(QStringLiteral("integerValue"), QString::number(value.toLongLong()));
        break;
    case QMetaType::Double:
    case QMetaType::Float:
        wrapper.insert(QStringLiteral("doubleValue"), value.toDouble());
        break;
    case QMetaType::QDateTime:
        wrapper.insert(QStringLiteral("timestampValue"), isoTimestamp(value.toDateTime()));
        break;
    case QMetaType::QVariantList:
    case QMetaType::QStringList: {
        const QVariantList list = value.toList();
        QJsonObject arrayValue;
        arrayValue.insert(QStringLiteral("values"), encodeArray(list));
        wrapper.insert(QStringLiteral("arrayValue"), arrayValue);
        break;
    }
    case QMetaType::QVariantMap: {
        const QVariantMap map = value.toMap();
        QJsonObject mapValue;
        mapValue.insert(QStringLiteral("fields"), encodeMap(map));
        wrapper.insert(QStringLiteral("mapValue"), mapValue);
        break;
    }
    default:
        wrapper.insert(QStringLiteral("stringValue"), value.toString());
        break;
    }

    return wrapper;
}

} // namespace

namespace {

QVariant decodeVariant(const QJsonObject &valueObject);

QVariantList decodeArray(const QJsonObject &arrayObject)
{
    QVariantList list;
    const QJsonArray values = arrayObject.value(QStringLiteral("values")).toArray();
    for (const QJsonValue &value : values) {
        if (value.isObject())
            list.append(decodeVariant(value.toObject()));
    }
    return list;
}

QVariantMap decodeMap(const QJsonObject &mapObject)
{
    QVariantMap map;
    for (auto it = mapObject.constBegin(), end = mapObject.constEnd(); it != end; ++it) {
        if (it.value().isObject())
            map.insert(it.key(), decodeVariant(it.value().toObject()));
    }
    return map;
}

QVariant decodeVariant(const QJsonObject &valueObject)
{
    if (valueObject.contains(QStringLiteral("nullValue")))
        return QVariant();
    if (valueObject.contains(QStringLiteral("booleanValue")))
        return valueObject.value(QStringLiteral("booleanValue")).toBool();
    if (valueObject.contains(QStringLiteral("integerValue")))
        return valueObject.value(QStringLiteral("integerValue")).toString().toLongLong();
    if (valueObject.contains(QStringLiteral("doubleValue")))
        return valueObject.value(QStringLiteral("doubleValue")).toDouble();
    if (valueObject.contains(QStringLiteral("timestampValue")))
        return valueObject.value(QStringLiteral("timestampValue")).toString();
    if (valueObject.contains(QStringLiteral("stringValue")))
        return valueObject.value(QStringLiteral("stringValue")).toString();
    if (valueObject.contains(QStringLiteral("mapValue"))) {
        const QJsonObject fieldsObject = valueObject.value(QStringLiteral("mapValue")).toObject().value(QStringLiteral("fields")).toObject();
        return decodeMap(fieldsObject);
    }
    if (valueObject.contains(QStringLiteral("arrayValue")))
        return decodeArray(valueObject.value(QStringLiteral("arrayValue")).toObject());
    return QVariant();
}

QVariantMap decodeDocument(const QJsonObject &documentObject)
{
    QVariantMap map;
    const QString fullName = documentObject.value(QStringLiteral("name")).toString();
    if (!fullName.isEmpty()) {
        map.insert(QStringLiteral("name"), fullName);
        map.insert(QStringLiteral("id"), fullName.section(QLatin1Char('/'), -1));
    }
    const QJsonObject fieldsObject = documentObject.value(QStringLiteral("fields")).toObject();
    const QVariantMap decodedFields = decodeMap(fieldsObject);
    for (auto it = decodedFields.constBegin(), end = decodedFields.constEnd(); it != end; ++it)
        map.insert(it.key(), it.value());
    return map;
}

} // namespace

FirebaseFirestore::FirebaseFirestore(QObject *parent)
    : QObject(parent)
{
}

FirebaseFirestore::~FirebaseFirestore() = default;

QString FirebaseFirestore::projectId() const
{
    return m_projectId;
}

void FirebaseFirestore::setProjectId(const QString &projectId)
{
    if (m_projectId == projectId)
        return;

    m_projectId = projectId;
    emit projectIdChanged();
    emit readyChanged();
}

QString FirebaseFirestore::apiKey() const
{
    return m_apiKey;
}

void FirebaseFirestore::setApiKey(const QString &apiKey)
{
    if (m_apiKey == apiKey)
        return;

    m_apiKey = apiKey;
    emit apiKeyChanged();
    emit readyChanged();
}

QString FirebaseFirestore::authToken() const
{
    return m_authToken;
}

void FirebaseFirestore::setAuthToken(const QString &authToken)
{
    if (m_authToken == authToken)
        return;

    m_authToken = authToken;
    emit authTokenChanged();
    emit readyChanged();
}

bool FirebaseFirestore::ready() const
{
    return hasRequiredConfig();
}

QString FirebaseFirestore::lastError() const
{
    return m_lastError;
}

void FirebaseFirestore::createDocument(const QString &collectionPath, const QVariantMap &fields)
{
    if (!hasRequiredConfig()) {
        const QString msg = QStringLiteral("FirebaseFirestore: missing projectId or apiKey/authToken.");
        qWarning() << msg;
        setLastError(msg);
        return;
    }

    if (collectionPath.trimmed().isEmpty()) {
        const QString msg = QStringLiteral("FirebaseFirestore: collection path cannot be empty.");
        qWarning() << msg;
        setLastError(msg);
        return;
    }

    const QString baseUrl = QStringLiteral("https://firestore.googleapis.com/v1/projects/%1/databases/(default)/documents/%2")
                                .arg(m_projectId, collectionPath);
    QUrl url(baseUrl);
    if (!m_apiKey.isEmpty()) {
        QUrlQuery query(url);
        query.addQueryItem(QStringLiteral("key"), m_apiKey);
        url.setQuery(query);
    }

    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, QStringLiteral("application/json"));
    if (!m_authToken.isEmpty())
        request.setRawHeader("Authorization", QByteArrayLiteral("Bearer ") + m_authToken.toUtf8());

    QJsonObject payload;
    payload.insert(QStringLiteral("fields"), encodeMap(fields));

    const QByteArray body = QJsonDocument(payload).toJson(QJsonDocument::Compact);

    QNetworkAccessManager *manager = network();
    QNetworkReply *reply = manager->post(request, body);

    QPointer<FirebaseFirestore> guard(this);
    QObject::connect(reply, &QNetworkReply::finished, this, [this, guard, reply, collectionPath]() {
        if (!guard)
            return;

        const auto replyError = reply->error();
        if (replyError != QNetworkReply::NoError) {
            const QString errorString = QStringLiteral("FirebaseFirestore: createDocument failed: %1")
                                            .arg(reply->errorString());
            qWarning() << errorString;
            const QByteArray responseBody = reply->readAll();
            if (!responseBody.isEmpty())
                qWarning() << "FirebaseFirestore response body:" << responseBody;
            setLastError(errorString);
        } else {
            const QByteArray responseBody = reply->readAll();
            const QJsonDocument doc = QJsonDocument::fromJson(responseBody);
            const QString name = doc.object().value(QStringLiteral("name")).toString();
            qInfo() << "FirebaseFirestore: document created in" << collectionPath << "->" << name;
            setLastError(QString());
            emit documentCreated(collectionPath, name);
        }

        reply->deleteLater();
    });
}

void FirebaseFirestore::setDocument(const QString &documentPath, const QVariantMap &fields)
{
    if (!hasRequiredConfig()) {
        const QString msg = QStringLiteral("FirebaseFirestore: missing projectId or apiKey/authToken.");
        qWarning() << msg;
        setLastError(msg);
        return;
    }

    if (documentPath.trimmed().isEmpty()) {
        const QString msg = QStringLiteral("FirebaseFirestore: document path cannot be empty.");
        qWarning() << msg;
        setLastError(msg);
        return;
    }

    const QString baseUrl = QStringLiteral("https://firestore.googleapis.com/v1/projects/%1/databases/(default)/documents/%2")
                                .arg(m_projectId, documentPath);
    QUrl url(baseUrl);
    if (!m_apiKey.isEmpty()) {
        QUrlQuery query(url);
        query.addQueryItem(QStringLiteral("key"), m_apiKey);
        url.setQuery(query);
    }

    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, QStringLiteral("application/json"));
    if (!m_authToken.isEmpty())
        request.setRawHeader("Authorization", QByteArrayLiteral("Bearer ") + m_authToken.toUtf8());

    QJsonObject payload;
    payload.insert(QStringLiteral("fields"), encodeMap(fields));
    const QByteArray body = QJsonDocument(payload).toJson(QJsonDocument::Compact);

    QNetworkReply *reply = network()->sendCustomRequest(request, QByteArrayLiteral("PATCH"), body);
    QPointer<FirebaseFirestore> guard(this);
    QObject::connect(reply, &QNetworkReply::finished, this, [this, guard, reply, documentPath]() {
        if (!guard)
            return;
        const auto replyError = reply->error();
        if (replyError != QNetworkReply::NoError) {
            const QString errorString = QStringLiteral("FirebaseFirestore: setDocument failed: %1").arg(reply->errorString());
            qWarning() << errorString;
            const QByteArray responseBody = reply->readAll();
            if (!responseBody.isEmpty())
                qWarning() << "FirebaseFirestore response body:" << responseBody;
            setLastError(errorString);
        } else {
            setLastError(QString());
            emit documentWritten(documentPath);
        }
        reply->deleteLater();
    });
}

void FirebaseFirestore::getDocument(const QString &documentPath)
{
    if (!hasRequiredConfig()) {
        const QString msg = QStringLiteral("FirebaseFirestore: missing projectId or apiKey/authToken.");
        qWarning() << msg;
        setLastError(msg);
        return;
    }
    if (documentPath.trimmed().isEmpty()) {
        const QString msg = QStringLiteral("FirebaseFirestore: document path cannot be empty.");
        qWarning() << msg;
        setLastError(msg);
        return;
    }

    const QString baseUrl = QStringLiteral("https://firestore.googleapis.com/v1/projects/%1/databases/(default)/documents/%2")
                                .arg(m_projectId, documentPath);
    QUrl url(baseUrl);
    if (!m_apiKey.isEmpty()) {
        QUrlQuery query(url);
        query.addQueryItem(QStringLiteral("key"), m_apiKey);
        url.setQuery(query);
    }

    QNetworkRequest request(url);
    if (!m_authToken.isEmpty())
        request.setRawHeader("Authorization", QByteArrayLiteral("Bearer ") + m_authToken.toUtf8());

    QNetworkReply *reply = network()->get(request);
    QPointer<FirebaseFirestore> guard(this);
    QObject::connect(reply, &QNetworkReply::finished, this, [this, guard, reply, documentPath]() {
        if (!guard)
            return;
        const auto replyError = reply->error();
        if (replyError != QNetworkReply::NoError) {
            const QString errorString = QStringLiteral("FirebaseFirestore: getDocument failed: %1").arg(reply->errorString());
            qWarning() << errorString;
            const QByteArray responseBody = reply->readAll();
            if (!responseBody.isEmpty())
                qWarning() << "FirebaseFirestore response body:" << responseBody;
            setLastError(errorString);
        } else {
            const QByteArray responseBody = reply->readAll();
            const QJsonDocument doc = QJsonDocument::fromJson(responseBody);
            const QVariantMap fields = decodeDocument(doc.object());
            setLastError(QString());
            emit documentFetched(documentPath, fields);
        }
        reply->deleteLater();
    });
}

void FirebaseFirestore::listDocuments(const QString &collectionPath)
{
    if (!hasRequiredConfig()) {
        const QString msg = QStringLiteral("FirebaseFirestore: missing projectId or apiKey/authToken.");
        qWarning() << msg;
        setLastError(msg);
        return;
    }
    if (collectionPath.trimmed().isEmpty()) {
        const QString msg = QStringLiteral("FirebaseFirestore: collection path cannot be empty.");
        qWarning() << msg;
        setLastError(msg);
        return;
    }

    const QString baseUrl = QStringLiteral("https://firestore.googleapis.com/v1/projects/%1/databases/(default)/documents/%2")
                                .arg(m_projectId, collectionPath);
    QUrl url(baseUrl);
    if (!m_apiKey.isEmpty()) {
        QUrlQuery query(url);
        query.addQueryItem(QStringLiteral("key"), m_apiKey);
        query.addQueryItem(QStringLiteral("pageSize"), QStringLiteral("100"));
        url.setQuery(query);
    }

    QNetworkRequest request(url);
    if (!m_authToken.isEmpty())
        request.setRawHeader("Authorization", QByteArrayLiteral("Bearer ") + m_authToken.toUtf8());

    QNetworkReply *reply = network()->get(request);
    QPointer<FirebaseFirestore> guard(this);
    QObject::connect(reply, &QNetworkReply::finished, this, [this, guard, reply, collectionPath]() {
        if (!guard)
            return;
        const auto replyError = reply->error();
        if (replyError != QNetworkReply::NoError) {
            const QString errorString = QStringLiteral("FirebaseFirestore: listDocuments failed: %1").arg(reply->errorString());
            qWarning() << errorString;
            const QByteArray responseBody = reply->readAll();
            if (!responseBody.isEmpty())
                qWarning() << "FirebaseFirestore response body:" << responseBody;
            setLastError(errorString);
        } else {
            const QByteArray responseBody = reply->readAll();
            const QJsonDocument doc = QJsonDocument::fromJson(responseBody);
            const QJsonArray documentsArray = doc.object().value(QStringLiteral("documents")).toArray();
            QVariantList documents;
            for (const QJsonValue &value : documentsArray) {
                if (value.isObject())
                    documents.append(decodeDocument(value.toObject()));
            }
            setLastError(QString());
            emit documentsFetched(collectionPath, documents);
        }
        reply->deleteLater();
    });
}
bool FirebaseFirestore::hasRequiredConfig() const
{
    return !m_projectId.isEmpty() && (!m_apiKey.isEmpty() || !m_authToken.isEmpty());
}

void FirebaseFirestore::setLastError(const QString &errorMessage)
{
    if (m_lastError == errorMessage)
        return;

    m_lastError = errorMessage;
    emit lastErrorChanged();
}

QNetworkAccessManager *FirebaseFirestore::network() const
{
    if (!m_networkAccessManager)
        m_networkAccessManager = new QNetworkAccessManager(const_cast<FirebaseFirestore *>(this));
    return m_networkAccessManager;
}
