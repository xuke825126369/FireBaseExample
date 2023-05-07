AliceLevelUI = {}

function AliceLevelUI:InitVariable()
    self.m_LeanTweenIDs = {}
    self.m_transform = nil
        
    self.m_RegisterLoadEffectNameTable = {"lztukuai", "catFeatureEffect"}
    self.tableFixedGoSymbol = {}
end 

function AliceLevelUI:initLevelUI()
    self:InitVariable()
    AliceFunc:InitVariable()

    self.m_transform = ThemeVideoScene.mNewGameNodeParent:FindDeepChild("LevelBG")
    LuaAutoBindMonoBehaviour.Bind(self.m_transform.gameObject, self)
    
    self.mFreeSpinBeginSplashUI = require "Lua/ThemeVideo/Alice/FreeSpinBeginSplashUI"
    self.mFreeSpinBeginSplashUI:Init()

    self.mFreeSpinAgainSplashUI = require "Lua/ThemeVideo/Alice/FreeSpinAgainSplashUI"
    self.mFreeSpinAgainSplashUI:Init()

    self.mFreeSpinFinishSplashUI = require "Lua/ThemeVideo/Alice/FreeSpinFinishSplashUI"
    self.mFreeSpinFinishSplashUI:Init()

    self.mDeckResultPayLines = require "Lua/ThemeVideo/Alice/DeckResultPayLines"
    self.mDeckResultPayLines:Init(SlotsGameLua)

    self.goFreeSpinScatterSel = self.m_transform:FindDeepChild("FreeSpinScatterSel").gameObject
    self.goPickBottom1 = self.goFreeSpinScatterSel.transform:FindDeepChild("goPickBottom1").gameObject
    self.goPickBottom2 = self.goFreeSpinScatterSel.transform:FindDeepChild("goPickBottom2").gameObject
    self.goPickBottom3 = self.goFreeSpinScatterSel.transform:FindDeepChild("goPickBottom3").gameObject
    self.goPickTop1 = self.goFreeSpinScatterSel.transform:FindDeepChild("goPickTop1").gameObject
    self.goPickTop2 = self.goFreeSpinScatterSel.transform:FindDeepChild("goPickTop2").gameObject
    self.goPickTop3 = self.goFreeSpinScatterSel.transform:FindDeepChild("goPickTop3").gameObject

    self.goFreeSpinTip = self.goFreeSpinScatterSel.transform:FindDeepChild("FreeSpinTip").gameObject
    self.goFreeSpinTip_X3 = self.goFreeSpinScatterSel.transform:FindDeepChild("FreeSpinTip/X3").gameObject
    self.goFreeSpinTip_Alice = self.goFreeSpinScatterSel.transform:FindDeepChild("FreeSpinTip/Alice").gameObject
    self.goFreeSpinTip_Cat = self.goFreeSpinScatterSel.transform:FindDeepChild("FreeSpinTip/Cat").gameObject
    self.goFreeSpinScatterSel:SetActive(false)

    self.goFreeSpinWinX3Logo = self.m_transform:FindDeepChild("FreeSpinWinX3Logo").gameObject
    self.goFreeSpinWinX3Logo:SetActive(false)

end 

function AliceLevelUI:Update()
    self.mDeckResultPayLines:ShowAllMatchLines()
    self.mDeckResultPayLines:DisplayMatchLinesInfo()
end

function AliceLevelUI:OnDestroy()
    self:CancelLeanTween()
    LuaHelper.ReleaseVariable(self)
    LuaHelper.ReleaseVariable(AliceFunc)
end

function AliceLevelUI:CancelLeanTween()
	local count = #self.m_LeanTweenIDs
	for i=1, count do
		local id = self.m_LeanTweenIDs[i]
		if LeanTween.isTweening(id) then
			LeanTween.cancel(id)
		end
	end
	self.m_LeanTweenIDs = {}
end

function AliceLevelUI:SetInteger(mAnimator, strKey, nAction)
    if mAnimator.gameObject.activeInHierarchy then
        if mAnimator:GetInteger(strKey) ~= nAction then
            mAnimator:SetInteger(strKey, nAction)
        end
    end
end

-- 查找某个符号的子节点，并缓存下来，高效可靠
function AliceLevelUI:FindSymbolElement(goSymbol, strKey)
    local tablePoolKey = {"Canvas", "clickBtn"}

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

            if strKey == "clickBtn" then 
                self.goSymbolElementPool[goSymbol][strKey] = go:GetComponent(typeof(UnityUI.Button))
            else
                self.goSymbolElementPool[goSymbol][strKey] = go
            end
        end
    end 

    return self.goSymbolElementPool[goSymbol][strKey]
