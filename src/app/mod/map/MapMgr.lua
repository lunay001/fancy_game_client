--
-- 地图管理器
--

require "BaseMgr"
require "NetworkMgr"
require "MapPos"

require("P100")
require("P101")

MapMgr = class("MapMgr", BaseMgr)

local _instance = nil
local _allowInstance = false

local netMgr = NetworkMgr:getInstance()
local roleMgr = RoleMgr:getInstance()

function MapMgr:ctor()
    if not _allowInstance then
        error("MapMgr is a singleton class,please call getInstance method")
    end

    self:init()
end

function MapMgr:getInstance()
    if _instance == nil then
        _allowInstance = true
        _instance = MapMgr.new()
        _allowInstance = false
    end
    return _instance
end

function MapMgr:init()
    require("P100")
    require("P101")

    local map_data = require("map_data")
    self.map_data_bases = map_data["base"]

    netMgr:addProtoListener(10100, self._on10100, self)
    netMgr:addProtoListener(10120, self._on10120, self)
    netMgr:addProtoListener(10121, self._on10121, self)
    netMgr:addProtoListener(10150, self._on10150, self)
    netMgr:addProtoListener(10151, self._on10151, self)
    netMgr:addProtoListener(10152, self._on10152, self)
    netMgr:addProtoListener(10153, self._on10153, self)
end

--[[
    登录后第一次进入地图
]]
function MapMgr:firstEnterMap()
    self.sceneLayer = GlobalLayers:getSceneLayer()

    local enterMapReq = P10100:create()
    netMgr:send(10100, enterMapReq:pack())
end

--[[
    把角色加入到场景
]]
function MapMgr:drawRole()
    ResMgr:addSpriteFrames("shape/role.plist")
    self.visual_roles = {}

    -- self.my_show_x = display.cx
    -- self.my_show_y = display.cy

    local pos = roleMgr:getMapPos()

    self.my_sp = cc.Sprite:createWithSpriteFrameName("role_1.png")
    -- self.my_sp:setPosition(cc.p(self.my_show_x, self.my_show_y))
    self.my_sp:setPosition(cc.p(pos.x, pos.y))
    self.sceneLayer:addChild(self.my_sp, 200)
end

--[[
    调整场景层位置
]]
function MapMgr:moveSceneLayer()
    local pos = roleMgr:getMapPos()
    local layer_x = 0
    local layer_y = 0
    if display.cx < pos.x then
        layer_x = -pos.x + display.cx
    end
    if display.cy < pos.y then
        layer_y = -pos.y + display.cy
    end

    self.sceneLayer:setPosition(cc.p(layer_x, layer_y))

    plog("sceneLayer pos:", layer_x, layer_y)
end

-- 定位到一个可见的其他角色
function MapMgr:getVisualRole(rid, platform, zoneId)
    for i,r in ipairs(self.visual_roles) do
        local map_role = r[1]
        if map_role.rid==rid and map_role.platform==platform and map_role.zone_id==zoneId then
            return {i, r}
        end
    end

    return nil
end

function MapMgr:findMapBase(mapBaseId)
    for _,v in ipairs(self.map_data_bases) do
        if v.id == mapBaseId then
            return v
        end
    end
    return nil
end

---------------------------------------------------------------------------

function MapMgr:_on10100(proto)
    -- plog("receive 10100")
    plog("enter map result:", proto.result, ", msg=", proto.msg)

    if proto.result == protoRtn.SUCCESS then
       
    end
end

function MapMgr:_on10120(proto)
    -- plog("receive 10120")
    
    local pos = MapPos.new()
    pos.mapId = proto.map_id
    pos.mapBaseId = proto.base_id
    pos.x = proto.x
    pos.y = proto.y

    plog("enter map pos:", pos.x, pos.y)
    
    local mapBase = self:findMapBase(pos.mapBaseId)
    self.mapWidth = mapBase.width
    self.mapHeight = mapBase.height
    self.sceneLayer:setContentSize(cc.size(self.mapWidth, self.mapHeight))

    roleMgr:setMapPos(pos)

    self:drawRole()

    self:moveSceneLayer()

    local req = P10101:create()
    netMgr:send(10101, req:pack())
end

