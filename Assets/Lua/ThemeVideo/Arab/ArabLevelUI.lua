ArabLevelUI = {}

function ArabLevelUI:InitVariable()
    self.m_LeanTweenIDs = {}
    self.m_transform = nil

    self.m_RegisterLoadEffectNameTable = {"gem1CollectEffect", "gem2CollectEffect", "gem3CollectEffect"}
    self.tableFixedGoSymbol = {}
end 

function ArabLevelUI:initLevelUI()
    self:InitVariable()
    ArabFunc:InitVariable()

    self.m_transform = ThemeVideoScene.mNewGameNodeParent:FindDeepChild("LevelBG")
    LuaAutoBindMonoBehaviour.Bind(self.m_transform.gameObject, self)

    self.mJackPotUI = require "Lua/ThemeVideo/Arab/JackPotUI"
    self.mJackPotUI:Init()
        
    self.mFreeSpinBeginSplashUI = require "Lua/ThemeVideo/Arab/FreeSpinBeginSplashUI"
    self.mFreeSpinBeginSplashUI:Init()
    
    self.mFreeSpinFinishSplashUI = require "Lua/ThemeVideo/Arab/FreeSpinFinishSplashUI"
    self.mFreeSpinFinishSplashUI:Init()

    self.mBonusGameBeginSplashUI = require "Lua/ThemeVideo/Arab/BonusGameBeginSplashUI"
    self.mBonusGameBeginSplashUI:Init()

    self.mBonusGameFinishSplashUI = require "Lua/ThemeVideo/Arab/BonusGameFinishSplashUI"
    self.mBonusGameFinishSplashUI:Init()

    self.mBonusGameUI = require "Lua/ThemeVideo/Arab/BonusGameUI"
    self.mBonusGameUI:Init()

    self.goGenFlyEndPos = self.m_transform:FindDeepChild("FlyEndPos").gameObject
    self.goGemProgressFullEffect = self.m_transform:FindDeepChild("GemProgressFullEffect").gameObject
    self.mProgressSpriteRenderer = self.m_transform:FindDeepChild("GemProgress/progress"):GetComponent(typeof(Unity.SpriteRenderer))

    self.goFreeSpinBackMask = self.m_transform:FindDeepChild("goFreeSpinBackMask").gameObject
    self.goFreeSpinBackMask:SetActive(false)
end     

function ArabLevelUI:Update()
    self.mJackPotUI:Update()
end 

function ArabLevelUI:OnDestroy()
    self:CancelLeanTween()
    LuaHelper.ReleaseVariable(self)
    LuaHelper.ReleaseVariable(ArabFunc)
end

function ArabLevelUI:CancelLeanTween()
	local count = #self.m_LeanTweenIDs
	for i=1, count do
		local id = self.m_LeanTweenIDs[i]
		if LeanTween.isTweening(id) then
			LeanTween.cancel(id)
		end
	end
	self.m_LeanTweenIDs = {}
end

function ArabLevelUI:SetInteger(mAnimator, strKey, nAction)
    if mAnimator.gameObject.activeInHierarchy then
        if mAnimator:GetInteger(strKey) ~= nAction then
            mAnimator:SetInteger(strKey, nAction)
        end
    end
end

-- 查找某个符号的子节点，并缓存下来，高效可靠
function ArabLevelUI:FindSymbolElement(goSymbol, strKey)
    local tablePoolKey = {"gem1", "gem2", "gem3", "TextMeshPro", "GrandClickEffect", "MajorClickEffect", "MinorClickEffect"}
    
    Debug.Assert(LuaHelper.tableContainsElement(tablePoolKey, strKey))
    if self.goSymbolElementPool == nil then
        self.goSymbolElementPool = {}
    end 

    if self.goSymbolElementPool[goSymbol] == nil then
        self.goSymbolElementPool[goSymbol] = {}
    end 

    if self.goSymbolElementPool[goSymbol][strKey] == nil then
        local goTran = goSymbol.transform:FindDeepChild(strKey)
        if goTran then
            local go = goTran.gameObject

            if strKey == "TextMeshPro" then 
                self.goSymbolElementPool[goSymbol][strKey] = go:GetComponent(typeof(TextMeshPro))
            else
                self.goSymbolElementPool[goSymbol][strKey] = go
            end
        end
    end 

    return self.goSymbolElementPool[goSymbol][strKey]
