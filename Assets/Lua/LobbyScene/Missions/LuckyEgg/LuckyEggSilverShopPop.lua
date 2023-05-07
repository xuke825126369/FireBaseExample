LuckyEggSilverShopPop = {}

function LuckyEggSilverShopPop:Show()
    if not LuaHelper.OrGameObjectExist(self.transform) then
        local goPrefab = AssetBundleHandler:LoadMissionAsset("Missions/LuckyEgg/LuckyEggSilverSalePop.prefab")
        local goPanel = Unity.Object.Instantiate(goPrefab)
        self.transform = goPanel.transform
        self.transform:SetParent(MissionMainUIPop.m_trPopNode, false)
        self.transform.localScale = Unity.Vector3.one
        self.transform.localPosition = Unity.Vector3.zero
        LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
        self.transform.gameObject:SetActive(false)

        self.m_ani = self.transform:GetComponentInChildren(typeof(Unity.Animator))
        self.m_trContent = self.transform:FindDeepChild("Content")
        self.m_btnClose = self.transform:FindDeepChild("BtnClose"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(self.m_btnClose)
        self.m_btnClose.onClick:AddListener(function()
            self.m_btnClose.interactable = false
            GlobalAudioHandler:PlayBtnSound()
            self:Hide()
        end)

        self.m_btnBuy1 = self.transform:FindDeepChild("BtnBuy1"):GetComponent(typeof(UnityUI.Button))
        self.m_btnBuy1Introduce = self.transform:FindDeepChild("PurchaseBenefits1Btn"):GetComponent(typeof(UnityUI.Button))
        local skuInfo1 = self:getSkuInfo(1)
        local price = self.m_btnBuy1.transform:FindDeepChild("Text"):GetComponent(typeof(TextMeshProUGUI))
        price.text = "$"..skuInfo1.nDollar
        DelegateCache:addOnClickButton(self.m_btnBuy1)
        self.m_btnBuy1.onClick:AddListener(function()
            GlobalAudioHandler:PlayBtnSound()
            WindowLoadingView:Show()
            
            EventHandler:AddListener("onPurchaseDoneNotifycation", self)
            EventHandler:AddListener("onPurchaseFailedNotifycation", self)
            UnityPurchasingHandler:purchase(skuInfo1)
        end)
        DelegateCache:addOnClickButton(self.m_btnBuy1Introduce)
        self.m_btnBuy1Introduce.onClick:AddListener(function()
            GlobalAudioHandler:PlayBtnSound()
            ShowPurchaseBenifitPop:Show(skuInfo1)
        end)

        self.m_btnBuy2 = self.transform:FindDeepChild("BtnBuy2"):GetComponent(typeof(UnityUI.Button))
        self.m_btnBuy2Introduce = self.transform:FindDeepChild("PurchaseBenefits2Btn"):GetComponent(typeof(UnityUI.Button))
        self.m_goItem2 = self.transform:FindDeepChild("CuXIao2").gameObject        
    end

    GlobalAudioHandler:PlaySound("popup")
    local bPortraitFlag = not ScreenHelper:isLandScape()
    if bPortraitFlag then
        self.m_trContent.localScale = Unity.Vector3.one * 0.65
    else
        self.m_trContent.localScale = Unity.Vector3.one
    end

    ViewScaleAni:Show(self.transform.gameObject, nil, function()
        self.m_btnClose.interactable = true
        self.m_ani:SetInteger("nPlayMode", 0)
    end)

    self.m_btnBuy2.onClick:RemoveAllListeners()
    self.m_btnBuy2Introduce.onClick:RemoveAllListeners()
    DelegateCache:addOnClickButton(self.m_btnBuy2)
    DelegateCache:addOnClickButton(self.m_btnBuy2Introduce)
    local nCount = 0
    for i = 1, 7 do
        local bFlag = LuckyEggHandler:getSilverEggHammered(i)
        if not bFlag then
            nCount = nCount + 1
        end
    end
    self.m_goItem2:SetActive(nCount > 1)
    if nCount > 1 then
        local skuInfo2 = self:getSkuInfo(nCount)
        local price = self.m_btnBuy2.transform:FindDeepChild("Text"):GetComponent(typeof(TextMeshProUGUI))
        local wasPrice = self.m_goItem2.transform:FindDeepChild("TextWas"):GetComponent(typeof(TextMeshProUGUI))
        wasPrice.text = "WAS $"..skuInfo2.wasPrice
        local textCount = self.m_goItem2.transform:FindDeepChild("TextBreak"):GetComponent(typeof(TextMeshProUGUI))
        textCount.text = "x"..skuInfo2.nSilverCount
        price.text = "$"..skuInfo2.nDollar

        self.m_btnBuy2.onClick:RemoveAllListeners()
        self.m_btnBuy2.onClick:AddListener(function()
            GlobalAudioHandler:PlayBtnSound()
            WindowLoadingView:Show()
            EventHandler:AddListener("onPurchaseDoneNotifycation", self)
            EventHandler:AddListener("onPurchaseFailedNotifycation", self)
            UnityPurchasingHandler:purchase(skuInfo2)
        end)

        self.m_btnBuy2Introduce.onClick:RemoveAllListeners()
        self.m_btnBuy2Introduce.onClick:AddListener(function()
            GlobalAudioHandler:PlayBtnSound()
            ShowPurchaseBenifitPop:Show(skuInfo2)
        end)
    end

end

function LuckyEggSilverShopPop:Hide()
    self.m_ani:SetInteger("nPlayMode", 1)
    ViewScaleAni:Hide(self.transform.gameObject)
end

function LuckyEggSilverShopPop:onPurchaseDoneNotifycation(skuInfo)
    EventHandler:RemoveListener("onPurchaseDoneNotifycation", self)
    EventHandler:RemoveListener("onPurchaseFailedNotifycation", self)
    WindowLoadingView:Hide()

    if skuInfo.nSilverCount > 0 then
        LuckyEggHandler:addSilverHammerCount(skuInfo.nSilverCount)
    end

    if skuInfo.nGoldCount > 0 then
        LuckyEggHandler:addGoldHammerCount(skuInfo.nGoldCount)
    end

    LuckyEggMainUI:updateUI()
    if LuckyEggMainUI.silverUI.transform.gameObject.activeSelf then
        LuckyEggMainUI.silverUI:updateUI()
    end

    self:Hide()
end

function LuckyEggSilverShopPop:onPurchaseFailedNotifycation()
    EventHandler:RemoveListener("onPurchaseDoneNotifycation", self)
    EventHandler:RemoveListener("onPurchaseFailedNotifycation", self)
    WindowLoadingView:Hide()
    CommonDialogBox:ShowSureUI("Purchase Failed")
end

function LuckyEggSilverShopPop:getSkuInfo(nSilverCount)
    local skuList = {
        {productId = AllBuyCFG[1].productId, nSilverCount = 1, wasPrice = AllBuyCFG[1].nDollar * 2},
        {productId = AllBuyCFG[2].productId, nSilverCount = 2, wasPrice = AllBuyCFG[2].nDollar * 2},
        {productId = AllBuyCFG[3].productId, nSilverCount = 3, wasPrice = AllBuyCFG[3].nDollar * 2},
        {productId = AllBuyCFG[4].productId, nSilverCount = 4, wasPrice = AllBuyCFG[4].nDollar * 2},
        {productId = AllBuyCFG[5].productId, nSilverCount = 5, wasPrice = AllBuyCFG[5].nDollar * 2},
        {productId = AllBuyCFG[6].productId, nSilverCount = 6, wasPrice = AllBuyCFG[6].nDollar * 2},
        {productId = AllBuyCFG[7].productId, nSilverCount = 7, wasPrice = AllBuyCFG[7].nDollar * 2}
    }
    
    local currentSku = skuList[1]
    for i = 1, #skuList do
        if nSilverCount == skuList[i].nSilverCount then
            currentSku = skuList[i]
            break
        end
    end

    local skuInfo = LuckyEggMainUI:getLuckyEggSkuInfo(currentSku.productId, nSilverCount, 0, currentSku.wasPrice)
    return skuInfo
end
