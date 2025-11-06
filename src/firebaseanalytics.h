#pragma once

#include <QObject>
#include <QVariantMap>

class QNetworkAccessManager;

class FirebaseAnalytics : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString measurementId READ measurementId WRITE setMeasurementId NOTIFY measurementIdChanged)
    Q_PROPERTY(QString appId READ appId WRITE setAppId NOTIFY appIdChanged)
    Q_PROPERTY(bool ready READ ready NOTIFY readyChanged)

public:
    explicit FirebaseAnalytics(QObject *parent = nullptr);
    ~FirebaseAnalytics() override;

    QString measurementId() const;
    void setMeasurementId(const QString &measurementId);

    QString appId() const;
    void setAppId(const QString &appId);

    QString apiSecret() const;
    void setApiSecret(const QString &apiSecret);

    bool ready() const;

    Q_INVOKABLE void logEvent(const QString &name, const QVariantMap &params = {});
    Q_INVOKABLE QString clientId() const;

signals:
    void measurementIdChanged();
    void appIdChanged();
    void readyChanged();

private:
    bool hasRequiredConfig() const;
    QString ensureClientId();

    QString m_measurementId;
    QString m_appId;
    QString m_apiSecret;
    QString m_clientId;
    QNetworkAccessManager *m_networkAccessManager = nullptr;
};
