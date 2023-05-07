local AnimationEventHub = {}

AnimationEventHub.m_strParam = ""


--参数格式说明：逗号分隔的一个字符串 形式如: LuckyStar,LuckyStar,ReelEffect_Fail,End ........
--关卡key, clipName, eventName
--eventName: 一遍播放结束：End  一遍的中间：Middle  开始：Start

function AnimationEventHub:AnimationEventFunc(strParam)
    Debug.Log("------function AnimationEventFunc(strParam)------strParam: " .. strParam)

    self.m_strParam = strParam
	
	local tableParam = LuaHelper.StringSplit(strParam, "_")
	if strParam == "Theme_Smitten_QiuBiTeFeatureEffect_0_Event" then
		SmittenLevelUI:PlayQiuBiTeFeatureEffectSpineEffect()
	elseif strParam == "Theme_FuXing_FreeSpin_Random_1_Event" then
		FuXingLevelUI.mFreeSpinBeginSplashUI:PlayFreeSpinRandom1EventEffect()
	elseif strParam == "Theme_FuXing_FreeSpin_Random_2_Event" then
		FuXingLevelUI.mFreeSpinBeginSplashUI:PlayFreeSpinRandom2EventEffect()
	elseif strParam == "Theme_FuXing_FreeSpin_Random_3_Event" then
		FuXingLevelUI.mFreeSpinBeginSplashUI:PlayFreeSpinRandom3EventEffect()
	elseif strParam == "Theme_FuXing_FreeSpin_Random_4_Event" then
		FuXingLevelUI.mFreeSpinBeginSplashUI:PlayFreeSpinRandom4EventEffect()
	elseif strParam == "Theme_GoldenVegas_GoldenMen_JuZhongLoopAniFinish_Event" then
		GoldenVegasLevelUI:PlayGoldenMen_JuZhongLoopAniFinish_EventEffect()
	elseif strParam == "Theme_GoldenVegas_GoldenMen_JuZhongLoopAniBegin_Event" then
		GoldenVegasLevelUI:PlayGoldenMen_JuZhongLoopAniBegin_EventEffect()
	elseif strParam == "Theme_FortuneFarm_FreeSpinPreparePlayTopEggHitLineAniEvent" then
		FortuneFarmLevelUI:FreeSpinPreparePlayTopEggHitLineAniEvent()
	elseif strParam == "Theme_Classic_DragonChase_RandomBonusCountAniEvent" then
		DragonChaseLevelUI.mFreeSpinFeatureSelectUI:PlayRandomBonusCountAniEvent()
	elseif strParam == "Theme_Classic_DragonChase_RandomFreeSpinCountAniEvent" then
		DragonChaseLevelUI.mFreeSpinFeatureSelectUI:PlayRandomFreeSpinCountAniEvent()
	end

end 

function AnimationEventHub:SplitStr(input, delimiter)
	input = tostring(input)
	delimiter = tostring(delimiter)
    if(delimiter == '') then
         return false
    end

	local pos, arr = 0, {}
	-- for each divider found
	for st, sp in function() return string.find(input, delimiter, pos, true) end do
		table.insert(arr, string.sub(input, pos, st - 1))
		pos = sp + 1
	end
	table.insert(arr, string.sub(input, pos))
	return arr
end

return AnimationEventHub