--
-- 登录管理器
--

require "BaseMgr"
require "NetworkMgr"
require "RoleMgr"

LoginMgr = class("LoginMgr", BaseMgr)

local _instance = nil
local _allowInstance = false

local netMgr = NetworkMgr:getInstance()

function LoginMgr:ctor()
    if not _allowInstance then
        error("LoginMgr is a singleton class,please call getInstance method")
    end
    
    self:init()
end

function LoginMgr:getInstance()
    if _instance == nil then
        _allowInstance = true
        _instance = LoginMgr.new()
        _allowInstance = false
    end
    return _instance
end

function LoginMgr:init()
    require("P10")
    require("P11")
    require("P100")

    netMgr:regOnConnected(self._onConnected, self)
    netMgr:regOnConnectFailed(self._onConnectFailed, self)

    netMgr:addProtoListener(1001, self._on1001, self)
    netMgr:addProtoListener(1101, self._on1101, self)
    netMgr:addProtoListener(1102, self._on1102, self)
    netMgr:addProtoListener(1103, self._on1103, self)
    netMgr:addProtoListener(10000, self._on10000, self)

    self.isLogined = false
    self.account = nil
end

function LoginMgr:login(account, ip, port)
    plog("login: ", account, ip, port)

    if not account or account == "" then
        return
    end

    if self.isLogined then
        return
    end

    self.account = account
    netMgr:connect(ip, port)
end

function LoginMgr:regApp(app)
    self.app = app
end

function LoginMgr:getApp()
    return self.app
end

function LoginMgr:_onConnected()
    plog("Connected to server, start login")

    local loginReq = P1001:create()
    loginReq.account = self.account
    loginReq.platform = "dev"
    loginReq.zone_id = 1
    loginReq.session_id = ""

    netMgr:send(1001, loginReq:pack())
end

function LoginMgr:_onConnectFailed()
    plog("Connect to server failed")

    self.account = nil
end

function LoginMgr:_on1001(proto)
    if proto.result == protoRtn.SUCCESS then
        isLogined = true
        self:startHeartbeat()
    else
        isLogined = false
    end
end

--[[
    开始心跳
]]
function LoginMgr:startHeartbeat()
    self:reqHeartbeat()
    TimerMgr.addTimer(15000, self.reqHeartbeat, true, self)
end

--[[
    停止心跳
]]
function LoginMgr:stopHeartbeat()
    TimerMgr.removeTimer(self.reqHeartbeat)
end

function LoginMgr:reqHeartbeat()
    local req = P1199:create()
    netMgr:send(1199, req:pack())
end

--------------------------------------------------

function LoginMgr:_on1101(proto)
    if proto.result == protoRtn.SUCCESS then
        if #(proto.role_list) == 0 then
            plog("No role, need to create!")

            local createRoleReq = P1102:create()
            createRoleReq.name = self.account
            netMgr:send(1102, createRoleReq:pack())
        else
            plog("Has roles, num=", #(proto.role_list))

            local role = proto.role_list[1]
            local loginRoleReq = P1103:create()
            loginRoleReq.rid = role.id.rid
            loginRoleReq.platform = role.id.platform
            loginRoleReq.zone_id = role.id.zone_id
            netMgr:send(1103, loginRoleReq:pack())
        end
    else
        plog("Query role list failed:", proto.msg)
        netMgr:disconnect()
    end
end

function LoginMgr:_on1102(proto)
    if proto.result == protoRtn.SUCCESS then
        plog("Create role success!")
    else
        plog("Create role failed:", proto.msg)
        netMgr:disconnect()
    end
end

function LoginMgr:_on1103(proto)
    if proto.result == 1 then
        plog("Login role success!")

        local roleInfoReq = P10000:create()
        netMgr:send(10000, roleInfoReq:pack())
    else
        plog("Login role failed:", proto.msg)
        netMgr:disconnect()
    end
end

function LoginMgr:_on10000(proto)
    --plog("Role info:name=", proto.name, ", lev=", proto.lev, ", hp_max=", proto.hp_max)
    local role = Role.new()
    role.rid = proto.rid
    role.platform = proto.platform
    role.zone_id = proto.zone_id
    role.name = proto.name
    role.lev = proto.lev
    role.hp_max = proto.hp_max
    role.hp = proto.hp

    RoleMgr:getInstance():initRole(role)

    local mainScene = require("MainScene"):create(self:getApp(), "MainScene")
    mainScene:showWithScene()
end

