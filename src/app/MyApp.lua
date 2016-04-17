require "util"
require "GlobalConstants"
require "CommonBus"
require "ResMgr"
require "TimerMgr"

local MyApp = class("MyApp", cc.load("mvc").AppBase)

function MyApp:onCreate()
    cc.Image:setPVRImagesHavePremultipliedAlpha(true)
    
    math.randomseed(os.time())

    ResMgr:start()
    TimerMgr:start()
end

return MyApp
