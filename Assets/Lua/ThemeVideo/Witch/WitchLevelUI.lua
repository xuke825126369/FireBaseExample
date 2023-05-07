WitchLevelUI = {}

function WitchLevelUI:InitVariable()
    self.m_LeanTweenIDs = {}
    self.m_transform = nil

    self.m_RegisterLoadEffectNameTable = {}
    self.mReSpinFinishCollectMoneyCououtine = nil
    self.tableNowbGetJackPot = {false, false, false, false}
    self.tableNowJackPotMoneyCount = {0, 0, 0, 0}
    self.bUseReSpinCurveGroup = false

    self.tableReSpinFixedCollectGoSymbol = {} --普通宙斯 收集的符号
    self.mMergeSymbolGroup = nil

    self.bReSpinReel0TriggerEffectFinish = false
    self.mReSpinPlayPowerUpAniCououtine = nil

    self.m_goResetEffect = nil
end

function WitchLevelUI:initLevelUI()
    self:InitVariable()
    WitchFunc:InitVariable()

    self.m_transform = ThemeVideoScene.mNewGameNodeParent:FindDeepChild("LevelBG")
    LuaAutoBindMonoBehaviour.Bind(self.m_transform.gameObject, self)

    self.mLeveData_Normal = require "Lua/ThemeVideo/Witch/LeveData_Normal"
    self.mLeveData_Normal:InitVariable()
    self.mLeveData_ReSpin = require "Lua/ThemeVideo/Witch/LeveData_ReSpin"
    self.mLeveData_ReSpin:InitVariable()

    self.mJackPotUI = require "Lua/ThemeVideo/Witch/JackPotUI"
    self.mJackPotUI:Init()

    self.mFreeSpinBeginSplashUI = require "Lua/ThemeVideo/Witch/FreeSpinBeginSplashUI"
    self.mFreeSpinBeginSplashUI:Init()

    self.mFreeSpinAgainSplashUI = require "Lua/ThemeVideo/Witch/FreeSpinAgainSplashUI"
    self.mFreeSpinAgainSplashUI:Init()

    self.mFreeSpinFinishSplashUI = require "Lua/ThemeVideo/Witch/FreeSpinFinishSplashUI"
    self.mFreeSpinFinishSplashUI:Init()

    self.mJackPotGrandSplashUI = require "Lua/ThemeVideo/Witch/JackPotGrandSplashUI"
    self.mJackPotGrandSplashUI:Init()

    self.mReSpinFinishSplashUI = require "Lua/ThemeVideo/Witch/ReSpinFinishSplashUI"
    self.mReSpinFinishSplashUI:Init()

    self.mDefaultCurveGroup = ThemeVideoScene.mNewGameNodeParent:FindDeepChild("LevelData"):GetComponent(typeof(CS.CurveGroup))
    self.mMergeSymbolGroup = self.m_transform:FindDeepChild("MaskGroup"):GetComponent(typeof(CS.CurveGroup))
    self.mMergeSymbolGroup.gameObject:SetActive(true)

    self.goRespinFenge_Normal = self.m_transform:FindDeepChild("RespinFenge_Normal").gameObject
    self.goRespinFenge_Normal:SetActive(false)
    
    self.goRespinFenge_FreeSpin = self.m_transform:FindDeepChild("RespinFenge_FreeSpin").gameObject
    self.goRespinFenge_FreeSpin:SetActive(false)

    self.goReSpinTitle = self.m_transform:FindDeepChild("RespinTip").gameObject
    self.goReSpinTitle:SetActive(false)

    self.m_goResetEffect = self.goReSpinTitle.transform:FindDeepChild("goResetEffect").gameObject
    self.m_goResetEffect:SetActive(false)

    self.textReSpinCount = self.m_transform:FindDeepChild("RespinTip/TextMeshProReSpinValue"):GetComponent(typeof(TextMeshPro))

    self.goReSpinGrayBg = self.m_transform:FindDeepChild("ReSpinBG").gameObject
    self.goReSpinGrayBg:SetActive(false)

end 

function WitchLevelUI:Update()
    self.mJackPotUI:Update()
end

function WitchLevelUI:OnDestroy()
    self:CancelLeanTween()
    LuaHelper.ReleaseVariable(self)
    LuaHelper.ReleaseVariable(WitchFunc)
end

function WitchLevelUI:CancelLeanTween()
	local count = #self.m_LeanTweenIDs
	for i=1, count do
		local id = self.m_LeanTweenIDs[i]
		if LeanTween.isTweening(id) then
			LeanTween.cancel(id)
		end
	end
	self.m_LeanTweenIDs = {}
end

function WitchLevelUI:SetInteger(mAnimator, strKey, nAction)
    if mAnimator.gameObject.activeInHierarchy then
        if mAnimator:GetInteger(strKey) ~= nAction then
            mAnimator:SetInteger(strKey, nAction)
        end
    end
end

-- 查找某个符号的子节点，并缓存下来，高效可靠
function WitchLevelUI:FindSymbolElement(goSymbol, strKey)
    local tablePoolKey = {"TextCoinValue", "MINI", "MINOR", "MAJOR", "Mask", "MagicBallInfo"}
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

            if strKey == "TextCoinValue" or strKey == "MINI" or strKey == "MINOR" or strKey == "MAJOR" then
                self.goSymbolElementPool[goSymbol][strKey] = go:GetComponent(typeof(TextMeshPro))
            elseif strKey == "MagicBallInfo" then
                self.goSymbolElementPool[goSymbol][strKey] = go:GetComponent(typeof(Unity.Animator))
            else
                self.goSymbolElementPool[goSymbol][strKey] = go
            end

        end
    end

    return self.goSymbolElementPool[goSymbol][strKey]
end

