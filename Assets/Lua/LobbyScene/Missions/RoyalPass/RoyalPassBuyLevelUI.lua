RoyalPassBuyLevelUI = {}

function RoyalPassBuyLevelUI:Show()
    if not LuaHelper.OrGameObjectExist(self.transform) then
        local goPrefab = AssetBundleHandler:LoadMissionAsset("Missions/RoyalPass/PopPrefab/RoyalPassBuyLevelUI.prefab")
        local goPanel = Unity.Object.Instantiate(goPrefab)
        self.transform = goPanel.transform
        self.transform:SetParent(MissionMainUIPop.m_trPopNode, false)
        self.transform.localScale = Unity.Vector3.one
        self.transform.localPosition = Unity.Vector3.zero
        LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
        self.transform.gameObject:SetActive(false)

        self.m_trContent = self.transform:FindDeepChild("Content")
        self.m_btnClose = self.transform:FindDeepChild("BtnClose"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(self.m_btnClose)
        self.m_btnClose.onClick:AddListener(function()
            self.m_btnClose.interactable = false
            GlobalAudioHandler:PlayBtnSound()
            self:Hide()
        end)

        self.m_goUnlockRoyalPassItem = self.transform:FindDeepChild("UnlockRoyalPassItem").gameObject
        self.m_btnUnlockRoyalPass = self.transform:FindDeepChild("BtnUnlockRoyalPass"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(self.m_btnUnlockRoyalPass)
        self.m_btnUnlockRoyalPass.onClick:AddListener(function()
            self.m_btnClose.interactable = false
            GlobalAudioHandler:PlayBtnSound()
            self:Hide()
            RoyalPassShopUI:Show()
        end)
        self.m_goAdd5LevelItem = self.transform:FindDeepChild("Add5LevelItem").gameObject
        self.m_btnAdd5Level = self.m_goAdd5LevelItem.transform:FindDeepChild("BtnBuy"):GetComponent(typeof(UnityUI.Button))
        self.m_btnAdd5LevelIntroduce = self.m_goAdd5LevelItem.transform:FindDeepChild("BtnPurchaseBenefits"):GetComponent(typeof(UnityUI.Button))
        
        self.m_goAdd10LevelItem = self.transform:FindDeepChild("Add10LevelItem").gameObject
        self.m_btnAdd10Level = self.m_goAdd10LevelItem.transform:FindDeepChild("BtnBuy"):GetComponent(typeof(UnityUI.Button))
        self.m_btnAdd10LevelIntroduce = self.m_goAdd10LevelItem.transform:FindDeepChild("BtnPurchaseBenefits"):GetComponent(typeof(UnityUI.Button))
        
        self.m_goAdd20LevelItem = self.transform:FindDeepChild("Add20LevelItem").gameObject
        self.m_btnAdd20Level = self.m_goAdd20LevelItem.transform:FindDeepChild("BtnBuy"):GetComponent(typeof(UnityUI.Button))
        self.m_btnAdd20LevelIntroduce = self.m_goAdd20LevelItem.transform:FindDeepChild("BtnPurchaseBenefits"):GetComponent(typeof(UnityUI.Button))
    end

    self.m_goUnlockRoyalPassItem:SetActive(not RoyalPassDbHandler.data.m_bIsPurchase)

    local skuInfos = self:getSkuInfos()
    local nLength = LuaHelper.tableSize(skuInfos)
    self.m_goAdd5LevelItem:SetActive(nLength >= 1)
    self.m_goAdd10LevelItem:SetActive(nLength >= 2)
    self.m_goAdd20LevelItem:SetActive(nLength >= 3)

    if nLength >= 1 then
        local textInfo = self.m_goAdd5LevelItem.transform:FindDeepChild("TextReachLevel"):GetComponent(typeof(TextMeshProUGUI))
        textInfo.text = "REACH LEVEL "..RoyalPassHandler.m_nLevel + skuInfos[1].nAddRoyalLevelCount
        local price = self.m_goAdd5LevelItem.transform:FindDeepChild("Text"):GetComponent(typeof(TextMeshProUGUI))
        price.text = "$"..skuInfos[1].nDollar
        self.m_btnAdd5Level.onClick:RemoveAllListeners()
        DelegateCache:addOnClickButton(self.m_btnAdd5Level)
        self.m_btnAdd5Level.onClick:AddListener(function()
            GlobalAudioHandler:PlayBtnSound()
            WindowLoadingView:Show()
            UnityPurchasingHandler:purchase(skuInfos[1])
        end)
        self.m_btnAdd5LevelIntroduce.onClick:RemoveAllListeners()
        DelegateCache:addOnClickButton(self.m_btnAdd5LevelIntroduce)
        self.m_btnAdd5LevelIntroduce.onClick:AddListener(function()
            GlobalAudioHandler:PlayBtnSound()
            ShowPurchaseBenifitPop:Show(skuInfos[1])
        end)
    end
    if nLength >= 2 then
        local textInfo = self.m_goAdd10LevelItem.transform:FindDeepChild("TextReachLevel"):GetComponent(typeof(TextMeshProUGUI))
        textInfo.text = "REACH LEVEL "..RoyalPassHandler.m_nLevel + skuInfos[2].nAddRoyalLevelCount
        local price = self.m_goAdd10LevelItem.transform:FindDeepChild("Text"):GetComponent(typeof(TextMeshProUGUI))
        price.text = "$"..skuInfos[2].nDollar
        self.m_btnAdd10Level.onClick:RemoveAllListeners()
        DelegateCache:addOnClickButton(self.m_btnAdd10Level)
        self.m_btnAdd10Level.onClick:AddListener(function()
            GlobalAudioHandler:PlayBtnSound()
            WindowLoadingView:Show()
            UnityPurchasingHandler:purchase(skuInfos[2])
        end)
        self.m_btnAdd10LevelIntroduce.onClick:RemoveAllListeners()
        DelegateCache:addOnClickButton(self.m_btnAdd10LevelIntroduce)
        self.m_btnAdd10LevelIntroduce.onClick:AddListener(function()
            GlobalAudioHandler:PlayBtnSound()
            ShowPurchaseBenifitPop:Show(skuInfos[2])
        end)
    end
    if nLength >= 3 then
        local textInfo = self.m_goAdd20LevelItem.transform:FindDeepChild("TextReachLevel"):GetComponent(typeof(TextMeshProUGUI))
        textInfo.text = "REACH LEVEL "..RoyalPassHandler.m_nLevel + skuInfos[3].nAddRoyalLevelCount
        local price = self.m_goAdd20LevelItem.transform:FindDeepChild("Text"):GetComponent(typeof(TextMeshProUGUI))
        price.text = "$"..skuInfos[3].nDollar
        self.m_btnAdd20Level.onClick:RemoveAllListeners()
        DelegateCache:addOnClickButton(self.m_btnAdd20Level)
        self.m_btnAdd20Level.onClick:AddListener(function()
            GlobalAudioHandler:PlayBtnSound()
            WindowLoadingView:Show()
            UnityPurchasingHandler:purchase(skuInfos[3])
        end)
        self.m_btnAdd20LevelIntroduce.onClick:RemoveAllListeners()
        DelegateCache:addOnClickButton(self.m_btnAdd20LevelIntroduce)
        self.m_btnAdd20LevelIntroduce.onClick:AddListener(function()
            GlobalAudioHandler:PlayBtnSound()
            ShowPurchaseBenifitPop:Show(skuInfos[3])
        end)
    end

    local bPortraitFlag = not ScreenHelper:isLandScape()
    if bPortraitFlag then
        self.m_trContent.localScale = Unity.Vector3.one * 0.65
    else
        self.m_trContent.localScale = Unity.Vector3.one
    end

    ViewScaleAni:Show(self.transform.gameObject, nil, function()
        self.m_btnClose.interactable = true
    end)
    GlobalAudioHandler:PlaySound("popup")

    EventHandler:AddListener("onPurchaseDoneNotifycation", self)
    EventHandler:AddListener("onPurchaseFailedNotifycation", self)
end

function RoyalPassBuyLevelUI:Hide()
    ViewScaleAni:Hide(self.transform.gameObject)
    EventHandler:RemoveListener("onPurchaseDoneNotifycation", self)
    EventHandler:RemoveListener("onPurchaseFailedNotifycation", self)
end

function RoyalPassBuyLevelUI:onPurchaseDoneNotifycation(skuInfo)
    WindowLoadingView:Hide()
    self:Hide()

    local addStarCount = RoyalPassHandler:getUpgradeNeedsStar(skuInfo.nAddRoyalLevelCount)
    local bIsUpgrade, bHasPrize = RoyalPassHandler:addStars(addStarCount)
    if bIsUpgrade then -- 两种方式
        RoyalPassMainUI:updateUI()
        PopStackViewHandler:Show(RoyalPassLevelUpUI, bHasPrize)
    end

end

function RoyalPassBuyLevelUI:onPurchaseFailedNotifycation()
    WindowLoadingView:Hide()
    CommonDialogBox:ShowSureUI("Purchase Failed")
end

function RoyalPassBuyLevelUI:getSkuInfos()
    local list = self:getSkus()
    local skuInfos = {}
    for i = 1, LuaHelper.tableSize(list) do
        local nAddRoyalLevelCount = 5
        if i == 1 then
            nAddRoyalLevelCount = 5
        elseif i == 2 then
            nAddRoyalLevelCount = 10
        else
            nAddRoyalLevelCount = 20
        end
        local skuInfo = self:getRoyalPassSaleSkuInfo(list[i], nAddRoyalLevelCount)
        skuInfos[i] = skuInfo
    end
    return skuInfos
end

function RoyalPassBuyLevelUI:getRoyalPassSaleSkuInfo(productId, nAddRoyalLevelCount)
    local skuInfo = GameHelper:GetSimpleSkuInfoById(productId)
    skuInfo.finalCoins = 0
    skuInfo.nAddRoyalLevelCount = nAddRoyalLevelCount
    skuInfo.nType = SkuInfoType.RoyalPassSale
    return skuInfo
end

function RoyalPassBuyLevelUI:getSkus()
    local royalLevel = RoyalPassHandler.m_nLevel
    if royalLevel <= 30 then
        return {AllBuyCFG[1].productId, AllBuyCFG[2].productId, AllBuyCFG[4].productId}
    elseif royalLevel <= 60 then
        return {AllBuyCFG[2].productId, AllBuyCFG[4].productId, AllBuyCFG[8].productId}
    elseif royalLevel <= 80 then
        return {AllBuyCFG[3].productId, AllBuyCFG[6].productId, AllBuyCFG[12].productId}
    elseif royalLevel <= 90 then
        return {AllBuyCFG[13].productId, AllBuyCFG[14].productId}
    elseif royalLevel <= 95 then
        return {AllBuyCFG[15].productId}
    end
end
