local DeckResultPayWays = {} 

function DeckResultPayWays:Init()
    self.m_Manager = SlotsGameLua
    self.m_allWinLines = {}

	self.m_mapHitLineEffect = {}
    self.m_mapSpineEffects = {}
    self.m_mapMultiClipEffects = {}
	self.m_mapLeanTweenID = {}
    self.m_listCurHitLineEffectKeys = {}
	self.m_bNeedCheckHitLineEffect = false

	self.m_bInSplashShowAllWinLines = false
	self.m_bShowLineFlag = false
	self.m_bShowAllWins = false

end

function DeckResultPayWays:InitCurPayWayEffectKeys(item)
	local nSymbolId = item.m_nSymbolIdx
	local nMatches = item.m_nMatches
	for x = 0, nMatches - 1 do
		for y = 0, self.m_Manager.m_nRowCount - 1 do
			local nKey = self.m_Manager.m_nRowCount * x + y
			local nCompSymbolId = self.m_Manager.m_listDeck[nKey]
			
			if TigerDragonFunc:isSamekindSymbol(nSymbolId, nCompSymbolId) then
				local nEffectKey = nKey

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

function DeckResultPayWays:ShowPayWayEffect(item)
	local nSymbolId = item.m_nSymbolIdx
	local nMatches = item.m_nMatches

	for x = 0, nMatches - 1 do

		local nRowCount = 4
		if x == 0 or x == 4 then
			nRowCount = 3
		end

		for y = 0, nRowCount - 1 do
			local nKey = self.m_Manager.m_nRowCount * x + y
			local nCompSymbolId = self.m_Manager.m_listDeck[nKey]

			if TigerDragonFunc:isSamekindSymbol(nSymbolId, nCompSymbolId) then
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

function DeckResultPayWays:GetHitLineEffectName(nKey)
	return "lztukuai"
end

function DeckResultPayWays:PlayHitLineEffect(nReelId, nRowIndex)
	local nKey = self.m_Manager.m_nRowCount * nReelId + nRowIndex
	if not self.m_mapHitLineEffect[nKey] then
		local goSymbol = self:GetGoSymbol(nReelId, nRowIndex)
		local effectPos = self:GetGoSymbolPos(nReelId, nRowIndex)

		local effectName = self:GetHitLineEffectName(nKey)
		local effectObj = TigerDragonLevelUI:GetEffectByEffectPool(effectName)
		effectObj.transform:SetParent(TigerDragonLevelUI.m_transform, false)
		effectObj.transform.localScale = Unity.Vector3.one
		effectObj.transform.position = effectPos
		effectObj:SetActive(true)

		self.m_mapHitLineEffect[nKey] = effectObj
    end
end

function DeckResultPayWays:PlaySpineEffect(nReelId, nRowIndex)
    local nKey = self.m_Manager.m_nRowCount * nReelId + nRowIndex
	if not self.m_mapSpineEffects[nKey] then	
		local goSymbol = self:GetGoSymbol(nReelId, nRowIndex)
			
		local spine = SymbolObjectPool.m_mapSpinEffect[goSymbol]
		if spine ~= nil then
			spine:PlayActiveAnimation()
			self.m_mapSpineEffects[nKey] = spine
		end
	end
end

function DeckResultPayWays:PlayMultiClipEffect(nReelId, nRowIndex)
	local nKey = self.m_Manager.m_nRowCount * nReelId + nRowIndex
	if not self.m_mapMultiClipEffects[nKey] then
		local goSymbol = self:GetGoSymbol(nReelId, nRowIndex)
		local clipEffect = SymbolObjectPool.m_mapMultiClipEffect[goSymbol]
		if clipEffect ~= nil then
			local effectType = MultiClipEffectType.EnumClipEffectAniClip
			clipEffect:playMultiClipEffect(effectType)
			self.m_mapMultiClipEffects[nKey] = clipEffect
		end
    end
end

function DeckResultPayWays:LoopScaleSymbol(nReelId, nRowIndex) -- 放回缓存之后重置为1
	local nKey = self.m_Manager.m_nRowCount * nReelId + nRowIndex
	local goSymbol = self:GetGoSymbol(nReelId, nRowIndex)

	local bFlag = self.m_mapSpineEffects[nKey] ~= nil -- 有spine动画的 就不缩放了
	if bFlag then
		return
	end

	bFlag = self.m_mapMultiClipEffects[nKey] ~= nil -- 有clip动画的 就不缩放了
	if bFlag then
		return
	end

	bFlag = self.m_mapLeanTweenID[nKey] ~= nil
	if bFlag then
		return
	end
		
	local fElemScale = 1.05
	local scale = Unity.Vector3(fElemScale, fElemScale, 1.0)
	local id = LeanTween.scale(goSymbol, scale, 0.3):setLoopPingPong(-1).id
	self.m_mapLeanTweenID[nKey] = id
end

function DeckResultPayWays:checkNeedReusedHitLineEffect()
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
		TigerDragonLevelUI:RecycleEffectToEffectPool(effectObj)
		self.m_mapHitLineEffect[key] = nil
	end
	listNeedRemove = {}
	
	return bres
end

function DeckResultPayWays:InitMatchLineShow()
	self.m_nWinOffset = 1
	self.m_nPreWinOffset = 0
	self.m_fWinShowAge = 0
    self.m_bInSplashShowAllWinLines = true
    self.m_fWinShowPeriod = 1.9
	self.m_bShowLineFlag = true
	self.m_bShowAllWins = false
end

