RedHatLevelUI = {}

function RedHatLevelUI:InitVariable()
    self.m_LeanTweenIDs = {}
    self.m_transform = nil

    self.m_RegisterLoadEffectNameTable = 
    {
        "lztukuaiEffect", "lztukuai2Effect", "lzDDFreeSpinEffect", "lzDDFreeSpin6X5Effect",
        "coinEffect", "ExtraSpinEffect1", "ExtraSpinEffect2", "ExtraSpinEffect3",
    }

    self.tableFixedGoSymbol = {}
end 

function RedHatLevelUI:initLevelUI()
    self:InitVariable()
    RedHatFunc:InitVariable()

    self.m_transform = ThemeVideoScene.mNewGameNodeParent:FindDeepChild("LevelBG")
    LuaAutoBindMonoBehaviour.Bind(self.m_transform.gameObject, self)

    self.mFreeSpinBeginSplashUI = require "Lua/ThemeVideo/RedHat/FreeSpinBeginSplashUI"
    self.mFreeSpinBeginSplashUI:Init()

    self.mFreeSpinAgainSplashUI = require "Lua/ThemeVideo/RedHat/FreeSpinAgainSplashUI"
    self.mFreeSpinAgainSplashUI:Init()

    self.mFreeSpinBonusBeginSplashUI = require "Lua/ThemeVideo/RedHat/FreeSpinBonusBeginSplashUI"
    self.mFreeSpinBonusBeginSplashUI:Init()

    self.mFreeSpinFinishSplashUI = require "Lua/ThemeVideo/RedHat/FreeSpinFinishSplashUI"
    self.mFreeSpinFinishSplashUI:Init()

    self.goBaseGameUI = self.m_transform:FindDeepChild("BaseGameUI").gameObject
    self.goBaseGameUI:SetActive(true)

    self.mDeckResultPayLines = require "Lua/ThemeVideo/RedHat/DeckResultPayLines"
    self.mDeckResultPayLines:Init(SlotsGameLua)

    self.goCollectTarget = self.m_transform:FindDeepChild("BaseGameUI/goCoinTargetLogo").gameObject
    self.goCollectFreeSpinTarget = self.m_transform:FindDeepChild("BaseGameUI/TextMeshProFreeSpinNum").gameObject
    self.textBonusFeatureFreeSpinCount = self.m_transform:FindDeepChild("BaseGameUI/TextMeshProFreeSpinNum"):GetComponent(typeof(TextMeshPro))

    self.goCollectProgressBar = self.m_transform:FindDeepChild("BaseGameUI/ProgressCoins").gameObject
    self.goCollectProgressBarAni = self.m_transform:FindDeepChild("BaseGameUI/ProgressCoins"):GetComponent(typeof(Unity.Animator))

    self.goCollectEnableMask = self.m_transform:FindDeepChild("BaseGameUI/CollectEnableMask").gameObject
    self.goFlyEndEffect = self.m_transform:FindDeepChild("BaseGameUI/hitCoinEffect").gameObject
    self.goProgressFullEffect = self.m_transform:FindDeepChild("BaseGameUI/progressFullEffect").gameObject

    self.tableBonusFeatureGoFixedWildType = {}
    for i = 1, 9 do
        self.tableBonusFeatureGoFixedWildType[i] = self.m_transform:FindDeepChild("BaseGameUI/stickyInfoLogos/type"..i).gameObject
    end 

end     

function RedHatLevelUI:Update()
    self.mDeckResultPayLines:ShowAllMatchLines()
    self.mDeckResultPayLines:DisplayMatchLinesInfo()
end 

function RedHatLevelUI:OnDestroy()
    self:CancelLeanTween()
    LuaHelper.ReleaseVariable(self)
    LuaHelper.ReleaseVariable(RedHatFunc)
end

