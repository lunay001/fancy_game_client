local ByteArray = require("ByteArray")

ProtoBasePack = class("ProtoBasePack")

function ProtoBasePack:ctor()
    self._byteData = ByteArray.new()
    self._byteData:setEndian(ByteArray.ENDIAN_BIG)
end

function ProtoBasePack:clear()
    self._byteData:clear()
end

ProtoBaseUnpack = class("ProtoBaseUnpack")

function ProtoBaseUnpack:ctor()
    self._byteData = ByteArray.new()
    self._byteData:setEndian(ByteArray.ENDIAN_BIG)
end

--[[
    配置数据解析
]]
ProtoDataUnpack = class("ProtoDataUnpack")

--表数据字典, 格式:{sheetName = rowList}
ProtoDataUnpack.sheetDict = nil

function ProtoDataUnpack:ctor()
    self.sheetDict = {}
end

function ProtoDataUnpack:unpack(bytes)
    self._byteData:writeBuf(bytes):setPos(1)
    local offset = 1
    local fileNameLen = self._byteData:readInt()
    local fileName = self._byteData:readStringBytes(fileNameLen)

    require(fileName)
    local numSheet = self._byteData:readInt()
    offset = offset + 4 + fileNameLen + 4
    for i = 1, numSheet do
        local sheetNameLen = self._byteData:readInt()
        local sheetName = self._byteData:readStringBytes(sheetNameLen)
        local classNameLen = self._byteData:readInt()
        local className = self._byteData:readStringBytes(classNameLen)
        local dataLen = self._byteData:readUInt()
        offset = offset + 4 + sheetNameLen + 4 + classNameLen + 4
        local sheetBytes = ByteArray.new(ByteArray.ENDIAN_BIG)
        self._byteData:readBytes(sheetBytes, offset, dataLen-1)
        local clazz = _G[className]:create()
        clazz:unpack(sheetBytes, offset)
        self.sheetDict[sheetName] = clazz.list
        offset = offset + dataLen
    end
end

function ProtoDataUnpack:parse(fileName)
    local data = require(fileName)
    self.sheetDict = data
end

function ProtoDataUnpack:create(fileName)
    local dataUnpack = ProtoDataUnpack.new()
    dataUnpack:parse(fileName)
    return dataUnpack
end

function ProtoDataUnpack:getSheetByName(sheetName)
    return self.sheetDict[sheetName]
end