end

function AliceLevelUI:CheckRecoverInfo()
    self.tableCachePos = {}
    for i = 0, SlotsGameLua.m_nReelCount - 1 do
        for j = 0, SlotsGameLua.m_nRowCount * 2 - 1 do
            local nKey = i * SlotsGameLua.m_nRowCount + j
            local goSymbol = SlotsGameLua.m_listReelLua[i].m_listGoSymbol[j]
            self.tableCachePos[nKey] = goSymbol.transform.position
        end
    end
    
    for i = 0, SlotsGameLua.m_nReelCount - 1 do
        for j = 0, SlotsGameLua.m_nRowCount * 2 - 1 do
            local nSymbolId =  AliceSymbol:GetCommonSymbolIdByReelId(i)
            AliceLevelUI:FillSymbol(nSymbolId, i, j)
        end
    end

    if SlotsGameLua.m_GameResult:InFreeSpin() then
        AliceLevelUI:getDBFreeSpin()
        self:PlayFreeSpinBeginHideAni()
    end

end

-- 显示Scatter 特效 -- 统一使用播放spine动画的接口: PlayActiveAnimation(enumType, true, 1.0)
function AliceLevelUI:ShowScatterBonusEffect()
    self.tableCollectScatter = {}

    for x = 0, SlotsGameLua.m_nReelCount - 1 do
        for y = 0, SlotsGameLua.m_nRowCount - 1 do
            local nKey = x * SlotsGameLua.m_nRowCount + y
            local reel = SlotsGameLua.m_listReelLua[x]

            local nSymbolId = reel.m_curSymbolIds[y]
            if AliceSymbol:isScatterSymbol(nSymbolId) then
                local goSymbol = reel.m_listGoSymbol[y]
                self.tableCollectScatter[nKey] = goSymbol
            end
        end
    end                  

    for k, v in pairs(self.tableCollectScatter) do
        SymbolObjectPool.m_mapSpinEffect[v]:PlayAnimation("animation", 0.0, true)
    end
end

function AliceLevelUI:handleFreeSpinBegin()
    self.mDeckResultPayLines:MatchLineHide()

    local bDelayTime = 0.5
    local bPlayScatterAniTime = 1.35 * 2
    LeanTween.delayedCall(bDelayTime, function()
        self:ShowScatterBonusEffect()

        if SlotsGameLua.m_GameResult.m_nFreeSpinCount == 0  then
            AudioHandler:PlayFreeGameTriggeredSound()
        else
            AudioHandler:PlayRetriggerSound()
        end 
    end)

    if SlotsGameLua.m_GameResult.m_nFreeSpinCount == 0 then
        LeanTween.delayedCall(2.0, function()
            self:PlayFreeSpinBeginAni()
        end)
    else
        LeanTween.delayedCall(3.5, function()
            self.mFreeSpinAgainSplashUI:Show()
        end)
    end

end

function AliceLevelUI:handleFreeSpinEnd()
    self.mDeckResultPayLines:MatchLineHide()
    self.mFreeSpinFinishSplashUI:Show()
end