function RedHatLevelUI:CancelLeanTween()
	local count = #self.m_LeanTweenIDs
	for i = 1, count do
		local id = self.m_LeanTweenIDs[i]
		if LeanTween.isTweening(id) then
			LeanTween.cancel(id)
		end
	end
	self.m_LeanTweenIDs = {}
end

function RedHatLevelUI:SetInteger(mAnimator, strKey, nAction)
    if mAnimator.gameObject.activeInHierarchy then
        if mAnimator:GetInteger(strKey) ~= nAction then
            mAnimator:SetInteger(strKey, nAction)
        end
    end
end

-- 查找某个符号的子节点，并缓存下来，高效可靠
function RedHatLevelUI:FindSymbolElement(goSymbol, strKey)
    local tablePoolKey = {"TextMeshProAddFreeSpin"}

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

            if strKey == "TextMeshProAddFreeSpin" then 
                self.goSymbolElementPool[goSymbol][strKey] = go:GetComponent(typeof(TextMeshPro))
            else
                self.goSymbolElementPool[goSymbol][strKey] = go
            end
        end
    end 
    
    return self.goSymbolElementPool[goSymbol][strKey]
end

function RedHatLevelUI:OnPreReelStop(nReelId)
    local reel = SlotsGameLua.m_listReelLua[nReelId]

    if SlotsGameLua.m_GameResult:InFreeSpin() then

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
        if self.m_ScatterEffectObj ~= nil then
            self:RecycleEffectToEffectPool(self.m_ScatterEffectObj)
            self.m_ScatterEffectObj = nil
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
            if RedHatSymbol:isScatterSymbol(nSymbolId) then
                local goSymbol = reel.m_listGoSymbol[i]
                LeanTween.scale(goSymbol, Unity.Vector3.one * 1.2, 0.15):setLoopPingPong(1)
                
                if not SpinButton.m_bUserStopSpin then
                    AudioHandler:PlayScatterStopSound(nReelId)
                elseif not RedHatFunc.m_bScatterSound then
                    AudioHandler:PlayScatterStopSound(nReelId)
                    RedHatFunc.m_bScatterSound = true
                end
            end
        end
    end

    if self.m_ScatterEffectObj ~= nil then
        self:RecycleEffectToEffectPool(self.m_ScatterEffectObj)
        self.m_ScatterEffectObj = nil
    end
        
    local bPlayingSlotFireSound = false
    --Scatter 着火开始
    if self:isNeedWaitingFreeSpin(nReelId) and not SpinButton.m_bUserStopSpin then
        self:PlayEffectWaitingFreeSpin(nReelId)
        bPlayingSlotFireSound = true
    else
        SlotsGameLua.m_bPlayingSlotFireSound = false
        AudioHandler:StopSlotsOnFire()
    end
end

function RedHatLevelUI:PlayEffectWaitingFreeSpin(nReelId)
    if nReelId >= SlotsGameLua.m_nReelCount- 1 then
        return 
    end

    local nNextReelID = nReelId + 1
    local effectPos = SlotsGameLua:getReelBGPosByReelID(nNextReelID)
    local effectType = enumEffectType.Effect_ScatterEffect
    local strEffectName = "lzDDFreeSpinEffect"
    if SlotsGameLua.m_GameResult:InFreeSpin() then
        strEffectName = "lzDDFreeSpin6X5Effect"
    end

    local goEffect = self:GetEffectByEffectPool(strEffectName)
    goEffect.transform:SetParent(SlotsGameLua.m_transform, false)
    goEffect.transform.localPosition = Unity.Vector3((nNextReelID - 2) * SlotsGameLua.m_fSymbolWidth, 0, 0)
    goEffect:SetActive(true)
    self.m_ScatterEffectObj = goEffect
        
    local fDisCoef = 3.9
    SlotsGameLua.m_listReelLua[nNextReelID].m_fRotateDistance = SlotsGameLua.m_fRotateDistance * fDisCoef
    if not SlotsGameLua.m_bPlayingSlotFireSound then
        SlotsGameLua.m_bPlayingSlotFireSound = true
        AudioHandler:PlaySlotsOnFire()
    end
