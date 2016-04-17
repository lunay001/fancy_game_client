--
-- 全局常量定义
--

ccDirector = cc.Director:getInstance()
ccTextureCache = ccDirector:getTextureCache()
ccSpriteFrameCache = cc.SpriteFrameCache:getInstance()
ccFileUtils = cc.FileUtils:getInstance()
ccArmatureMgr = ccs.ArmatureDataManager:getInstance()
ccScheduler = ccDirector:getScheduler()

-- 协议返回的结果
protoRtn = {}
protoRtn.FAILED = 0
protoRtn.SUCCESS = 1

-- 全局事件
globalEvent = {}
