--
-- 资源管理器
--

ResMgr = class("ResMgr")

-- 异步加载纹理图像队列 [{plistPath, {cbData}, pixelFormat}]
ResMgr._asyncImageList = {}
-- 异步加载plist字典 plistPath => imagePath
ResMgr._asyncPlistDict = {}
-- 纹理路径信息 imagePath => {plistPath, {cbData}, pixelFormat}
ResMgr._imagePathDict = {}
-- 当前是否正在异步加载
ResMgr._isLoading = false
-- 当前正在加载的纹理图像路径
ResMgr._loadingPath = nil

-- 当前正在使用的纹理
ResMgr._usingTextureDict = {}
-- 当前正在使用的序列帧
ResMgr._usingSpriteFrames = {}
-- 当前要释放的plist plistPath => {RefCount, frameList, imagePath}
ResMgr._releasePathDict = {}
-- 当前要释放的纹理 imagePath => 时间（单位：秒）
ResMgr._releaseTextureDict = {}
-- 当前要释放的骨骼动画 armaturePath => 时间（单位：秒）
ResMgr._releaseArmatureDict = {}

-- UI使用的plist字典 plistPath => true | nil
ResMgr._uiPathDict = {}
ResMgr._armaturePathDict = {}


--[[
    定时资源回收
]]
function ResMgr.onResGC(dt)
    local flag = false
    for k,v in pairs(ResMgr._releasePathDict) do
        ccSpriteFrameCache:removeSpriteFramesFromFile(k)

        local frameList = v[2]
        local imagePath = v[3]

        for i,j in ipairs(frameList) do
            j:release()
        end

        local texture = ccTextureCache:getTextureForKey(imagePath)
        if texture then
            texture:release()
        end

        ccTextureCache:removeTextureForKey(imagePath)

        flag = true
    end

    if flag then
        -- plog("回收纹理后的信息======================>")
        -- plog(ccTextureCache:getCachedTextureInfo())
        -- plog("<======================================")
        reslog("纹理回收...")
    end
    
    ResMgr._releasePathDict = {}
end

--[[
    每帧处理异步加载
]]
function ResMgr:onEnterFrame(dt)
    if #ResMgr._asyncImageList == 0 then
        ResMgr._isLoading = false
        ResMgr._loadingPath = nil
        return
    end

    -- 如果该帧已经有正在加载中的任务则跳过
    if ResMgr._isLoading then
        return
    end

    ResMgr._isLoading = true
    local path = ResMgr._asyncImageList[1]
    ResMgr._loadingPath = path
    data = ResMgr._imagePathDict[path]
    reslog("异步加载纹理:", path)
    
    ccTextureCache:addImageAsync(
        path,
        ResMgr._onLoadTextureEnd,
        data[3]
    )
end

--[[
    启动定时回收
]]
function ResMgr:start()
    ccScheduler:scheduleScriptFunc(handler(ResMgr, ResMgr.onResGC), 5, false)
    -- ccScheduler:scheduleScriptFunc(handler(ResMgr, ResMgr.onAsyncLoad), 0, false)
end

function ResMgr.onResGC(dt)
    -- plog("aaaaaaaaaaaaa")
end

--[[
    异步加载资源
    @param imagePath 图片路径
    @param plistPath 配置路径
    @param cbData 回调数据, 如果有plistPath回调函数会传入{plistPath, imagePath}, 不然只有{imagePath}
    @param pixelFormat 像素格式
]]
function ResMgr:loadImageAsync(imagePath, plistPath, cbData, pixelFormat)
    if plistPath then
        if not ccFileUtils:isFileExist(plistPath) then
            plog("纹理>> 加载不存在的配置文件", plistPath, debug.traceback("", 2))
            if cbData then
                cbData:execute({plistPath, imagePath})
                return
            end
        end
    else
        if not ccFileUtils:isFileExist(imagePath) then
            plog("纹理>> 加载不存在的纹理文件", imagePath, debug.traceback("", 2))
            if cbData then
                cbData:execute({imagePath})
                return
            end
        end
    end

    local usingData
    if plistPath then
        usingData = ResMgr._usingSpriteFrames[plistPath]
        if usingData then
            ResMgr:addSpriteFrames(plistPath)
            if cbData then
                cbData:execute({plistPath, imagePath})
            end
            return
        end
        ResMgr._asyncPlistDict[plistPath] = imagePath
    else
        usingData = ResMgr._usingTextureDict[imagePath]
        if usingData then
            ResMgr:addTexture(imagePath)
            if cbData then
                cbData:execute({imagePath})
            end
            return
        end
    end

    -- TODO:table为何有indexof方法？
    if table.indexof(ResMgr._asyncImageList, imagePath) then
        local data = ResMgr._imagePathDict[imagePath]
        if data then
            table.insert(data[2], cbData)
        end
        return
    end

    pixelFormat = pixelFormat or cc.TEXTURE2_D_PIXEL_FORMAT_AUTO

    ResMgr._imagePathDict[imagePath] = {plistPath, {cbData}, pixelFormat}

    table.insert(ResMgr._asyncImageList, imagePath)

    if not ResMgr._isLoading then
        -- ResMgr:_startLoad()
    end
