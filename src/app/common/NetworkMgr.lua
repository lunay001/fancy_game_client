--[[
    网络管理器
]]

require("CommonBus")
require("GlobalConstants")

net = {}
net.SocketTCP = require("SocketTCP")

local ByteArray = require("ByteArray")
local scheduler = require("scheduler")

NetworkMgr = class("NetworkMgr")

local _NET_DEBUG_ = true

local _instance = nil
local _allowInstance = false

function NetworkMgr:ctor()
    if not _allowInstance then
        error("NetworkMgr is a singleton class,please call getInstance method")
    end

    self.socket = nil
    self.ip = nil
    self.port = nil
    self.isConnected = false
    -- self.statusListeners = {}
    -- self.dataListeners = {}
    -- self.protoListeners = {}
    self.readHead = true
    self.recvBuf = nil
    self.recvBodyLen = 0    -- 应该接收的协议体长度
end

function NetworkMgr:getInstance()
    if _instance == nil then
        _allowInstance = true
        _instance = NetworkMgr.new()
        _allowInstance = false
    end
    return _instance
end

function NetworkMgr:isConnected()
    return self.isConnected
end

--[[
    连接服务器
    ip :: "xx.xx.xx.xx"
    port :: integer()
]]
function NetworkMgr:connect(ip, port)
    plog("connecting to:%s %s", ip, port)

    if self.isConnected then
        self.socket:disconnect()
    end

    self.ip = ip
    self.port = port
	self.socket = net.SocketTCP.new(self.ip, self.port, false)

	self.socket:addEventListener(net.SocketTCP.EVENT_CONNECTED, handler(self, self.onStatus))
	self.socket:addEventListener(net.SocketTCP.EVENT_CLOSE, handler(self, self.onStatus))
	self.socket:addEventListener(net.SocketTCP.EVENT_CLOSED, handler(self, self.onStatus))
	self.socket:addEventListener(net.SocketTCP.EVENT_CONNECT_FAILURE, handler(self, self.onStatus))

	self.socket:addEventListener(net.SocketTCP.EVENT_DATA, handler(self, self.onData))

    self.socket:connect()
end

--[[
    断开连接
]]
function NetworkMgr:disconnect()
    if self.isConnected then
        -- self.socket:disconnect()
        self.socket:close()
    end
end

--[[
    事件处理：状态变化
]]
function NetworkMgr:onStatus(event)
	plog("socket event: event=", event, ", event.name=", event.name)

    if event.name == net.SocketTCP.EVENT_CONNECTED then
        self.isConnected = true
        self.readHead = true
        self.recvBuf = createByteArray()
    elseif event.name == net.SocketTCP.EVENT_CLOSED then
        -- self.socket:close()
        self.isConnected = false
    elseif event.name == net.SocketTCP.EVENT_CONNECT_FAILURE then
        self.isConnected = false
    end

    CommonBus:dispatchEvent(event.name, event.data)

    -- for handle, listener in pairs(self.statusListeners) do
    --     listener(event)
    --     if event.stop_ then
    --         break
    --     end
    -- end
end

--[[
    事件处理：接收数据
]]
function NetworkMgr:onData(event)
    local lastPos = self.recvBuf:getPos()
    self.recvBuf:writeBuf(event.data):setPos(1)
    local leftLen = self.recvBuf:getAvailable()

    -- plog("onData():leftLen=", leftLen, ", lastPos=", lastPos, ", recvBodyLen=", self.recvBodyLen, ", data=", self.recvBuf:toString())

    local function handleData()
        if self.readHead then
            if leftLen >= 4 then
                self.recvBodyLen = self.recvBuf:readUInt()
                self.readHead = false
                leftLen = leftLen - 4
            else
                return false
            end

            if leftLen < self.recvBodyLen then
                return false
            end
        else
            if leftLen < self.recvBodyLen then
                return false
            end
        end

        local protoId = self.recvBuf:readUShort()
        self.recvBodyLen = self.recvBodyLen - 2
        -- plog("Recv protoId=", protoId, ", lastPos=", self.recvBuf:getPos(), ", data=", self.recvBuf:toString())

        -- TODO:这里可以优化下，每次消息体都创建一个ByteArray可能会慢
        -- local t1 = os.clock()
        local body = createByteArray()
        -- local t2 = os.clock()
        -- plog("create body needs:", (t2-t1))
        self.recvBuf:readBytes(body, 1, self.recvBodyLen)

        local className = string.format("U%d", protoId)
        local clazz = _G[className]
        if not clazz then
            plog("收到协议", protoId, "但是没有找到对应的处理类")
        else
            -- plog("收到协议:", protoId)
            local c = clazz:create()
            c:unpack(body:getBytes())
            -- for _,listener in pairs(self.protoListeners[protoId]) do
            --     listener(c)
            -- end
            CommonBus:dispatchEvent(protoEventName(protoId), c)
        end

        self.readHead = true
        leftLen = self.recvBuf:getLen() - self.recvBuf:getPos() + 1

        return true
    end

    while(true) do
        if not handleData() then
            break
        end
    end

    leftLen = self.recvBuf:getAvailable()

    -- plog("leftLen=", leftLen, ", leftData=", self.recvBuf:leftToString())

    -- TODO:这里不知道会不会影响性能
    if leftLen > 0 then
        local newBuf = createByteArray()
        -- newBuf:writeBytes(self.recvBuf)
        self.recvBuf:readBytes(newBuf)
        self.recvBuf = newBuf
        -- plog("resize=", newBuf:toString())
    else
        self.recvBuf:clear()
    end
