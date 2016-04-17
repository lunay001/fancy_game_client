require("ProtoBase")



P1001 = class("P1001", ProtoBasePack)

function P1001:ctor()
    P1001.super.ctor(self)
    self.account = ""
    self.platform = ""
    self.zone_id = 0
    self.session_id = ""

end

function P1001:pack()
    local _ba = self._byteData
    self:fill(_ba)
    return self._byteData
end

function P1001:fill(_ba)
    _ba:writeStringUShort(self.account)
    _ba:writeStringUShort(self.platform)
    _ba:writeUShort(self.zone_id)
    _ba:writeStringUShort(self.session_id)

end







U1001 = class("U1001", ProtoBaseUnpack)

function U1001:ctor()
    U1001.super.ctor(self)
    self.result = 0
    self.msg = ""

end

function U1001:unpack(bytes)
    self._byteData:writeBuf(bytes):setPos(1)
    self:fill(self._byteData)
end

function U1001:fill(_ba)
    self.result = _ba:readUByte()
    self.msg = _ba:readStringUShort()

end




