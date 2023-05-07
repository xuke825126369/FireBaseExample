MardiGrasLevelUI = {}

function MardiGrasLevelUI:InitVariable()
    self.m_LeanTweenIDs = {}
    self.m_transform = nil

    self.m_RegisterLoadEffectNameTable = {"BigwheelGreen", "BigwheelRed", "BigwheelYellow"}
    self.tableFixedGoSymbol = {}

    self.tableGoWheelEffect = {}
end 

function MardiGrasLevelUI:initLevelUI()
    self:InitVariable()
    MardiGrasFunc:InitVariable()

    self.m_transform = ThemeVideoScene.mNewGameNodeParent:FindDeepChild("LevelBG")
    LuaAutoBindMonoBehaviour.Bind(self.m_transform.gameObject, self)

    self.mFreeSpinSeeSplashUI = require("Lua/ThemeVideo/MardiGras/FreeSpinSeeSplashUI")
    self.mFreeSpinSeeSplashUI:Init()

    self.mFreeSpinBeginSplashUI = require("Lua/ThemeVideo/MardiGras/FreeSpinBeginSplashUI")
    self.mFreeSpinBeginSplashUI:Init()

    self.mFreeSpinFinishSplashUI = require("Lua/ThemeVideo/MardiGras/FreeSpinFinishSplashUI")
    self.mFreeSpinFinishSplashUI:Init()

    self.mWheelUI = require("Lua/ThemeVideo/MardiGras/WheelUI")
    self.mWheelUI:Init()
    
    self.tableGoReelWheel = {}
    self.tableGoReelWheel[0] = self.m_transform:FindDeepChild("ReelWheels/BigwheelYellow").gameObject
    self.tableGoReelWheel[1] = self.m_transform:FindDeepChild("ReelWheels/BigwheelRed").gameObject
    self.tableGoReelWheel[2] = self.m_transform:FindDeepChild("ReelWheels/BigwheelGreen").gameObject

    self.goDengEffect = self.m_transform:FindDeepChild("LampEffectCanvas/LampEffect").gameObject
    self.goDengEffect:SetActive(false)

    self.goMardigrasLevel = self.m_transform:FindDeepChild("MardigrasLevel").gameObject
    self.goMardigrasLevel:SetActive(true)

end     

function MardiGrasLevelUI:Update()
    --self.mJackPotUI:Update()
end 

function MardiGrasLevelUI:OnDestroy()
    self:CancelLeanTween()
    LuaHelper.ReleaseVariable(self)
    LuaHelper.ReleaseVariable(MardiGrasFunc)
end

function MardiGrasLevelUI:CancelLeanTween()
	local count = #self.m_LeanTweenIDs
	for i=1, count do
		local id = self.m_LeanTweenIDs[i]
		if LeanTween.isTweening(id) then
			LeanTween.cancel(id)
		end
	end
	self.m_LeanTweenIDs = {}
end

function MardiGrasLevelUI:SetInteger(mAnimator, strKey, nAction)
    if mAnimator.gameObject.activeInHierarchy then
        if mAnimator:GetInteger(strKey) ~= nAction then
            mAnimator:SetInteger(strKey, nAction)
        end
    end
end

-- 查找某个符号的子节点，并缓存下来，高效可靠
function MardiGrasLevelUI:FindSymbolElement(goSymbol, strKey)
    local tablePoolKey = {"redWheel", "yellowWheel", "greenWheel", "highLightMask1", "highLightMask2", "highLightMask3"}

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