end

function ArabLevelUI:CheckRecoverInfo()
    ArabLevelUI:getDBCollectGemCount()

    self.tableCachePos = {}
    for i = 0, SlotsGameLua.m_nReelCount - 1 do
        for j = 0, SlotsGameLua.m_nRowCount * 2 - 1 do
            local nKey = i * SlotsGameLua.m_nRowCount + j
            local goSymbol = SlotsGameLua.m_listReelLua[i].m_listGoSymbol[j]
            self.tableCachePos[nKey] = goSymbol.transform.position
        end
    end

    for i = 0, SlotsGameLua.m_nReelCount - 1 do
        local reelLua = SlotsGameLua.m_listReelLua[i]
        local fPosX = (i - 2) * SlotsGameLua.m_fSymbolWidth
        reelLua.m_transform.localPosition = Unity.Vector3(fPosX, 0, 0)
    end

    ArabLevelUI:ResetGemProgressAni()

    if SlotsGameLua.m_GameResult:InFreeSpin() then
        self:PlayFreeSpinBeginHideAni()
    else

    end

end

-- 显示Scatter 特效 -- 统一使用播放spine动画的接口: PlayActiveAnimation(enumType, true, 1.0)
function ArabLevelUI:ShowScatterBonusEffect()
    self.tableCollectScatter = {}
    
    for x = 0, SlotsGameLua.m_nReelCount - 1 do
        for y = 0, SlotsGameLua.m_nRowCount - 1 do
            local nKey = x * SlotsGameLua.m_nRowCount + y
            local reel = SlotsGameLua.m_listReelLua[x]

            local nSymbolId = reel.m_curSymbolIds[y]
            if ArabSymbol:isScatterSymbol(nSymbolId) then
                local goSymbol = reel.m_listGoSymbol[y]
                self.tableCollectScatter[nKey] = goSymbol
            end
        end
    end                  

    for k, v in pairs(self.tableCollectScatter) do
        SymbolObjectPool.m_mapSpinEffect[v]:PlayAnimation("animation", 0.0, true)
    end
end

function ArabLevelUI:handleFreeSpinBegin()
    PayLinePayWaysEffectHandler:MatchLineHide()

    local bDelayTime = 0.5
    local bPlayScatterAniTime = 1.35 * 2
    LeanTween.delayedCall(bDelayTime, function()
        self:ShowScatterBonusEffect()

        if SlotsGameLua.m_GameResult.m_nFreeSpinCount == 0  then
            AudioHandler:PlayFreeGameTriggeredSound()
        else
            AudioHandler:PlayRetriggerSound()
        end

        LeanTween.delayedCall(bPlayScatterAniTime, function()
            self.mFreeSpinBeginSplashUI:Show()
        end)
    end)

end 

function ArabLevelUI:handleFreeSpinEnd()
    PayLinePayWaysEffectHandler:MatchLineHide()
    self.mFreeSpinFinishSplashUI:Show()
end

function ArabLevelUI:handleBonusGameBegin()
    LeanTween.delayedCall(2.0, function()
        self.mBonusGameBeginSplashUI:Show()
    end)
end

function ArabLevelUI:PlayFreeSpinBeginHideAni()
    self.goFreeSpinBackMask:SetActive(true)
end

function ArabLevelUI:PlayFreeSpinEndHideAni()
    self.goFreeSpinBackMask:SetActive(false)
end

function ArabLevelUI:ResetGemProgressAni()
    local fMaxWidth = 1315
    local fPercent = ArabFunc.nCollectGemCount / ArabConfig.N_MAX_COLLECT_GEM_COUNT
    fPercent = math.min(1.0, fPercent)
    fPercent = math.max(0.0, fPercent)
    local fTargetSizeX = fMaxWidth * fPercent

    local oriSize = self.mProgressSpriteRenderer.size
    self.mProgressSpriteRenderer.size = Unity.Vector2(fTargetSizeX, oriSize.y)
end

function ArabLevelUI:PlayGemProgressAni()
    local fMaxWidth = 1315
    local fPercent = ArabFunc.nCollectGemCount / ArabConfig.N_MAX_COLLECT_GEM_COUNT
    fPercent = math.min(1.0, fPercent)
    fPercent = math.max(0.0, fPercent)
    local fTargetSizeX = fMaxWidth * fPercent

    local oriSize = self.mProgressSpriteRenderer.size
    LeanTween.value(oriSize.x, fTargetSizeX, 0.3):setOnUpdate(function(fValue)
        self.mProgressSpriteRenderer.size = Unity.Vector2(fValue, oriSize.y)
    end)
