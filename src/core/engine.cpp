#include "engine.h"
#include <QHash>

Engine *Sangousha = NULL;

Engine::Engine()
{
    Sangousha = this;

    // 初始化Lua
    lua = CreateLuaState();
    DoLuaScript(lua, "lua/config.lua");

}

Engine::~Engine()
{

}

/**
 * 翻译字符串
 *
 * @brief Engine::translate
 * @param toTranslate
 * @return
 */
QString Engine::translate(const QString &toTranslate) const
{
//    return translations.value(toTranslate, toTranslate);
    return toTranslate;
}