function WitchLevelUI:CheckRecoverInfo()
    self:AddSymbolPools()

    self.mLeveData_Normal:Init()
    self.mLeveData_ReSpin:Init()
    self.mLeveData_Normal:Active()

    self:InitReSpinMask()
    self:InitDeckUI()
    
    WitchLevelUI:getDBReSpin()
    if WitchFunc.bInReSpin then
        if WitchFunc.nRemainReSpinSpinCount <= 0 then
            local fAddMoneyCount = WitchFunc:GetReSpinMoneyCount(SlotsGameLua.m_GameResult)

            self:CollectMoneyToDB(fAddMoneyCount)
            self:UpdateCollectMoneyToUI(fAddMoneyCount, 1.0)
            WitchFunc.bInReSpin = false
            WitchFunc:CancelAllReSpinFixedSymbol()

            UITop:updateCoinCountInUi(1.0)

            self.bUseReSpinCurveGroup = false
            self:setDBReSpin()
        else
            for i = 1, 4 do
                WitchLevelUI.tableNowbGetJackPot[i] = false
                WitchLevelUI.tableNowJackPotMoneyCount[i] = WitchLevelUI.mJackPotUI:GetTotalJackPotValue(i)
            end 

            SlotsGameLua.m_GameResult.m_nReSpinCount = 3 - WitchFunc.nRemainReSpinSpinCount
            SlotsGameLua.m_GameResult.m_nReSpinTotalCount = 3

            WitchLevelUI:RecoverReSpinUI()
        end
    end
end

function WitchLevelUI:RecoverReSpinUI()
    self.goRespinFenge_Normal:SetActive(false)
    self.goRespinFenge_FreeSpin:SetActive(false)
    if SlotsGameLua.m_GameResult:InFreeSpin() then
        self.goRespinFenge_FreeSpin:SetActive(true)
    else
        self.goRespinFenge_Normal:SetActive(true)
    end

    self.goReSpinTitle:SetActive(true)
    self.goReSpinGrayBg:SetActive(true)
    self:SetReSpinRemainCount(SlotsGameLua.m_GameResult.m_nReSpinTotalCount - SlotsGameLua.m_GameResult.m_nReSpinCount)

    self:ResetNormalToReSpinUI1()

    AudioHandler:LoadAndPlayRespinGameMusic()

    CoroutineHelper.waitForEndOfFrame(function()
        SceneSlotGame:ButtonEnable(false)
        SceneSlotGame.m_btnSpin.interactable = false
    end)
end

function WitchLevelUI:InitDeckUI()

    for i = 0, SlotsGameLua.m_nReelCount - 1 do
        for j = 0, SlotsGameLua.m_nRowCount - 1 do
            local nSymbolId = WitchSymbol:GetCommonSymbolId(i)
            WitchFunc:FillSymbol(nSymbolId, i, j)
        end
    end

end

function WitchLevelUI:InitReSpinMask()
    local nCurrentMaxRowCount = WitchFunc.nReSpinCurrentRowCount
    local targetPos = self.mLeveData_ReSpin.tableCachePosByRow[nCurrentMaxRowCount][0]
    targetPos = Unity.Vector3(0, targetPos.y, 0)
    local nMaxPos = targetPos - Unity.Vector3(0, SlotsGameLua.m_fSymbolHeight / 2, 0)

    for i = 1, nCurrentMaxRowCount - 1 do
        local goFen = self.m_transform:FindDeepChild("RespinFenge_Normal/FenGeXian_"..i).gameObject
        local pos = nMaxPos -  Unity.Vector3(0, (i - 1) * SlotsGameLua.m_fSymbolHeight, 0)
        goFen.transform.position = pos
        goFen:SetActive(true)

        local goFen = self.m_transform:FindDeepChild("RespinFenge_FreeSpin/FenGeXian_"..i).gameObject
        local pos = nMaxPos -  Unity.Vector3(0, (i - 1) * SlotsGameLua.m_fSymbolHeight, 0)
        goFen.transform.position = pos
        goFen:SetActive(true)
    end
end

function WitchLevelUI:SetCollectSymbol(goSymbol, nType, nMoneyMultuile, nReelId)
    Debug.Assert(nType >= 1 and nType <= 4)
    
    -- "TextCoinValue", "MINI", "MINOR", "MAJOR"
    local moneyText = self:FindSymbolElement(goSymbol, "TextCoinValue")

    local goMini = self:FindSymbolElement(goSymbol, "MINI")
    local goMinor = self:FindSymbolElement(goSymbol, "MINOR")
    local goMajor = self:FindSymbolElement(goSymbol, "MAJOR")

    moneyText.gameObject:SetActive(false)
    goMini.gameObject:SetActive(false)
    goMinor.gameObject:SetActive(false)
    goMajor.gameObject:SetActive(false)

    if nType == 1 then
        goMini.gameObject:SetActive(true)
    elseif nType == 2 then
        goMinor.gameObject:SetActive(true)
    elseif nType == 3 then
        goMajor.gameObject:SetActive(true)
    elseif nType == 4 then
        local nMoneyCount = SceneSlotGame.m_nTotalBet * nMoneyMultuile
        moneyText.text = "$"..MoneyFormatHelper.coinCountOmit(nMoneyCount)
        moneyText.gameObject:SetActive(true)
    end
end

function WitchLevelUI:HideReelAllSymbol(nReelId)
    for k, v in pairs(SlotsGameLua.m_listReelLua[nReelId].m_listOutSideSymbols) do
        v:SetActive(false)
    end 

    for nRowIndex = 0, 2 * SlotsGameLua.m_nRowCount - 1 do
        local hideObj = SlotsGameLua.m_listReelLua[nReelId].m_listGoSymbol[nRowIndex]
        hideObj:SetActive(false)
    end
end

function WitchLevelUI:PlayReSpinSymbolDiaoLuoAni(goSymbol)
    SymbolObjectPool.m_mapMultiClipEffect[goSymbol]:playAniByPlayMode(1)
    LeanTween.delayedCall(0.583, function()
        SymbolObjectPool.m_mapMultiClipEffect[goSymbol]:playAniByPlayMode(0)  
    end)

end