end

--[[
    异步加载纹理完成
]]
function ResMgr._onLoadTextureEnd()
    
    local path = table.remove(ResMgr._asyncImageList, 1)
    reslog("纹理>> 异步加载完成", #ResMgr._asyncImageList, path)

    if path then
        local data = ResMgr._imagePathDict[path]
        ResMgr._imagePathDict[path] = nil
        --add plist
        if data then
            if data[1] then
                ResMgr._asyncPlistDict[data[1]] = nil
                for _, _ in ipairs(data[2]) do
                    ResMgr:addSpriteFrames(data[1])
                end
            else
                for _, _ in ipairs(data[2]) do
                    ResMgr:addTexture(path)
                end
            end
            for _, v in ipairs(data[2]) do
                if v then
                    if data[1] then
                        v:execute({data[1], path})
                    else
                        v:execute({path})
                    end
                end
            end
        end
    end
    ResMgr._loadingPath = nil
    ResMgr._isLoading = false
end

function ResMgr:stopLoadPlist(plist, cbData)
    local imagePath = ResMgr._asyncPlistDict[plist]
    if not imagePath then
        return
    end
    ResMgr:stopLoadImage(imagePath, cbData)
end

function ResMgr:stopLoadImage(imagePath, cbData)

    local index = table.indexof(ResMgr._asyncImageList, imagePath)
    if not index then
        return
    end
    -- print("纹理>> 停止加载", imagePath, debug.traceback())

    local function clear()
        table.remove(ResMgr._asyncImageList, index)
        local data = ResMgr._imagePathDict[imagePath]
        if data[1] then
            ResMgr._asyncPlistDict[data[1]] = nil
        end
        ResMgr._imagePathDict[imagePath] = nil

        if DEBUG then
            plog("纹理>> 停止加载", imagePath)
        end

        --正在加载中
        if imagePath == ResMgr._loadingPath then
            ccTextureCache:unbindImageAsync(imagePath)
            ResMgr._isLoading = false
        end
    end

    if cbData then
        local data = ResMgr._imagePathDict[imagePath]
        local cbIndex = table.indexof(data[2], cbData)
        if cbIndex then
            table.remove(data[2], cbIndex)
        end
        if #data[2] == 0 then
            clear()
        end
    else
        clear()
    end
end

--[[
    加载plist和序列帧
    @param plistPath
    @param isAsync 是否异步加载
]]
function ResMgr:addSpriteFrames(plistPath, isAsync)
    -- 加载帧缓存时文件不存在会出错，所以要先判断一下
    if not ccFileUtils:isFileExist(plistPath) then
        plog("plist not exist:", plistPath)
        return
    end

    local flag = isAsync or false
    local function syncLoad()

        -- Use: 18 ms
        ccSpriteFrameCache:addSpriteFrames(plistPath)

        local usingData = ResMgr._usingSpriteFrames[plistPath]
        if usingData then
            usingData[2] = usingData[2] + 1
        else
            local fullPath = ccFileUtils:fullPathForFilename(plistPath)
            local dict = ccFileUtils:getValueMapFromFile(fullPath)
            local keyList = dict.frames
            local metadata = dict.metadata
            -- Use: 8 us
            local imagePath = ccFileUtils:fullPathFromRelativeFile(metadata.textureFileName, plistPath)
            local frameList = {}
            local texture = ccTextureCache:getTextureForKey(imagePath)
            texture:retain()
            for k,v in pairs(keyList) do
                local frame = ccSpriteFrameCache:getSpriteFrame(k)
                frame:retain()
                table.insert(frameList, frame)
            end
            usingData = {frameList, 1, imagePath}
            ResMgr._usingSpriteFrames[plistPath] = usingData
        end


        -- 同步加载完毕后干掉异步加载队列里的相同任务
        repeat
            local imagePath = ResMgr._asyncPlistDict[plistPath]
            if not imagePath then
                break
            end
            local asyncData = ResMgr._imagePathDict[imagePath]
            if not asyncData then
                break
            end

            -- 处理正在等待加载的资源
            local callbackList = ipairs(asyncData[2])
            for _,_ in callbackList do
                usingData[2] = usingData[2] + 1
            end

            for _,cb in callbackList do
                -- 有设置回调方法的就要回调
                if cb then
                    cb:execute({asyncData[1], imagePath})
                end
            end
        until true

        ResMgr:stopLoadPlist(plistPath)

        plog("纹理同步增加:", plistPath, usingData[3], usingData[2])
    end

    local function asyncLoad()
        
    end

    if flag == true then
        asyncLoad()
    else
        syncLoad()
    end
end

function ResMgr:removeSpriteFrames(plistPath)
    local usingData = ResMgr._usingSpriteFrames[plistPath]
    if not usingData then
        return
    end
    
    local frameList = usingData[1]
    usingData[2] = usingData[2] - 1
    local imagePath = usingData[3]

    plog("纹理回收:", plistPath, usingData[3], usingData[2])

    if usingData[2] <= 0 then
        ResMgr._releasePathDict[plistPath] = {1, frameList, imagePath}
    end
end

--[[
    同步加载纹理
]]
function ResMgr:addTexture(imagePath)

    if ResMgr._releaseTextureDict[imagePath] then
        ResMgr._releaseTextureDict[imagePath] = nil
    end

    local data = ResMgr._usingTextureDict[imagePath]
    if data then
        data[1] = data[1] + 1
    else
        local texture = ccTextureCache:addImage(imagePath)
        -- local texture = ccTextureCache:getTextureForKey(imagePath)
        if texture then
            texture:retain()
        end
        data = {1, texture}
        ResMgr._usingTextureDict[imagePath] = data
    end
end

--[[
    移除纹理
    @param imagePath 纹理路径
    @param force 如果为true则立刻删除纹理, 不等待缓存
]]
function ResMgr:removeTexture(imagePath, force)
    ResMgr:stopLoadImage(path)
    --延期移除
    local data = ResMgr._usingTextureDict[path]
    if not data then
        return
    end
    
    data[1] = data[1] - 1
    if data[1] <= 0 then
        if force then
            ResMgr:_clearTexture(path)
        else
            ResMgr._releaseTextureDict[path] = 1
        end
    end
end

--[[
    清除不用的资源
]]
function ResMgr:releaseUnusedAsset()

    for k, v in pairs(ResMgr._releasePathDict) do
        ResMgr:_clearSpriteFrames(k)
    end

    for k, v in pairs(ResMgr._releaseTextureDict) do
        ResMgr:_clearTexture(k)
    end

    for k, _ in pairs(ResMgr._releaseArmatureDict) do
        ResMgr:_clearArmature(k)
    end

    ccSpriteFrameCache:removeUnusedSpriteFrames()
    ccTextureCache:removeUnusedTextures()
end

function ResMgr:_clearSpriteFrames(plistPath)
    local gcData = ResMgr._releasePathDict[plistPath]
    if not gcData then
        return
    end

    reslog("纹理>> 释放配置文件", plistPath)

    local frameList = gcData[2]
    for i, v in ipairs(frameList) do
        v:release()
    end

    local imagePath = gcData[3]
    local texture = ccTextureCache:getTextureForKey(imagePath)
    if texture then
        if DEBUG then
            local count = texture:getReferenceCount()
            if count > 2 then
                reslog("texture>> reference count", imagePath, count, #frameList)
            end
        end
        texture:release()
    end

    ResMgr._uiPathDict[plistPath] = nil

    ccSpriteFrameCache:removeSpriteFramesFromFile(plistPath)
    ccTextureCache:removeTextureForKey(imagePath)
    ResMgr._usingSpriteFrames[plistPath] = nil
    ResMgr._releasePathDict[plistPath] = nil
end

--[[
 加载UI用plist
]]
function ResMgr:addUISpriteFrames(plistPath)
    ResMgr._uiPathDict[plistPath] = true
    ResMgr:addSpriteFrames(plistPath)
end

--[[
    移除UI用plist
]]
function ResMgr:removeUISpriteFrames(plistPath)
    ResMgr:removeSpriteFrames(plistPath)
end

--加载jpg格式的plist
function ResMgr:addJpgUISpriteFrames(plistPath)
    cc.Texture2D:setDefaultAlphaPixelFormat(cc.TEXTURE2_D_PIXEL_FORMAT_RG_B565)
    ResMgr:addUISpriteFrames(plistPath)
    cc.Texture2D:setDefaultAlphaPixelFormat(cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888)
end

function ResMgr:addArmaturePath(path)
    local data = ResMgr._armaturePathDict[path]
    ResMgr._releaseArmatureDict[path] = nil
    if not data then
        data = {}
        data.count = 1
    else
        data.count = data.count + 1
    end
    ResMgr._armaturePathDict[path] = data
end

function ResMgr:removeArmaturePath(path)
    if ResMgr._releaseArmatureDict[path] then
        return
    end

    local data = ResMgr._armaturePathDict[path]
    if not data then
        return
    end

    data.count = data.count - 1
    -- ResMgr._armaturePathDict[path] = nil
    if data.count <= 0 then
        ResMgr._releaseArmatureDict[path] = 1
    end
end

function reslog(msg, ...)
    if DEBUG then
        plog(msg, ...)
    end
end
