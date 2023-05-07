local DeckResultPayLines = {}

function DeckResultPayLines:New(m_Manager)
    local o = {}
    setmetatable(o, self)
    self.__index = self

    o:Init(m_Manager)
    return o
end 

function DeckResultPayLines:Init(m_Manager)
    self.m_Manager = m_Manager
    self.m_allWinLines = {}
    self.m_goAllWinLines = {}

	self.m_mapHitLineEffect = {}
    self.m_mapSpineEffects = {}
    self.m_mapMultiClipEffects = {}
	self.m_mapLeanTweenID = {}
    self.m_listCurHitLineEffectKeys = {}
    self.m_bNeedCheckHitLineEffect = false

	self.m_bInSplashShowAllWinLines = false
    self.m_bShowLineFlag = false
end

function DeckResultPayLines:InitCurPayLineEffectKeys(nLineID, bFortunesOfGoldReel2, winItem)
	if not self.m_bNeedCheckHitLineEffect then
		return
	end

	local ld = SlotsGameLua:GetLine(nLineID) 
	local nMatches = winItem.m_nMatches

    for x = 0, nMatches - 1 do -- SlotsGameLua.m_nReelCount-1
		local nEffectKey = SlotsGameLua.m_nRowCount * x + ld.Slots[x]
		local bflag = LuaHelper.tableContainsElement(self.m_listCurHitLineEffectKeys, nEffectKey)
		if not bflag then
			table.insert( self.m_listCurHitLineEffectKeys, nEffectKey )
		end
	end	

end

function DeckResultPayLines:ShowPayLineEffect(nLineID, nMaxMatchReelID)
	local ld = SlotsGameLua:GetLine(nLineID)
	for x=0, nMaxMatchReelID do --SlotsGameLua.m_nReelCount-1
		local y = ld.Slots[x]

		local nResultKey = SlotsGameLua.m_nRowCount * x + ld.Slots[x]
		local nEffectKey = nResultKey
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

function DeckResultPayLines:PlayHitLineEffect2(effectPos, nEffectKey, x, y)
	local bHasHitEffectFlag = self.m_mapHitLineEffect[nEffectKey] ~= nil
	if not bHasHitEffectFlag then
		local effectType = enumEffectType.Effect_PayLineSymbol
		local effectObj = AliceLevelUI:GetEffectByEffectPool("lztukuai")
		effectObj.transform:SetParent(AliceLevelUI.m_transform, false)
		effectObj.transform.localScale = Unity.Vector3.one
		effectObj.transform.position = effectPos
		effectObj:SetActive(true)
		self.m_mapHitLineEffect[nEffectKey] = effectObj
	end
end

function DeckResultPayLines:PlayHitLineEffect(x, y)
	local nEffectKey = SlotsGameLua.m_nRowCount * x + y
	local effectPos = self:GetGoSymbolPos(x, y)
	self:PlayHitLineEffect2(effectPos, nEffectKey, x, y)
end

function DeckResultPayLines:PlaySpineEffect2(go, nEffectKey)
	local bHasSpineEffectFlag = self.m_mapSpineEffects[nEffectKey] ~= nil
	if bHasSpineEffectFlag then
		return
	end

	local spine = SymbolObjectPool.m_mapSpinEffect[go]
	local nSymbolId = SlotsGameLua.m_listDeck[nEffectKey]
	if spine ~= nil then
		spine:StopActiveAnimation()
		spine:PlayActiveAnimation()
		self.m_mapSpineEffects[nEffectKey] = spine
	end

end

function DeckResultPayLines:PlaySpineEffect(x, y)
	local nEffectKey, goSymbol = self:GetGoSymbol(x, y)
    local bHasSpineEffectFlag = self.m_mapSpineEffects[nEffectKey] ~= nil
    if bHasSpineEffectFlag then
        return
    end	
		
	self:PlaySpineEffect2(goSymbol, nEffectKey)
end

function DeckResultPayLines:PlayMultiClipEffect(x, y)
	local nEffectKey, goSymbol = self:GetGoSymbol(x, y)
	local bHasClipEffectFlag = self.m_mapMultiClipEffects[nEffectKey] ~= nil
	if not bHasClipEffectFlag then
		local clipEffect = SymbolObjectPool.m_mapMultiClipEffect[goSymbol]
		if clipEffect ~= nil then
			local effectType = MultiClipEffectType.EnumClipEffectAniClip
			clipEffect:playMultiClipEffect(effectType)
			self.m_mapMultiClipEffects[nEffectKey] = clipEffect
		end
	end

end

function DeckResultPayLines:LoopScaleSymbol2(go, nEffectKey, x, y, bCustomFlag)
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
	local id = LeanTween.scale(go, scale, 0.3):setLoopPingPong(-1).id
	self.m_mapLeanTweenID[nEffectKey] = id
end

function DeckResultPayLines:LoopScaleSymbol(x, y) -- 放回缓存之后重置为1
	local nEffectKey, goSymbol = self:GetGoSymbol(x, y)
	self:LoopScaleSymbol2(goSymbol, nEffectKey, x, y)
end

function DeckResultPayLines:checkNeedReusedHitLineEffect()
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
		AliceLevelUI:RecycleEffectToEffectPool(effectObj)
		self.m_mapHitLineEffect[key] = nil
	end
	listNeedRemove = {}

	return bres