-- 列停止
function WitchLevelUI:OnPreReelStop(nReelId)
    local reel = SlotsGameLua.m_listReelLua[nReelId]

    local bHaveCollectElement = false
    local reel = SlotsGameLua.m_listReelLua[nReelId]
    for i = 0, SlotsGameLua.m_nRowCount - 1 do
        local nKey = nReelId * SlotsGameLua.m_nRowCount + i
        local goSymbol = reel.m_listGoSymbol[i]
        local nSymbolId = reel.m_curSymbolIds[i]

        if WitchSymbol:isReSpinCollectSymbol(nSymbolId) and not WitchFunc.tableReSpinFixedCollectSymbol[nKey] then
            if SlotsGameLua.m_GameResult:InReSpin() then
                local goSymbol1 = WitchFunc:FixedReSpinCollectSymbol(nReelId, i)
                CoroutineHelper.waitForEndOfFrame(function()
                    self:PlayReSpinSymbolDiaoLuoAni(goSymbol1)
                end)
            else
                self:PlayReSpinSymbolDiaoLuoAni(goSymbol)
            end

            bHaveCollectElement = true
        end
    end     

    if bHaveCollectElement then
        if SlotsGameLua.m_GameResult:InFreeSpin() then
            if nReelId ~= 1 and nReelId ~= 3 then
                AudioHandler:PlayBonusLanded()
            end
        else
            AudioHandler:PlayBonusLanded()
        end
    end
    
    if not SlotsGameLua.m_GameResult:InReSpin() then
        if SpinButton.m_bUserStopSpin then
            AudioHandler:StopSlotsOnFire()
            if reel.m_ScatterEffectObj ~= nil then -- 这列都停了，如果上一列有着火特效也马上停掉。。（绕着列转大圈圈的特效）
                reel.m_ScatterEffectObj:reuseCacheEffect()
                reel.m_ScatterEffectObj = nil
            end 
        end 

        local bAllReelFixedSymbol = true
        for i=0, SlotsGameLua.m_nRowCount - 1 do
            local bStickyFlag, nStickyIndex = reel:isStickyPos(i)
            if not bStickyFlag then
                bAllReelFixedSymbol = false
                break
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

        if not SlotsGameLua.m_GameResult:InFreeSpin() then
            local nScatterSymbolId = SlotsGameLua:GetSymbolIdByObjName("Scatter")
            if self:isScatterPossibleUseful(nReelId) then
                for i=0, SlotsGameLua.m_nRowCount - 1 do
                    local nSymbolId = reel.m_curSymbolIds[i]
                    if nSymbolId == nScatterSymbolId then
                        local goSymbol = reel.m_listGoSymbol[i]

                        --SymbolObjectPool.m_mapSpinEffect[v]:PlayAnimation("animation", 0.0, true)
                        
                        if not SpinButton.m_bUserStopSpin then
                            AudioHandler:PlayScatterStopSound(nReelId)
                        elseif not WitchFunc.m_bScatterSound then
                            AudioHandler:PlayScatterStopSound(nReelId)
                            WitchFunc.m_bScatterSound = true
                        end

                        break
                    end
                end
            end
            
            --Scatter 着火开始
            if self:isNeedWaitingFreeSpin(nReelId) and not SpinButton.m_bUserStopSpin then
                reel:PlayEffectWaitingFreeSpin()
            else
                SlotsGameLua.m_bPlayingSlotFireSound = false
                AudioHandler:StopSlotsOnFire()
            end

            if reel.m_ScatterEffectObj ~= nil then -- 这列都停了，如果上一列有着火特效也马上停掉。。（绕着列转大圈圈的特效）
                reel.m_ScatterEffectObj:reuseCacheEffect()
                reel.m_ScatterEffectObj = nil
            end
        end

    end 

end

function WitchLevelUI:isScatterPossibleUseful(nReelId)
    local nScatterSymbolId = SlotsGameLua:GetSymbolIdByObjName("Scatter")

    local nScatterCount = 0
    for x = 0, nReelId - 1 do
        local reel = SlotsGameLua.m_listReelLua[x]
        for i = 0, SlotsGameLua.m_nRowCount - 1 do
            local nSymbolId = reel.m_curSymbolIds[i]

            if nSymbolId == nScatterSymbolId  then
                nScatterCount = nScatterCount + 1
                break
            end
        end
    end 

    return nScatterCount + SlotsGameLua.m_nReelCount - 1 - nReelId >= 3
end

function WitchLevelUI:isNeedWaitingFreeSpin(nReelId)
    if nReelId >= SlotsGameLua.m_nReelCount - 1 then
        return false
    end 

    local nScatterSymbolId = SlotsGameLua:GetSymbolIdByObjName("Scatter")

    local nScatterCount = 0
    for x = 0, nReelId do
        local reel = SlotsGameLua.m_listReelLua[x]
        for i = 0, SlotsGameLua.m_nRowCount - 1 do
            local nSymbolId = reel.m_curSymbolIds[i]

            if nSymbolId == nScatterSymbolId then
                nScatterCount = nScatterCount + 1
                break
            end
        end
    end

    return nScatterCount >= 2
end

-- 显示Scatter 特效 -- 统一使用播放spine动画的接口: PlayActiveAnimation(enumType, true, 1.0)
function WitchLevelUI:ShowScatterBonusEffect()
    self.tableCollectScatter = {}
    --每列只能出现一个Scatter
    local nScatterSymbolId = SlotsGameLua:GetSymbolIdByObjName("Scatter")
    for x=0, SlotsGameLua.m_nReelCount - 1 do
        for y=0, SlotsGameLua.m_nRowCount - 1 do
            local reel = SlotsGameLua.m_listReelLua[x]
            
            local nSymbolId = reel.m_curSymbolIds[y]
            if nSymbolId == nScatterSymbolId then
                local goSymbol = reel.m_listGoSymbol[y]
                table.insert(self.tableCollectScatter, goSymbol)
            end
        end
    end     

    for k, v in pairs(self.tableCollectScatter) do
        SymbolObjectPool.m_mapSpinEffect[v]:PlayAnimation("animation", 0.0, true)
    end

end     

-- 隐藏 Scatter 特效 -- 播放的时候记录着 隐藏的时候就不用再去查找了
function WitchLevelUI:HideScatterBonusEffect()

end

