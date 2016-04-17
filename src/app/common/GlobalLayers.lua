--
-- 全局分层
--

GlobalLayers = class("GlobalLayers")

-- 场景层
GlobalLayers._sceneLayer = nil
-- 主UI层
GlobalLayers._mainUILayer = nil
-- 加载层
GlobalLayers._loadingLayer = nil
-- 弹出消息层
GlobalLayers._msgLayer = nil 


function GlobalLayers:ctor()
end

function GlobalLayers:init(scene)
    self._scene = scene

    self._gameLayer = display.newNode()
    scene:addChild(self._gameLayer, 1)

    self._sceneLayer = display.newNode()
    self._gameLayer:addChild(self._sceneLayer, 100)
    
    self._mainUILayer = display.newNode()
    self._gameLayer:addChild(self._mainUILayer, 200)

    self._loadingLayer = display.newNode()
    self._gameLayer:addChild(self._loadingLayer, 300)

    self._msgLayer = display.newNode()
    self._gameLayer:addChild(self._msgLayer, 400)
end

function GlobalLayers:getSceneLayer()
    return self._sceneLayer
end

function GlobalLayers:getMainUILayer()
    return self._mainUILayer
end

function GlobalLayers:getMsgLayer()
    return self._msgLayer
end

function GlobalLayers:getLoadingLayer()
    return self._loadingLayer
end

