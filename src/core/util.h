#ifndef UTIL_H
#define UTIL_H

struct lua_State;

#include <QList>
#include <QStringList>

/**
 * 洗牌
 */
template<typename T>
void qShuffle(QList<T> &list)
{
    int i, n = list.length();
    for (i = 0; i < n; i++) {
        int r = qrand() * (n - i) + i;
        list.swap(i, r);
    }
}

// lua解析器相关
lua_State *CreateLuaState();
void DoLuaScript(lua_State *L, const char *script);
void DoLuaScripts(lua_State *L, const QStringList &script);

QVariant GetValueFromLuaState(lua_State *L, const char *tableName, const char *key);

#endif // UTIL_H
