#ifndef APPINFO_H
#define APPINFO_H

#include <QObject>
#include <QCoreApplication>

class AppInfo : public QObject
{
    Q_OBJECT
    // Делаем свойства доступными для чтения в QML
    Q_PROPERTY(QString name READ name CONSTANT)
    Q_PROPERTY(QString version READ version CONSTANT)
    Q_PROPERTY(QString organization READ organization CONSTANT)

public:
    explicit AppInfo(QObject *parent = nullptr) : QObject(parent) {}

    // Возвращает имя приложения, установленное в main.cpp
    QString name() const {
        return QCoreApplication::applicationName();
    }

    // Возвращает версию приложения
    QString version() const {
        return QCoreApplication::applicationVersion();
    }

    // Возвращает название организации
    QString organization() const {
        return QCoreApplication::organizationName();
    }
};

#endif // APPINFO_H
