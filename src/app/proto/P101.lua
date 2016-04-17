require("ProtoBase")



P10100 = class("P10100", ProtoBasePack)

function P10100:ctor()
    P10100.super.ctor(self)

end

function P10100:pack()
    local _ba = self._byteData
    self:fill(_ba)
    return self._byteData
end

function P10100:fill(_ba)

end





P10101 = class("P10101", ProtoBasePack)

function P10101:ctor()
    P10101.super.ctor(self)

end

function P10101:pack()
    local _ba = self._byteData
    self:fill(_ba)
    return self._byteData
end

function P10101:fill(_ba)

end





P10102 = class("P10102", ProtoBasePack)

function P10102:ctor()
    P10102.super.ctor(self)
    self.map_id = 0
    self.x = 0
    self.y = 0
    self.dir = 0

end

function P10102:pack()
    local _ba = self._byteData
    self:fill(_ba)
    return self._byteData
end

function P10102:fill(_ba)
    _ba:writeUInt(self.map_id)
    _ba:writeUShort(self.x)
    _ba:writeUShort(self.y)
    _ba:writeUByte(self.dir)

end





P10103 = class("P10103", ProtoBasePack)

function P10103:ctor()
    P10103.super.ctor(self)
    self.map_id = 0
    self.x = 0
    self.y = 0
    self.dir = 0

end

function P10103:pack()
    local _ba = self._byteData
    self:fill(_ba)
    return self._byteData
end

function P10103:fill(_ba)
    _ba:writeUInt(self.map_id)
    _ba:writeUShort(self.x)
    _ba:writeUShort(self.y)
    _ba:writeUByte(self.dir)

end





P10120 = class("P10120", ProtoBasePack)

function P10120:ctor()
    P10120.super.ctor(self)

end

function P10120:pack()
    local _ba = self._byteData
    self:fill(_ba)
    return self._byteData
end

function P10120:fill(_ba)

end





P10121 = class("P10121", ProtoBasePack)

function P10121:ctor()
    P10121.super.ctor(self)

end

function P10121:pack()
    local _ba = self._byteData
    self:fill(_ba)
    return self._byteData
end

function P10121:fill(_ba)

end





P10150 = class("P10150", ProtoBasePack)

function P10150:ctor()
    P10150.super.ctor(self)

end

function P10150:pack()
    local _ba = self._byteData
    self:fill(_ba)
    return self._byteData
end

function P10150:fill(_ba)

end





P10151 = class("P10151", ProtoBasePack)

function P10151:ctor()
    P10151.super.ctor(self)

end

function P10151:pack()
    local _ba = self._byteData
    self:fill(_ba)
    return self._byteData
end

function P10151:fill(_ba)

end





P10152 = class("P10152", ProtoBasePack)

function P10152:ctor()
    P10152.super.ctor(self)

end

function P10152:pack()
    local _ba = self._byteData
    self:fill(_ba)
    return self._byteData
end

function P10152:fill(_ba)

end





P10153 = class("P10153", ProtoBasePack)

function P10153:ctor()
    P10153.super.ctor(self)

end

function P10153:pack()
    local _ba = self._byteData
    self:fill(_ba)
    return self._byteData
end

function P10153:fill(_ba)

end







U10100 = class("U10100", ProtoBaseUnpack)

function U10100:ctor()
    U10100.super.ctor(self)
    self.result = 0
    self.msg = ""

end

function U10100:unpack(bytes)
    self._byteData:writeBuf(bytes):setPos(1)
    self:fill(self._byteData)
end

function U10100:fill(_ba)
    self.result = _ba:readUByte()
    self.msg = _ba:readStringUShort()

end





U10101 = class("U10101", ProtoBaseUnpack)

function U10101:ctor()
    U10101.super.ctor(self)

end

function U10101:unpack(bytes)
    self._byteData:writeBuf(bytes):setPos(1)
    self:fill(self._byteData)
end

function U10101:fill(_ba)

end





U10102 = class("U10102", ProtoBaseUnpack)

function U10102:ctor()
    U10102.super.ctor(self)
    self.result = 0
    self.msg = ""

end

function U10102:unpack(bytes)
    self._byteData:writeBuf(bytes):setPos(1)
    self:fill(self._byteData)
end

function U10102:fill(_ba)
    self.result = _ba:readUByte()
    self.msg = _ba:readStringUShort()

end





U10103 = class("U10103", ProtoBaseUnpack)

