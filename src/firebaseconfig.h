#pragma once

#include <QString>

struct FirebaseConfig {
    QString apiKey;
    QString authDomain;
    QString projectId;
    QString storageBucket;
    QString messagingSenderId;
    QString appId;
    QString measurementId;
};

inline FirebaseConfig firebaseConfig()
{
    return FirebaseConfig{
        QStringLiteral("AIzaSyDJwHW57VZ-_NDd1piK-Q5jLIfCkf4ZkK4"),
        QStringLiteral("runeboundmagicdesktop.firebaseapp.com"),
        QStringLiteral("runeboundmagicdesktop"),
        QStringLiteral("runeboundmagicdesktop.firebasestorage.app"),
        QStringLiteral("129661174805"),
        QStringLiteral("1:129661174805:web:8bb2e3e0f34ad2165efa1c"),
        QStringLiteral("G-3L747WTYKT")
    };
}
