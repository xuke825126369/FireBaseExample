LeanTweenHelper = {}

--定时器
function LeanTweenHelper:Timer(fDelay, fTime, nLoopCount, func)
    assert(fDelay and fTime > 0 and nLoopCount and func)

    local ltd = LeanTween.delayedCall (fTime, function()
        func()
    end):setDelay (fDelay):setLoopCount(nLoopCount):setOnCompleteOnRepeat (true);
    return ltd
end

--帧定时器
function LeanTweenHelper:FrameTimer(fDelay, fTime, nLoopCount, func)
    assert(fDelay and fTime > 0 and nLoopCount > 0 and func)

    local ltd = LeanTween.delayedCall (fTime, function()
        func()
    end):setUseFrames(true):setDelay(fDelay):setLoopCount(nLoopCount):setOnCompleteOnRepeat (true);
    return ltd
end

--等几帧 再做
function LeanTweenHelper:WaitFrame(fTime, func)
    assert(fTime > 0 and func)
    local ltd = LeanTween.delayedCall (fTime, function()
        func()
    end):setUseFrames(true);
    return ltd
end

function LeanTweenHelper:CancelLeanTween(id)
    if LeanTween.isTweening(id) then
        LeanTween.cancel(id)
    end
end

