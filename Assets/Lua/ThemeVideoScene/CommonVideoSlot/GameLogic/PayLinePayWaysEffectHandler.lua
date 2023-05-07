local PayLinePayWaysEffectHandler = {}

PayLinePayWaysEffectHandler.m_mapHitLineEffect = {} --Dictionary<int, EffectObj>
PayLinePayWaysEffectHandler.m_mapHighLightEffects = {} --Dictionary<int, HighLightEffect>
PayLinePayWaysEffectHandler.m_mapLeanTweenID = {} --Dictionary<int, int>

--//用来检查当前播放线与上次播放线有哪些相同的元素 哪些不同的元素。。相同的特效不重播 不同的要把该回收的回收掉。。
PayLinePayWaysEffectHandler.m_bNeedCheckHitLineEffect = false
PayLinePayWaysEffectHandler.m_listCurHitLineEffectKeys = {}

PayLinePayWaysEffectHandler.m_mapHighLightEffects = {}

PayLinePayWaysEffectHandler.m_allWinLines = {}
PayLinePayWaysEffectHandler.m_goAllWinLines = {}


PayLinePayWaysEffectHandler.m_mapSpineEffects = {} --Dictionary<int, SpineEffect>
PayLinePayWaysEffectHandler.m_mapMultiClipEffects = {} --Dictionary<int, MultiClipEffectObj>

--[[
    @desc: 3x3有些关卡需要画出中奖线来。。
    author:{author}
    time:2017-09-04 16:29:02
    --@nLineID: 
    return
]]

function PayLinePayWaysEffectHandler:reset()
    -- 下面这些需要释放的吧？？会内存泄漏吗？。。。。 todo
 	self.m_mapHitLineEffect = {}
	self.m_mapHighLightEffects = {}
	self.m_mapLeanTweenID = {}
	self.m_listCurHitLineEffectKeys = {}

	self.m_mapSpineEffects = {} --Dictionary<int, SpineEffect>
	self.m_mapMultiClipEffects = {}

	SlotsGameLua.m_bInSplashShowAllWinLines = false
	SlotsGameLua.m_bShowLineFlag = false -- 隐藏绕中奖元素转圈圈的粒子框特效...
end

function PayLinePayWaysEffectHandler:LoadLine()
    self.m_allWinLines = {}
	self.m_ArraySortingLayer = {}
	local nTempSortingOrder = 0
	local fWidth = 10

	if not GameLevelUtil:isNeedShowWinLine() then
		return 
	end

	if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_MardiGras then
		nTempSortingOrder = 20
	end
	
	if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_Shinydiamonds or
		SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_ColossalDog
	then
		nTempSortingOrder = -30
	end

	if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_ColossalDog then
		fWidth = 25
	end

	local strLineTexturePath = "Prefabs/Line"
	local LinePrefab =  CS.UnityEngine.Resources.Load(strLineTexturePath, typeof(Unity.GameObject))
	local goAllWinLinesDir = SlotsGameLua.m_goSlotsGame.transform:FindDeepChild("allWinLines")
	if goAllWinLinesDir == nil then
		goAllWinLinesDir = CS.UnityEngine.GameObject().transform
		goAllWinLinesDir:SetParent(SlotsGameLua.m_goSlotsGame.transform ,false)
		goAllWinLinesDir.name = "allWinLines"
	end

	if goAllWinLinesDir ~= nil then
		for i = 1, #SlotsGameLua.m_listLineLua do
			local obj = Unity.Object.Instantiate(LinePrefab)
			obj.transform:SetParent(goAllWinLinesDir, false)
			local mLineRenderer = obj:GetComponentInChildren(typeof(CS.UnityEngine.LineRenderer))
			mLineRenderer.positionCount = SlotsGameLua.m_nReelCount
			self.m_allWinLines[i] = mLineRenderer
			self.m_allWinLines[i].startColor = Unity.Color(1, 1, 1, 0)
			self.m_allWinLines[i].endColor = Unity.Color(1, 1, 1, 0)

			self.m_allWinLines[i].widthMultiplier = fWidth

			local mSortLayer = obj:GetComponentInChildren(typeof(CS.SortingLayerExposer))
			self.m_ArraySortingLayer[i] = mSortLayer
			self.m_ArraySortingLayer[i].SortingOrder = nTempSortingOrder
			self.m_ArraySortingLayer[i]:SetSortingOrder(nTempSortingOrder) 
		end
	end
	
end