function WitchLevelUI:handleFreeSpinBegin()
    -- 播放scatter动画 -- 然后一段时间后显示界面.. todo
    local bDelayTime = 0.5
    local bPlayScatterAniTime = 5

    LeanTween.delayedCall(bDelayTime, function()
        self:ShowScatterBonusEffect()

        if SceneSlotGame.m_bFreeSpinRetrigger then
            AudioHandler:PlayRetriggerSound()
        else
            AudioHandler:PlayFreeGameTriggeredSound()
        end 
    end)

    LeanTween.delayedCall(bDelayTime + bPlayScatterAniTime, function()
        if SceneSlotGame.m_bFreeSpinRetrigger then
            SceneSlotGame.m_bFreeSpinRetrigger = false
            self.mFreeSpinAgainSplashUI:Show()
        else
            self.mFreeSpinBeginSplashUI:Show()
        end
        self:HideScatterBonusEffect()
    end)
end

function WitchLevelUI:handleFreeSpinEnd()
    self.mFreeSpinFinishSplashUI:Show()
end

function WitchLevelUI:handleReSpinBegin()
    LeanTween.delayedCall(1, function()
        local tableGoReSpinCollect = {}
        for i = 0, SlotsGameLua.m_nReelCount - 1 do
            for j = 0, SlotsGameLua.m_nRowCount - 1 do
                local nSymbolId = SlotsGameLua.m_listReelLua[i].m_curSymbolIds[j]
                local goSymbol = SlotsGameLua.m_listReelLua[i].m_listGoSymbol[j]

                if WitchSymbol:isReSpinCollectSymbol(nSymbolId) then
                    table.insert(tableGoReSpinCollect, goSymbol)
                end
            end
        end

        for k, v in pairs(tableGoReSpinCollect) do
            SymbolObjectPool.m_mapMultiClipEffect[v]:playAniByPlayMode(2)
            LeanTween.delayedCall(1.183 * 2, function()
                SymbolObjectPool.m_mapMultiClipEffect[v]:playAniByPlayMode(0)
            end)

            CoroutineHelper.waitForEndOfFrame(function()
                self:SetModifyLayer(v, WitchFunc.nReSpinFixedSymbolOrder + 1) 
            end)
        end

        LeanTween.delayedCall(3, function()
            self:PlayReSpinBeginAni()
        end)

    end)

end 

function WitchLevelUI:handleReSpinEnd()
    self.mReSpinFinishCollectMoneyCououtine = StartCoroutine(function()
        self:PlayReSpinFinishAni()
    end)
end 

function WitchLevelUI:PlayFreeSpinBeginHideAni()
    PayLinePayWaysEffectHandler:MatchLineHide(true)

    WitchFunc.nNoBigSymbolGrid = 0
    SlotsGameLua:SetRandomSymbolToReel()
end

function WitchLevelUI:PlayFreeSpinFinishHideAni()
    PayLinePayWaysEffectHandler:MatchLineHide(true)
    
    for x = 0, SlotsGameLua.m_nReelCount - 1 do
        for y = 0, 2 * SlotsGameLua.m_nRowCount - 1 do
            local nSymbolId = WitchSymbol:GetCommonSymbolId(x)
            local goSymbol = SlotsGameLua.m_listReelLua[x].m_listGoSymbol[y]
            SymbolObjectPool:Unspawn(goSymbol)

            local targetGroup = WitchFunc:GetCurrentCurveGroup(x)
            local newGO = WitchFunc:SpawnSymbolByCurveGroup(nSymbolId, targetGroup)
            newGO.transform:SetParent(SlotsGameLua.m_listReelLua[x].m_transform, false)
            newGO.transform.localScale = Unity.Vector3.one
            newGO.transform.localPosition = SlotsGameLua.m_listReelLua[x].m_listSymbolPos[y]

            SlotsGameLua.m_listReelLua[x].m_listGoSymbol[y] = newGO
            SlotsGameLua.m_listReelLua[x].m_curSymbolIds[y] = nSymbolId
        end
    end

end

function WitchLevelUI:SetReSpinRemainCount(nReSpinRemainCount)
    self.textReSpinCount.text = nReSpinRemainCount

    if nReSpinRemainCount == 3 then
        self.m_goResetEffect:SetActive(true)
        LeanTween.delayedCall(2, function()
            self.m_goResetEffect:SetActive(false)
        end)
    end
end

function WitchLevelUI:PlayReSpinBeginAni()
    PayLinePayWaysEffectHandler:MatchLineHide(true)
    self.mJackPotUI:modifyJackpotValueByTotalBet()

    self.goRespinFenge_Normal:SetActive(false)
    self.goRespinFenge_FreeSpin:SetActive(false)
    if SlotsGameLua.m_GameResult:InFreeSpin() then
        self.goRespinFenge_FreeSpin:SetActive(true)
    else
        self.goRespinFenge_Normal:SetActive(true)
    end

    self.goReSpinTitle:SetActive(true)
    self.goReSpinGrayBg:SetActive(true)
    self:SetReSpinRemainCount(WitchConfig.N_RESPIN_TRIGGER_FREECOUNT)

    self:ResetNormalToReSpinUI()

    AudioHandler:LoadAndPlayRespinGameMusic()

    LeanTween.delayedCall(1.0, function()
        SceneSlotGame:OnSplashHide(SplashType.ReSpin)
    end)

end

function WitchLevelUI:PlayReSpinFinishAni()
    AudioHandler:LoadAndPlayRespinGameMusic()

    local fSumMoneyCount = SlotsGameLua.m_GameResult.m_fGameWin
    if SlotsGameLua.m_GameResult:InFreeSpin() then
        fSumMoneyCount = 0.0
    end
    
    fSumMoneyCount = fSumMoneyCount + WitchFunc.fReSpinCollectMoneyCount
    if LuaHelper.tableSize(WitchFunc.tableReSpinFixedCollectSymbol) == SlotsGameLua.m_nReelCount * SlotsGameLua.m_nRowCount then
        local nJackPotIndex = 4
        local fAddMoneyCount = self.tableNowJackPotMoneyCount[nJackPotIndex]

        WitchLevelUI:CollectMoneyToDB(fAddMoneyCount)
        if not WitchLevelUI.tableNowbGetJackPot[nJackPotIndex] then
            WitchLevelUI.tableNowbGetJackPot[nJackPotIndex] = true
            WitchLevelUI.mJackPotUI:ResetCurrentJackPot(nJackPotIndex)
        end 

        self.mJackPotGrandSplashUI:Show(fAddMoneyCount)
        while self.mJackPotGrandSplashUI.m_transform.gameObject.activeInHierarchy do
            yield_return(0)
        end
        
        fSumMoneyCount = fSumMoneyCount + fAddMoneyCount
        yield_return(Unity.WaitForSeconds(2.0))
    end 

    Debug.Log("ReSpin 普通赢钱： ".. WitchFunc.fReSpinCollectMoneyCount)
    Debug.Log("ReSpin 总赢钱： "..fSumMoneyCount)
    
    SlotsGameLua:ShowCustomBigWin(fSumMoneyCount, function()   
        self:PlayReSpinFinishHideAni()
        local fCoinTime = self:UpdateCollectMoneyToUI(WitchFunc.fReSpinCollectMoneyCount)
        LeanTween.delayedCall(fCoinTime, function()
            SceneSlotGame:OnSplashHide(SplashType.ReSpinEnd)
        end)

        if SlotsGameLua:orTriggerBigWin(fSumMoneyCount, SceneSlotGame.m_nTotalBet) then
            UITop:updateCoinCountInUi(10)
        else
            UITop:updateCoinCountInUi(5)
        end
    end)

    SlotsGameLua:onFinalReportForReSpin(fSumMoneyCount)
    SlotsGameLua:ShowCurFreeSpinWinInfo(fSumMoneyCount)
