--
-- 通用事件派发器 static class
--[[
    eg: CommonBus:addEvent(
            "eventName", 
            function(data) 
                print(data[1], data[2], data[3])  --1, 2, 3
            end
        )
        CommonBus:dispatchEvent("eventName", {1, 2, 3})
]]

EventData = class("EventData")
EventData.name = ""
EventData.listener = nil
EventData.target = nil

function EventData:create()
    return EventData.new()
end


CommonBus = class("CommonBus")

CommonBus._eventDict = {}


--[[
    注册事件
    @param eventName 事件名（字符串 或 数字）
    @param listener 回调函数
    @param target 注册者(类似使用target:listener())
]]
function CommonBus:addEvent(eventName, listener, target)

    assert(type(eventName) == "string" or type(eventName) == "number" or eventName ~= "", "invalid event name")

    if not listener then
        return
    end

    local listeners = CommonBus._eventDict[eventName] or {}
    CommonBus._eventDict[eventName] = listeners

    for _, v in ipairs(listeners) do
        if v.listener == listener then
            return
        end
    end

    local event = EventData:create()
    event.listener = listener
    event.name = eventName
    event.target = target

    table.insert(listeners, event)

end

function CommonBus:removeEvent(eventName, listener)
    local listeners = CommonBus._eventDict[eventName]
    if not listeners then
        return
    end
    
    for i, event in ipairs(listeners) do
        if event.listener == listener then
            table.remove(listeners, i)
            break
        end
    end
end

function CommonBus:dispatchEvent(eventName, data)
    local listeners = CommonBus._eventDict[eventName]
    if not listeners then
        return
    end

    for _, v in ipairs(listeners) do
        local callback = v.listener
        if v.target then
            callback(v.target, data)
        else
            callback(data)
        end
    end
end

function CommonBus:removeAllEvent(eventName)
    CommonBus._eventDict[eventName] = nil
end

function CommonBus:hasEvent(eventName, listener)
    local listeners = CommonBus._eventDict[eventName]
    if not listeners then
        return false
    end

    for _, event in ipairs(listeners) do
        if event.listener == listener then
            return true
        end
    end

    return false
end