function PayLinePayWaysEffectHandler:ShowWinLine(winItem, bShowAll)
	if not GameLevelUtil:isNeedShowWinLine() then
		return 
	end

	local nLineID = winItem.m_nLineID
	local ld = SlotsGameLua:GetLine(nLineID)
	if self.m_allWinLines[nLineID] then
		self.m_allWinLines[nLineID].startColor = SlotsGameLua:GetLine(nLineID).color
		self.m_allWinLines[nLineID].endColor = SlotsGameLua:GetLine(nLineID).color

		for x = 0, SlotsGameLua.m_nReelCount - 1 do
			local vSymboolPos = SlotsGameLua.m_listReelLua[x].m_listGoSymbol[ld.Slots[x]].transform.position
			if self.m_allWinLines[nLineID] then
				self.m_allWinLines[nLineID]:SetPosition(x, vSymboolPos)
			end
		end
	end

	if not bShowAll then
		for i = 1, #self.m_allWinLines do
			if self.m_allWinLines[i] and i ~= nLineID then
				self.m_allWinLines[i].startColor = Unity.Color(1, 1, 1, 0)
				self.m_allWinLines[i].endColor = Unity.Color(1, 1, 1, 0)
			end
		end
	end

end

function PayLinePayWaysEffectHandler:ShowHighLightWinLine(nLineID, nMaxMatchReelID)
	local ld = SlotsGameLua:GetLine(nLineID)
	for x = 0, SlotsGameLua.m_nReelCount-1 do --- self.m_nReelCount-1 如果有类似四叶草这种单元素任意位置中奖的判断就要所有列。。
		local nResultKey = SlotsGameLua.m_nRowCount * x + ld.Slots[x]
		local nEffectKey = nResultKey
		local effect = self.m_mapHighLightEffects[nEffectKey]
		if effect == nil then
			-- 创建播放特效 todo
			--local effectObj = nil --todo
			--LevelCommonFunctions.m_mapHighLightEffects[nEffectKey] = effectObj
		end
	end
end

function PayLinePayWaysEffectHandler:InitCurPayLineEffectKeys(nLineID, bFortunesOfGoldReel2, winItem)
	if not self.m_bNeedCheckHitLineEffect then
		return
	end

	if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_CharmWitch and nLineID == 0 then
		CharmWitchFunc:AddExtraInitCurPayLineEffectKeys()
		return
    end	
	
	if bFortunesOfGoldReel2 == nil then
		bFortunesOfGoldReel2 = false
	end

	local ld = SlotsGameLua:GetLine(nLineID)
	local nMatches = winItem.m_nMatches
	-- 2020-1-3 bug修改
    for x = 0, nMatches - 1 do -- SlotsGameLua.m_nReelCount-1
		local nEffectKey = SlotsGameLua.m_nRowCount * x + ld.Slots[x]
		
		if x == 2 and bFortunesOfGoldReel2 then
			nEffectKey = nEffectKey + 100
		end

		local bflag = LuaHelper.tableContainsElement(self.m_listCurHitLineEffectKeys, nEffectKey)
		if not bflag then
			table.insert( self.m_listCurHitLineEffectKeys, nEffectKey )
		end
	end	

	if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_IrishTwo then
		IrishTwoFunc:AddExtraInitCurPayLineEffectKeys(nLineID)
	elseif SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_HappyChristmas then
		HappyChristmasFunc:AddExtraInitCurPayLineEffectKeys()
	end
	
end

function PayLinePayWaysEffectHandler:ShowPayLineEffect(nLineID, nMaxMatchReelID)
	local bClassicLevel = GameLevelUtil:isClassicLevel()
	local bHasLineParticleEffect = GameLevelUtil:hasLineParticleEffect()
	
	local ld = SlotsGameLua:GetLine(nLineID)
	for x = 0, nMaxMatchReelID do
		local y = ld.Slots[x]

		local nResultKey = SlotsGameLua.m_nRowCount * x + ld.Slots[x]
		local nEffectKey = nResultKey
		-- 1. 转圈粒子特效 非33关卡一定有  其他的就依次检查，有一种播放就break
		if bHasLineParticleEffect then
			self:PlayHitLineEffect(x, y)
		end

		-- 2. spine特效
		self:PlaySpineEffect(x, y)

		-- 3. unity动画
		self:PlayMultiClipEffect(x, y)

		-- 4. 缩放
		if not bClassicLevel then
			self:LoopScaleSymbol(x, y)
		end
	end

	if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_IrishTwo then
		IrishTwoFunc:ShowExtraPayLineEffect(nLineID, nMaxMatchReelID)
	end	

end