end

function ArabLevelUI:RefreshCollectSymbol(go, nGemType, nMultuile)
    local goGem1 = ArabLevelUI:FindSymbolElement(go, "gem1")
    local goGem2 = ArabLevelUI:FindSymbolElement(go, "gem2")
    local goGem3 = ArabLevelUI:FindSymbolElement(go, "gem3")
    local textMoneyCount = ArabLevelUI:FindSymbolElement(go, "TextMeshPro")

    goGem1:SetActive(false)
    goGem2:SetActive(false)
    goGem3:SetActive(false)

    if nGemType == 1 then
        goGem1:SetActive(true)
    elseif nGemType == 2 then
        goGem2:SetActive(true)
    elseif nGemType == 3 then
        goGem3:SetActive(true)
    else
        Debug.Assert(false)
    end 

    if nMultuile > 0 then
        local nMoneyCount = nMultuile * SceneSlotGame.m_nTotalBet
        textMoneyCount.text = MoneyFormatHelper.coinCountOmit(nMoneyCount)
    else
        textMoneyCount.text = ""
    end

end

function ArabLevelUI:FillSymbol(nSymbolId, nReelId, nRowIndex)
    local preGoSymbol = SlotsGameLua.m_listReelLua[nReelId].m_listGoSymbol[nRowIndex]
    SymbolObjectPool:Unspawn(preGoSymbol)

    local newGO = LevelCommonFunctions:SpawnSymbol(nSymbolId, nReelId, nRowIndex)
    newGO.transform:SetParent(SlotsGameLua.m_listReelLua[nReelId].m_transform, false)
    newGO.transform.localScale = Unity.Vector3.one
    newGO.transform.localPosition = SlotsGameLua.m_listReelLua[nReelId].m_listSymbolPos[nRowIndex]

    SlotsGameLua.m_listReelLua[nReelId].m_listGoSymbol[nRowIndex] = newGO
    SlotsGameLua.m_listReelLua[nReelId].m_curSymbolIds[nRowIndex] = nSymbolId
    return newGO
end

function ArabLevelUI:FixedAliceSymbol(nSymbolId, nReelId, nRowIndex)
    local nKey = nReelId * SlotsGameLua.m_nRowCount + nRowIndex
    if nRowIndex >= SlotsGameLua.m_nRowCount then
        nKey = nKey + 100
    end

    if self.tableFixedGoSymbol[nKey] then
        return
    end

    local goFixedAliceSymbol = LevelCommonFunctions:SpawnSymbol(nSymbolId, nReelId, nRowIndex)
    local newSymbolParent = SlotsGameLua.m_transform
    goFixedAliceSymbol.transform:SetParent(newSymbolParent, false)
    goFixedAliceSymbol.transform.position = SlotsGameLua.m_listReelLua[nReelId].m_listGoSymbol[nRowIndex].transform.position

    self:SetModifyLayer(goFixedAliceSymbol, 0)
    self.tableFixedGoSymbol[nKey] = goFixedAliceSymbol
    return goFixedAliceSymbol
end

function ArabLevelUI:ResetTotalWinToUI(fMoneyCount)
    SlotsGameLua.m_GameResult.m_fGameWin = fMoneyCount
    SceneSlotGame.m_SlotsNumberWins:End(fMoneyCount)
end

function ArabLevelUI:UpdateTotalWinToUI(fAddMoneyCount, fAniTime)
    if fAniTime == nil then
        fAniTime = 1.0
    end

    SlotsGameLua.m_GameResult.m_fGameWin = SlotsGameLua.m_GameResult.m_fGameWin + fAddMoneyCount
    SceneSlotGame.m_fCurWinCoinTime = fAniTime
    SceneSlotGame:UpdateTotalWinToUI()
end

function ArabLevelUI:CollectMoneyToDB(fAddMoneyCount)
    if SlotsGameLua.m_GameResult:InFreeSpin() then
        SlotsGameLua.m_GameResult.m_fFreeSpinTotalWins = SlotsGameLua.m_GameResult.m_fFreeSpinTotalWins + fAddMoneyCount
        LevelDataHandler:addFreeSpinTotalWin(ThemeLoader.themeKey, fAddMoneyCount)
    else
        PlayerHandler:AddCoin(fAddMoneyCount)
        LevelDataHandler:AddPlayerWinCoins(fAddMoneyCount)
    end