end

function RedHatLevelUI:isScatterPossibleUseful(nReelId)
    local nScatterCount = 0
    local nReelCount = 0
    for x = 0, nReelId - 1 do
        local reel = SlotsGameLua.m_listReelLua[x]
        local bHaveScatter = false
        for i = 0, SlotsGameLua.m_nRowCount - 1 do
            local nSymbolId = reel.m_curSymbolIds[i]

            if RedHatSymbol:isScatterSymbol(nSymbolId) then
                nScatterCount = nScatterCount + 1
                bHaveScatter = true
            end
        end 
        
        if not bHaveScatter then
            break
        else
            nReelCount = nReelCount + 1
        end
    end     

    return nReelCount == nReelId
end

function RedHatLevelUI:isNeedWaitingFreeSpin(nReelId)
    if nReelId >= SlotsGameLua.m_nReelCount - 1 then
        return false
    end     
    
    local nScatterCount = 0
    local nReelCount = 0
    for x = 0, nReelId do
        nReelCount = nReelCount + 1
        local reel = SlotsGameLua.m_listReelLua[x]
        local bHaveScatter = false
        for i = 0, SlotsGameLua.m_nRowCount - 1 do
            local nSymbolId = reel.m_curSymbolIds[i]

            if RedHatSymbol:isScatterSymbol(nSymbolId) then
                nScatterCount = nScatterCount + 1
                bHaveScatter = true
                break
            end
        end

        if not bHaveScatter then
            break
        end
    end

    return nScatterCount >= 3 and nReelCount == nReelId + 1
end

function RedHatLevelUI:CheckRecoverInfo()
    self.mLeveData_3X5 = require "Lua/ThemeVideo/RedHat/LeveData_3X5"
    self.mLeveData_6X5 = require "Lua/ThemeVideo/RedHat/LeveData_6X5"
    self.mLeveData_3X5:Init()
    self.mLeveData_6X5:Init()
    self.mLeveData_3X5:Active()

    self:TotalBetChange()
    RedHatLevelUI:getDBCollectCount()
    RedHatLevelUI:getDBFreeSpin()
    if SlotsGameLua.m_GameResult:InFreeSpin() then
        self:PlayFreeSpinBeginHideAni()
    else
        if RedHatFunc.nFreeSpinFixedType == 0 then
            RedHatFunc:SwitchBonusFeatureFixedWildType()
        end
        
        if RedHatFunc:orInBonusFeatureFull() then
            RedHatFunc.nCollectCount = 0
            RedHatFunc.nCollectFreeSpinCount = 0
            RedHatFunc:SwitchBonusFeatureFixedWildType()
            self:setDBCollectCount()
        end

        self:ResetCollectProgressBarAni()
    end

end

