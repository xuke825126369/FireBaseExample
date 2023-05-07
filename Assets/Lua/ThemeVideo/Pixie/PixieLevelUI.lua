PixieLevelUI = {}

function PixieLevelUI:InitVariable()
    self.m_LeanTweenIDs = {}
    self.m_transform = nil

    self.m_RegisterLoadEffectNameTable = {"TXWildFly", "lztukuai"}
    self.tableFixedGoSymbol = {}
end 

function PixieLevelUI:initLevelUI()
    self:InitVariable()
    PixieFunc:InitVariable()

    self.m_transform = ThemeVideoScene.mNewGameNodeParent:FindDeepChild("LevelBG")
    LuaAutoBindMonoBehaviour.Bind(self.m_transform.gameObject, self)

    self.mFreeSpinBeginSplashUI = require "Lua/ThemeVideo/Pixie/FreeSpinBeginSplashUI"
    self.mFreeSpinBeginSplashUI:Init()

    self.mFreeSpinFinishSplashUI = require "Lua/ThemeVideo/Pixie/FreeSpinFinishSplashUI"
    self.mFreeSpinFinishSplashUI:Init()

    self.mDeckResultPayLines = require "Lua/ThemeVideo/Pixie/DeckResultPayLines"
    self.mDeckResultPayLines:Init(SlotsGameLua)

end     

function PixieLevelUI:Update()
    self.mDeckResultPayLines:ShowAllMatchLines()
    self.mDeckResultPayLines:DisplayMatchLinesInfo()
end 

function PixieLevelUI:OnDestroy()
    self:CancelLeanTween()
    LuaHelper.ReleaseVariable(self)
    LuaHelper.ReleaseVariable(PixieFunc)
end

function PixieLevelUI:CancelLeanTween()
	local count = #self.m_LeanTweenIDs
	for i = 1, count do
		local id = self.m_LeanTweenIDs[i]
		if LeanTween.isTweening(id) then
			LeanTween.cancel(id)
		end
	end
	self.m_LeanTweenIDs = {}
end

function PixieLevelUI:SetInteger(mAnimator, strKey, nAction)
    if mAnimator.gameObject.activeInHierarchy then
        if mAnimator:GetInteger(strKey) ~= nAction then
            mAnimator:SetInteger(strKey, nAction)
        end
    end
end

-- 查找某个符号的子节点，并缓存下来，高效可靠
function PixieLevelUI:FindSymbolElement(goSymbol, strKey)
    local tablePoolKey = {"wildInfo"}
    
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

function PixieLevelUI:OnPreReelStop(nReelId)
    local reel = SlotsGameLua.m_listReelLua[nReelId]

    if SlotsGameLua.m_GameResult:InFreeSpin() then
        if not PixieFunc.tableFreeSpinStickyBigSymbol[nReelId] and PixieFunc.tableBigSymbol[nReelId] then
            local nRowIndex = PixieFunc.tableBigSymbol[nReelId][1]
            local nSymbolId = PixieFunc.tableBigSymbol[nReelId][2]
            if nSymbolId == PixieFunc.nFreeSpinSelectBigSymbolId then
                local goSymbol = SlotsGameLua.m_listReelLua[nReelId].m_listGoSymbol[nRowIndex]
                local goWildInfo = PixieLevelUI:FindSymbolElement(goSymbol, "wildInfo")
                goWildInfo:SetActive(true)
            end
        end
    end

    local bAllReelFixedSymbol = true
    for i = 0, SlotsGameLua.m_nRowCount - 1 do
        local bStickyFlag, nStickyIndex = reel:isStickyPos(i)
        if not bStickyFlag then
            bAllReelFixedSymbol = false
            break
        end
    end 

    if SpinButton.m_bUserStopSpin then
        AudioHandler:StopSlotsOnFire()
        if reel.m_ScatterEffectObj ~= nil then -- 这列都停了，如果上一列有着火特效也马上停掉。。（绕着列转大圈圈的特效）
            reel.m_ScatterEffectObj:reuseCacheEffect()
            reel.m_ScatterEffectObj = nil
        end
    end 
    
    --播放 列停止声音
    if not SpinButton.m_bUserStopSpin then
        if not LevelCommonFunctions:isStopReel(nReelId) and not bAllReelFixedSymbol then
            AudioHandler:PlayReelStopSound(nReelId)
        end
    elseif nReelId == SlotsGameLua.m_nReelCount - 1 then
        AudioHandler:PlayReelStopSound(nReelId)
    end

    --scatter 列停止动画
    if self:isScatterPossibleUseful(nReelId) then
        for i = 0, SlotsGameLua.m_nRowCount - 1 do
            local nSymbolId = reel.m_curSymbolIds[i]
            if PixieSymbol:isScatterSymbol(nSymbolId) then
                local goSymbol = reel.m_listGoSymbol[i]
                LeanTween.scale(goSymbol, Unity.Vector3.one * 1.2, 0.15):setLoopPingPong(1)

                self:SetModifyLayer(goSymbol, 50)
                LeanTween.delayedCall(1.0, function()
                    self:SetModifyLayer(goSymbol, -24)
                end)
                
                if not SpinButton.m_bUserStopSpin then
                    AudioHandler:PlayScatterStopSound(nReelId)
                elseif not PixieFunc.m_bScatterSound then
                    AudioHandler:PlayScatterStopSound(nReelId)
                    PixieFunc.m_bScatterSound = true
                end
            end
        end
    end

    local bPlayingSlotFireSound = false
    --Scatter 着火开始
    if self:isNeedWaitingFreeSpin(nReelId) and not SpinButton.m_bUserStopSpin then
        reel:PlayEffectWaitingFreeSpin()
        bPlayingSlotFireSound = true
    else
        SlotsGameLua.m_bPlayingSlotFireSound = false
        AudioHandler:StopSlotsOnFire()
    end

    if reel.m_ScatterEffectObj ~= nil then -- 这列都停了，如果上一列有着火特效也马上停掉。。（绕着列转大圈圈的特效）
        reel.m_ScatterEffectObj:reuseCacheEffect()
        reel.m_ScatterEffectObj = nil
    end
