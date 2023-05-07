local MultiClipEffectObj = {}

MultiClipEffectObj.m_strDefaultStateName = ""
MultiClipEffectObj.m_enumEffectType = MultiClipEffectType.EnumMultiClipEffectType_NULL
MultiClipEffectObj.m_animator = nil
MultiClipEffectObj.m_nPlayMode = 0
MultiClipEffectObj.m_bIsPlaying = false
MultiClipEffectObj.m_strGameObjectTag = ""

function MultiClipEffectObj:create(obj) --obj: gameobject
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.m_strGameObjectTag = obj.name

    o.m_nPlayMode = 0
    o.m_animator = obj:GetComponentInChildren(typeof(Unity.Animator))

    if o.m_animator==nil then
        return nil
    end
    
    return o
end

function MultiClipEffectObj:playMultiClipEffect(effectType)
    -- if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_WildBeast then
    --     local bPrinceWildFlag = string.find(self.m_strGameObjectTag, "wangziWILD")
    --     if bPrinceWildFlag then
    --         self:playPrinceWildMultiClipEffect(effectType)
    --         return
    --     end
    -- end

    if self.m_enumEffectType == effectType then
        return
    end

    self.m_enumEffectType = effectType

    if effectType == MultiClipEffectType.EnumPixieScatter_Stop or
        effectType == MultiClipEffectType.EnumMardigrasLampEffect_Stop or
        effectType == MultiClipEffectType.EnumClipEffectDefaultClip
    then
        self.m_nPlayMode = 0
		self.m_bIsPlaying = false

    elseif effectType == MultiClipEffectType.EnumPixieScatter_Ani or
            effectType == MultiClipEffectType.EnumMardigrasLampEffect_Ani or
            effectType == MultiClipEffectType.EnumClipEffectAniClip
    then
	    self.m_nPlayMode = 1
		self.m_bIsPlaying = true
    
    elseif effectType == MultiClipEffectType.EnumChangeEffectClip
    then
		self.m_nPlayMode = 2
		self.m_bIsPlaying = true
    end

    self.m_animator:SetInteger("nPlayMode", self.m_nPlayMode)

    if effectType==MultiClipEffectType.EnumPixieScatter_Ani then
        MultiClipEffectObj:delayResetEffectType()
    end

    MultiClipEffectObj:playAni()

end

     --//pixieScatter LuckyVegas(wild scatter) TroyNvshenWild WildBeast PrinceWild
function MultiClipEffectObj:resetEffectType()
    if self.m_enumEffectType == MultiClipEffectType.EnumPixieScatter_Stop or
       self.m_enumEffectType == MultiClipEffectType.EnumClipEffectDefaultClip or
       self.m_enumEffectType == MultiClipEffectType.EnumMultiClipEffectType_NULL then
        return
    end

	if self.m_enumEffectType == MultiClipEffectType.EnumClipEffectAniClip or
        self.m_enumEffectType == MultiClipEffectType.EnumChangeEffectClip then
            
        self.m_enumEffectType = MultiClipEffectType.EnumClipEffectDefaultClip
	else
	    self.m_enumEffectType = MultiClipEffectType.EnumPixieScatter_Stop
    end

	self.m_nPlayMode = 0
	self.m_bIsPlaying = false
	self.m_animator:SetInteger("nPlayMode", self.m_nPlayMode)

end

function MultiClipEffectObj:delayResetEffectType(ftime)
    local id = LeanTween.delayedCall(ftime, function()
        self:resetEffectType()
    end).id
    
    table.insert(SceneSlotGame.m_listLeanTweenIDs, id)
end

function MultiClipEffectObj:playAni()
    -- if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_WildBeast then
    --     local bPrinceWildFlag = string.find(self.m_strGameObjectTag, "wangziWILD")
    --     if bPrinceWildFlag then
    --         self:PrinceWildPlayAni()
    --         return
    --     end
    -- end

    if self.m_animator==nil then
        return
    end

    local bTroyFlag = enumThemeType.enumLevelType_Troy == SlotsGameLua.m_enumLevelType
    local strLevelName = ThemeLoader.themeKey
    
    if bTroyFlag then
        local flag = string.find(self.m_strGameObjectTag, "NormalWild_1")
        if flag then --normalWild_1
            if self.m_nPlayMode == 2 then
                self.m_strDefaultStateName = "gongzhuwildTX"
            elseif self.m_nPlayMode == 1 then
                self.m_strDefaultStateName = "zhongjiangAni"
            else
                self.m_strDefaultStateName = "changtxjingzhen"
            end
        end
    end

    if strLevelName == "SnowWhite" then
        if self.m_nPlayMode == 2 then
            self.m_strDefaultStateName = "wildAni2"
        elseif self.m_nPlayMode == 1 then
            self.m_strDefaultStateName = "WildAni"
        else
            self.m_strDefaultStateName = "wildDefault"
        end
    end

    if self.m_animator~=nil and self.m_strDefaultStateName=="" then
        self.m_strDefaultStateName = self.m_animator.runtimeAnimatorController.animationClips[0].name
    end

    if self.m_animator~=nil then
        self.m_animator:Play(self.m_strDefaultStateName, -1, 0)
    end
end

function MultiClipEffectObj:playAniByPlayMode(nPlayMode)
    self.m_animator:SetInteger("nPlayMode", nPlayMode)

    ------todo-------MultiClipEffectObj:playAni()
end

function MultiClipEffectObj:resetPlayModeDefault()
    self.m_enumEffectType = MultiClipEffectType.EnumMultiClipEffectType_NULL
	self.m_nPlayMode = 0
	self.m_bIsPlaying = false
	self.m_animator:SetInteger("nPlayMode", self.m_nPlayMode)
end

return MultiClipEffectObj