end     

function WitchLevelUI:PlayFreeSpinBigSymbolEffect() -- 还应该包括进wild牌..
    if SlotsGameLua.m_GameResult:InFreeSpin() and not SlotsGameLua.m_GameResult:InReSpin() and SlotsGameLua.m_GameResult.m_nFreeSpinCount > 0 then
        local bContainBig = false

        for k, v in pairs(SlotsGameLua.m_GameResult.m_listWins) do
            local nLineId = v.m_nLineID
            local nMatchCount = v.m_nMatches
            if nMatchCount > 1 then
                bContainBig = true
                break
            end
        end

        if bContainBig then
            local goSymbol = SlotsGameLua.m_listReelLua[2].m_listGoSymbol[1]
            if SymbolObjectPool.m_mapSpinEffect[goSymbol] then
                PayLinePayWaysEffectHandler:PlaySpineEffect(2, 1)
            elseif SymbolObjectPool.m_mapMultiClipEffect[goSymbol] then
                PayLinePayWaysEffectHandler:PlayMultiClipEffect(2, 1)
            else
                PayLinePayWaysEffectHandler:LoopScaleSymbol(2, 1)
            end
        end

    end

end

function WitchLevelUI:PlayNormalWildMergeAni()
    local tableAdjacent = {}
    local tableInWinLineKeys = {}
    for k, v in pairs(SlotsGameLua.m_GameResult.m_listWins) do
        local nLineId = v.m_nLineID
        for i = 0, v.m_nMatches - 1 do
            local nReelId = i
            local nRowIndex = SlotsGameLua.m_listLineLua[nLineId].Slots[nReelId]
            local nKey =  SlotsGameLua.m_nRowCount * nReelId + nRowIndex
            if WitchSymbol:isWildSymbol(SlotsGameLua.m_listDeck[nKey]) then
                if not LuaHelper.tableContainsElement(tableInWinLineKeys, nKey) then
                    table.insert(tableInWinLineKeys, nKey)
                end
            end
        end
    end

    local bHaveAdjacentWild = false
    for i = 0, SlotsGameLua.m_nReelCount - 1 do
        local bStartCheckAdjacent = false
        local nFirstZeusRowIndex = -1
        local nAdjacentCount = 0

        for j = SlotsGameLua.m_nRowCount - 1, 0, -1 do
            local nKey = i * SlotsGameLua.m_nRowCount + j
            local nSymbolId = SlotsGameLua.m_listDeck[nKey]

            if WitchSymbol:isWildSymbol(nSymbolId) and LuaHelper.tableContainsElement(tableInWinLineKeys, nKey) then
                if not bStartCheckAdjacent then
                    nFirstZeusRowIndex = j
                    bStartCheckAdjacent = true
                    nAdjacentCount = 1
                else
                    nAdjacentCount = nAdjacentCount + 1
                end

                if j == 0 then
                    if nAdjacentCount >= 2 and nFirstZeusRowIndex >= 0 then
                        tableAdjacent[i * SlotsGameLua.m_nRowCount + nFirstZeusRowIndex] = nAdjacentCount
                    end
                end
            else
                if nAdjacentCount >= 2 and nFirstZeusRowIndex >= 0 then
                    tableAdjacent[i * SlotsGameLua.m_nRowCount + nFirstZeusRowIndex] = nAdjacentCount
                end

                bStartCheckAdjacent = false
                nFirstZeusRowIndex = -1
                nAdjacentCount = 0
            end

        end
    end

    for k, v in pairs(tableAdjacent) do
        local nReelId = math.floor(k / SlotsGameLua.m_nRowCount)
        local nRowIndex = k % SlotsGameLua.m_nRowCount
        local nAdjacentCount = v

        local preGoSymbol = SlotsGameLua.m_listReelLua[nReelId].m_listGoSymbol[nRowIndex]

        local prefab = self.Wild_2x1SymbolPool
        if nAdjacentCount == 3 then
            prefab = self.Wild_3x1SymbolPool
        end

        local targetGroup = WitchFunc:GetCurrentCurveGroup(nReelId)
        local newGO = self:SpawnSymbolToSymbolPool(targetGroup, prefab)
        newGO.transform:SetParent(SlotsGameLua.m_listReelLua[nReelId].m_transform, false)
        newGO.transform.localScale = Unity.Vector3.one
        newGO.transform.localPosition = SlotsGameLua.m_listReelLua[nReelId].m_listSymbolPos[nRowIndex]

        SlotsGameLua.m_listReelLua[nReelId].m_listGoSymbol[nRowIndex] = newGO

        local startPos = Unity.Vector3(-125.0, 120.0, 0.0)
        local startScale = Unity.Vector3(0.0, 0.0, 0.0)
        local endPos = Unity.Vector3(0, -120, 0)
        local endScale = Unity.Vector3(1.0, 1.0, 1.0)

        if nAdjacentCount == 3 then
            startPos = Unity.Vector3(-125, 120.0, 0.0)
            startScale = Unity.Vector3(0.0, 0.0, 0.0)
            endPos = Unity.Vector3(0.0, -240, 0.0)
            endScale = Unity.Vector3(1.0, 1.0, 1.0)
        end 

        local deltaPos = endPos - startPos;
        local deltaScale = endScale - startScale;
        
        local trMaskbg = self:FindSymbolElement(newGO, "Mask")
        trMaskbg.transform.localPosition = startPos;
        trMaskbg.transform.localScale = startScale;
        LeanTween.value(0, 1, 0.3):setOnUpdate(function(value)
            local pos = startPos + value * deltaPos;
            local scale = startScale + value * deltaScale;

            trMaskbg.transform.localPosition = pos;
            trMaskbg.transform.localScale = scale;
        end):setOnComplete(function()
            SymbolObjectPool:Unspawn(preGoSymbol)
            for i = 1, nAdjacentCount - 1 do
                local goSymbol = SlotsGameLua.m_listReelLua[nReelId].m_listGoSymbol[nRowIndex - i]
                goSymbol:SetActive(false)
            end
        end)
        
    end

