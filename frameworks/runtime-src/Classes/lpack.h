
#ifndef __LUA_LPACK_H_
#define __LUA_LPACK_H_

#ifdef __cplusplus
extern "C"{
#endif
#include "tolua++.h"
#include "lua.h"
#ifdef __cplusplus
}
#endif

extern "C"{
    int luaopen_pack(lua_State *L);
}
#endif