function PayLinePayWaysEffectHandler:PlayHitLineEffect2(effectPos, nEffectKey, x, y)
	local bHasHitEffectFlag = self.m_mapHitLineEffect[nEffectKey] ~= nil
	if not bHasHitEffectFlag then
		local effectType = enumEffectType.Effect_PayLineSymbol
		local effectObj = EffectObj:Show(effectPos, effectType)
		
		if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_FortunesOfGold then
			if x == 2 then
				effectObj.m_effectGo.transform.localScale = Unity.Vector3(1, 0.5, 1)
			end
		end

		if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_Aladdin then
			if SlotsGameLua.m_GameResult:InFreeSpin() then
				effectObj.m_effectGo.transform.localScale = Unity.Vector3.one * 0.8
			else
				effectObj.m_effectGo.transform.localScale = Unity.Vector3.one
			end
		end
		
		self.m_mapHitLineEffect[nEffectKey] = effectObj

	end
end

function PayLinePayWaysEffectHandler:PlayHitLineEffect(x, y)
	local nEffectKey = SlotsGameLua.m_nRowCount * x + y
	local pos0 = SlotsGameLua.m_listReelLua[x].m_transform.localPosition
	local pos1 = SlotsGameLua.m_listReelLua[x].m_listGoSymbol[y].transform.localPosition
	local pos2 = SlotsGameLua.m_transform.localPosition
	local effectPos = pos0 + pos1 + pos2
	
	if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_Aladdin then
		effectPos = SlotsGameLua.m_listReelLua[x].m_listGoSymbol[y].transform.position
	end

	self:PlayHitLineEffect2(effectPos, nEffectKey, x, y)
end

function PayLinePayWaysEffectHandler:PlaySpineEffect2(go, nEffectKey)
	local bHasSpineEffectFlag = self.m_mapSpineEffects[nEffectKey] ~= nil
	if bHasSpineEffectFlag then
		return
	end

	local spine = SymbolObjectPool.m_mapSpinEffect[go]
	if spine ~= nil then
		spine:PlayActiveAnimation()
		self.m_mapSpineEffects[nEffectKey] = spine
	end

end

function PayLinePayWaysEffectHandler:PlaySpineEffect(x, y)
	local nEffectKey = -1
	local go = nil

	if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_MermaidMischief then
		nEffectKey, go = MermaidMischiefFunc:GetPlaySpineAniGoSymbol(x, y)
	elseif SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_ColossalDog then
		nEffectKey, go = ColossalDogFunc:GetPlaySpineAniGoSymbol(x, y)
	else
		nEffectKey = SlotsGameLua.m_nRowCount * x + y
		local bHasSpineEffectFlag = self.m_mapSpineEffects[nEffectKey] ~= nil
		if bHasSpineEffectFlag then
			return
		end

		if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_KingOfOcean then
			local nSymbolId = SlotsGameLua.m_listDeck[nEffectKey]
			if KingOfOceanSymbol:isKingOfOceanSymbol(nSymbolId) then
				return
			end
		end
		
		local bStickyFlag, nStickyIndex = SlotsGameLua.m_listReelLua[x]:isStickyPos(y)
		if bStickyFlag then
			go = SlotsGameLua.m_listReelLua[x].m_listStickySymbol[nStickyIndex].m_goSymbol
		else
			local listGo = SlotsGameLua.m_listReelLua[x].m_listGoSymbol
			go = listGo[y]
		end
	end

	self:PlaySpineEffect2(go, nEffectKey)

end

function PayLinePayWaysEffectHandler:PlayMultiClipEffect(x, y)
	if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_DiaDeAmor then
		DiaDeAmorFunc:PlayMultiClipEffect(x, y)
		return
	end
	
	local nEffectKey = SlotsGameLua.m_nRowCount * x + y
	local bHasClipEffectFlag = self.m_mapMultiClipEffects[nEffectKey] ~= nil
	if not bHasClipEffectFlag then
		local bStickyFlag, nStickyIndex = SlotsGameLua.m_listReelLua[x]:isStickyPos(y)
		if bStickyFlag then
			local goSticky = SlotsGameLua.m_listReelLua[x].m_listStickySymbol[nStickyIndex].m_goSymbol
			local clipEffect = SymbolObjectPool.m_mapMultiClipEffect[goSticky]
			if clipEffect ~= nil then
				local effectType = MultiClipEffectType.EnumClipEffectAniClip
				clipEffect:playMultiClipEffect(effectType)
				self.m_mapMultiClipEffects[nEffectKey] = clipEffect
			end
		else
			local listGo = SlotsGameLua.m_listReelLua[x].m_listGoSymbol
			local obj = listGo[y]
			local clipEffect = SymbolObjectPool.m_mapMultiClipEffect[obj]
			if clipEffect ~= nil then
				local effectType = MultiClipEffectType.EnumClipEffectAniClip
				clipEffect:playMultiClipEffect(effectType)
				self.m_mapMultiClipEffects[nEffectKey] = clipEffect
			end
		end
	end
	
