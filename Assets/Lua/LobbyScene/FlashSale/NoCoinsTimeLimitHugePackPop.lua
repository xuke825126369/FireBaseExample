NoCoinsTimeLimitHugePackPop = PopStackViewBase:New()

function NoCoinsTimeLimitHugePackPop:Show()
    if not LuaHelper.OrGameObjectExist(self.transform) then
        local go = Unity.Object.Instantiate(AssetBundleHandler:LoadAsset("lobby", "FirstIAP/NoCoinsTimeLimitHugePackPop.prefab"))
        self.transform = go.transform
        self.transform:SetParent(LobbyScene.popCanvas, false)
        LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)

        self.m_trContent = self.transform:FindDeepChild("Content")
        local btn = self.transform:FindDeepChild("ButtonClose"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(btn)
        btn.onClick:AddListener(function()
            self:onCloseBtnClicked()
        end)
        
        self.button = self.transform:FindDeepChild ("ButtonCollect"):GetComponent(typeof(UnityUI.Button))
        self.timeText = self.transform:FindDeepChild("TimeText"):GetComponent(typeof(TextMeshProUGUI))
        self:refreshContent()

        self.mTimeOutGenerator = TimeOutGenerator:New()
    end

    self.button.interactable = true
    ViewScaleAni:Show(self.transform.gameObject, nil, function()
        local localpos = self.getOldCoinCountText.textInfo.characterInfo[3].bottomRight
        local localpos1 = self.getOldCoinCountText.textInfo.characterInfo[self.getOldCoinCountText.textInfo.characterCount-6].bottomLeft
        local length = Unity.Vector2.Distance(Unity.Vector2(localpos.x,localpos.y), Unity.Vector2(localpos1.x,localpos1.y))
        local redLine = self.transform:FindDeepChild("Redline")
        redLine.sizeDelta = Unity.Vector2(length, 4)
        redLine.localRotation = Unity.Quaternion.Euler(0, 0, 0)
    end)
end

function NoCoinsTimeLimitHugePackPop:refreshContent()
    local ratioText = self.transform:FindDeepChild ("Ratio"):GetComponent(typeof(UnityUI.Text))
    local getCoinsText = self.transform:FindDeepChild ("GetCoins"):GetComponent(typeof(UnityUI.Text))
    self.getOldCoinCountText = self.transform:FindDeepChild("OldCoins"):GetComponent(typeof(TextMeshProUGUI))
    local priceText = self.transform:FindDeepChild("Price"):GetComponent(typeof(TextMeshProUGUI))

    local productId = FlashSaleHandler.data.productId
    local ratio = FlashSaleHandler.data.nSaleMultuile

    local skuInfo = self:getSkuInfo(productId)
    local str = tostring(math.floor(skuInfo.baseCoins))
    LeanTween.scale(self.button.gameObject, Unity.Vector3.one*0.9, 0.8):setEase(LeanTweenType.easeInQuad):setLoopPingPong(-1)

    getCoinsText.text = MoneyFormatHelper.numWithCommas(skuInfo.finalCoins)
    self.getOldCoinCountText.text = "WAS "..MoneyFormatHelper.numWithCommas(skuInfo.baseCoins).." COINS"
    local moreNum = LuaHelper.GetInteger((ratio - 1) * 100)
    ratioText.text = string.format("%d",moreNum).."%"
    priceText.text = "$ "..skuInfo.nDollar.."USD"
    DelegateCache:addOnClickButton(self.button)
    self.button.onClick:AddListener(function()
        self.button.interactable = false

        EventHandler:AddListener("onPurchaseDoneNotifycation", self)
        EventHandler:AddListener("onPurchaseFailedNotifycation", self)
        WindowLoadingView:Show()
        UnityPurchasingHandler:purchase(skuInfo)
    end)
end

function NoCoinsTimeLimitHugePackPop:onCloseBtnClicked()
    GlobalAudioHandler:PlayBtnSound()
    ViewScaleAni:Hide(self.transform.gameObject)
end

function NoCoinsTimeLimitHugePackPop:getSkuInfo(productId)
    local ratio = FlashSaleHandler.data.nSaleMultuile
    local skuInfo = GameHelper:GetSimpleSkuInfoById(productId)
    skuInfo.finalCoins = skuInfo.baseCoins * ratio // 1000 * 1000
    return skuInfo
end

function NoCoinsTimeLimitHugePackPop:onPurchaseDoneNotifycation(skuInfo)
    WindowLoadingView:Hide()
    EventHandler:RemoveListener("onPurchaseDoneNotifycation", self)
    EventHandler:RemoveListener("onPurchaseFailedNotifycation", self)
    ViewScaleAni:Hide(self.transform.gameObject)
    
    local nAddMoneyCount = skuInfo.finalCoins
    PlayerHandler:AddRecharge(skuInfo.nDollar)
    PlayerHandler:AddCoin(nAddMoneyCount)
    PopStackViewHandler:Show(ShopEndPop, skuInfo)
end

function NoCoinsTimeLimitHugePackPop:onPurchaseFailedNotifycation()
    WindowLoadingView:Hide()
    EventHandler:RemoveListener("onPurchaseDoneNotifycation", self)
    EventHandler:RemoveListener("onPurchaseFailedNotifycation", self)

    self.button.interactable = true
    CommonDialogBox:ShowSureUI("Purchase Failed")
end

function NoCoinsTimeLimitHugePackPop:Update()
    if self.mTimeOutGenerator:orTimeOut() then
        self:onSecond()
    end
end

function NoCoinsTimeLimitHugePackPop:onSecond()
    local timediff = FlashSaleHandler.data.nSaleEndTimeStamp - TimeHandler:GetServerTimeStamp()
    if timediff <= 0 then
        ViewScaleAni:Hide(self.transform.gameObject)
    end
    
    self.timeText.text = GameHelper:GetRemainTimeDes(timediff)
end