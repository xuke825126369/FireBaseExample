require("Lua.LobbyScene.DailyBonus.DailyBonusChestRewardPop")
require("Lua.LobbyScene.DailyBonus.DailyBonusLoginRewardPop")

DailyBonusPop = PopStackViewBase:New()

function DailyBonusPop:Show()
    if not LuaHelper.OrGameObjectExist(self.transform) then
        self.tableName = "DailyBonusPop"
        local go = Unity.Object.Instantiate(AssetBundleHandler:LoadAsset("lobby", "DailyBonus/DailyBonus.prefab"))
        self.transform = go.transform
        self.transform:SetParent(LobbyScene.popCanvas, false)
        LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)

        self.dayTipContainer = self.transform:FindDeepChild("DayTipConainer")
        self.closeBtn = self.transform:FindDeepChild("CloseBtn"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(self.closeBtn)
        self.closeBtn.onClick:AddListener(function()
            self:onCloseBtnClicked()
        end)

        self.imgProgress = self.transform:FindDeepChild("Progress"):GetComponent(typeof(UnityUI.Image))
        self.dayCountText = self.transform:FindDeepChild("DayCountText"):GetComponent(typeof(TextMeshProUGUI))
        self.m_DaysInfo = {}
        for i = 1, 7 do
            local info = {}
            info.container = self.transform:FindDeepChild("Day"..i.."/SendContainer")
            info.goDone = self.transform:FindDeepChild("Day"..i.."/Done").gameObject
            info.ani = self.transform:FindDeepChild("Day"..i.."/ZiBiaoQian"):GetComponent(typeof(Unity.Animator))
            self.m_DaysInfo[i] = info
        end

        self.tableGoBaoXiangTip = {}
        self.tableGoBaoXiangTip[1] = self.transform:FindDeepChild("RewardDaysTip/Tip1").gameObject
        self.tableGoBaoXiangTip[2] = self.transform:FindDeepChild("RewardDaysTip/Tip2").gameObject
        self.tableGoBaoXiangTip[3] = self.transform:FindDeepChild("RewardDaysTip/Tip3").gameObject
        self.tableGoBaoXiangTip[4] = self.transform:FindDeepChild("RewardDaysTip/Tip4").gameObject

        self.tableGoBaoXiang = {}
        self.tableGoBaoXiang[1] = self.transform:FindDeepChild("Hor/LvBaoXiang").gameObject
        self.tableGoBaoXiang[2] = self.transform:FindDeepChild("Hor/LanBaoXiang").gameObject
        self.tableGoBaoXiang[3] = self.transform:FindDeepChild("Hor/ZiBaoXiang").gameObject
        self.tableGoBaoXiang[4] = self.transform:FindDeepChild("Hor/HongBaoXiang").gameObject

        self.lvBaoXiangBtn = self.transform:FindDeepChild("LvBaoXiang/BaoXiangBtn"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(self.lvBaoXiangBtn)
        self.lvBaoXiangBtn.onClick:AddListener(function()
            GlobalAudioHandler:PlayBtnSound()
            self:onClickBaoXiangBtn(1)
        end)
        self.lanBaoXiangBtn = self.transform:FindDeepChild("LanBaoXiang/BaoXiangBtn"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(self.lanBaoXiangBtn)
        self.lanBaoXiangBtn.onClick:AddListener(function()
            GlobalAudioHandler:PlayBtnSound()
            self:onClickBaoXiangBtn(2)
        end)
        self.ziBaoXiangBtn = self.transform:FindDeepChild("ZiBaoXiang/BaoXiangBtn"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(self.ziBaoXiangBtn)
        self.ziBaoXiangBtn.onClick:AddListener(function()
            GlobalAudioHandler:PlayBtnSound()
            self:onClickBaoXiangBtn(3)
        end)
        self.hongBaoXiangBtn = self.transform:FindDeepChild("HongBaoXiang/BaoXiangBtn"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(self.hongBaoXiangBtn)
        self.hongBaoXiangBtn.onClick:AddListener(function()
            GlobalAudioHandler:PlayBtnSound()
            self:onClickBaoXiangBtn(4)
        end)

        self.animationId = Unity.Animator.StringToHash("ShowEffect")
        self.m_goStamp = self.transform:FindDeepChild("StampAni").gameObject
    end

    self.m_goStamp:SetActive(false)
    self:UpdateChestUI()

    self.closeBtn.interactable = false
    self.dayNum = DailyBonusDataHandler:GetCurrentDayIndex()
    Debug.Log("self.dayNum: "..self.dayNum.." | "..DailyBonusDataHandler.data.nLoginDaysCount)

    local nCount = DailyBonusDataHandler:getDailyBonusLoginDaysCount()
    if nCount > DailyBonusDataHandler.DAILY_BONUS_MAX then
        nCount = DailyBonusDataHandler.DAILY_BONUS_MAX
    end

    self.dayCountText.text = nCount.."/"..DailyBonusDataHandler.DAILY_BONUS_MAX
    self.imgProgress.fillAmount = nCount / DailyBonusDataHandler.DAILY_BONUS_MAX

    self:InitRewardItem()
    GlobalAudioHandler:PlaySound("popup")
    ViewScaleAni:Show(self.transform.gameObject, nil, function()
        self:BeginShowAni()
        for i = 1, 7 do
            local info = self.m_DaysInfo[i]
            if i < self.dayNum then
                info.ani:SetTrigger(self.animationId)
            end
        end
    end)

end

function DailyBonusPop:Hide()
    ViewScaleAni:Hide(self.transform.gameObject, function()
        Unity.Object.Destroy(self.transform.gameObject)
    end)
end

function DailyBonusPop:UpdateChestUI()
    local flag = DailyBonusDataHandler:getChestRewardFlag(1)
    self.lvBaoXiangBtn.interactable = not flag
    self.lvBaoXiangBtn.gameObject:SetActive(not flag)
    self:FindSymbolElement(self.tableGoBaoXiang[1], "GetRewards"):SetActive(flag)

    local flag = DailyBonusDataHandler:getChestRewardFlag(2)
    self.lanBaoXiangBtn.interactable = not flag
    self.lanBaoXiangBtn.gameObject:SetActive(not flag)
    self:FindSymbolElement(self.tableGoBaoXiang[2], "GetRewards"):SetActive(flag)

    local flag = DailyBonusDataHandler:getChestRewardFlag(3)
    self.ziBaoXiangBtn.interactable = not flag
    self.ziBaoXiangBtn.gameObject:SetActive(not flag)
    self:FindSymbolElement(self.tableGoBaoXiang[3], "GetRewards"):SetActive(flag)

    local flag = DailyBonusDataHandler:getChestRewardFlag(4)
    self.hongBaoXiangBtn.interactable = not flag
    self.hongBaoXiangBtn.gameObject:SetActive(not flag)
    self:FindSymbolElement(self.tableGoBaoXiang[4], "GetRewards"):SetActive(flag)
end

function DailyBonusPop:InitRewardItem()
    for i = 1, 7 do
        local info = self.m_DaysInfo[i]
        if info.container.childCount > 0 then
            for k = 0, info.container.childCount - 1 do
               Unity.Object.Destroy(info.container:GetChild(k).gameObject)
            end
        end

        info.goDone:SetActive(i < self.dayNum)
        info.container.gameObject:SetActive(i >= self.dayNum)

        local mapType = DailyBonusDataHandler:getCurrentDayReward(i)
        local nLength = LuaHelper.tableSize(mapType)
        local posX = nLength > 1 and -70 or 0
        for j = 1, nLength do
            local nRewardType = mapType[j].nType
            local path = "DailyBonus/CoinsItem.prefab"
            if nRewardType == DailyBonusDataHandler.nRewardType.Coins then
                path = "DailyBonus/CoinsItem.prefab"
            elseif nRewardType == DailyBonusDataHandler.nRewardType.SlotsCards then
                if SlotsCardsManager:orActivityOpen() then
                    path = "DailyBonus/SlotsCardsItem.prefab"
                end
            elseif nRewardType == DailyBonusDataHandler.nRewardType.VipPoint then
                path = "DailyBonus/VipItem.prefab"
            elseif nRewardType == DailyBonusDataHandler.nRewardType.Diamond then
                path = "DailyBonus/DiamondItem.prefab"
            elseif nRewardType == DailyBonusDataHandler.nRewardType.Activty then
                local active = ActiveManager.activeType
                if active then
                    path = string.format("DailyBonus/%sItem.prefab", active)
                end
            elseif nRewardType == DailyBonusDataHandler.nRewardType.LoungePoints then
                path = "DailyBonus/LoungePointsItem.prefab"
            end
            if path then
                local go = Unity.Object.Instantiate(AssetBundleHandler:LoadAsset("lobby", path))
                self:UpdateItemUI(go.transform, mapType[j])
                go.transform:SetParent(info.container, false)
                go.transform.anchoredPosition3D = Unity.Vector3.zero
                if i ~= 7 then
                    go.transform.anchoredPosition = Unity.Vector2(posX, 0)
                    posX = 100
                end
            end
        end
    end
    
end

function DailyBonusPop:UpdateItemUI(item, info)
    if info.nType == DailyBonusDataHandler.nRewardType.Coins then
        local textCoins = self:FindSymbolElement(item, "CoinsText")
        local nCoins = DailyBonusDataHandler:getBaseCoinsPrize() * info.fRatio
        textCoins.text = MoneyFormatHelper.coinCountOmit(nCoins)
    elseif info.nType == DailyBonusDataHandler.nRewardType.SlotsCards then
        if SlotsCardsManager:orActivityOpen() then
            local textCount = self:FindSymbolElement(item, "PackCountText")
            textCount.text = "+"..info.nCount
            local stars = self:FindSymbolElement(item, "Stars")
            local packTypeContainer = self:FindSymbolElement(item, "IconContainer")
            local packType = info.nSlotsType
            stars.transform.sizeDelta = Unity.Vector2(20* (packType), 20)
            for j = 0, stars.transform.childCount - 1 do
                if j < packType then
                    stars.transform:GetChild(j).gameObject:SetActive(true)
                else
                    stars.transform:GetChild(j).gameObject:SetActive(false)
                end
                packTypeContainer.transform:GetChild(j).gameObject:SetActive(j + 1 == packType)
            end
        else
            local textCoins = self:FindSymbolElement(item, "CoinsText")
            local nCoins = DailyBonusDataHandler:getBaseCoinsPrize()
            textCoins.text = MoneyFormatHelper.coinCountOmit(nCoins)
        end
    elseif info.nType == DailyBonusDataHandler.nRewardType.VipPoint then
        local textCount = self:FindSymbolElement(item, "VipPoint")
        textCount.text = info.nCount
    elseif info.nType == DailyBonusDataHandler.nRewardType.Diamond then
        local textCount = self:FindSymbolElement(item, "DiamondCount")
        textCount.text = info.nCount
    elseif info.nType == DailyBonusDataHandler.nRewardType.Activty then
        local active = ActiveManager.activeType
        if active then
            local textCount = self:FindSymbolElement(item, "CountText")
            textCount.text = _G[active.."IAPConfig"].skuMapOther[info.sku]
        else
            local textCoins = self:FindSymbolElement(item, "CoinsText")
            local nCoins = DailyBonusDataHandler:getBaseCoinsPrize()
            textCoins.text = MoneyFormatHelper.coinCountOmit(nCoins)
        end
    elseif info.nType == DailyBonusDataHandler.nRewardType.LoungePoints then
        local textCount = self:FindSymbolElement(item, "CountText")
        textCount.text = info.nCount
    end

end

function DailyBonusPop:BeginShowAni()
    DailyBonusDataHandler:setDailyBonusReward()

    local nCount = DailyBonusDataHandler:getDailyBonusLoginDaysCount()
    self.dayCountText.text = nCount.."/"..DailyBonusDataHandler.DAILY_BONUS_MAX
    local lastValue = (nCount - 1) / DailyBonusDataHandler.DAILY_BONUS_MAX
    
    local nCurrentDay = self.dayNum
    self.m_goStamp.transform.position = self.m_DaysInfo[nCurrentDay].goDone.transform.position
    
    local mapType = DailyBonusDataHandler:getCurrentDayReward(nCurrentDay)
    DailyBonusLoginRewardPop:Show(mapType, function()
        EventHandler:Brocast("OnSlotsCardsActivityStateChanged")
        self.m_goStamp:SetActive(true)
        LeanTween.delayedCall(self.transform.gameObject, 0.67, function()
            GlobalAudioHandler:PlaySound("chest_drop1")
        end)

        LeanTween.delayedCall(self.transform.gameObject, 1, function()
            local nCount = DailyBonusDataHandler:getDailyBonusLoginDaysCount()
            self.m_DaysInfo[nCurrentDay].goDone:SetActive(true)
            self.m_DaysInfo[nCurrentDay].container.gameObject:SetActive(false)
            self.m_DaysInfo[nCurrentDay].ani:SetTrigger(self.animationId)
            LeanTween.value(self.transform.gameObject, lastValue, nCount / DailyBonusDataHandler.DAILY_BONUS_MAX, 0.5):setOnUpdate(function(value)
                self.imgProgress.fillAmount = value
            end):setOnComplete(function()
                -- 宝箱奖励
                local nGetChestRewardIndex = 0
                if nCount >= 7 and (not DailyBonusDataHandler:getChestRewardFlag(1)) then
                    nGetChestRewardIndex = 1
                elseif nCount >= 15 and (not DailyBonusDataHandler:getChestRewardFlag(2)) then
                    nGetChestRewardIndex = 2
                elseif nCount >= 22 and (not DailyBonusDataHandler:getChestRewardFlag(3)) then
                    nGetChestRewardIndex = 3
                elseif nCount >= 30 and (not DailyBonusDataHandler:getChestRewardFlag(4)) then
                    nGetChestRewardIndex = 4
                end
                if nGetChestRewardIndex ~= 0 then
                    DailyBonusDataHandler:getChestReward(nGetChestRewardIndex)
                end
                if nGetChestRewardIndex == 1 then
                    local ani = self.lvBaoXiangBtn.gameObject:GetComponent(typeof(Unity.Animator))
                    ani:SetTrigger(self.animationId)
                    GlobalAudioHandler:PlaySound("popup1")
                elseif nGetChestRewardIndex == 2 then
                    local ani = self.lanBaoXiangBtn.gameObject:GetComponent(typeof(Unity.Animator))
                    ani:SetTrigger(self.animationId)
                    GlobalAudioHandler:PlaySound("popup1")
                elseif nGetChestRewardIndex == 3 then
                    local ani = self.ziBaoXiangBtn.gameObject:GetComponent(typeof(Unity.Animator))
                    ani:SetTrigger(self.animationId)
                    GlobalAudioHandler:PlaySound("popup1")
                elseif nGetChestRewardIndex == 4 then
                    local ani = self.hongBaoXiangBtn.gameObject:GetComponent(typeof(Unity.Animator))
                    ani:SetTrigger(self.animationId)
                    GlobalAudioHandler:PlaySound("popup1")
                end
                
                if nGetChestRewardIndex == 0 then
                    self.closeBtn.interactable = true
                end

                LeanTween.delayedCall(self.transform.gameObject, 1, function()
                    self.m_goStamp:SetActive(false)
                    if nGetChestRewardIndex ~= 0 then
                        DailyBonusChestRewardPop:Show(nGetChestRewardIndex)
                    end
                    self:UpdateChestUI()
                end)
            end)
        end)
    end)

end

function DailyBonusPop:onCloseBtnClicked()
    self.closeBtn.interactable = false
    GlobalAudioHandler:PlayBtnSound()
    self:Hide()
end

function DailyBonusPop:onClickBaoXiangBtn(nIndex)
    local flag = DailyBonusDataHandler:getChestRewardFlag(nIndex)
    if flag then
        self:UpdateChestUI()
        return
    end
    
    local nCount = DailyBonusDataHandler:getDailyBonusLoginDaysCount()
    if nCount >= DailyBonusDataHandler.tableBaoXiangRewardDaysIndex[nIndex] then
        self:UpdateChestUI()
    else
        for i = 1, 4 do
            self.tableGoBaoXiangTip[i]:SetActive(false)
        end

        local tipGo = self.tableGoBaoXiangTip[nIndex]
        local node = self:FindSymbolElement(self.tableGoBaoXiangTip[nIndex], "TiShiNode")
        if tipGo.activeSelf then
            tipGo:SetActive(false)
        else
            local node = self:FindSymbolElement(self.tableGoBaoXiangTip[nIndex], "TiShiNode")

            local mClickBtn = tipGo.transform:FindDeepChild("TipCloseBtn"):GetComponent(typeof(UnityUI.Button))
            mClickBtn.onClick:RemoveAllListeners()
            mClickBtn.onClick:AddListener(function()
                GlobalAudioHandler:PlayBtnSound()
                tipGo:SetActive(false)
            end)

            local container = self:FindSymbolElement(node, "SendContainer")
            if container.transform.childCount == 0 then
                self:InitTipGoSendContainer(node, container.transform, nIndex)
            end
            tipGo:SetActive(true)
        end
    end
    
end

function DailyBonusPop:InitTipGoSendContainer(tipTr, parent, nChestIndex)
    local tipTr = tipTr.transform:GetComponent(typeof(Unity.RectTransform))

    local chestReward = DailyBonusDataHandler.MAP_CHESTREWARD[nChestIndex]
    local nLength = LuaHelper.tableSize(chestReward)
    for i = 1, nLength do
        local nRewardType = chestReward[i].nType
        local path = "DailyBonus/CoinsItem.prefab"
        if nRewardType == DailyBonusDataHandler.nRewardType.Coins then
            path = "DailyBonus/CoinsItem.prefab"
        elseif nRewardType == DailyBonusDataHandler.nRewardType.SlotsCards then
            if SlotsCardsManager:orActivityOpen() then
                path = "DailyBonus/SlotsCardsItem.prefab"
            end
        elseif nRewardType == DailyBonusDataHandler.nRewardType.VipPoint then
            path = "DailyBonus/VipItem.prefab"
        elseif nRewardType == DailyBonusDataHandler.nRewardType.Diamond then
            path = "DailyBonus/DiamondItem.prefab"
        elseif nRewardType == DailyBonusDataHandler.nRewardType.Activty then
            local active = ActiveManager.activeType
            if active then
                path = string.format("DailyBonus/%sItem.prefab", active)
            end
        elseif nRewardType == DailyBonusDataHandler.nRewardType.LoungePoints then
            path = "DailyBonus/LoungePointsItem.prefab"
        end

        if path then
            local go = Unity.Object.Instantiate(AssetBundleHandler:LoadAsset("lobby", path))
            self:UpdateItemUI(go.transform, chestReward[i])
            go.transform:SetParent(parent, false)
            go.transform.anchoredPosition3D = Unity.Vector3.zero
            go.transform.localScale = Unity.Vector3.one
        end
    end 
    
    tipTr.sizeDelta = Unity.Vector2(120 * nLength, 130)
end

function DailyBonusPop:FindSymbolElement(goSymbol, strKey, bSelf)
    if GameConfig.PLATFORM_EDITOR then
		local tablePoolKey = {"GetRewards", "CoinsText", "PackCountText", "Stars", "IconContainer", 
        "VipPoint", "DiamondCount", "CountText", "SendContainer", "TiShiNode", "Tip" }
        Debug.Assert(LuaHelper.tableContainsElement(tablePoolKey, strKey))
    end

    if self.goSymbolElementPool == nil then
        self.goSymbolElementPool = {}
    end

    if self.goSymbolElementPool[goSymbol] == nil then
        self.goSymbolElementPool[goSymbol] = {}
    end     

    if self.goSymbolElementPool[goSymbol][strKey] == nil then
        local goTran = nil
        if bSelf then
            goTran = goSymbol.transform
        else
            goTran = goSymbol.transform:FindDeepChild(strKey)
        end

        if goTran then
            local go = goTran.gameObject

            if strKey == "CountText" or strKey == "CoinsText" or strKey == "PackCountText" or strKey == "VipPoint" or strKey == "DiamondCount" then
                self.goSymbolElementPool[goSymbol][strKey] = go:GetComponent(typeof(TextMeshProUGUI))
            else
                self.goSymbolElementPool[goSymbol][strKey] = go
            end
        end

    end     
    
    return self.goSymbolElementPool[goSymbol][strKey]
end