function U10103:ctor()
    U10103.super.ctor(self)
    self.result = 0
    self.msg = ""

end

function U10103:unpack(bytes)
    self._byteData:writeBuf(bytes):setPos(1)
    self:fill(self._byteData)
end

function U10103:fill(_ba)
    self.result = _ba:readUByte()
    self.msg = _ba:readStringUShort()

end





U10120 = class("U10120", ProtoBaseUnpack)

function U10120:ctor()
    U10120.super.ctor(self)
    self.map_id = 0
    self.base_id = 0
    self.x = 0
    self.y = 0

end

function U10120:unpack(bytes)
    self._byteData:writeBuf(bytes):setPos(1)
    self:fill(self._byteData)
end

function U10120:fill(_ba)
    self.map_id = _ba:readUInt()
    self.base_id = _ba:readUInt()
    self.x = _ba:readUShort()
    self.y = _ba:readUShort()

end





U10121 = class("U10121", ProtoBaseUnpack)

function U10121:ctor()
    U10121.super.ctor(self)
    self.role_list = {}

end

function U10121:unpack(bytes)
    self._byteData:writeBuf(bytes):setPos(1)
    self:fill(self._byteData)
end

function U10121:fill(_ba)
    local role_list_len = _ba:readUShort()
    for i=1,role_list_len do
        local v = U10121_role_list_item.new()
        v:fill(_ba)
        table.insert(self.role_list, v)
    end

end


U10121_role_list_item = class("U10121_role_list_item")

function U10121_role_list_item:ctor()
    self.rid = 0
    self.platform = ""
    self.zone_id = 0
    self.name = ""
    self.lev = 0
    self.status = 0
    self.action = 0
    self.speed = 0
    self.hp_max = 0
    self.hp = 0
    self.x = 0
    self.y = 0
    self.gx = 0
    self.gy = 0

end

function U10121_role_list_item:fill(_ba)
    self.rid = _ba:readUInt()
    self.platform = _ba:readStringUShort()
    self.zone_id = _ba:readUShort()
    self.name = _ba:readStringUShort()
    self.lev = _ba:readUByte()
    self.status = _ba:readUByte()
    self.action = _ba:readUByte()
    self.speed = _ba:readUShort()
    self.hp_max = _ba:readUInt()
    self.hp = _ba:readUInt()
    self.x = _ba:readUShort()
    self.y = _ba:readUShort()
    self.gx = _ba:readUShort()
    self.gy = _ba:readUShort()

end




U10150 = class("U10150", ProtoBaseUnpack)

function U10150:ctor()
    U10150.super.ctor(self)
    self.enter_role_list = {}
    self.leave_role_list = {}

end

function U10150:unpack(bytes)
    self._byteData:writeBuf(bytes):setPos(1)
    self:fill(self._byteData)
end

function U10150:fill(_ba)
    local enter_role_list_len = _ba:readUShort()
    for i=1,enter_role_list_len do
        local v = U10150_enter_role_list_item.new()
        v:fill(_ba)
        table.insert(self.enter_role_list, v)
    end
    local leave_role_list_len = _ba:readUShort()
    for i=1,leave_role_list_len do
        local v = U10150_leave_role_list_item.new()
        v:fill(_ba)
        table.insert(self.leave_role_list, v)
    end

end


U10150_enter_role_list_item = class("U10150_enter_role_list_item")

function U10150_enter_role_list_item:ctor()
    self.rid = 0
    self.platform = ""
    self.zone_id = 0
    self.name = ""
    self.lev = 0
    self.status = 0
    self.action = 0
    self.speed = 0
    self.hp_max = 0
    self.hp = 0
    self.x = 0
    self.y = 0
    self.gx = 0
    self.gy = 0
    self.last_move_src_x = 0
    self.last_move_src_y = 0
    self.last_move_dest_x = 0
    self.last_move_dest_y = 0
    self.last_move_dir = 0

end

function U10150_enter_role_list_item:fill(_ba)
    self.rid = _ba:readUInt()
    self.platform = _ba:readStringUShort()
    self.zone_id = _ba:readUShort()
    self.name = _ba:readStringUShort()
    self.lev = _ba:readUByte()
    self.status = _ba:readUByte()
    self.action = _ba:readUByte()
    self.speed = _ba:readUShort()
    self.hp_max = _ba:readUInt()
    self.hp = _ba:readUInt()
    self.x = _ba:readUShort()
    self.y = _ba:readUShort()
    self.gx = _ba:readUShort()
    self.gy = _ba:readUShort()
    self.last_move_src_x = _ba:readUShort()
    self.last_move_src_y = _ba:readUShort()
    self.last_move_dest_x = _ba:readUShort()
    self.last_move_dest_y = _ba:readUShort()
    self.last_move_dir = _ba:readUByte()

