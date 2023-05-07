local NTDescr = {}

function NTDescr:new()
	local o = {
        time = 0,
        intervalTime = 0,
        value = 0,
        from = 0,
        to = 0,
        delay = 0,
        updateCallback = nil,
        completeCallback = nil,
        isTweening = false
    }
	setmetatable(o, self)
	self.__index = self
	return o
end


function NTDescr:setOnUpdate(updateCallback)
	self.updateCallback = updateCallback
    return self
end

function NTDescr:setOnComplete(completeCallback)
	self.completeCallback = completeCallback
    return self
end

NumberTween = {}
local tweens = {}
function NumberTween:value(from, to, time, delay)
    local tween = nil
    for i, v in ipairs(tweens) do
        if(not v.isTweening) then
            tween = v
            break
        end
    end
    if tween == nil then
        tween = NTDescr:new()
        tweens[#tweens + 1] = tween
    end
    tween = tween or NTDescr:new()
    tween.from = from
    tween.to = to
    tween.time = time
    tween.intervalTime = 0
    tween.delay = delay or 0
    tween.updateCallback = nil
    tween.completeCallback = nil
    tween.isTweening = true
    return tween
end

function NumberTween:Init()
    local gameObject = Unity.GameObject("~NumberTween")
    Unity.GameObject.DontDestroyOnLoad (gameObject)
    LuaAutoBindMonoBehaviour.Bind(gameObject, self)
    for i = 1, 10 do
        tweens[i] = NTDescr:new()
    end
end

function NumberTween:Update()
    local dt = Unity.Time.deltaTime
    for i, v in ipairs(tweens) do
        if(v.isTweening) then
            v.intervalTime = v.intervalTime + dt
            if(v.intervalTime > v.delay) then
                v.value = (v.to - v.from) * (v.intervalTime - v.delay) / v.time + v.from
                if(v.intervalTime - v.delay >= v.time) then
                    v.value = v.to
                    v.isTweening = false
                    if(v.updateCallback) then v.updateCallback(v.value)  end
                    if(v.completeCallback) then v.completeCallback()  end
                else
                    if(v.updateCallback) then v.updateCallback(v.value)  end
                end
            end
        end
    end
end

function NumberTween:cancel(tweenDescr)
    tweenDescr.isTweening = false
end

NumberTween:Init()