end

function PixieLevelUI:isScatterPossibleUseful(nReelId)
    local nScatterCount = 0
    for x = 0, nReelId - 1 do
        local reel = SlotsGameLua.m_listReelLua[x]
        for i = 0, SlotsGameLua.m_nRowCount - 1 do
            local nSymbolId = reel.m_curSymbolIds[i]

            if PixieSymbol:isScatterSymbol(nSymbolId) then
                nScatterCount = nScatterCount + 1
                break
            end
        end
    end     

    return nScatterCount + SlotsGameLua.m_nReelCount - nReelId >= 3
end

function PixieLevelUI:isNeedWaitingFreeSpin(nReelId)
    if nReelId >= SlotsGameLua.m_nReelCount - 1 then
        return false
    end     

    local nScatterCount = 0
    for x = 0, nReelId do
        local reel = SlotsGameLua.m_listReelLua[x]
        for i = 0, SlotsGameLua.m_nRowCount - 1 do
            local nSymbolId = reel.m_curSymbolIds[i]

            if PixieSymbol:isScatterSymbol(nSymbolId) then
                nScatterCount = nScatterCount + 1
                break
            end
        end
    end

    return nScatterCount >= 2
end

function PixieLevelUI:CheckRecoverInfo()
    self.tableCachePos = {}
    for i = 0, SlotsGameLua.m_nReelCount - 1 do
        self.tableCachePos[i] = {}
        for j = 0, SlotsGameLua.m_nRowCount * 2 - 1 do
            local goSymbol = SlotsGameLua.m_listReelLua[i].m_listGoSymbol[j]
            self.tableCachePos[i][j] = goSymbol.transform.position
        end
    end 

    if not SlotsGameLua.m_TestGameResult:InFreeSpin() then
        for i = 0, SlotsGameLua.m_nReelCount - 1 do
            for j = 0, SlotsGameLua.m_nRowCount * 2 - 1 do
                local nKey = i * SlotsGameLua.m_nRowCount + j
                local goSymbol = SlotsGameLua.m_listReelLua[i].m_listGoSymbol[j]
                if i <= 3 then
                    if j == SlotsGameLua.m_nRowCount - 1 then
                        if i == 0 then
                            local nSymbolId = SlotsGameLua:GetSymbolIdByObjName("PixieBlueA_1")
                            self:FillSymbol(nSymbolId, i, j)
                        elseif i == 1 then
                            local nSymbolId = SlotsGameLua:GetSymbolIdByObjName("PixieGreenB_1")
                            self:FillSymbol(nSymbolId, i, j)
                        elseif i == 2 then
                            local nSymbolId = SlotsGameLua:GetSymbolIdByObjName("PixieRedC_1")
                            self:FillSymbol(nSymbolId, i, j)
                        elseif i == 3 then
                            local nSymbolId = SlotsGameLua:GetSymbolIdByObjName("PixieYellowD_1")
                            self:FillSymbol(nSymbolId, i, j)
                        end
                    elseif j < SlotsGameLua.m_nRowCount - 1 then
                        local nSymbolId = SlotsGameLua:GetSymbolIdByObjName("Symbol_null")
                        self:FillSymbol(nSymbolId, i, j)
                    end
                else
                    local nSymbolId = PixieSymbol:GetCommonSymbolIdByReelId(i)
                    while PixieSymbol:isBigSymbol(nSymbolId) do
                        nSymbolId = PixieSymbol:GetCommonSymbolIdByReelId(i)
                    end
                    self:FillSymbol(nSymbolId, i, j)
                end
            end

            for j = SlotsGameLua.m_nRowCount, SlotsGameLua.m_nRowCount * 2 - 1 do
                local nSymbolId = PixieSymbol:GetCommonSymbolIdByReelId(i)
                while PixieSymbol:isBigSymbol(nSymbolId) do
                    nSymbolId = PixieSymbol:GetCommonSymbolIdByReelId(i)
                end
                self:FillSymbol(nSymbolId, i, j)
            end
        end
    end

    PixieLevelUI:getDBFreeSpin()
    if SlotsGameLua.m_GameResult:InFreeSpin() then
        if PixieFunc.nFreeSpinSelectBigSymbolId == -1 then
            SlotsGameLua.m_bSplashFlags[SplashType.FreeSpin] = true
            SlotsGameLua.m_bInResult = true
            SlotsGameLua.m_bInSplashShow = true
            SlotsGameLua.m_nSplashActive = SplashType.FreeSpin

            self.mFreeSpinBeginSplashUI:Show()
        else
            self:PlayFreeSpinBeginHideAni()
        end
    end