end

function WitchLevelUI:CollectMoneyToDB(fAddMoneyCount)
    if SlotsGameLua.m_GameResult:InFreeSpin() then
        SlotsGameLua.m_GameResult.m_fFreeSpinTotalWins = SlotsGameLua.m_GameResult.m_fFreeSpinTotalWins + fAddMoneyCount
        LevelDataHandler:addFreeSpinTotalWin(ThemeLoader.themeKey, fAddMoneyCount)
    else
        PlayerHandler:AddCoin(fAddMoneyCount)
        LevelDataHandler:AddPlayerWinCoins(fAddMoneyCount)
    end
end

function WitchLevelUI:UpdateCollectMoneyToUI(fAddMoneyCount, fCoinTime)
    if fCoinTime == nil then
        local ratio = fAddMoneyCount / SceneSlotGame.m_nTotalBet
        fCoinTime = AudioHandler:HandleAllReelStopAudioBaseGame(ratio, true)
    end

    SlotsGameLua.m_GameResult.m_fGameWin = SlotsGameLua.m_GameResult.m_fGameWin + fAddMoneyCount
    SceneSlotGame.m_fCurWinCoinTime = fCoinTime
    SceneSlotGame:UpdateTotalWinToUI()

    return fCoinTime
end

function WitchLevelUI:PlayReSpinFinishHideAni()
    self.goRespinFenge_Normal:SetActive(false)
    self.goRespinFenge_FreeSpin:SetActive(false)

    self.goReSpinTitle:SetActive(false)
    self.goReSpinGrayBg:SetActive(false)
    self:ResetReSpinToNormalUI()    

    for k, v in pairs(self.tableReSpinFixedCollectGoSymbol) do
        SymbolObjectPool:Unspawn(v)
    end

    self.tableReSpinFixedCollectGoSymbol = {}

    WitchFunc:CancelAllReSpinFixedSymbol()

    
end

------------------------------------- 盘面切换 ----------------------------------
-- 对单个 Key 进行翻转
function WitchLevelUI:NormalToReSpinDeckKey(nNormalKey)
    local nReelId = math.floor(nNormalKey / WitchFunc.nReSpinCurrentRowCount)
    local nRowIndex = nNormalKey % WitchFunc.nReSpinCurrentRowCount

    local nRowIndex = WitchFunc.nReSpinCurrentRowCount - 1 - nRowIndex
    return nReelId * WitchFunc.nReSpinCurrentRowCount + nRowIndex
end

---------------- 正常 -> ReSpin 切换盘面 -------------------
function WitchLevelUI:ResetNormalToReSpinUI()
    self.bUseReSpinCurveGroup = true
    CoroutineHelper.waitForEndOfFrame(function()
        self.mLeveData_Normal:DeActive()
    end)
    
    self.mLeveData_ReSpin:Active()

    local tempTable = {}
    for k, v in pairs(WitchFunc.tableReSpinFixedCollectSymbol) do
        local nKey = k
        nKey = self:NormalToReSpinDeckKey(nKey)
        tempTable[nKey] = v
    end

    WitchFunc.tableReSpinFixedCollectSymbol = tempTable
    WitchFunc.tableCollectElementType = tempTable
    
    self.tableReSpinFixedCollectGoSymbol = {}
    for i = 0, WitchFunc.nReSpinCurrentReelCount - 1 do
        for j = 0, WitchFunc.nReSpinCurrentRowCount - 1 do
            local nKey = i * WitchFunc.nReSpinCurrentRowCount + j

            local nNormalKey = i * WitchFunc.nReSpinCurrentRowCount + (WitchFunc.nReSpinCurrentRowCount - j - 1)
            local nSymbolId = SlotsGameLua.m_listDeck[nNormalKey]

            local nActualReelId = math.floor(nKey / SlotsGameLua.m_nRowCount)
            local nActualRowIndex = nKey % SlotsGameLua.m_nRowCount

            WitchFunc:FillSymbol(nSymbolId, nActualReelId, nActualRowIndex)
            if WitchSymbol:isReSpinCollectSymbol(nSymbolId) then
                Debug.Assert(WitchFunc.tableReSpinFixedCollectSymbol[nKey])
                local goSymbol = WitchFunc:FixedReSpinCollectSymbol(nActualReelId, nActualRowIndex)
                
                if SlotsGameLua.m_GameResult:InFreeSpin() then
                    if i >= 1 and i <= 3 then
                        goSymbol:SetActive(false)

                        if nNormalKey == 7 then
                            SymbolObjectPool:Unspawn(self.tableReSpinFixedCollectGoSymbol[nKey])
                            self.tableReSpinFixedCollectGoSymbol[nKey] = nil

                            local prefab = WitchLevelUI.tableBigSymbolPool[nSymbolId]
                            local newGO = WitchLevelUI:SpawnSymbolToSymbolPool(self.mMergeSymbolGroup, prefab)
                            newGO.transform:SetParent(self.mMergeSymbolGroup.transform, false)
                            newGO.transform.localScale = Unity.Vector3.one
                            newGO.transform.position = goSymbol.transform.position

                            self.tableReSpinFixedCollectGoSymbol[nKey] = newGO

                            local nType = WitchFunc.tableCollectElementType[nKey][2]
                            local nMoneyMultuile = WitchFunc.tableCollectElementType[nKey][3]
                            self:SetCollectSymbol(newGO, nType, nMoneyMultuile, nActualReelId)

                            CoroutineHelper.waitForEndOfFrame(function()
                                self:SetModifyLayer(newGO, WitchFunc.nReSpinFixedSymbolOrder) 
                            end)

                        end
                    end
                end
            end
        end
    end
    
    CoroutineHelper.waitForEndOfFrame(function()
        Unity.Resources.UnloadUnusedAssets()
    end)

