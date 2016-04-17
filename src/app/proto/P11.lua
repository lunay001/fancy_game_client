require("ProtoBase")



P1101 = class("P1101", ProtoBasePack)

function P1101:ctor()
    P1101.super.ctor(self)

end

function P1101:pack()
    local _ba = self._byteData
    self:fill(_ba)
    return self._byteData
end

function P1101:fill(_ba)

end





P1102 = class("P1102", ProtoBasePack)

function P1102:ctor()
    P1102.super.ctor(self)
    self.name = ""

end

function P1102:pack()
    local _ba = self._byteData
    self:fill(_ba)
    return self._byteData
end

function P1102:fill(_ba)
    _ba:writeStringUShort(self.name)

end





P1103 = class("P1103", ProtoBasePack)

function P1103:ctor()
    P1103.super.ctor(self)
    self.rid = 0
    self.platform = ""
    self.zone_id = 0

end

function P1103:pack()
    local _ba = self._byteData
    self:fill(_ba)
    return self._byteData
end

function P1103:fill(_ba)
    _ba:writeUInt(self.rid)
    _ba:writeStringUShort(self.platform)
    _ba:writeUShort(self.zone_id)

end





P1199 = class("P1199", ProtoBasePack)

function P1199:ctor()
    P1199.super.ctor(self)

end

function P1199:pack()
    local _ba = self._byteData
    self:fill(_ba)
    return self._byteData
end

function P1199:fill(_ba)

end







U1101 = class("U1101", ProtoBaseUnpack)

function U1101:ctor()
    U1101.super.ctor(self)
    self.result = 0
    self.msg = ""
    self.role_list = {}

end

function U1101:unpack(bytes)
    self._byteData:writeBuf(bytes):setPos(1)
    self:fill(self._byteData)
end

function U1101:fill(_ba)
    self.result = _ba:readUByte()
    self.msg = _ba:readStringUShort()
    local role_list_len = _ba:readUShort()
    for i=1,role_list_len do
        local v = U1101_role_list_item.new()
        v:fill(_ba)
        table.insert(self.role_list, v)
    end

end


U1101_role_list_item = class("U1101_role_list_item")

function U1101_role_list_item:ctor()
    self.id = {}
    self.id.rid = 0
    self.id.platform = ""
    self.id.zone_id = 0
    self.name = ""

end

function U1101_role_list_item:fill(_ba)
    self.id.rid = _ba:readUInt()
    self.id.platform = _ba:readStringUShort()
    self.id.zone_id = _ba:readUShort()
    self.name = _ba:readStringUShort()

end




U1102 = class("U1102", ProtoBaseUnpack)

function U1102:ctor()
    U1102.super.ctor(self)
    self.result = 0
    self.msg = ""
    self.id = {}
    self.id.rid = 0
    self.id.platform = ""
    self.id.zone_id = 0

end

function U1102:unpack(bytes)
    self._byteData:writeBuf(bytes):setPos(1)
    self:fill(self._byteData)
end

function U1102:fill(_ba)
    self.result = _ba:readUByte()
    self.msg = _ba:readStringUShort()
    self.id.rid = _ba:readUInt()
    self.id.platform = _ba:readStringUShort()
    self.id.zone_id = _ba:readUShort()

end





U1103 = class("U1103", ProtoBaseUnpack)

function U1103:ctor()
    U1103.super.ctor(self)
    self.result = 0
    self.msg = ""

end

function U1103:unpack(bytes)
    self._byteData:writeBuf(bytes):setPos(1)
    self:fill(self._byteData)
end

function U1103:fill(_ba)
    self.result = _ba:readUByte()
    self.msg = _ba:readStringUShort()

end





U1199 = class("U1199", ProtoBaseUnpack)

function U1199:ctor()
    U1199.super.ctor(self)
    self.ts = 0

end

function U1199:unpack(bytes)
    self._byteData:writeBuf(bytes):setPos(1)
    self:fill(self._byteData)
end

function U1199:fill(_ba)
    self.ts = _ba:readUInt()

end




