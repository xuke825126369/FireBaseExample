SpineAnimationType = {}
SpineAnimationType.EnumSpinType_Custom = -1 
SpineAnimationType.EnumSpinType_Normal = 0 --// "animation" -- 笑
SpineAnimationType.EnumSpinType_GodOfWealthClap = 1 --//"xiaohehe" -- 拍手
SpineAnimationType.EnumSpinType_MagicBallWin = 2 --// >=6个触发中奖 或者是respin结束结算时候播放 长动画。。
SpineAnimationType.EnumSpinType_ScatterLanded = 3 -- 目前Phoenix关的scatter用到了

local SpineEffect = {}
SpineEffect.m_bNeedStopFlag = false
SpineEffect.m_bActiveAnimation = false
SpineEffect.ACTIVEANIMATION_NAME = "animation" --财神的笑
SpineEffect.GODOFWEALTHCLAP_NAME = "xiaohehe" --财神的拍手
SpineEffect.MAGICBALLWIN_NAME = "animation2"
SpineEffect.SCATTERLANDED_NAME = "animation1"
SpineEffect.m_curEnumAniType = SpineAnimationType.EnumSpinType_Custom
SpineEffect.m_bInitParamFlag = false
SpineEffect.m_bInPlaying = false
SpineEffect.m_strGameObjectTag = ""

function SpineEffect:create(obj) --obj: gameobject
    local o = {}
    setmetatable(o, self)
    self.__index = self

    local listAni = obj:GetComponentsInChildren(typeof(SkeletonAnimation), true)
    o.m_SpineAnimations = {}
    for i=0, listAni.Length-1 do
        o.m_SpineAnimations[i+1] = listAni[i]
    end
    
    local cnt = #o.m_SpineAnimations
    if cnt == 0 then
        return nil
    end

    o.m_goSymbol = obj
    o.m_curEnumAniType = SpineAnimationType.EnumSpinType_Custom
    o.m_strGameObjectTag = obj.name
    LuaAutoBindMonoBehaviour.Bind(obj, o)

    return o
end

function SpineEffect:Start()
    self:initStartParam()
end

function SpineEffect:initStartParam() --Start()
    -- .state is not guaranteed to exist in Awake
    self:Reset()
    self:InitAniCompleteCallBack()

end

function SpineEffect:InitAniCompleteCallBack()
    local spineAni1 = self.m_SpineAnimations[1]
    if spineAni1==nil then
        return
    end

    spineAni1.AnimationState:Complete("+", function(trackEntry)
        self:SpineAnimation1Complete(trackEntry)
    end)
end

function SpineEffect:SpineAnimation1Complete(entry)
    -- 就依据spine1来确定是否播放完一遍了。。
    if self.m_bNeedStopFlag then
        self:StopActiveAnimation()
    end
end

function SpineEffect:Reset()
    self.m_curEnumAniType = SpineAnimationType.EnumSpinType_Custom
        
    self.m_bInPlaying = false
    self.m_bActiveAnimation = false

    if self.m_SpineAnimations == nil then
        Debug.Log("--------self.m_SpineAnimations == nil---------")
        return
    end

    local cnt = #self.m_SpineAnimations
    for i=1, cnt do
        local spineAni = self.m_SpineAnimations[i]
        if spineAni == nil then
            return
        end
        
        local track = spineAni.AnimationState:GetCurrent(0)
        if track==nil then
            return
        end
        track.TrackTime = 0.0
        spineAni.AnimationState.TimeScale = 0.0
        spineAni:Update()

    end
end

function SpineEffect:StopActiveAnimation()
    self.m_bNeedStopFlag = false
    self:Reset()
    return
end

function SpineEffect:setNeedStop()
    if self.m_bActiveAnimation then
        self.m_bNeedStopFlag = true
    end
end

SpineEffect.test = 0
function SpineEffect:PlayActiveAnimation(enumType, bLoop, fSpeed)
    local enumType = enumType or SpineAnimationType.EnumSpinType_Normal
    if bLoop == nil then
        bLoop = true
    end
    
    local fSpeed = fSpeed or 1.0

    self.m_bInPlaying = true

    if self.m_bActiveAnimation then
        if self.m_curEnumAniType==enumType and (enumType==SpineAnimationType.EnumSpinType_Normal or enumType==SpineAnimationType.EnumSpinType_ScatterLanded)
        then
            return
        else
            self:StopActiveAnimation()
        end
    end
    
    self.m_curEnumAniType = enumType
    local strAniName = self.ACTIVEANIMATION_NAME

    if enumType==SpineAnimationType.EnumSpinType_GodOfWealthClap then
        strAniName = self.GODOFWEALTHCLAP_NAME
    elseif enumType==SpineAnimationType.EnumSpinType_MagicBallWin then
        strAniName = self.MAGICBALLWIN_NAME
    elseif enumType==SpineAnimationType.EnumSpinType_ScatterLanded then
        strAniName = self.SCATTERLANDED_NAME
        
    end

    self.m_bActiveAnimation = true
    for i=1, #self.m_SpineAnimations do
        local var = self.m_SpineAnimations[i]
        if var==nil then
            return
        end
        var.AnimationState.TimeScale = fSpeed
        var.AnimationState:SetAnimation(0, strAniName, bLoop).TrackTime = 0.0
    end

end

function SpineEffect:GetCurrentPlayTime()
    local track = self.m_SpineAnimations[1].AnimationState:GetCurrent(0)
    return track.TrackTime
end

function SpineEffect:PlayAnimation(strAniName, AnibeginPosTime, bLoop, fSpeed)
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

    self.m_curEnumAniType = SpineAnimationType.EnumSpinType_Custom 
    self.m_strLastAniName = strAniName
    self.m_bActiveAnimation = true

    for i=1, #self.m_SpineAnimations do
        local var = self.m_SpineAnimations[i]
        var.AnimationState.TimeScale = fSpeed

        var.AnimationState:SetAnimation(0, strAniName, bLoop).TrackTime = AnibeginPosTime
    end

end

return SpineEffect