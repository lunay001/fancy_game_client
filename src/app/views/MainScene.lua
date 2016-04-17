
local MainScene = class("MainScene", cc.load("mvc").ViewBase)

MainScene.RESOURCE_FILENAME = "MainScene.csb"

require("GlobalLayers")
require("MapMgr")

function MainScene:onCreate()
    printf("resource node = %s", tostring(self:getResourceNode()))

    self:init()
end

function MainScene:init()
    GlobalLayers:init(self)

    MapMgr:getInstance():firstEnterMap()
end

return MainScene