end

-- 显示Scatter 特效 -- 统一使用播放spine动画的接口: PlayActiveAnimation(enumType, true, 1.0)
function PixieLevelUI:ShowScatterBonusEffect()
    self.tableCollectScatter = {}

    for x = 0, SlotsGameLua.m_nReelCount - 1 do
        for y = 0, SlotsGameLua.m_nRowCount - 1 do
            local nKey = x * SlotsGameLua.m_nRowCount + y
            local reel = SlotsGameLua.m_listReelLua[x]

            local nSymbolId = reel.m_curSymbolIds[y]
            if PixieSymbol:isScatterSymbol(nSymbolId) then
                local goSymbol = reel.m_listGoSymbol[y]
                self.tableCollectScatter[nKey] = goSymbol
            end
        end
    end                  

    for k, v in pairs(self.tableCollectScatter) do
        SymbolObjectPool.m_mapMultiClipEffect[v]:playAniByPlayMode(1)
    end
end

function PixieLevelUI:handleFreeSpinBegin()
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
            if SlotsGameLua.m_GameResult.m_nFreeSpinCount == 0  then
                self.mFreeSpinBeginSplashUI:Show()
            else
                self.mFreeSpinAgainSplashUI:Show() 
            end
        end)
    end)

end 

function PixieLevelUI:handleFreeSpinEnd()
    PayLinePayWaysEffectHandler:MatchLineHide()
    self.mFreeSpinFinishSplashUI:Show()
end

function PixieLevelUI:PlayFreeSpinBeginHideAni()
    for k, v in pairs(PixieFunc.tableFreeSpinStickyBigSymbol) do
        local nReelId = k
        local nRowIndex = v[1]
        local nSymbolId = v[2]
        self:FixedBigSymbol(nSymbolId, nReelId, nRowIndex)
    end
end 

function PixieLevelUI:PlayFreeSpinFinishHideAni()
    for x = 0, SlotsGameLua.m_nReelCount - 1 do
        for y = 0, SlotsGameLua.m_nRowCount * 2 - 1 do
            if PixieLevelUI.tableFixedGoSymbol[x] and PixieLevelUI.tableFixedGoSymbol[x][y] then
                local goFixedSymbol = PixieLevelUI.tableFixedGoSymbol[x][y]
                SymbolObjectPool:Unspawn(goFixedSymbol)
            end
        end
    end
    PixieLevelUI.tableFixedGoSymbol = {}
    PixieFunc.tableFreeSpinStickyBigSymbol = {}
end 

function PixieLevelUI:FillSymbol(nSymbolId, nReelId, nRowIndex)
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