end 

function WitchLevelUI:ResetNormalToReSpinUI1()
    self.bUseReSpinCurveGroup = true
    CoroutineHelper.waitForEndOfFrame(function()
        self.mLeveData_Normal:DeActive()
    end)

    self.mLeveData_ReSpin:Active()

    WitchFunc.tableCollectElementType = WitchFunc.tableReSpinFixedCollectSymbol

    self.tableReSpinFixedCollectGoSymbol = {}
    for i = 0, WitchFunc.nReSpinCurrentReelCount - 1 do
        for j = 0, WitchFunc.nReSpinCurrentRowCount - 1 do
            local nKey = i * WitchFunc.nReSpinCurrentRowCount + j
            if WitchFunc.tableReSpinFixedCollectSymbol[nKey] then
                local nNormalKey = i * WitchFunc.nReSpinCurrentRowCount + (WitchFunc.nReSpinCurrentRowCount - j - 1)
                local nSymbolId = WitchFunc.tableReSpinFixedCollectSymbol[nKey][1]

                local nActualReelId = math.floor(nKey / SlotsGameLua.m_nRowCount)
                local nActualRowIndex = nKey % SlotsGameLua.m_nRowCount

                WitchFunc:FillSymbol(nSymbolId, nActualReelId, nActualRowIndex)
                if WitchSymbol:isReSpinCollectSymbol(nSymbolId) then
                    Debug.Assert(WitchFunc.tableReSpinFixedCollectSymbol[nKey])
                    local goSymbol = WitchFunc:FixedReSpinCollectSymbol(nActualReelId, nActualRowIndex)
                    
                    if SlotsGameLua.m_GameResult:InFreeSpin() then
                        if i >= 1 and i <= 3 then
                            goSymbol:SetActive(false)

                            if nNormalKey == 7 then
                                SymbolObjectPool:Unspawn(self.tableReSpinFixedCollectGoSymbol[nKey])
                                self.tableReSpinFixedCollectGoSymbol[nKey] = nil

                                local prefab = WitchLevelUI.tableBigSymbolPool[nSymbolId]
                                local newGO = WitchLevelUI:SpawnSymbolToSymbolPool(self.mMergeSymbolGroup, prefab)
                                newGO.transform:SetParent(self.mMergeSymbolGroup.transform, false)
                                newGO.transform.localScale = Unity.Vector3.one
                                newGO.transform.position = goSymbol.transform.position

                                self.tableReSpinFixedCollectGoSymbol[nKey] = newGO

                                local nType = WitchFunc.tableCollectElementType[nKey][2]
                                local nMoneyMultuile = WitchFunc.tableCollectElementType[nKey][3]
                                self:SetCollectSymbol(newGO, nType, nMoneyMultuile, nActualReelId)

                                CoroutineHelper.waitForEndOfFrame(function()
                                    self:SetModifyLayer(newGO, WitchFunc.nReSpinFixedSymbolOrder) 
                                end)

                            end
                        end
                    end
                end
            end
            
        end
    end
end 

-- ReSpin -> 正常 切换盘面
function WitchLevelUI:ResetReSpinToNormalUI()
    self.bUseReSpinCurveGroup = false

    local preDeck = SlotsGameLua.m_listDeck

    self.mLeveData_ReSpin:DeActive()
    self.mLeveData_Normal:Active()

    for k, p in pairs(preDeck) do
        local nReSpinKey = k
        local nReelId = math.floor(nReSpinKey / WitchFunc.nReSpinCurrentRowCount)
        local nRowIndex = nReSpinKey % WitchFunc.nReSpinCurrentRowCount
        nRowIndex = WitchFunc.nReSpinCurrentRowCount - nRowIndex - 1

        local nKey = nReelId * SlotsGameLua.m_nRowCount + nRowIndex
        local nSymbolId = p

        local goSymbol = WitchFunc:FillSymbol(nSymbolId, nReelId, nRowIndex)
        if WitchSymbol:isReSpinCollectSymbol(nSymbolId) then
            local nType = WitchFunc.tableCollectElementType[nReSpinKey][2]
            local nMoneyMultuile = WitchFunc.tableCollectElementType[nReSpinKey][3]
            self:SetCollectSymbol(goSymbol, nType, nMoneyMultuile, nReelId)

            CoroutineHelper.waitForEndOfFrame(function()
                WitchLevelUI:SetModifyLayer(goSymbol, WitchFunc.nReSpinFixedSymbolOrder)

                SymbolObjectPool.m_mapMultiClipEffect[goSymbol]:playAniByPlayMode(2)
                LeanTween.delayedCall(1.183 * 2, function()
                    SymbolObjectPool.m_mapMultiClipEffect[goSymbol]:playAniByPlayMode(0)
                end)

            end)

        end
    end

    Unity.Resources.UnloadUnusedAssets()
end

---------------------- 设置 符号 的层级 -----------------------------
function WitchLevelUI:CacheSymbolElementLayer(goSymbol)
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

function WitchLevelUI:SetModifyLayer(goSymbol, nOrder)
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

function WitchLevelUI:GetEffectByEffectPool(strKey)
    Debug.Assert(LuaHelper.tableContainsElement(self.m_RegisterLoadEffectNameTable, strKey))

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

function WitchLevelUI:RecycleEffectToEffectPool(UsedObj)
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

