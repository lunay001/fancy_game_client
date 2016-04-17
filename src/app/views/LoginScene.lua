
local LoginScene = class("LoginScene", cc.load("mvc").ViewBase)

LoginScene.RESOURCE_FILENAME = "LoginScene.csb"

require("LoginMgr")
local loginMgr = LoginMgr:getInstance()

function LoginScene:onCreate()
    printf("resource node = %s", tostring(self:getResourceNode()))
    
    --[[ you can create scene with following comment code instead of using csb file.
    -- add background image
    display.newSprite("HelloWorld.png")
        :move(display.center)
        :addTo(self)

    -- add HelloWorld label
    cc.Label:createWithSystemFont("Hello World", "Arial", 40)
        :move(display.cx, display.cy + 200)
        :addTo(self)
    ]]

    self:init()
end

function LoginScene:init()
    loginMgr:regApp(self:getApp())

    local rootNode = self:getResourceNode()
    local btnLogin = rootNode:getChildByName("btn_login")
    local edtAccount = rootNode:getChildByName("edt_account")
    btnLogin:addTouchEventListener(function(sender, eventType)
        if eventType ~= ccui.TouchEventType.ended then
            return
        end

        local account = edtAccount:getString()
        loginMgr:login(account, "127.0.0.1", 15001)
    end)
end

return LoginScene