end

function PayLinePayWaysEffectHandler:PlayMultiClipEffect2(go, nEffectKey)
	local bHasClipEffectFlag = self.m_mapMultiClipEffects[nEffectKey] ~= nil
	if not bHasClipEffectFlag then

		local clipEffect = SymbolObjectPool.m_mapMultiClipEffect[go]
		if clipEffect ~= nil then
			local effectType = MultiClipEffectType.EnumClipEffectAniClip
			clipEffect:playMultiClipEffect(effectType)
			self.m_mapMultiClipEffects[nEffectKey] = clipEffect
		end
		
	end
end

function PayLinePayWaysEffectHandler:LoopScaleSymbol2(go, nEffectKey, x, y, bCustomFlag)
	if bCustomFlag == nil then
		bCustomFlag = false
	end

	local bFlag = self.m_mapSpineEffects[nEffectKey] ~= nil -- 有spine动画的 就不缩放了
	if bFlag then
		return
	end

	bFlag = self.m_mapMultiClipEffects[nEffectKey] ~= nil -- 有clip动画的 就不缩放了
	if bFlag then
		return
	end

	bFlag = self.m_mapLeanTweenID[nEffectKey] ~= nil
	if bFlag then
		return
	end

	local fElemScale = 1.05
	local scale = Unity.Vector3(fElemScale, fElemScale, 1.0)
	if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_FortunesOfGold then
		if x == 2 then
			local fScaleCoef = FortunesOfGoldFunc:getScaleCoef(x, y, bCustomFlag)
			local fElemScaley = 1.05 * fScaleCoef
			scale = Unity.Vector3(fElemScale, fElemScaley, 1.0)
		end
	end

	local id = LeanTween.scale(go, scale, 0.3):setLoopPingPong(-1).id
	self.m_mapLeanTweenID[nEffectKey] = id
end

function PayLinePayWaysEffectHandler:LoopScaleSymbol(x, y) -- 放回缓存之后重置为1
	--不是每关都缩放的。。比如很多3x3关卡就是带光效的元素闪烁播放。。
	if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_WildRespin or
		SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_WildSliding or
		SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_LuckyStar
	then
		return
	end

	local nEffectKey = SlotsGameLua.m_nRowCount * x + y
	
	local goSymbol = SlotsGameLua.m_listReelLua[x].m_listGoSymbol[y]

	local reel = SlotsGameLua.m_listReelLua[x]
	local bStickyFlag, nStickyIndex = reel:isStickyPos(y)
	if bStickyFlag then
		goSymbol = reel.m_listStickySymbol[nStickyIndex].m_goSymbol
	end

	self:LoopScaleSymbol2(goSymbol, nEffectKey, x, y)
end

function PayLinePayWaysEffectHandler:checkNeedReusedHitLineEffect()
	if not self.m_bNeedCheckHitLineEffect then
		return false
	end

	self.m_bNeedCheckHitLineEffect = false
	local bres = false
	local listNeedRemove = {}
	for k,v in pairs(self.m_mapHitLineEffect) do
    	local bFlag = LuaHelper.tableContainsElement(self.m_listCurHitLineEffectKeys, k)
		if not bFlag then
			table.insert( listNeedRemove, k )
			bres = true
		end
	end
	self.m_listCurHitLineEffectKeys = {}

	local cnt = #listNeedRemove
	for i=1, cnt do
		local key = listNeedRemove[i]
		local effectObj = self.m_mapHitLineEffect[key]
		effectObj:reuseCacheEffect()
		self.m_mapHitLineEffect[key] = nil
	end
	listNeedRemove = {}

	return bres
end

function PayLinePayWaysEffectHandler:resetHighLightEffects()
	for k,v in pairs(self.m_mapHighLightEffects) do
		v:StopActiveAnimation()
	end
	self.m_mapHighLightEffects = {}
end