end

---------------------- 设置 符号 的层级 -----------------------------
function ArabLevelUI:CacheSymbolElementLayer(goSymbol)
    if not self.mapGoSortingOrder then
        self.mapGoSortingOrder = {}
    end

    if not self.mapGoSortingOrder[goSymbol] then
        self.mapGoSortingOrder[goSymbol] = {}
    end

    if not self.mapGoNeedGetOrder then
        self.mapGoNeedGetOrder = {}
    end

    if not self.mapGoNeedGetOrder[goSymbol] then
        local curveItemList = LuaHelper.GetComponentsInChildren(goSymbol, typeof(Unity.Renderer))
        self.mapGoNeedGetOrder[goSymbol] = curveItemList
    end

    if LuaHelper.tableSize(self.mapGoNeedGetOrder[goSymbol]) > 0 then
        local tableAdd = {}
        for k, v in pairs(self.mapGoNeedGetOrder[goSymbol]) do
            if v.gameObject.activeInHierarchy then
                tableAdd[k] = v
            end
        end

        for k, v in pairs(tableAdd) do
            self.mapGoSortingOrder[goSymbol][v] = v.sortingOrder
            self.mapGoNeedGetOrder[goSymbol][k] = nil
        end 

        --Debug.Log("Cache Symbol "..goSymbol.name.." : "..LuaHelper.tableSize(self.mapGoNeedGetOrder[goSymbol]))
    end

end

function ArabLevelUI:SetModifyLayer(goSymbol, nOrder)
    self:CacheSymbolElementLayer(goSymbol)

    local nMinOrder = 100000000
    local elementTable = self.mapGoSortingOrder[goSymbol]
    for k, v in pairs(elementTable) do
        if v < nMinOrder then
            nMinOrder = v
        end
    end

    local elementTable = self.mapGoSortingOrder[goSymbol]
    for k, v in pairs(elementTable) do
        k.sortingOrder = v - nMinOrder + nOrder
    end
end 

--=--------------------------- Simple Effect Pool -----------------------------------

function ArabLevelUI:GetEffectByEffectPool(strKey)
    Debug.Assert(LuaHelper.tableContainsElement(self.m_RegisterLoadEffectNameTable, strKey), strKey)

    if not self.EffectPool then
        self.EffectPool = {}
    end

    if not self.EffectPool[strKey] then
        self.EffectPool[strKey] = {}
    end

    local UsedObj =  table.remove(self.EffectPool[strKey])
    if UsedObj then
        return UsedObj
    else
        local assetPath = "SpecialEffectAnimation/"..strKey..".prefab"
        local goPrefab = AssetBundleHandler:LoadThemeAsset(assetPath, typeof(Unity.GameObject))

        for i = 1, 2 do
            local obj = Unity.Object.Instantiate(goPrefab)
            obj.transform:SetParent(self.m_transform, false)
            obj:SetActive(false)

            table.insert(self.EffectPool[strKey], obj)
        end
        
        return self:GetEffectByEffectPool(strKey)
    end
end	

function ArabLevelUI:RecycleEffectToEffectPool(UsedObj)
    UsedObj.transform:SetParent(self.m_transform, false)
    UsedObj:SetActive(false)
    local assetNameTable = self.m_RegisterLoadEffectNameTable
    for k, v in pairs(assetNameTable) do
        if string.match(UsedObj.name, v) then
            table.insert(self.EffectPool[v], UsedObj)
            return 
        end
    end

    Debug.Assert(false, "RecycleEffectToEffectPool Error: "..UsedObj.name)
end

------==================================== 数据库 ===========================================  
function ArabLevelUI:setDBCollectGemCount()
    LevelDataHandler.m_Data.mThemeData.nCollectGemCount = ArabFunc.nCollectGemCount
    LevelDataHandler:persistentData()
end

function ArabLevelUI:getDBCollectGemCount()
    if LevelDataHandler.m_Data.mThemeData.nCollectGemCount ~= nil then
        ArabFunc.nCollectGemCount = LevelDataHandler.m_Data.mThemeData.nCollectGemCount
    end
end
