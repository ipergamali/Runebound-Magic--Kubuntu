#pragma once

#include <QObject>
#include <QVariantMap>

class QNetworkAccessManager;

class FirebaseFirestore : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString projectId READ projectId WRITE setProjectId NOTIFY projectIdChanged)
    Q_PROPERTY(QString apiKey READ apiKey WRITE setApiKey NOTIFY apiKeyChanged)
    Q_PROPERTY(QString authToken READ authToken WRITE setAuthToken NOTIFY authTokenChanged)
    Q_PROPERTY(bool ready READ ready NOTIFY readyChanged)
    Q_PROPERTY(QString lastError READ lastError NOTIFY lastErrorChanged)

public:
    explicit FirebaseFirestore(QObject *parent = nullptr);
    ~FirebaseFirestore() override;

    QString projectId() const;
    void setProjectId(const QString &projectId);

    QString apiKey() const;
    void setApiKey(const QString &apiKey);

    QString authToken() const;
    void setAuthToken(const QString &authToken);

    bool ready() const;
    QString lastError() const;

    Q_INVOKABLE void createDocument(const QString &collectionPath, const QVariantMap &fields);
    Q_INVOKABLE void setDocument(const QString &documentPath, const QVariantMap &fields);
    Q_INVOKABLE void getDocument(const QString &documentPath);
    Q_INVOKABLE void listDocuments(const QString &collectionPath);

signals:
    void projectIdChanged();
    void apiKeyChanged();
    void authTokenChanged();
    void readyChanged();
    void lastErrorChanged();
    void documentCreated(const QString &collectionPath, const QString &documentName);
    void documentWritten(const QString &documentPath);
    void documentFetched(const QString &documentPath, const QVariantMap &fields);
    void documentsFetched(const QString &collectionPath, const QVariantList &documents);

private:
    bool hasRequiredConfig() const;
    void setLastError(const QString &errorMessage);
    QNetworkAccessManager *network() const;

    QString m_projectId;
    QString m_apiKey;
    QString m_authToken;
    QString m_lastError;
    mutable QNetworkAccessManager *m_networkAccessManager = nullptr;
};