function RedHatLevelUI:TotalBetChange()
    local totalBetList = GameLevelUtil:getTotalBetList()
    RedHatFunc.bBonusFeatureUnlock = SceneSlotGame.m_nTotalBet >= totalBetList[#totalBetList]
    self.goCollectEnableMask:SetActive(not RedHatFunc:orBonusFeatureUnlock())
end

-- 显示Scatter 特效 -- 统一使用播放spine动画的接口: PlayActiveAnimation(enumType, true, 1.0)
function RedHatLevelUI:ShowScatterBonusEffect()
    local nScatter1SymbolId = -1
    local nScatter2SymbolId = -1
    if SlotsGameLua.m_GameResult:InFreeSpin() and SlotsGameLua.m_GameResult.m_nFreeSpinCount > 0 then
        nScatter1SymbolId = SlotsGameLua:GetSymbolIdByObjName("Scatter12_1")
        nScatter2SymbolId = SlotsGameLua:GetSymbolIdByObjName("Scatter22_1")
    else
        nScatter1SymbolId = SlotsGameLua:GetSymbolIdByObjName("Scatter1")
        nScatter2SymbolId = SlotsGameLua:GetSymbolIdByObjName("Scatter2")
    end

    self.tableCollectScatter = {}
    for x = 0, SlotsGameLua.m_nReelCount - 1 do
        for y = 0, SlotsGameLua.m_nRowCount - 1 do
            local nKey = x * SlotsGameLua.m_nRowCount + y
            local reel = SlotsGameLua.m_listReelLua[x]

            local nSymbolId = reel.m_curSymbolIds[y]
            if nSymbolId == nScatter1SymbolId or nSymbolId == nScatter2SymbolId then
                local goSymbol = reel.m_listGoSymbol[y]
                self.tableCollectScatter[nKey] = goSymbol
            end
        end
    end                  

    for k, v in pairs(self.tableCollectScatter) do
        SymbolObjectPool.m_mapSpinEffect[v]:PlayAnimation("animation", 0.0, true)
    end
end

function RedHatLevelUI:handleFreeSpinBegin()
    local bDelayTime = 0.5
    local bPlayScatterAniTime = 1.35 * 2
    LeanTween.delayedCall(bDelayTime, function()
        if RedHatFunc:orInBonusFeatureFull() then
            if SlotsGameLua.m_GameResult.m_nFreeSpinCount > 0  then
                self:ShowScatterBonusEffect()
            end
        else
            self:ShowScatterBonusEffect()
        end

        if SlotsGameLua.m_GameResult.m_nFreeSpinCount == 0  then
            AudioHandler:PlayFreeGameTriggeredSound()
        else
            AudioHandler:PlayRetriggerSound()
        end

        LeanTween.delayedCall(bPlayScatterAniTime, function()
            if SlotsGameLua.m_GameResult.m_nFreeSpinCount == 0  then
                if RedHatFunc:orInBonusFeatureFull() then
                    self.mFreeSpinBonusBeginSplashUI:Show()
                else
                    self.mFreeSpinBeginSplashUI:Show()
                end
            else
                self.mFreeSpinAgainSplashUI:Show() 
            end
        end)
    end)

end 

function RedHatLevelUI:handleFreeSpinEnd()
    self.mFreeSpinFinishSplashUI:Show()
end

function RedHatLevelUI:PlayFreeSpinBeginHideAni()
    self.mDeckResultPayLines:MatchLineHide()

    self.goBaseGameUI:SetActive(false)
    self.mLeveData_3X5:DeActive()
    self.mLeveData_6X5:Active()
    
    if RedHatFunc:orInBonusFeatureFull() then
        for k, v in pairs(RedHatFunc.tableFreeSpinStickySymbol) do
            local nKey = v
            local nReelId = nKey // SlotsGameLua.m_nRowCount
            local nRowIndex = nKey % SlotsGameLua.m_nRowCount
            local nWildSymbolId = SlotsGameLua:GetSymbolIdByObjName("StickyWild_1")
            self:FixedSymbol(nWildSymbolId, nReelId, nRowIndex)
        end

        RedHatFunc.preTotalBet = SceneSlotGame.m_nTotalBet
        SceneSlotGame.m_nTotalBet = RedHatFunc:GetAverageBet()
        SceneSlotGame:UpdateTotalBetToUI("AVERAGE")
    end

end 

function RedHatLevelUI:PlayFreeSpinFinishHideAni()
    self.mDeckResultPayLines:MatchLineHide()
    for k, v in pairs(RedHatLevelUI.tableFixedGoSymbol) do
        SymbolObjectPool:Unspawn(v)
    end
    RedHatLevelUI.tableFixedGoSymbol = {}
    RedHatFunc.tableFreeSpinStickySymbol = {}
    RedHatLevelUI:setDBFreeSpin()
        
    RedHatLevelUI.goProgressFullEffect:SetActive(false)
    self.goBaseGameUI:SetActive(true)
    self.mLeveData_6X5:DeActive()
    self.mLeveData_3X5:Active()

    if RedHatFunc:orInBonusFeatureFull() then
        RedHatFunc.nCollectCount = 0
        RedHatFunc.nCollectFreeSpinCount = 0
        RedHatFunc:SwitchBonusFeatureFixedWildType()
        RedHatLevelUI:setDBCollectCount()
        RedHatFunc:ResetAverageBet()
        if RedHatFunc.preTotalBet then
            SceneSlotGame.m_nTotalBet = RedHatFunc.preTotalBet
        end
        SceneSlotGame:UpdateTotalBetToUI()
    end

    self:ResetCollectProgressBarAni()
end 

function RedHatLevelUI:PlayCollectProgressBarAni()
    local beginPosX = -900
    local endPosX = -220

    local fPercent = RedHatFunc.nCollectCount / RedHatFunc:GetBonusFeatureMaxCollectCount()
    local fNowPosX = self.goCollectProgressBar.transform.localPosition.x
    local fPosX = beginPosX * (1.0 - fPercent) + endPosX * fPercent
    LeanTween.value(fNowPosX, fPosX, 1.0):setOnUpdate(function(fValue)
        self.goCollectProgressBar.transform.localPosition = Unity.Vector3(fValue, 365, 0)
    end)

    local strStateName = self.goCollectProgressBarAni.runtimeAnimatorController.animationClips[0].name
    self.goCollectProgressBarAni:Play(strStateName, -1, 0.0)
    self.textBonusFeatureFreeSpinCount.text = RedHatFunc.nCollectFreeSpinCount + RedHatFunc:GetBonusFeatureInitFreeSpinCount()
    AudioHandler:PlayThemeSound("bonusCollectionFilled")
end

function RedHatLevelUI:ResetCollectProgressBarAni()
    local beginPosX = -900
    local endPosX = -220

    local fPercent = RedHatFunc.nCollectCount / RedHatFunc:GetBonusFeatureMaxCollectCount()
    local fPosX = beginPosX * (1.0 - fPercent) + endPosX * fPercent
    self.goCollectProgressBar.transform.localPosition = Unity.Vector3(fPosX, 365, 0)
    self.textBonusFeatureFreeSpinCount.text = RedHatFunc.nCollectFreeSpinCount + RedHatFunc:GetBonusFeatureInitFreeSpinCount()
end

function RedHatLevelUI:FillSymbol(nSymbolId, nReelId, nRowIndex)
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

function RedHatLevelUI:FixedSymbol(nSymbolId, nReelId, nRowIndex)
    local nKey = nReelId * SlotsGameLua.m_nRowCount + nRowIndex
    local goFixedBigSymbol = LevelCommonFunctions:SpawnSymbol(nSymbolId, nReelId, nRowIndex)
    goFixedBigSymbol.transform:SetParent(SlotsGameLua.m_goStickySymbolsDir.transform, false)
    goFixedBigSymbol.transform.position = SlotsGameLua.m_listReelLua[nReelId].m_listGoSymbol[nRowIndex].transform.position

    self.tableFixedGoSymbol[nKey] = goFixedBigSymbol
    CoroutineHelper.waitForEndOfFrame(function()
        self:SetModifyLayer(goFixedBigSymbol, 10, true)
    end)
    return goFixedBigSymbol
end

function RedHatLevelUI:ResetTotalWinToUI(fMoneyCount)
    SlotsGameLua.m_GameResult.m_fGameWin = fMoneyCount
    SceneSlotGame.m_SlotsNumberWins:End(fMoneyCount)
end

function RedHatLevelUI:UpdateTotalWinToUI(fAddMoneyCount, fAniTime)
    if fAniTime == nil then
        fAniTime = 1.0
    end

    SlotsGameLua.m_GameResult.m_fGameWin = SlotsGameLua.m_GameResult.m_fGameWin + fAddMoneyCount
    SceneSlotGame.m_fCurWinCoinTime = fAniTime
    SceneSlotGame:UpdateTotalWinToUI()
end

function RedHatLevelUI:CollectMoneyToDB(fAddMoneyCount)
    if SlotsGameLua.m_GameResult:InFreeSpin() then
        SlotsGameLua.m_GameResult.m_fFreeSpinTotalWins = SlotsGameLua.m_GameResult.m_fFreeSpinTotalWins + fAddMoneyCount
        LevelDataHandler:addFreeSpinTotalWin(ThemeLoader.themeKey, fAddMoneyCount)
    else
        PlayerHandler:AddCoin(fAddMoneyCount)
        LevelDataHandler:AddPlayerWinCoins(fAddMoneyCount)
    end
end

---------------------- 设置 符号 的层级 -----------------------------
function RedHatLevelUI:CacheSymbolElementLayer(goSymbol)
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

function RedHatLevelUI:SetModifyLayer(goSymbol, nOrder)
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

function RedHatLevelUI:GetEffectByEffectPool(strKey)
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

function RedHatLevelUI:RecycleEffectToEffectPool(UsedObj)
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
function RedHatLevelUI:setDBCollectCount()
	if LevelDataHandler.m_Data.mThemeData == nil then
		LevelDataHandler.m_Data.mThemeData = {}
    end

    LevelDataHandler.m_Data.mThemeData.nCollectFreeSpinCount = RedHatFunc.nCollectFreeSpinCount
    LevelDataHandler.m_Data.mThemeData.nCollectCount = RedHatFunc.nCollectCount
    LevelDataHandler.m_Data.mThemeData.nFreeSpinFixedType = RedHatFunc.nFreeSpinFixedType

    LevelDataHandler.m_Data.mThemeData.nSpinCount = RedHatFunc.nSpinCount
    LevelDataHandler.m_Data.mThemeData.nSumTotalBetCount = RedHatFunc.nSumTotalBetCount
    LevelDataHandler:persistentData()
end

function RedHatLevelUI:getDBCollectCount()
	if LevelDataHandler.m_Data.mThemeData == nil then
		return
	end

	if LevelDataHandler.m_Data.mThemeData.nCollectFreeSpinCount == nil then
		return
	end         

    RedHatFunc.nCollectFreeSpinCount = LevelDataHandler.m_Data.mThemeData.nCollectFreeSpinCount
    RedHatFunc.nCollectCount = LevelDataHandler.m_Data.mThemeData.nCollectCount
    RedHatFunc.nFreeSpinFixedType = LevelDataHandler.m_Data.mThemeData.nFreeSpinFixedType

    RedHatFunc.nSpinCount = LevelDataHandler.m_Data.mThemeData.nSpinCount
    RedHatFunc.nSumTotalBetCount = LevelDataHandler.m_Data.mThemeData.nSumTotalBetCount
end

function RedHatLevelUI:setDBFreeSpin()
    local strLevelName = ThemeLoader.themeKey
	if LevelDataHandler.m_Data.mThemeData == nil then
		LevelDataHandler.m_Data.mThemeData = {}
    end

    LevelDataHandler.m_Data.mThemeData.tableFreeSpinStickySymbol = RedHatFunc.tableFreeSpinStickySymbol
    setmetatable(LevelDataHandler.m_Data.mThemeData.tableFreeSpinStickySymbol, {__jsontype = "array"})
    LevelDataHandler:persistentData()
end

function RedHatLevelUI:getDBFreeSpin()
	if LevelDataHandler.m_Data.mThemeData == nil then
		return
	end

	if LevelDataHandler.m_Data.mThemeData.tableFreeSpinStickySymbol == nil then
		return
	end         

    RedHatFunc.tableFreeSpinStickySymbol = LevelDataHandler.m_Data.mThemeData.tableFreeSpinStickySymbol
end