function MardiGrasLevelUI:OnPreReelStop(nReelId)
    local reel = SlotsGameLua.m_listReelLua[nReelId]

    local bHaveBonus = false
    for i = 0, SlotsGameLua.m_nRowCount - 1 do
        local nSymbolId = reel.m_curSymbolIds[i]
        local goSymbol = reel.m_listGoSymbol[i]

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
    
    if SpinButton.m_bUserStopSpin then
        if nReelId == SlotsGameLua.m_nReelCount - 1 then
            if self:isNeedShowWheelEffect(nReelId) then
                for i = 0, SlotsGameLua.m_nReelCount - 1 do
                    local effetcName = "BigwheelGreen"
                    if i == 0 then
                        effetcName = "BigwheelYellow"
                    elseif i == 1 then
                        effetcName = "BigwheelRed"
                    else
                        effetcName = "BigwheelGreen"
                    end

                    local goEffect = self:GetEffectByEffectPool(effetcName)
                    goEffect.transform.position = self.tableGoReelWheel[i].transform.position
                    goEffect:SetActive(true)
                    table.insert(self.tableGoWheelEffect, goEffect)
                end
            else
                for k, v in pairs(self.tableGoWheelEffect) do
                    self:RecycleEffectToEffectPool(v)
                end
                self.tableGoWheelEffect = {}
            end
        end
    else
        if self:isNeedShowWheelEffect(nReelId) then
            local effetcName = "BigwheelGreen"
            if nReelId == 0 then
                effetcName = "BigwheelYellow"
            elseif nReelId == 1 then
                effetcName = "BigwheelRed"
            else
                effetcName = "BigwheelGreen"
            end

            local goEffect = self:GetEffectByEffectPool(effetcName)
            goEffect.transform.position = self.tableGoReelWheel[nReelId].transform.position
            goEffect:SetActive(true)
            table.insert(self.tableGoWheelEffect, goEffect)
        else
            for k, v in pairs(self.tableGoWheelEffect) do
                self:RecycleEffectToEffectPool(v)
            end
            self.tableGoWheelEffect = {}
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
end

function MardiGrasLevelUI:isNeedShowWheelEffect(nReelId)
    for i = 0, nReelId do
        local bHaveWheel = false
        for j = 0, SlotsGameLua.m_nRowCount - 1 do
            local nKey = i * SlotsGameLua.m_nRowCount + j
            if LuaHelper.tableContainsElement(MardiGrasFunc.tableWheelKey, nKey) then
                bHaveWheel = true
            end
        end

        if not bHaveWheel then
            return false
        end
    end
    return true
end

function MardiGrasLevelUI:CheckRecoverInfo()
    local tablePayLines = {
        {nId = 1,	winLine = {0, 0, 0}},
        {nId = 2,	winLine = {1, 1, 1}},
        {nId = 3,	winLine = {2, 2, 2}},
        {nId = 4,	winLine = {0, 1, 2}},
        {nId = 5,	winLine = {2, 1, 0}},
    }
    ThemePlayData:SetCFGLineInfo(tablePayLines)

    self.tableCachePos = {}
    for i = 0, SlotsGameLua.m_nReelCount - 1 do
        for j = 0, SlotsGameLua.m_nRowCount * 2 - 1 do
            local nKey = i * SlotsGameLua.m_nRowCount + j
            local goSymbol = SlotsGameLua.m_listReelLua[i].m_listGoSymbol[j]
            self.tableCachePos[nKey] = goSymbol.transform.position
        end
    end

    MardiGrasLevelUI:getDBFreeSpin()
    if SlotsGameLua.m_GameResult:InFreeSpin() then
        self:PlayFreeSpinBeginHideAni()
    end

end     

function MardiGrasLevelUI:handleFreeSpinBegin()
    MardiGrasLevelUI:ResetTotalWinToUI(0)
    self.goDengEffect:SetActive(true)
    AudioHandler:PlayThemeSound("freeTrigger")
    LeanTween.delayedCall(2.0, function()
        self.mFreeSpinSeeSplashUI:Show()
    end)
end

function MardiGrasLevelUI:handleFreeSpinEnd()

    self.mFreeSpinFinishSplashUI:Show()
end