------------------------------------ 符号缓冲池 -----------------------------------
function WitchLevelUI:CachePreBuildSymbol(nSymbolId, targetGroup, nCount)
    if not self.tablePreBuildSymbol then
        self.tablePreBuildSymbol = {}
    end

    if not self.tablePreBuildSymbol[targetGroup] then
        self.tablePreBuildSymbol[targetGroup] = {}
    end

    if not self.tablePreBuildSymbol[targetGroup][nSymbolId] then
        self.tablePreBuildSymbol[targetGroup][nSymbolId] = {}
    end 

    for i = 1, nCount do
        local goSymbol = WitchFunc:SpawnSymbolByCurveGroup(nSymbolId, targetGroup)
        goSymbol.transform:SetParent(targetGroup.transform, false)
        goSymbol.transform.position = Unity.Vector3(1000000, 0, 0)

        WitchFunc:ShowSymbolFrame0AndSpineNode(goSymbol)
        table.insert(self.tablePreBuildSymbol[targetGroup][nSymbolId], goSymbol)
    end

end 

function WitchLevelUI:GetPreBuildSymbol(nSymbolId, targetGroup)
    if self.tablePreBuildSymbol and self.tablePreBuildSymbol[targetGroup] and 
        self.tablePreBuildSymbol[targetGroup][nSymbolId]  then
        
        local temTable = self.tablePreBuildSymbol[targetGroup][nSymbolId]
        self.tablePreBuildSymbol[targetGroup][nSymbolId] = nil
        return temTable
    else
        Debug.LogError(" 需要 预先 缓存 Build 符号")
        return nil
    end
    
end

function WitchLevelUI:SpawnSymbolToSymbolPool(group, prefab)
    if not self.mapSymbolCurveGroup then
        self.mapSymbolCurveGroup = {}
    end

    local tr = nil
    local obj = nil
    local list = SymbolObjectPool.m_mapPooledObjects[prefab]
    local nRemoveIndex = -1
    if list and #list > 0 then
        for k, v in pairs(list) do
            if self.mapSymbolCurveGroup[v] == group or (not self.mapSymbolCurveGroup[v]) then
                nRemoveIndex = k
                break
            end
        end

        if nRemoveIndex > 0 then
            obj = table.remove(list, nRemoveIndex)
            obj:SetActive(true)
        end
    end

    if nRemoveIndex == -1 then
        obj = Unity.Object.Instantiate(prefab)
        SymbolObjectPool.m_mapGOElemTransform[obj] = obj.transform

        SymbolObjectPool:CacheGlobalEffect(obj)
        obj:SetActive(true)
    end

    if not self.mapSymbolCurveGroup[obj] then
        self.mapSymbolCurveGroup[obj] = group
    end

    obj.transform.localScale = Unity.Vector3.one
    obj.name = prefab.name.."_"..group.name

    Debug.Assert(self.mapSymbolCurveGroup[obj] == group)
    SymbolObjectPool.m_mapSpawnedObjects[obj] = prefab
    return obj
end

function WitchLevelUI:AddSymbolPools()
    self.tableBigSymbolPool = {}
    for i = 1, #SlotsGameLua.m_listSymbolLua do
        local prefabName = SlotsGameLua:GetSymbol(i).prfab.name
        prefabName = "3x3_"..prefabName

        local symbolPrefab = SymbolLua:getSymbolPrefab(prefabName)
        local nSize = 15
        SymbolObjectPool:CreatePool(symbolPrefab, nSize)

        self.tableBigSymbolPool[i] = symbolPrefab
    end

    self.Wild_2x1SymbolPool = SymbolLua:getSymbolPrefab("Wild_2x1")
    SymbolObjectPool:CreatePool(self.Wild_2x1SymbolPool, 5)

    self.Wild_3x1SymbolPool = SymbolLua:getSymbolPrefab("Wild_3x1")
    SymbolObjectPool:CreatePool(self.Wild_3x1SymbolPool, 5)

end

--==================================== 数据库 ======================================

function WitchLevelUI:setDBReSpin()
    LevelDataHandler.m_Data.mThemeData.bInReSpin = WitchFunc.bInReSpin

    local tableReSpinFixedSymbol = {}
    for k, v in pairs(WitchFunc.tableReSpinFixedCollectSymbol) do
        table.insert(tableReSpinFixedSymbol, {k, v[1], v[2], v[3]})
    end

    LevelDataHandler.m_Data.mThemeData.tableReSpinFixedSymbol = tableReSpinFixedSymbol

    local nRemainReSpinSpinCount = SlotsGameLua.m_GameResult.m_nReSpinTotalCount - SlotsGameLua.m_GameResult.m_nReSpinCount
    if nRemainReSpinSpinCount < 0 then
        nRemainReSpinSpinCount = 0
    end     

    LevelDataHandler.m_Data.mThemeData.nRemainReSpinSpinCount = nRemainReSpinSpinCount
    LevelDataHandler:persistentData()

end         

function WitchLevelUI:setDBReSpinForFixedSymbol()
    local tempTables = {}
    for k, v in pairs(WitchFunc.tableReSpinFixedCollectSymbol) do
        local nKey = k
        local nNewKey = WitchLevelUI:NormalToReSpinDeckKey(nKey)

        tempTables[nNewKey] = {v[1], v[2], v[3]}
    end        

    local tableReSpinFixedSymbol = {}
    for k, v in pairs(tempTables) do
        table.insert(tableReSpinFixedSymbol, {k, v[1], v[2], v[3]})
    end 

    LevelDataHandler.m_Data.mThemeData.tableReSpinFixedSymbol = tableReSpinFixedSymbol
	LevelDataHandler:persistentData()
end

function WitchLevelUI:getDBReSpin()
	if LevelDataHandler.m_Data.mThemeData.bInReSpin == nil then
		return
	end                 

    WitchFunc.bInReSpin = LevelDataHandler.m_Data.mThemeData.bInReSpin

    if WitchFunc.bInReSpin then
        if LevelDataHandler.m_Data.mThemeData.tableReSpinFixedSymbol then
            WitchFunc.tableReSpinFixedCollectSymbol = {}
            for k, v in pairs(LevelDataHandler.m_Data.mThemeData.tableReSpinFixedSymbol) do
                WitchFunc.tableReSpinFixedCollectSymbol[v[1]] = {v[2], v[3], v[4]}
            end
        end  

        WitchFunc.nRemainReSpinSpinCount = LevelDataHandler.m_Data.mThemeData.nRemainReSpinSpinCount
    end

end