end

U10150_leave_role_list_item = class("U10150_leave_role_list_item")

function U10150_leave_role_list_item:ctor()
    self.rid = 0
    self.platform = ""
    self.zone_id = 0

end

function U10150_leave_role_list_item:fill(_ba)
    self.rid = _ba:readUInt()
    self.platform = _ba:readStringUShort()
    self.zone_id = _ba:readUShort()

end




U10151 = class("U10151", ProtoBaseUnpack)

function U10151:ctor()
    U10151.super.ctor(self)
    self.role_list = {}

end

function U10151:unpack(bytes)
    self._byteData:writeBuf(bytes):setPos(1)
    self:fill(self._byteData)
end

function U10151:fill(_ba)
    local role_list_len = _ba:readUShort()
    for i=1,role_list_len do
        local v = U10151_role_list_item.new()
        v:fill(_ba)
        table.insert(self.role_list, v)
    end

end


U10151_role_list_item = class("U10151_role_list_item")

function U10151_role_list_item:ctor()
    self.rid = 0
    self.platform = ""
    self.zone_id = 0
    self.x = 0
    self.y = 0
    self.dest_x = 0
    self.dest_y = 0
    self.dir = 0

end

function U10151_role_list_item:fill(_ba)
    self.rid = _ba:readUInt()
    self.platform = _ba:readStringUShort()
    self.zone_id = _ba:readUShort()
    self.x = _ba:readUShort()
    self.y = _ba:readUShort()
    self.dest_x = _ba:readUShort()
    self.dest_y = _ba:readUShort()
    self.dir = _ba:readUByte()

end




U10152 = class("U10152", ProtoBaseUnpack)

function U10152:ctor()
    U10152.super.ctor(self)
    self.role_list = {}

end

function U10152:unpack(bytes)
    self._byteData:writeBuf(bytes):setPos(1)
    self:fill(self._byteData)
end

function U10152:fill(_ba)
    local role_list_len = _ba:readUShort()
    for i=1,role_list_len do
        local v = U10152_role_list_item.new()
        v:fill(_ba)
        table.insert(self.role_list, v)
    end

end


U10152_role_list_item = class("U10152_role_list_item")

function U10152_role_list_item:ctor()
    self.rid = 0
    self.platform = ""
    self.zone_id = 0
    self.map_id = 0
    self.base_id = 0

end

function U10152_role_list_item:fill(_ba)
    self.rid = _ba:readUInt()
    self.platform = _ba:readStringUShort()
    self.zone_id = _ba:readUShort()
    self.map_id = _ba:readUInt()
    self.base_id = _ba:readUInt()

end




U10153 = class("U10153", ProtoBaseUnpack)

function U10153:ctor()
    U10153.super.ctor(self)
    self.role_list = {}

end

function U10153:unpack(bytes)
    self._byteData:writeBuf(bytes):setPos(1)
    self:fill(self._byteData)
end

function U10153:fill(_ba)
    local role_list_len = _ba:readUShort()
    for i=1,role_list_len do
        local v = U10153_role_list_item.new()
        v:fill(_ba)
        table.insert(self.role_list, v)
    end

end


U10153_role_list_item = class("U10153_role_list_item")

function U10153_role_list_item:ctor()
    self.rid = 0
    self.platform = ""
    self.zone_id = 0
    self.name = ""
    self.lev = 0
    self.status = 0
    self.action = 0
    self.speed = 0
    self.hp_max = 0
    self.hp = 0
    self.x = 0
    self.y = 0
    self.gx = 0
    self.gy = 0

end

function U10153_role_list_item:fill(_ba)
    self.rid = _ba:readUInt()
    self.platform = _ba:readStringUShort()
    self.zone_id = _ba:readUShort()
    self.name = _ba:readStringUShort()
    self.lev = _ba:readUByte()
    self.status = _ba:readUByte()
    self.action = _ba:readUByte()
    self.speed = _ba:readUShort()
    self.hp_max = _ba:readUInt()
    self.hp = _ba:readUInt()
    self.x = _ba:readUShort()
    self.y = _ba:readUShort()
    self.gx = _ba:readUShort()
    self.gy = _ba:readUShort()

end



