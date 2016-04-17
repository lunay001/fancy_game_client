
cc.FileUtils:getInstance():setPopupNotify(false)
cc.FileUtils:getInstance():addSearchPath("src/")
cc.FileUtils:getInstance():addSearchPath("res/")
cc.FileUtils:getInstance():addSearchPath("src/app/views/")
cc.FileUtils:getInstance():addSearchPath("src/app/common/")
cc.FileUtils:getInstance():addSearchPath("src/app/proto/")
cc.FileUtils:getInstance():addSearchPath("src/app/data/")
cc.FileUtils:getInstance():addSearchPath("src/app/mod/login/")
cc.FileUtils:getInstance():addSearchPath("src/app/mod/map/")
cc.FileUtils:getInstance():addSearchPath("src/app/mod/role/")

require "config"
require "cocos.init"

local function main()
    collectgarbage("setpause", 100)
    collectgarbage("setstepmul", 5000)

    require("app.MyApp"):create():run()
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    print(msg)
end
