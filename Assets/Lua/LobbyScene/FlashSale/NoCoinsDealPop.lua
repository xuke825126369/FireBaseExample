NoCoinsDealPop = PopStackViewBase:New()
local allDealSkusArray = {
    {1, 3, 5},
    {1, 4, 7},
    {1, 5, 9},
    {1, 6, 11},
    {1, 7, 13},
}

function NoCoinsDealPop:Show()
    if not LuaHelper.OrGameObjectExist(self.transform) then
        local go = Unity.Object.Instantiate(AssetBundleHandler:LoadAsset("lobby", "FirstIAP/NoCoinsDealPop.prefab"))
        self.transform = go.transform
        self.transform:SetParent(LobbyScene.popCanvas, false)
        LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
        
        self.m_trContent = self.transform:FindDeepChild("Content")
        local btn = self.transform:FindDeepChild("CloseButton"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(btn)
        btn.onClick:AddListener(function()
            self:onCloseBtnClicked()
        end)

        self.elementsArray = {}
        local itemsContainer = self.transform:FindDeepChild("ItemsContainer")
        for i = 0, itemsContainer.childCount - 1 do
            local item = itemsContainer:GetChild(i)
            local coinCountText = item:FindDeepChild ("FinalCoinValueText"):GetComponent(typeof(UnityUI.Text))
            local normalText = item:FindDeepChild("NormalCoinValueText"):GetComponent(typeof(TextMeshProUGUI))
            local priceText = item:FindDeepChild("PriceText"):GetComponent(typeof(TextMeshProUGUI))
            local upToText = item:FindDeepChild("UpTo"):GetComponent(typeof(UnityUI.Text))
            local redLine = item:FindDeepChild("Redline")
            local elements = {}
            elements.coinCountText = coinCountText
            elements.priceText = priceText
            elements.normalText = normalText
            elements.upToText = upToText
            elements.redLine = redLine
            elements.button = item:FindDeepChild("GoStoreButton"):GetComponent(typeof(UnityUI.Button))
            self.elementsArray[#self.elementsArray+1] = elements
        end
    end

    if not BuyHandler:orHaveRecharge() then
        self.rateTable = {2, 3, 4}
    else
        self.rateTable = {1.5, 2, 2.5}
    end

    self.skuArrayIndex = math.random(1, #allDealSkusArray)
    for i, nBuyIndex in ipairs(allDealSkusArray[self.skuArrayIndex]) do
        local productId = AllBuyCFG[nBuyIndex].productId
        local skuInfo = self:getSkuInfo(productId, self.rateTable[i])

        self.elementsArray[i].normalText.text = "WAS "..MoneyFormatHelper.numWithCommas(skuInfo.baseCoins).." COINS"
        self.elementsArray[i].coinCountText.text = MoneyFormatHelper.numWithCommas(skuInfo.finalCoins)
        self.elementsArray[i].priceText.text = "$"..skuInfo.nDollar

        local rate = math.floor((self.rateTable[i] - 1)*100 + 0.5)/100
        local strRatio = tostring(LuaHelper.GetInteger(rate*100))
        self.elementsArray[i].upToText.text = strRatio.."%"

        self.elementsArray[i].button.onClick:RemoveAllListeners()
        DelegateCache:addOnClickButton(self.elementsArray[i].button)
        self.elementsArray[i].button.onClick:AddListener(function()
            EventHandler:AddListener("onPurchaseDoneNotifycation", self)
            EventHandler:AddListener("onPurchaseFailedNotifycation", self)
            WindowLoadingView:Show()
            self.currentBtn = self.elementsArray[i].button
            UnityPurchasingHandler:purchase(skuInfo)
        end)
    end

    ViewScaleAni:Show(self.transform.gameObject, nil, function()
        for i, nBuyIndex in ipairs(allDealSkusArray[self.skuArrayIndex]) do
            local productId = AllBuyCFG[nBuyIndex].productId
            local localpos = self.elementsArray[i].normalText.textInfo.characterInfo[3].bottomRight
            Debug.Log("characterCount:"..self.elementsArray[i].normalText.textInfo.characterCount)
            local localpos1 = self.elementsArray[i].normalText.textInfo.characterInfo[self.elementsArray[i].normalText.textInfo.characterCount-6].bottomLeft
            local length = Unity.Vector2.Distance(Unity.Vector2(localpos.x,localpos.y), Unity.Vector2(localpos1.x,localpos1.y))
            self.elementsArray[i].redLine.sizeDelta = Unity.Vector2(length, 4)
            self.elementsArray[i].redLine.localRotation = Unity.Quaternion.Euler(0, 0, 0)
        end
    end)

    return true
end

function NoCoinsDealPop:onCloseBtnClicked()
    GlobalAudioHandler:PlayBtnSound()
    ViewScaleAni:Hide(self.transform.gameObject)
end

function NoCoinsDealPop:checkIsShowHugeDis()
    local bShow = false
    local timeNoCoinsDealEndTime = DBHandler:getNoCoinsDealEndTime()
    local now = os.time()
    if timeNoCoinsDealEndTime ~= nil then
        if timeNoCoinsDealEndTime <= now then
            bShow = true
            timeNoCoinsDealEndTime = now + 3600*24
            DBHandler:setNoCoinsDealEndTime(timeNoCoinsDealEndTime)
        else
            bShow = false
        end
    else
        timeNoCoinsDealEndTime = now + 3600*24
        DBHandler:setNoCoinsDealEndTime(timeNoCoinsDealEndTime)
        bShow = true
    end
    return bShow
end

function NoCoinsDealPop:onPurchaseDoneNotifycation(skuInfo)
    WindowLoadingView:Hide()
    EventHandler:RemoveListener("onPurchaseDoneNotifycation", self)
    EventHandler:RemoveListener("onPurchaseFailedNotifycation", self)
    ViewScaleAni:Hide(self.transform.gameObject)
        
    local nAddMoneyCount = skuInfo.finalCoins
    PlayerHandler:AddRecharge(skuInfo.nDollar)
    PlayerHandler:AddCoin(nAddMoneyCount)
    PopStackViewHandler:Show(ShopEndPop, skuInfo)
end 

function NoCoinsDealPop:onPurchaseFailedNotifycation()
    WindowLoadingView:Hide()
    EventHandler:RemoveListener("onPurchaseDoneNotifycation", self)
    EventHandler:RemoveListener("onPurchaseFailedNotifycation", self)
    CommonDialogBox:ShowSureUI("Purchase Failed")
end

function NoCoinsDealPop:getSkuInfo(productId, ratio)
    local skuInfo = GameHelper:GetSimpleSkuInfoById(productId)
    skuInfo.nType = SkuInfoType.ShopCoins
    skuInfo.finalCoins = skuInfo.baseCoins * ratio // 1000 * 1000
    return skuInfo
end