function PixieLevelUI:FixedBigSymbol(nSymbolId, nReelId, nRowIndex)
    local nKey = nReelId * SlotsGameLua.m_nRowCount + nRowIndex
    local goFixedBigSymbol = LevelCommonFunctions:SpawnSymbol(nSymbolId, nReelId, nRowIndex)
    goFixedBigSymbol.transform:SetParent(SlotsGameLua.m_goStickySymbolsDir.transform, false)
    goFixedBigSymbol.transform.position = SlotsGameLua.m_listReelLua[nReelId].m_listGoSymbol[nRowIndex].transform.position

    if not self.tableFixedGoSymbol[nReelId] then
        self.tableFixedGoSymbol[nReelId] = {}
    end
    self.tableFixedGoSymbol[nReelId][nRowIndex] = goFixedBigSymbol

    local goWildInfo = PixieLevelUI:FindSymbolElement(goFixedBigSymbol, "wildInfo")
    goWildInfo:SetActive(true)
    CoroutineHelper.waitForEndOfFrame(function()
        self:SetModifyLayer(goFixedBigSymbol, 10, true)
    end)

    return goFixedBigSymbol
end

function PixieLevelUI:ResetTotalWinToUI(fMoneyCount)
    SlotsGameLua.m_GameResult.m_fGameWin = fMoneyCount
    SceneSlotGame.m_SlotsNumberWins:End(fMoneyCount)
end

function PixieLevelUI:UpdateTotalWinToUI(fAddMoneyCount, fAniTime)
    if fAniTime == nil then
        fAniTime = 1.0
    end

    SlotsGameLua.m_GameResult.m_fGameWin = SlotsGameLua.m_GameResult.m_fGameWin + fAddMoneyCount
    SceneSlotGame.m_fCurWinCoinTime = fAniTime
    SceneSlotGame:UpdateTotalWinToUI()
end

function PixieLevelUI:CollectMoneyToDB(fAddMoneyCount)
    if SlotsGameLua.m_GameResult:InFreeSpin() then
        SlotsGameLua.m_GameResult.m_fFreeSpinTotalWins = SlotsGameLua.m_GameResult.m_fFreeSpinTotalWins + fAddMoneyCount
        LevelDataHandler:addFreeSpinTotalWin(ThemeLoader.themeKey, fAddMoneyCount)
    else
        PlayerHandler:AddCoin(fAddMoneyCount)
        LevelDataHandler:AddPlayerWinCoins(fAddMoneyCount)
    end
end

---------------------- 设置 符号 的层级 -----------------------------
function PixieLevelUI:CacheSymbolElementLayer(goSymbol)
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
    end

end

function PixieLevelUI:SetModifyLayer(goSymbol, nOrder)
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

function PixieLevelUI:GetEffectByEffectPool(strKey)
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

function PixieLevelUI:RecycleEffectToEffectPool(UsedObj)
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

-------------------------------------------- ReSpin 记录 -----------------------------------------------
function PixieLevelUI:setDBFreeSpin()
    local strLevelName = ThemeLoader.themeKey
	if LevelDataHandler.m_Data.mThemeData == nil then
		LevelDataHandler.m_Data.mThemeData = {}
    end 

    LevelDataHandler.m_Data.mThemeData.nFreeSpinSelectBigSymbolId = PixieFunc.nFreeSpinSelectBigSymbolId

    local tableFreeSpinStickyBigSymbol = {}
    for k, v in pairs(PixieFunc.tableFreeSpinStickyBigSymbol) do
        local nReelId = k
        table.insert(tableFreeSpinStickyBigSymbol, {nReelId, v[1], v[2]})
    end
    LevelDataHandler.m_Data.mThemeData.tableFreeSpinStickyBigSymbol = tableFreeSpinStickyBigSymbol

    setmetatable(LevelDataHandler.m_Data.mThemeData.tableFreeSpinStickyBigSymbol, {__jsontype = "array"})
    LevelDataHandler:persistentData()
end

function PixieLevelUI:getDBFreeSpin()
	if LevelDataHandler.m_Data.mThemeData == nil then
		return
	end

	if LevelDataHandler.m_Data.mThemeData.nFreeSpinSelectBigSymbolId == nil then
		return
	end         

    PixieFunc.nFreeSpinSelectBigSymbolId = LevelDataHandler.m_Data.mThemeData.nFreeSpinSelectBigSymbolId
    local tableFreeSpinStickyBigSymbol = LevelDataHandler.m_Data.mThemeData.tableFreeSpinStickyBigSymbol
    for k, v in pairs(tableFreeSpinStickyBigSymbol) do
        PixieFunc.tableFreeSpinStickyBigSymbol[v[1]] = {v[2], v[3]}
    end

end