function MapMgr:_on10121(proto)
    -- plog("receive 10121")

    local role_list = proto.role_list
    -- plog("10121 role_list size=", #role_list)
    for _,v in pairs(role_list) do
        local sp = cc.Sprite:createWithSpriteFrameName("role_2.png")
        -- sp:setPosition(self:offset_pos(v.x, v.y))
        sp:setPosition(cc.p(v.x, v.y))
        self.sceneLayer:addChild(sp, 100)
        table.insert(self.visual_roles, {v, sp})
    end
end

function MapMgr:_on10150(proto)
    -- plog("receive 10150")

    local enter_role_list = proto.enter_role_list
    local role = roleMgr:getRole()
    -- plog("10150 enter_role_list size=", #enter_role_list)
    for _,v in ipairs(enter_role_list) do
        if not roleMgr:isMyRole(v.rid, v.platform, v.zone_id) then
            local vr = self:getVisualRole(v.rid, v.platform, v.zone_id)
            local sp = nil
            if vr==nil then
                -- 先添加
                sp = cc.Sprite:createWithSpriteFrameName("role_2.png")
                -- sp:setPosition(self:offset_pos(v.x, v.y))
                sp:setPosition(cc.p(v.x, v.y))
                self.sceneLayer:addChild(sp, 100)
                table.insert(self.visual_roles, {v, sp})
            else
                sp = vr[2][2]
            end

            -- 添加后再移动
            -- local toPos = self:offset_pos(v.last_move_dest_x, v.last_move_dest_y)
            local toPos = cc.p(v.last_move_dest_x, v.last_move_dest_y)
            local dist = math.sqrt(math.pow(v.last_move_dest_x - v.x, 2) + math.pow(v.last_move_dest_y - v.y, 2))

            plog("on10150 enter:",v.rid,v.platform,v.zone_id,",(x,y)=", v.x, v.y, ",dist=", dist, ", move:",v.last_move_src_x,v.last_move_src_y, " => ", v.last_move_dest_x, v.last_move_dest_y)

            if dist > 0 then
                local time = dist / 100
                local moveAction = cc.MoveTo:create(time, toPos)
                sp:stopAllActions()
                sp:runAction(moveAction)
            end
        end
    end

    local leave_role_list = proto.leave_role_list
    -- plog("10150 leave_role_list size=", #leave_role_list)
    for _,v in ipairs(leave_role_list) do
        local vr = self:getVisualRole(v.rid, v.platform, v.zone_id)
        if vr ~= nil then
            plog("on10150 leave:",v.rid,v.platform,v.zone_id)
            local idx = vr[1]
            local map_role = vr[2][1]
            local sp = vr[2][2]
            table.remove(self.visual_roles, idx)
            self.sceneLayer:removeChild(sp)
        end
    end
    -- plog("end 10150")
end

function MapMgr:_on10151(proto)
    -- plog("receive 10151")

    for _,v in ipairs(proto.role_list) do
        if not roleMgr:isMyRole(v.rid, v.platform, v.zone_id) then
            local vr = self:getVisualRole(v.rid, v.platform, v.zone_id)
            if vr ~= nil then
                local sp = vr[2][2]
                -- local toPos = self:offset_pos(v.dest_x, v.dest_y)
                local toPos = cc.p(v.dest_x, v.dest_y)
                local dist = math.sqrt(math.pow(v.dest_x - v.x, 2) + math.pow(v.dest_y - v.y, 2))

                plog("on10151:", v.rid, v.platform, v.zone_id, ",move:",v.x, v.y, " => ", v.dest_x,v.dest_y)

                if dist > 0 then
                    local time = dist / 100
                    local moveAction = cc.MoveTo:create(time, toPos)
                    sp:stopAllActions()
                    sp:runAction(moveAction)
                end
            end
        end
    end
end

function MapMgr:_on10152(proto)
    -- plog("receive 10152")
end

function MapMgr:_on10153(proto)
    -- plog("receive 10153")
end

function MapMgr:offset_pos(x, y)
    local pos = roleMgr:getMapPos()

    local off_x = x - pos.x
    local off_y = y - pos.y
    local show_x = self.my_show_x + off_x
    local show_y = self.my_show_y + off_y
    return cc.p(show_x, show_y)
end