function AliceLevelUI:PlayFreeSpinBeginAni()
    self.goFreeSpinScatterSel:SetActive(true)
    self.goFreeSpinTip:SetActive(false)

    self.goPickBottom1:SetActive(false)
    self.goPickBottom2:SetActive(false)
    self.goPickBottom3:SetActive(false)
    self.goPickTop1:SetActive(false)
    self.goPickTop2:SetActive(false)
    self.goPickTop3:SetActive(false)

    for i = 0, SlotsGameLua.m_nReelCount - 1 do
        for j = 0, SlotsGameLua.m_nRowCount - 1 do
            local nKey = i * SlotsGameLua.m_nRowCount + j
            local nSymbolId = SlotsGameLua.m_listDeck[nKey]
            local goSymbol = SlotsGameLua.m_listReelLua[i].m_listGoSymbol[j]
            if AliceSymbol:isScatterSymbol(nSymbolId) then
                local goCanvas = AliceLevelUI:FindSymbolElement(goSymbol, "Canvas")
                goCanvas:SetActive(true)
                local mClickBtn = AliceLevelUI:FindSymbolElement(goSymbol, "clickBtn")
                mClickBtn.onClick:RemoveAllListeners()
                mClickBtn.onClick:AddListener(function()
                    self.goFreeSpinTip:SetActive(true)
                    self.goFreeSpinTip.transform.position = goSymbol.transform.position

                    self.goFreeSpinTip_X3:SetActive(false)
                    self.goFreeSpinTip_Alice:SetActive(false)
                    self.goFreeSpinTip_Cat:SetActive(false)
                    if AliceFunc.nPickQueenFeature == 1 then
                        self.goFreeSpinTip_X3:SetActive(true)
                    elseif AliceFunc.nPickQueenFeature == 2 then
                        self.goFreeSpinTip_Cat:SetActive(true)
                    elseif AliceFunc.nPickQueenFeature == 3 then
                        self.goFreeSpinTip_Alice:SetActive(true)
                    end

                    LeanTween.delayedCall(3.0, function()
                        self.mFreeSpinBeginSplashUI:Show()
                    end)
                end)

                if j >= 2 then
                    if i == 0 then
                        self.goPickBottom1:SetActive(true)
                        self.goPickBottom1.transform.position = goSymbol.transform.position
                    elseif i == 2 then
                        self.goPickBottom2:SetActive(true)
                        self.goPickBottom2.transform.position = goSymbol.transform.position
                    elseif i == 4 then
                        self.goPickBottom3:SetActive(true)
                        self.goPickBottom3.transform.position = goSymbol.transform.position
                    end
                else
                    if i == 0 then
                        self.goPickTop1:SetActive(true)
                        self.goPickTop1.transform.position = goSymbol.transform.position
                    elseif i == 2 then
                        self.goPickTop2:SetActive(true)
                        self.goPickTop2.transform.position = goSymbol.transform.position
                    elseif i == 4 then
                        self.goPickTop3:SetActive(true)
                        self.goPickTop3.transform.position = goSymbol.transform.position
                    end
                end
            end
        end
    end
    
    if SlotsGameLua.m_bAutoSpinFlag then
        LeanTween.delayedCall(3.0,function()
            self.mFreeSpinBeginSplashUI:Show()
        end)
    end
end

function AliceLevelUI:PlayFreeSpinBeginHideAni()
    self.goFreeSpinScatterSel:SetActive(false)

    if AliceFunc.nPickQueenFeature == 1 then
        self.goFreeSpinWinX3Logo:SetActive(true)
    else
        self.goFreeSpinWinX3Logo:SetActive(false)
    end

end

function AliceLevelUI:PlayFreeSpinEndHideAni()
    self.goFreeSpinWinX3Logo:SetActive(false)
    for k, v in pairs(AliceLevelUI.tableFixedGoSymbol) do
        AliceLevelUI:SetModifyLayer(v, -10)
        SymbolObjectPool:Unspawn(v)
    end

    AliceLevelUI.tableFixedGoSymbol = {}
    AliceFunc.tableFixedAliceSymbol = {}
end

function AliceLevelUI:FillSymbol(nSymbolId, nReelId, nRowIndex)
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

function AliceLevelUI:FixedAliceSymbol(nSymbolId, nReelId, nRowIndex)
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

---------------------- 设置 符号 的层级 -----------------------------
function AliceLevelUI:CacheSymbolElementLayer(goSymbol)
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

function AliceLevelUI:SetModifyLayer(goSymbol, nOrder)
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

function AliceLevelUI:GetEffectByEffectPool(strKey)
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

function AliceLevelUI:RecycleEffectToEffectPool(UsedObj)
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
function AliceLevelUI:setDBFreeSpin()
    LevelDataHandler.m_Data.mThemeData.nPickQueenFeature = AliceFunc.nPickQueenFeature
    
    local tableFixedAliceSymbol = {}
    for k, v in pairs(AliceFunc.tableFixedAliceSymbol) do
        table.insert(tableFixedAliceSymbol, {k, v})
    end

    LevelDataHandler.m_Data.mThemeData.tableFixedAliceSymbol = tableFixedAliceSymbol
    LevelDataHandler:persistentData()
end

function AliceLevelUI:getDBFreeSpin()
    AliceFunc.nPickQueenFeature = LevelDataHandler.m_Data.mThemeData.nPickQueenFeature
    AliceFunc.tableFixedAliceSymbol = {}
    for k, v in pairs(LevelDataHandler.m_Data.mThemeData.tableFixedAliceSymbol) do
        AliceFunc.tableFixedAliceSymbol[v[1]] = v[2]
    end
end