function DeckResultPayWays:MatchLineHide()
	self.m_bInSplashShowAllWinLines = false
	self.m_bShowLineFlag = false -- 隐藏绕中奖元素转圈圈的粒子框特效...

	LevelCommonFunctions:SetWinSymbolWhenShowAndHide(false)

	self.m_listCurHitLineEffectKeys = {}

	for k, v in pairs(self.m_mapHitLineEffect) do
		if v ~= nil then
			local effectObj = v
			TigerDragonLevelUI:RecycleEffectToEffectPool(effectObj)
		end
	end
	self.m_mapHitLineEffect = {}

	-- 1. spine effect
	for k,v in pairs(self.m_mapSpineEffects) do
		local spine = self.m_mapSpineEffects[k]
		spine:setNeedStop()  -- StopActiveAnimation 
	end
	self.m_mapSpineEffects = {}

	-- 2. multiClip ani todo 
	for k,v in pairs(self.m_mapMultiClipEffects) do
		local clip = self.m_mapMultiClipEffects[k]
		clip:resetEffectType()  -- Stop
	end

	self.m_mapMultiClipEffects = {}

	-- 3. 缩放动画
	for k,v in pairs(self.m_mapLeanTweenID) do
		LeanTween.cancel(v)
	end
	self.m_mapLeanTweenID = {}

end

-- =--------------------------------------------------------

function DeckResultPayWays:DisplayAllMatchWaysInfo()
    if not self.m_bShowLineFlag then
        return false
    end

    if not self.m_bInSplashShowAllWinLines then
        return false
    end	

    local nTotalWins = LuaHelper.tableSize(self.m_Manager.m_GameResult.m_mapWinItemPayWays)
    if nTotalWins == 0 then
        self.m_bInSplashShowAllWinLines = false
        return false
    end	

    self.m_fWinShowAge = self.m_fWinShowAge + Unity.Time.deltaTime
    if self.m_fWinShowAge > self.m_fWinShowPeriod then
        self.m_fWinShowAge = 0.0
        self.m_bInSplashShowAllWinLines = false
        self.m_bNeedCheckHitLineEffect = true
        self.m_bShowAllWins = false
        return
    end

    if self.m_bShowAllWins then
        return true
	end
	self.m_bShowAllWins = true
	
	LevelCommonFunctions:SetWinSymbolWhenShowAndHide(true)

    for k,v in pairs(self.m_Manager.m_GameResult.m_mapWinItemPayWays) do
        local nSymbolId = k
        local item = v
        self:ShowPayWayEffect(item)
    end

    return true
end

function DeckResultPayWays:DisplayMatchWaysInfo()
    if not self.m_bShowLineFlag then
        return
    end

    if self.m_bInSplashShowAllWinLines then
        return
    end

    local cnt = LuaHelper.tableSize(self.m_Manager.m_GameResult.m_mapWinItemPayWays)
    if cnt == 0 then
        return
    end

    local nPayWays = #self.m_Manager.m_GameResult.m_listWinItemPayWays
    if nPayWays == 0 then
        for k, v in pairs(self.m_Manager.m_GameResult.m_mapWinItemPayWays) do
            table.insert(self.m_Manager.m_GameResult.m_listWinItemPayWays, v)
        end
    end

    self.m_fWinShowAge = self.m_fWinShowAge + Unity.Time.deltaTime
    if self.m_fWinShowAge > self.m_fWinShowPeriod then
        self.m_bNeedCheckHitLineEffect = true
        self.m_fWinShowAge = 0.0
        self.m_nWinOffset = self.m_nWinOffset + 1
        if self.m_nWinOffset > #self.m_Manager.m_GameResult.m_listWinItemPayWays then
            self.m_nWinOffset = 1
        end
    end 

    if self.m_nPreWinOffset == self.m_nWinOffset then
        return
    end

    self.m_nPreWinOffset = self.m_nWinOffset

    local item = self.m_Manager.m_GameResult.m_listWinItemPayWays[self.m_nWinOffset]
    self:ShowPayWayEffect(item)
    self:InitCurPayWayEffectKeys(item)
    self:checkNeedReusedHitLineEffect()

end

function DeckResultPayWays:GetGoSymbol(nReelId, nRowIndex)
	local nEffectKey = nReelId * self.m_Manager.m_nRowCount + nRowIndex
	local goSymbol = self.m_Manager.m_listReelLua[nReelId].m_listGoSymbol[nRowIndex]
	local nSymbolId = self.m_Manager.m_listReelLua[nReelId].m_curSymbolIds[nRowIndex]

	local nSymbolId = self.m_Manager.m_listReelLua[nReelId].m_curSymbolIds[1]
	if TigerDragonFunc.tableBigSymbol[nReelId] then
		local nTargetRowIndex = TigerDragonFunc.tableBigSymbol[nReelId][1]
		if nTargetRowIndex >= nRowIndex and nRowIndex >= nTargetRowIndex - 2 then
			nEffectKey = nReelId * self.m_Manager.m_nRowCount + nTargetRowIndex + 100
			goSymbol =  self.m_Manager.m_listReelLua[nReelId].m_listGoSymbol[nTargetRowIndex]
		end
	end			

	return goSymbol
end

function DeckResultPayWays:GetGoSymbolPos(nReelId, nRowIndex)
	local nKey = nReelId * self.m_Manager.m_nRowCount + nRowIndex
	local goSymbol = self.m_Manager.m_listReelLua[nReelId].m_listGoSymbol[nRowIndex]

	local pos = goSymbol.transform.position
	return pos
end

return DeckResultPayWays