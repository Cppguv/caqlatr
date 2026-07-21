// Copyright (C) 2026 The Qt Company Ltd && Mary Khmylova
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQuickStyle>
#include <QQmlDebuggingEnabler>
#include <QDebug>
#include <QProcess>
#include <QJsonDocument>
#include <QJsonObject>
#include <QStandardPaths>
#include <QDir>
#include <QQmlContext>
#include "AppInfo.h"


class BackendBridge : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString outputText READ outputText NOTIFY outputTextChanged)

public:
    explicit BackendBridge(QObject *parent = nullptr) : QObject(parent), m_process(nullptr)
    {
        m_process = new QProcess(this);

        connect(m_process, &QProcess::readyReadStandardOutput, this, &BackendBridge::handleOutput);
        connect(m_process, &QProcess::readyReadStandardError, this, [=]() {
            qDebug() << "Python stderr:" << m_process->readAllStandardError();
        });
    }

    QString outputText() const { return m_outputText; }

    Q_INVOKABLE void prove(const QString &inputPremises, const QString &inputGoal, const bool &isStepMode)
    {
        if (m_process->state() == QProcess::Running) {
            qDebug() << "Python process is busy";
            return;
        }

        // Готовим JSON с входными данными
        QJsonObject request;
        request["inputPremises"] = inputPremises;
        request["inputGoal"] = inputGoal;
        request["isStepMode"] = isStepMode;

        QJsonDocument doc(request);
        QByteArray data = doc.toJson();

        // 1. Получаем путь к папке, где лежит наш calqulatr.exe
        QString appDir = QCoreApplication::applicationDirPath();

        // 2. Формируем пути к скрипту и встроенному Python (его скопировали внутрь папки с исполняемым файлом приложения)
        // Start основной Python файл Interface.py, который вызовет наш файл Backend.py
        QString pythonScript = appDir + "/Interface.py";

#ifdef Q_OS_WIN
        QString pythonExecutable = "pythonw";        // Либо appDir + "/python.exe" при автономной сборке
#else
        QString pythonExecutable = "python3";        // если на линукс
#endif

        // 3. Задаем рабочую директорию, чтобы Python понимал, откуда брать файлы content
        m_process->setWorkingDirectory(appDir);

        m_process->start(pythonExecutable, QStringList() << pythonScript);
        m_process->waitForStarted();

        m_process->write(data);
        m_process->closeWriteChannel();
    }

//     Q_INVOKABLE void callAutoExample()
//     {
//         if (m_process->state() == QProcess::Running) {
//             qDebug() << "Python process is busy";
//             return;
//         }

//         // Prepare JSON input
//         QJsonObject request;
//         request["input"] = input;

//         QJsonDocument doc(request);
//         QByteArray data = doc.toJson();

//         // Начало Python процесса
//         QString pythonScript = QCoreApplication::applicationDirPath() + "/backend.py";

// #ifdef Q_OS_WIN
//         QString pythonExecutable = "python";
// #else
//         QString pythonExecutable = "python3";
// #endif

//         m_process->start(pythonExecutable, QStringList() << pythonScript);
//         m_process->waitForStarted();

//         m_process->write(data);
//         m_process->closeWriteChannel();
//     }

signals:
    void outputTextChanged();

private slots:
    void handleOutput()
    {
        QByteArray output = m_process->readAllStandardOutput();
        QJsonDocument doc = QJsonDocument::fromJson(output);

        if (doc.isObject()) {
            QJsonObject response = doc.object();
            if (response.contains("result")) {
                m_outputText = response["result"].toString();
                emit outputTextChanged();
            } else if (response.contains("error")) {
                qDebug() << "Python error:" << response["error"].toString();
                m_outputText = "Error: " + response["error"].toString();
                emit outputTextChanged();
            }
        }

        m_process->waitForFinished();
    }

private:
    QProcess *m_process;
    QString m_outputText;
};


int main(int argc, char *argv[])
{
    QQmlDebuggingEnabler::enableDebugging(true);
    QCoreApplication::setOrganizationName("QtProject");
    QCoreApplication::setApplicationName("Calqlatr");

    QGuiApplication app(argc, argv);

    qmlRegisterType<BackendBridge>("Interface", 1, 0, "BackendBridge");

    QQuickStyle::setStyle("Basic");
    //QQuickStyle::setStyle("Fusion");

    // Устанавливаем данные здесь
    app.setApplicationName("Автоматическое доказательство логических\nвыражений методом резолюций");
    app.setApplicationVersion("1.0.0");
    app.setOrganizationName("КубГУ 2026   @ Mary Khmylova");

    AppInfo appInfo;
    //qmlRegisterType<AppInfo>("appInfo", 1, 0, "Dialog");

    QQmlApplicationEngine engine;

    // Регистрируем объект под именем "appInfo"
    engine.rootContext()->setContextProperty("appInfo", &appInfo);


    QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed,
            &app, []() { QCoreApplication::exit(-1); },
            Qt::QueuedConnection);
    engine.loadFromModule("calqlatr", "Main");

    return app.exec();
}

#include "main.moc"