function PayLinePayWaysEffectHandler:MatchLineHide(bHideAllEffect)
	SlotsGameLua.m_bInSplashShowAllWinLines = false

	SlotsGameLua.m_bShowLineFlag = false -- 隐藏绕中奖元素转圈圈的粒子框特效...

	LevelCommonFunctions:SetWinSymbolWhenShowAndHide(false)
	
	-- if self.m_CurWinLine then
	-- 	self.m_CurWinLine.startColor = Unity.Color(1, 1, 1, 0)
	-- 	self.m_CurWinLine.endColor = Unity.Color(1, 1, 1, 0)
	-- end
	
	for i = 1, #self.m_allWinLines do
		if self.m_allWinLines[i] then
			self.m_allWinLines[i].startColor = Unity.Color(1, 1, 1, 0)
			self.m_allWinLines[i].endColor = Unity.Color(1, 1, 1, 0)
		end
	end

	self.m_listCurHitLineEffectKeys = {}

	 -- 3x3关卡展示了线条的 在这里隐藏掉。。
	for k,v in pairs(self.m_mapHitLineEffect) do
		if v ~= nil then
			v:reuseCacheEffect()
		end
	end
	self.m_mapHitLineEffect = {}

	self:resetHighLightEffects()

	if bHideAllEffect then
		-- 1. spine effect
		for k,v in pairs(self.m_mapSpineEffects) do
			local spine = self.m_mapSpineEffects[k]
			spine:setNeedStop()  -- StopActiveAnimation 
		end
		self.m_mapSpineEffects = {}

		-- 2. multiClip ani todo 
		for k,v in pairs(self.m_mapMultiClipEffects) do
			local clipEffect = self.m_mapMultiClipEffects[k]
			clipEffect:resetEffectType()
		end
		self.m_mapMultiClipEffects = {}
		
		-- 3. 缩放动画
		for k,v in pairs(self.m_mapLeanTweenID) do
			LeanTween.cancel(v)
		end
		self.m_mapLeanTweenID = {}
	end
end

----------payWays-------

-- item: WinItemPayWay

-- 中奖线上的元素播放特效处理。。--- 目的是找出共同的。。下次不用切换线的不要改变这个相同的特效
function PayLinePayWaysEffectHandler:InitCurPayWayEffectKeys(item)
	local nSymolID = item.m_nSymbolIdx
	local nMatches = item.m_nMatches
	for x = 0, nMatches-1 do
		local nCurReelRows = SlotsGameLua.m_listReelLua[x].m_nReelRow
		for y = 0, nCurReelRows-1 do
			local nkey = SlotsGameLua.m_nRowCount * x + y
			local nID = SlotsGameLua.m_listDeck[nkey]
			local bSameKindSymbolFlag = LevelCommonFunctions:isSamekindSymbol(nSymolID, nID)

			if bSameKindSymbolFlag then
				-- 1. 转圈粒子特效 非33关卡一定有  其他的就依次检查，有一种播放就break
				local nEffectKey = nkey

				if self.m_bNeedCheckHitLineEffect then
					local bflag = LuaHelper.tableContainsElement(self.m_listCurHitLineEffectKeys, nEffectKey)
					if not bflag then
						table.insert( self.m_listCurHitLineEffectKeys, nEffectKey )
					end
				end

			end
		end
	end
end

function PayLinePayWaysEffectHandler:ShowPayWayEffect(item)
	local nSymolID = item.m_nSymbolIdx
	local nMatches = item.m_nMatches
	for x = 0, nMatches-1 do
		local nCurReelRows = SlotsGameLua.m_listReelLua[x].m_nReelRow
		for y = 0, nCurReelRows-1 do
			local nkey = SlotsGameLua.m_nRowCount * x + y
			local nID = SlotsGameLua.m_listDeck[nkey]
			local bSameKindSymbolFlag = LevelCommonFunctions:isSamekindSymbol(nSymolID, nID)

			if bSameKindSymbolFlag then
				-- 1. 转圈粒子特效 非33关卡一定有  其他的就依次检查，有一种播放就break
				self:PlayHitLineEffect(x, y)

				-- 2. spine特效
				self:PlaySpineEffect(x, y)

				-- 3. unity动画
				self:PlayMultiClipEffect(x, y)

				-- 4. 缩放
				self:LoopScaleSymbol(x, y)

			end

		end
	end
end

function PayLinePayWaysEffectHandler:PlayHitLineEffect3(effectPos, nEffectKey, strName, trParent)
	local bHasHitEffectFlag = self.m_mapHitLineEffect[nEffectKey] ~= nil
	if not bHasHitEffectFlag then
		local effectObj = EffectObj:CreateAndShowByName(effectPos, strName, trParent)

		self.m_mapHitLineEffect[nEffectKey] = effectObj

		return effectObj
	end

	return nil
end

return PayLinePayWaysEffectHandler