end

function DeckResultPayLines:InitMatchLineShow()
    self.m_nWinOffset = 1
	self.m_fWinShowAge = 0
    self.m_bInSplashShowAllWinLines = true
    self.m_fWinShowPeriod = 1.9
	self.m_bShowLineFlag = true
	self.m_bShowAllWins = false
end

function DeckResultPayLines:MatchLineHide()
	self.m_bInSplashShowAllWinLines = false
	self.m_bShowLineFlag = false -- 隐藏绕中奖元素转圈圈的粒子框特效...

	LevelCommonFunctions:SetWinSymbolWhenShowAndHide(false)

	for i = 1, #self.m_allWinLines do
		if self.m_allWinLines[i] then
			self.m_allWinLines[i].startColor = Unity.Color(1, 1, 1, 0)
			self.m_allWinLines[i].endColor = Unity.Color(1, 1, 1, 0)
		end
	end

	self.m_listCurHitLineEffectKeys = {}

	for k, v in pairs(self.m_mapHitLineEffect) do
		AliceLevelUI:RecycleEffectToEffectPool(v)
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
function DeckResultPayLines:ShowAllMatchLines()

    if not self.m_bShowLineFlag then
        return false
    end

    if not self.m_bInSplashShowAllWinLines then
        return false
	end

    self.m_fWinShowAge = self.m_fWinShowAge + SlotsGameLua.m_fDeltaTime
    if self.m_fWinShowAge > self.m_fWinShowPeriod * 1.35 then
        self.m_fWinShowAge = 0.0
        self.m_bInSplashShowAllWinLines = false
        self.m_bNeedCheckHitLineEffect = true
        return true
	end

	if self.m_bShowAllWins then
        return true
    end
    self.m_bShowAllWins = true
	
    LevelCommonFunctions:SetWinSymbolWhenShowAndHide(true)

    local nTotalWinLines = #self.m_Manager.m_GameResult.m_listWins
    local bNeedShowLines = false
    local bShowHighLightEffectFlag = false

    for nWinIndex = 1, nTotalWinLines do
        local wi = self.m_Manager.m_GameResult.m_listWins[nWinIndex]
        local ld = SlotsGameLua:GetLine(wi.m_nLineID)

        self:ShowPayLineEffect(wi.m_nLineID, wi.m_nMaxMatchReelID)
    end
	
    return true
end

function DeckResultPayLines:DisplayMatchLinesInfo()
    if not self.m_bShowLineFlag then
        return
    end

    if self.m_bInSplashShowAllWinLines then
        return
	end

	local nTotalWinLines = #self.m_Manager.m_GameResult.m_listWins
	if nTotalWinLines == 0 then
		return
	end

    local nTotalWinLines = #self.m_Manager.m_GameResult.m_listWins
    self.m_fWinShowAge = self.m_fWinShowAge + SlotsGameLua.m_fDeltaTime
    if self.m_fWinShowAge > self.m_fWinShowPeriod then
        self.m_bNeedCheckHitLineEffect = true

        self.m_fWinShowAge = 0.0
		self.m_nWinOffset = self.m_nWinOffset + 1
		if self.m_nWinOffset > nTotalWinLines then
            self.m_nWinOffset = 1
        end
    end

	local wi = self.m_Manager.m_GameResult.m_listWins[self.m_nWinOffset] -- 从1开始的。。

	Debug.Assert(wi, self.m_nWinOffset)
    local ld = SlotsGameLua:GetLine(wi.m_nLineID)

    self:ShowPayLineEffect(wi.m_nLineID, wi.m_nMaxMatchReelID)

    self:InitCurPayLineEffectKeys(wi.m_nLineID, false, wi)
    self:checkNeedReusedHitLineEffect()

end

function DeckResultPayLines:GetGoSymbol(nReelId, nRowIndex)
	local nEffectKey = nReelId * self.m_Manager.m_nRowCount + nRowIndex
	local goSymbol = self.m_Manager.m_listReelLua[nReelId].m_listGoSymbol[nRowIndex]

	if AliceFunc.tableAliceSymbol[nReelId] then
		local nTargetRowIndex = AliceFunc.tableAliceSymbol[nReelId]
		if nRowIndex <= nTargetRowIndex and nRowIndex >= nTargetRowIndex - 4 then
			goSymbol = self.m_Manager.m_listReelLua[nReelId].m_listGoSymbol[nTargetRowIndex]

			if nTargetRowIndex >= SlotsGameLua.m_nRowCount then
				nEffectKey = nReelId * self.m_Manager.m_nRowCount + nTargetRowIndex + 100
			else
				nEffectKey = nReelId * self.m_Manager.m_nRowCount + nTargetRowIndex
			end
		end
	end		

	return nEffectKey, goSymbol
end

function DeckResultPayLines:GetGoSymbolPos(nReelId, nRowIndex)
	local nKey = nReelId * self.m_Manager.m_nRowCount + nRowIndex
	local goSymbol = self.m_Manager.m_listReelLua[nReelId].m_listGoSymbol[nRowIndex]

	local pos = goSymbol.transform.position
	return pos
end

return DeckResultPayLines