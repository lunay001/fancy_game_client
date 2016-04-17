require("ProtoBase")



P10000 = class("P10000", ProtoBasePack)

function P10000:ctor()
    P10000.super.ctor(self)

end

function P10000:pack()
    local _ba = self._byteData
    self:fill(_ba)
    return self._byteData
end

function P10000:fill(_ba)

end







U10000 = class("U10000", ProtoBaseUnpack)

function U10000:ctor()
    U10000.super.ctor(self)
    self.rid = 0
    self.platform = ""
    self.zone_id = 0
    self.name = ""
    self.lev = 0
    self.hp_max = 0
    self.hp = 0

end

function U10000:unpack(bytes)
    self._byteData:writeBuf(bytes):setPos(1)
    self:fill(self._byteData)
end

function U10000:fill(_ba)
    self.rid = _ba:readUInt()
    self.platform = _ba:readStringUShort()
    self.zone_id = _ba:readUShort()
    self.name = _ba:readStringUShort()
    self.lev = _ba:readUByte()
    self.hp_max = _ba:readUInt()
    self.hp = _ba:readUInt()

end




