#ifndef ENGINE_H
#define ENGINE_H

#include <QObject>
#include <QHash>

#include "util.h"

class Engine : public QObject
{
    Q_OBJECT

public:
    explicit Engine();
    ~Engine();

    QString translate(const QString &toTranslate) const;

private:
    QHash<QString, QString> translations;

    lua_State *lua;
};

// 单例变量s
extern Engine *Sangousha;

#endif // ENGINE_H
