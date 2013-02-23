#-------------------------------------------------
#
# Project created by QtCreator 2013-02-22T13:25:03
#
#-------------------------------------------------

QT       += core gui network sql declarative

greaterThan(QT_MAJOR_VERSION, 4): QT += widgets

TARGET = QSanguosha-Peter
TEMPLATE = app


SOURCES += \
    src/main.cpp\
    src/dialog/mainwindow.cpp \
    src/core/engine.cpp \
    src/core/util.cpp \
    src/lua/print.c \
    src/lua/lzio.c \
    src/lua/lvm.c \
    src/lua/lundump.c \
    src/lua/ltm.c \
    src/lua/ltablib.c \
    src/lua/ltable.c \
    src/lua/lstrlib.c \
    src/lua/lstring.c \
    src/lua/lstate.c \
    src/lua/lparser.c \
    src/lua/loslib.c \
    src/lua/lopcodes.c \
    src/lua/lobject.c \
    src/lua/loadlib.c \
    src/lua/lmem.c \
    src/lua/lmathlib.c \
    src/lua/llex.c \
    src/lua/liolib.c \
    src/lua/linit.c \
    src/lua/lgc.c \
    src/lua/lfunc.c \
    src/lua/ldump.c \
    src/lua/ldo.c \
    src/lua/ldebug.c \
    src/lua/ldblib.c \
    src/lua/lcode.c \
    src/lua/lbaselib.c \
    src/lua/lauxlib.c \
    src/lua/lapi.c \
    swig/sanguosha_wrap.cxx

HEADERS  += \
    src/dialog/mainwindow.h \
    src/core/engine.h \
    src/core/util.h \
    src/lua/lzio.h \
    src/lua/lvm.h \
    src/lua/lundump.h \
    src/lua/lualib.h \
    src/lua/luaconf.h \
    src/lua/lua.hpp \
    src/lua/lua.h \
    src/lua/ltm.h \
    src/lua/ltable.h \
    src/lua/lstring.h \
    src/lua/lstate.h \
    src/lua/lparser.h \
    src/lua/lopcodes.h \
    src/lua/lobject.h \
    src/lua/lmem.h \
    src/lua/llimits.h \
    src/lua/llex.h \
    src/lua/lgc.h \
    src/lua/lfunc.h \
    src/lua/ldo.h \
    src/lua/ldebug.h \
    src/lua/lcode.h \
    src/lua/lauxlib.h \
    src/lua/lapi.h

FORMS    += \
    src/dialog/mainwindow.ui

INCLUDEPATH += include
INCLUDEPATH += src/core
INCLUDEPATH += src/dialog
INCLUDEPATH += src/lua
