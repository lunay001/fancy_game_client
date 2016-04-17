--
-- 定时器管理器
--

local DRIVE_TYPE = {
	TIME = 0,
	FRAME = 1
}

TimerMgr = {}

TimerMgr._funcHandle = nil

TimerMgr._timerList = {}
TimerMgr._frameList = {}
TimerMgr._enterFrameCO = nil

TimerMgr._needClean = false

TimerMgr._dt = 0

TimerMgr._running = false

function TimerMgr.start()

	if TimerMgr._funcHandle then
		return
	end

	TimerMgr._running = true

	TimerMgr._createTimerThread()

	TimerMgr._funcHandle = cc.Director:
	                getInstance():
	                getScheduler():
	                scheduleScriptFunc(
	                	TimerMgr.onEnterFrame, 
	                	0, 
	                	false
	                )

end

function TimerMgr._createTimerThread()

	TimerMgr._enterFrameCO = coroutine.create(function()

		while TimerMgr._running do

			if TimerMgr._needClean then

				TimerMgr._clean()

				TimerMgr._needClean = false
			
			end

			for i, v in ipairs(TimerMgr._timerList) do

				if v and v._isDirty == false and v._isPause == false then

					local trigger = false
					if v._type == DRIVE_TYPE.FRAME then
						v._currentFrame = v._currentFrame + 1
						if v._currentFrame >= v._totalFrame then
							trigger = true
							if v._loop then
								v._currentFrame = 0
							else
								v._isDirty = true
								TimerMgr._needClean = true
							end
						end
					else
						v._countTime = v._countTime + TimerMgr._dt
						if v._countTime >= v._totalTime then
							trigger = true
							if v._loop then
								v._countTime = 0
							else
								v._isDirty = true
								TimerMgr._needClean = true
							end
						end
					end

					--清理空函数
					if v._callFunc == nil then
						v._isDirty = true
						TimerMgr._needClean = true
					else
						if trigger then
							if v._data then
								v._callFunc(v._data)
							else
								v._callFunc()
							end
						end
					end
				end	
			end

			coroutine.yield()
		end

	end)
end

function TimerMgr.stop()

	if not TimerMgr._funcHandle then
		return
	end

	cc.Director:getInstance():getScheduler():unscheduleScriptEntry(TimerMgr._funcHandle)

	TimerMgr._funcHandle = nil

	--make coroutine dead
	TimerMgr._running = false
	coroutine.resume(TimerMgr._enterFrameCO)

	TimerMgr._enterFrameCO = nil

end

function TimerMgr._clean()

	local tempList = {}

	local i = 1
	local timerData = nil
	while i <= #TimerMgr._timerList do

		timerData = TimerMgr._timerList[i]

		if timerData._isDirty == true then

			timerData._callFunc = nil
			table.remove(TimerMgr._timerList, i)
		else
			i = i + 1
		end

	end

end

function TimerMgr._initTimer(timer, time, loop, data, token)
	timer._type = DRIVE_TYPE.TIME --时间驱动
	timer._totalTime = time * 0.001  --触发间隔时间(这里改成s)
	timer._countTime = 0 --统计时间
	timer._loop = loop  --是否循环
	timer._data = data --附带数据
	timer._isDirty = false --
	timer._isPause = false --是否暂停
	timer._token = token
end

function TimerMgr._initFrame(timer, frames, loop, data, token)
	timer._type = DRIVE_TYPE.FRAME --帧驱动
	if frames <= 0 then
		frames = 1
	end
	timer._totalFrame = frames
	timer._currentFrame = 0 --统计时间
	timer._loop = loop  --是否循环
	timer._data = data --附带数据
	timer._isDirty = false --
	timer._isPause = false --是否暂停
	timer._token = token
end

--[[
    添加时间驱动定时器
    @param time 时间(ms)
    @param callFunc 回调函数
    @param loop 是否循环
    @param data 附带数据
    @param token 定时器附带的标识(用作清除)
]]
function TimerMgr.addTimer(time, callFunc, loop, data, token)

	if type(callFunc) ~= "function" then
		return
	end

	for i, v in ipairs(TimerMgr._timerList) do

		if v._callFunc == callFunc then

			TimerMgr._initTimer(v, time, loop, data, token)

			return

		end

	end

	local timer = {}
	timer._callFunc = callFunc  --回调函数

	TimerMgr._initTimer(timer, time, loop, data, token)

	TimerMgr._timerList[#TimerMgr._timerList + 1] = timer

end

--[[
    添加帧驱动定时器
]]
function TimerMgr.addFrame(frames, callFunc, loop, data, token)

	if type(callFunc) ~= "function" then
		return
	end

	for i, v in ipairs(TimerMgr._timerList) do

		if v._callFunc == callFunc then

			TimerMgr._initFrame(v, frames, loop, data, token)

			return

		end

	end

	local timer = {}
	timer._callFunc = callFunc  --回调函数

	TimerMgr._initFrame(timer, frames, loop, data, token)

	TimerMgr._timerList[#TimerMgr._timerList + 1] = timer
end

--[[
    根据回调清除定时器
]]
function TimerMgr.removeTimer(callFunc)

	if type(callFunc) ~= "function" then
		return
	end

	local co = coroutine.create(function()

		for i, v in ipairs(TimerMgr._timerList) do

			if v and v._isDirty == false then

				if v._callFunc == callFunc then

					v._isDirty = true

					TimerMgr._needClean = true

					break
				end
			end
		end

	end)

	coroutine.resume(co)

end

--[[
    根据设置标识清除定时器
]]
function TimerMgr.removeTimerWithToken(token)

	if token == nil then
		return
	end

	local co = coroutine.create(function()

		for i, v in ipairs(TimerMgr._timerList) do

			if v and v._isDirty == false then

				if v._token == token then

					v._isDirty = true

					TimerMgr._needClean = true

					-- break
				end
			end
		end

	end)

	coroutine.resume(co)

end

--[[
	暂停定时器
]]
function TimerMgr.pauseTimer(callFunc)

	local timer = TimerMgr._getTimer(callFunc)
	if timer == nil then
		return
	end

	timer._isPause = true

end

--[[
    恢复定时器
]]
function TimerMgr.resumeTimer(callFunc)

	local timer = TimerMgr._getTimer(callFunc)
	if timer == nil then
		return
	end

	timer._isPause = false

end

function TimerMgr._getTimer(callFunc)

	for i, v in ipairs(TimerMgr._timerList) do

		if v and v._isDirty == false then

			if v._callFunc == callFunc then

				return v
			end
		end
	end

	return nil

end

function TimerMgr.onEnterFrame(dt)

	TimerMgr._dt = dt

	local status, msg = coroutine.resume(TimerMgr._enterFrameCO)
	if status == false then
		print("定时器调试>> 执行函数报错:", msg)
		-- GmManager:getInstance():addErrorInfo(msg)
		TimerMgr._createTimerThread()
	end

end

