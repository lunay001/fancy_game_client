--
-- 角色管理器
--

require "BaseMgr"
require("Role")
require("NetworkMgr")

RoleMgr = class("RoleMgr", BaseMgr)

local _instance = nil
local _allowInstance = false

local netMgr = NetworkMgr:getInstance()

function RoleMgr:ctor()
    if not _allowInstance then
        error("RoleMgr is a singleton class,please call getInstance method")
    end
end

function RoleMgr:getInstance()
    if _instance == nil then
        _allowInstance = true
        _instance = RoleMgr.new()
        _allowInstance = false
    end
    return _instance
end

function RoleMgr:initRole(role)
    self._role = role
    self._role.mapPos = nil
end

function RoleMgr:getRole()
    return self._role
end

function RoleMgr:setMapPos(mapPos)
    self._role.mapPos = mapPos
end

function RoleMgr:getMapPos()
    return self._role.mapPos
end

function RoleMgr:isMyRole(rid, platform, zone_id)
    if self._role.rid == rid and self._role.platform == platform and self._role.zone_id == zone_id then
        return true
    end
    return false
end
