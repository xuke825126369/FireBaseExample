SpineUIEffect = {}

SpineUIEffect.m_goSymbol = nil
SpineUIEffect.m_bNeedStopFlag = false
SpineUIEffect.m_bActiveAnimation = false
SpineUIEffect.m_bInPlaying = false

function SpineUIEffect:create(obj) --obj: gameobject
    local o = {}
    setmetatable(o, self)
    self.__index = self

    o.m_SpineAnimation = obj:GetComponentInChildren(typeof(SkeletonGraphic), true)
    o.m_goSymbol = obj
    LuaAutoBindMonoBehaviour.Bind(obj, o)
        
    return o
end

function SpineUIEffect:Start()
    self:Reset()

    local spineAni1 = self.m_SpineAnimation
    spineAni1.AnimationState:Complete("+", function(trackEntry)
        self:SpineAnimation1Complete(trackEntry)
    end)
end

function SpineUIEffect:SpineAnimation1Complete(entry)
    if self.m_bNeedStopFlag then
        self:StopActiveAnimation()
    end
end

function SpineUIEffect:Reset()
    self.m_bInPlaying = false
    self.m_bActiveAnimation = false

    local spineAni = self.m_SpineAnimation
    local track = spineAni.AnimationState:GetCurrent(0)
    track.TrackTime = 0.0
    spineAni.AnimationState.TimeScale = 0.0
    spineAni:Update()
end

function SpineUIEffect:StopActiveAnimation()
    self.m_bNeedStopFlag = false
    self:Reset()
    return
end

function SpineUIEffect:setNeedStop()
    if self.m_bActiveAnimation then
        self.m_bNeedStopFlag = true
    end
end

function SpineUIEffect:GetCurrentPlayTime()
    local track = self.m_SpineAnimation.AnimationState:GetCurrent(0)
    return track.TrackTime
end

function SpineUIEffect:PlayAnimation(strAniName, AnibeginPosTime, bLoop, fSpeed)
    if bLoop == nil then
        bLoop = true
    end

    if AnibeginPosTime == nil then
        AnibeginPosTime = 0
    end

    local fSpeed = fSpeed or 1.0
    
    if self.m_bActiveAnimation then
        if self.m_strLastAniName == strAniName then
            return
        else
            self:StopActiveAnimation()
        end
    end
    
    self.m_strLastAniName = strAniName
    self.m_bActiveAnimation = true

    self.m_SpineAnimation.AnimationState.TimeScale = fSpeed
    self.m_SpineAnimation.AnimationState:SetAnimation(0, strAniName, bLoop).TrackTime = AnibeginPosTime

end