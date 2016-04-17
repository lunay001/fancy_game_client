--
-- 基础管理器
--

BaseMgr = class("BaseMgr")

function BaseMgr:ctor()
end

function BaseMgr:create()
    return BaseMgr.new()
end