end

--[[
    发送协议
    protoId :: 协议编号
    protoBody :: 协议体，ByteArray
]]
function NetworkMgr:send(protoId, protoBody)
    if not self.isConnected then
        plog("Not connected! Can not send!")
        return
    end
    
    -- 发送协议头
    local header = createByteArray()
    header:writeUInt(protoBody:getLen() + 2)
    header:writeUShort(protoId)
    self.socket:send(header:getBytes())

    -- 发送协议体
    self.socket:send(protoBody:getBytes())
end

--[[
    注册回调事件
]]
-- function NetworkMgr:addStatusListener(listener)
--     local listeners = self.statusListeners
--     for _,v in ipairs(listeners) do
--         if v == listener then
--             return
--         end
--     end
-- 
--     table.insert(listeners, listener)
-- end
-- 
-- function NetworkMgr:removeStatusListener(listener)
--     local listeners = self.statusListeners
--     for i,v in ipairs(listeners) do
--         if v == listener then
--             table.remove(listeners, i)
--         end
--     end
-- end
-- 
-- function NetworkMgr:addDataListener(listener)
--     local listeners = self.dataListeners
--     for _,v in ipairs(listeners) do
--         if v == listener then
--             return
--         end
--     end
-- 
--     table.insert(listeners, listener)
-- end
-- 
-- function NetworkMgr:removeDataListener(listener)
--     local listeners = self.dataListeners
--     for i,v in ipairs(listeners) do
--         if v == listener then
--             table.remove(listeners, i)
--         end
--     end
-- end
-- 
-- function NetworkMgr:addProtoListener(listener, protoId)
--     local listeners = self.protoListeners[protoId]
--     if listeners ~= nil then
--         for _,v in ipairs(listeners) do
--             if v == listener then
--                 return
--             end
--         end
--         table.insert(listeners, listener)
--     else
--         listeners = {}
--         table.insert(listeners, listener)
--         self.protoListeners[protoId] = listeners
--     end
-- end
-- 
-- function NetworkMgr:removeProtoListener()
-- end

--[[
    添加协议监听
]]
function NetworkMgr:addProtoListener(protoId, listener, target)
    CommonBus:addEvent(
        protoEventName(protoId), 
        listener, 
        target
    )
end

--[[
    移除协议监听
]]
function NetworkMgr:removeProtoListener(protoId, listener)
    CommonBus:removeEvent(
        protoEventName(protoId), 
        listener
    )
end

--[[
    添加网络状态变化
]]
function NetworkMgr:regOnConnected(listener, target)
    CommonBus:addEvent(
        net.SocketTCP.EVENT_CONNECTED,
        listener,
        target
    )
end

function NetworkMgr:unregOnConnected(listener)
    CommonBus:removeEvent(
        net.SocketTCP.EVENT_CONNECTED,
        listener
    )
end

function NetworkMgr:regOnConnectFailed(listener, target)
    CommonBus:addEvent(
        net.SocketTCP.EVENT_CONNECT_FAILURE,
        listener,
        target
    )
end

function NetworkMgr:unregOnConnectFailed(listener)
    CommonBus:removeEvent(
        net.SocketTCP.EVENT_CONNECT_FAILURE,
        listener
    )
end

function NetworkMgr:regOnClosed(listener, target)
    CommonBus:addEvent(
        net.SocketTCP.EVENT_CLOSED,
        listener,
        target
    )
end

function NetworkMgr:unregOnClosed(listener)
    CommonBus:removeEvent(
        net.SocketTCP.EVENT_CLOSED,
        listener
    )
end


function createByteArray()
    local ba = ByteArray.new()
    ba:setEndian(ByteArray.ENDIAN_BIG)
    return ba
end

function protoEventName(protoId)
    return string.format("Proto_%d", protoId)
end