function MardiGrasLevelUI:PlayFreeSpinBeginHideAni()
    self.goMardigrasLevel:SetActive(true)
    self.mWheelUI:ResetAngle()
    self.goDengEffect:SetActive(false)
    for k, v in pairs(self.tableGoWheelEffect) do
        self:RecycleEffectToEffectPool(v)
    end
    self.tableGoWheelEffect = {}
end

function MardiGrasLevelUI:PlayFreeSpinFinishHideAni()
    self.goMardigrasLevel:SetActive(true)
    self.mWheelUI:ResetAngle()
    self.goDengEffect:SetActive(false)
    for k, v in pairs(self.tableGoWheelEffect) do
        self:RecycleEffectToEffectPool(v)
    end
    self.tableGoWheelEffect = {}
end

function MardiGrasLevelUI:FillSymbol(nSymbolId, nReelId, nRowIndex)
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

function MardiGrasLevelUI:FixedAliceSymbol(nSymbolId, nReelId, nRowIndex)
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

function MardiGrasLevelUI:ResetTotalWinToUI(fMoneyCount)
    SlotsGameLua.m_GameResult.m_fGameWin = fMoneyCount
    SceneSlotGame.m_SlotsNumberWins:End(fMoneyCount)
end

function MardiGrasLevelUI:UpdateTotalWinToUI(fAddMoneyCount, fAniTime)
    if fAniTime == nil then
        fAniTime = 1.0
    end

    SlotsGameLua.m_GameResult.m_fGameWin = SlotsGameLua.m_GameResult.m_fGameWin + fAddMoneyCount
    SceneSlotGame.m_fCurWinCoinTime = fAniTime
    SceneSlotGame:UpdateTotalWinToUI()
end

function MardiGrasLevelUI:CollectMoneyToDB(fAddMoneyCount)
    if SlotsGameLua.m_GameResult:InFreeSpin() then
        SlotsGameLua.m_GameResult.m_fFreeSpinTotalWins = SlotsGameLua.m_GameResult.m_fFreeSpinTotalWins + fAddMoneyCount
        LevelDataHandler:addFreeSpinTotalWin(ThemeLoader.themeKey, fAddMoneyCount)
    else
        PlayerHandler:AddCoin(fAddMoneyCount)
        LevelDataHandler:AddPlayerWinCoins(fAddMoneyCount)
    end
end

---------------------- 设置 符号 的层级 -----------------------------
function MardiGrasLevelUI:CacheSymbolElementLayer(goSymbol)
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

function MardiGrasLevelUI:SetModifyLayer(goSymbol, nOrder)
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

function MardiGrasLevelUI:GetEffectByEffectPool(strKey)
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

function MardiGrasLevelUI:RecycleEffectToEffectPool(UsedObj)
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

--==================================== 数据库 ======================================
function MardiGrasLevelUI:setDBFreeSpin()
	LevelDataHandler.m_Data.mThemeData.nSelectedYellowMultuile = MardiGrasFunc.nSelectedYellowMultuile
    LevelDataHandler.m_Data.mThemeData.nSelectedRedMultuile = MardiGrasFunc.nSelectedRedMultuile
    LevelDataHandler.m_Data.mThemeData.nSelectedGreenMultuile = MardiGrasFunc.nSelectedGreenMultuile
	LevelDataHandler:persistentData()
end 

function MardiGrasLevelUI:getDBFreeSpin()
	if LevelDataHandler.m_Data.mThemeData.nSelectedGreenMultuile == nil then
		return
	end
    
	MardiGrasFunc.nSelectedYellowMultuile = LevelDataHandler.m_Data.mThemeData.nSelectedYellowMultuile
    MardiGrasFunc.nSelectedRedMultuile = LevelDataHandler.m_Data.mThemeData.nSelectedRedMultuile
    MardiGrasFunc.nSelectedGreenMultuile = LevelDataHandler.m_Data.mThemeData.nSelectedGreenMultuile
end
