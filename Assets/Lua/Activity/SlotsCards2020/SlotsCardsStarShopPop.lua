SlotsCardsStarShopPop = {}
SlotsCardsStarShopPop.m_bTestAllCompletedFlag = false
SlotsCardsStarShopPop.tableNPrice = {0, 100, 300, 500, 600, 1500}

function SlotsCardsStarShopPop:Show()
    if not LuaHelper.OrGameObjectExist(self.transform) then
        local goPrefab = AssetBundleHandler:LoadSlotsCardsAsset("StarShopPop.prefab")
        local goPanel = Unity.Object.Instantiate(goPrefab)
        self.transform = goPanel.transform
        self.transform:SetParent(LobbyScene.popCanvas, false)
        self.transform.localScale = Unity.Vector3.one
        self.transform.localPosition = Unity.Vector3.zero
        LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
        self.transform.gameObject:SetActive(false)

        self.btnClose = self.transform:FindDeepChild("BtnClose"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(self.btnClose)
        self.btnClose.onClick:AddListener(function()
            SlotsCardsAudioHandler:PlaySound("click")
            self:Hide()
        end)

        self.btnContainer = self.transform:FindDeepChild("BtnList")
        for i=1,6 do
            local item = self.btnContainer:GetChild(i-1)
            if i == 1 then
                self.freeBtnText = item:FindDeepChild("ConsumeStarCount"):GetComponent(typeof(TextMeshProUGUI))
                self.freeBtn = item:GetComponentInChildren(typeof(UnityUI.Button))
            end
            
            self:SetBtnInfo(item, i)
            local btn = item:GetComponentInChildren(typeof(UnityUI.Button))
            DelegateCache:addOnClickButton(btn)
            btn.onClick:AddListener(function()
                self:OnBtnClicked(item, btn, i)
            end)
        end
        self.textStarCount = self.transform:FindDeepChild("StarCount"):GetComponent(typeof(UnityUI.Text))
        self.mTimeOutGenerator = TimeOutGenerator:New()
    else
        self:RefreshUI()
    end
    
    ViewScaleAni:Show(self.transform.gameObject)
    self:UpdateStarCountUI()
end

function SlotsCardsStarShopPop:RefreshUI()
    for i=1,6 do
        local item = self.btnContainer:GetChild(i-1)
        self:SetBtnInfo(item, i)
    end
end

function SlotsCardsStarShopPop:UpdateStarCountUI()
    self.textStarCount.text = "Stars: "..SlotsCardsHandler:getTotalStarCount()
end

function SlotsCardsStarShopPop:getStarShopCoins(nIndex)
    local nCoins = 0
    local strSku
    if nIndex == 2 then
        strSku = AllBuyCFG[1].productId
    elseif nIndex == 3 then
        strSku = AllBuyCFG[1].productId
    end
    
    local skuInfo = GameHelper:GetSimpleSkuInfoById( strSku)
    nCoins = FormulaHelper:GetAddMoneyBySpendDollar(skuInfo.nDollar)
    return nCoins
end

function SlotsCardsStarShopPop:SetBtnInfo(item, nIndex)
    local bIsCompleted = SlotsCardsHandler.data.activityData[SlotsCardsManager.album].bIsGetCompletedGift
    local btn = item:GetComponentInChildren(typeof(UnityUI.Button))
    local starCount = SlotsCardsHandler:getTotalStarCount()
    local consumeText = item:FindDeepChild("ConsumeStarCount"):GetComponent(typeof(TextMeshProUGUI))
    local nPrice = self.tableNPrice[nIndex]
    if nIndex == 1 then
        local packContainer = item.transform:FindDeepChild("PackType")
        local nType = SlotsCardsHandler:getNextFreePackType()
        for i = 0, (packContainer.childCount - 1) do
            packContainer:GetChild(i).gameObject:SetActive(i==nType)
        end
    elseif nIndex == 2 then
        consumeText.text = nPrice
        local coinRewardText = item:FindDeepChild("GetGift"):GetComponent(typeof(TextMeshProUGUI))
        local winCoin = self:getStarShopCoins(nIndex) -- 这里取商店10美元的
        coinRewardText.text = MoneyFormatHelper.coinCountOmit(winCoin)
        if starCount < nPrice then
            btn.interactable = false
        else
            btn.interactable = true
        end
    elseif nIndex == 3 then
        consumeText.text = nPrice
        local coinRewardText = item:FindDeepChild("GetGift"):GetComponent(typeof(TextMeshProUGUI))
        local winCoin = self:getStarShopCoins(nIndex) -- 这里取商店30美元的

        coinRewardText.text = MoneyFormatHelper.coinCountOmit(winCoin)
        if starCount < nPrice then
            btn.interactable = false
        else
            btn.interactable = true
        end
    elseif nIndex == 4 then
        consumeText.text = nPrice
        if starCount < nPrice then
            btn.interactable = false
        else
            if bIsCompleted then
                btn.interactable = false
            else
                btn.interactable = true
            end
        end
    elseif nIndex == 5 then
        consumeText.text = nPrice
        if starCount < nPrice then
            btn.interactable = false
        else
            if bIsCompleted then
                btn.interactable = false
            else
                btn.interactable = true
            end
        end
    elseif nIndex == 6 then
        consumeText.text = nPrice
        if starCount < nPrice then
            btn.interactable = false
        else
            if bIsCompleted then
                btn.interactable = false
            else
                btn.interactable = true
            end
        end
    end
end

function SlotsCardsStarShopPop:OnBtnClicked(item, btn, nIndex)
    Debug.Log("SlotsCardsStarShopPop:OnBtnClicked "..nIndex)
    SlotsCardsAudioHandler:PlaySound("button")
    local starCount = SlotsCardsHandler:getTotalStarCount()
    local nPrize = self.tableNPrice[nIndex]
    if nIndex == 1 then
        local lastType = SlotsCardsHandler:getNextFreePackType()
        SlotsCardsHandler:addPackCount(lastType, 1)
        SlotsCardsGetPackPop:Show(lastType, true, 1)
        local nType = self:randomGetPackType()
        SlotsCardsHandler:setFreePackTime(nType)
        local packContainer = item.transform:FindDeepChild("PackType")
        for i = 0, (packContainer.childCount - 1) do
            packContainer:GetChild(i).gameObject:SetActive(i==nType)
        end
    elseif nIndex == 2 then
        if starCount < nPrize then
            return
        end
        btn.interactable = false
        local winCoin = self:getStarShopCoins(nIndex)
        local rewardCoins = self:RandomGetCoinsWinUpTo(winCoin)
        PlayerHandler:AddCoin(rewardCoins)
        SlotsCardsGetCoinsPop:Show(rewardCoins)
        SlotsCardsHandler:reduceStarCount(nPrize)
        self:UpdateStarCountUI()
    elseif nIndex == 3 then
        if starCount < nPrize then
            return
        end
        btn.interactable = false
        local winCoin = self:getStarShopCoins(nIndex)
        local rewardCoins = self:RandomGetCoinsWinUpTo(winCoin)
        PlayerHandler:AddCoin(rewardCoins)
        SlotsCardsGetCoinsPop:Show(rewardCoins)
        SlotsCardsHandler:reduceStarCount(nPrize)
        self:UpdateStarCountUI()
    elseif nIndex == 4 then
        if starCount < nPrize then
            return
        end
        btn.interactable = false
        SlotsCardsHandler:addPackCount(SlotsCardsAllProbTable.PackType.Four, 1)
        SlotsCardsGetPackPop:Show(SlotsCardsAllProbTable.PackType.Four, true, 1)
        SlotsCardsHandler:reduceStarCount(nPrize)
        self:UpdateStarCountUI()
    elseif nIndex == 5 then
        if starCount < nPrize then
            return
        end
        btn.interactable = false
        SlotsCardsHandler:addPackCount(SlotsCardsAllProbTable.PackType.Five, 1)
        SlotsCardsGetPackPop:Show(SlotsCardsAllProbTable.PackType.Five, true, 1)
        SlotsCardsHandler:reduceStarCount(nPrize)
        self:UpdateStarCountUI()
    elseif nIndex == 6 then
        if starCount < nPrize then
            return
        end
        btn.interactable = false
        SlotsCardsHandler:addStampBonus(1)
        EventHandler:Brocast("ShowBonusStampPop")
        SlotsCardsHandler:reduceStarCount(nPrize)
        self:UpdateStarCountUI()
        self:Hide()
    end
    SlotsCardsMainUIPop:UpdateStarCount()
    LeanTween.delayedCall(0.5, function()
        self:RefreshUI()
    end)
end

function SlotsCardsStarShopPop:RandomGetCoinsWinUpTo(winUpTo)
    local tableRatio = {690, 560, 520, 390, 370, 350, 230, 220, 100, 50, 30, 20, 10, 10, 10}
    local listCoefs = {0.1, 0.15, 0.2, 0.25, 0.3, 0.35, 0.4, 0.45, 0.5, 0.6, 0.7, 0.75, 0.8, 0.9, 1.0}
    local index = LuaHelper.GetIndexByRate(tableRatio)
    
    local nCoin = winUpTo * listCoefs[index]
    local nWinCoin = MoneyFormatHelper.normalizeCoinCount(nCoin)
    return nWinCoin
end

function SlotsCardsStarShopPop:refreshFreePackBtn()
    local btn = self.freeBtn
    local text = self.freeBtnText
    local lastFreeTime = SlotsCardsHandler:getFreePackTime()
    if lastFreeTime == nil then
        lastFreeTime = TimeHandler:GetServerTimeStamp()
    end

    local endTime = lastFreeTime + SlotsCardsHandler.FREEPACKTIMEDIFF
    local nowSecond = TimeHandler:GetServerTimeStamp()
    local timediff = endTime - nowSecond
    btn.interactable = timediff <= 0

    local days = timediff // (3600*24)
    local hours = timediff // 3600 - 24 * days
    local minutes = timediff // 60 - 24 * days * 60 - 60 * hours
    local seconds = timediff % 60
    text.text = string.format("%02d:%02d:%02d", hours, minutes, seconds) --os.date("%H:%M:%S", time)
    if timediff <= 0 then
        text.text = "Free"
    end
end

function SlotsCardsStarShopPop:randomGetPackType()
    local probs = SlotsCardsAllProbTable.GetPackTypeProb.probs
    local nRandomIndex = LuaHelper.GetIndexByRate(probs)
    return nRandomIndex
end

function SlotsCardsStarShopPop:Hide()
    SlotsCardsMainUIPop:ShowMainUI()
    ViewScaleAni:Hide(self.transform.gameObject)
end

function SlotsCardsStarShopPop:Update()
    if self.mTimeOutGenerator:orTimeOut() then
        self:refreshFreePackBtn()
    end
end

function SlotsCardsStarShopPop:onSecond(second)
    
end