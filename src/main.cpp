#include "firebaseconfig.h"
#include "firebasefirestore.h"

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

int main(int argc, char **argv)
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    FirebaseFirestore firestore;
    const FirebaseConfig config = firebaseConfig();
    firestore.setProjectId(config.projectId);
    firestore.setApiKey(config.apiKey);
    engine.rootContext()->setContextProperty(QStringLiteral("firestore"), &firestore);

    engine.load(QUrl(QStringLiteral("qrc:/RuneboundMagic/src/main.qml")));

    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
