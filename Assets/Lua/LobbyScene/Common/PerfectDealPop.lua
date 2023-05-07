
require("Lua.UI.PopPanel.CouponTipPop")

PerfectDealPop = {}

local allDealSkusArray = {
    {"com.slots.goldfever.coins001", "com.slots.goldfever.coins002",  "com.slots.goldfever.coins004"},
    {"com.slots.goldfever.coins001", "com.slots.goldfever.coins004",  "com.slots.goldfever.coins005"},
    {"com.slots.goldfever.coins001", "com.slots.goldfever.coins002",  "com.slots.goldfever.coins009"},
    {"com.slots.goldfever.coins001", "com.slots.goldfever.coins005",  "com.slots.goldfever.coins009"},
    {"com.slots.goldfever.coins001", "com.slots.goldfever.coins004",  "com.slots.goldfever.coins009"},
    {"com.slots.goldfever.coins001", "com.slots.goldfever.coins010",  "com.slots.goldfever.coins015"},
    {"com.slots.goldfever.coins002", "com.slots.goldfever.coins005",  "com.slots.goldfever.coins015"},
}

function PerfectDealPop:isActiveShow()
    return self.gameObject and self.gameObject.activeInHierarchy
end

function PerfectDealPop:createAndShow(bForceShow)
    -- if BonusUtil.shopDiscountRatio() > 1 then
    --     self.lastPopTime = self.lastPopTime or 0
    --     local lastPopDiff = os.time() - self.lastPopTime
    --     if bForceShow or lastPopDiff >= 120 then
    --         self.lastPopTime = os.time()
    --         CouponTipPop:createAndShow()
    --     end
    --     return
    -- end
    local bLandscape = (not GameLevelUtil:isPortraitLevel())
    if(bLandscape ~= self.bLandscape) then
        if self.gameObject then
            Unity.GameObject.Destroy(self.gameObject)
        end
        if bLandscape then
            self.gameObject = Unity.Object.Instantiate(Util.getHotPrefab("Assets/BaseHotAdd/PerfectDeal/PerfectDealPop.prefab"))
        else
            self.gameObject = Unity.Object.Instantiate(Util.getHotPrefab("Assets/BaseHotAdd/PerfectDeal/PerfectDealPopPortrait.prefab"))
        end
        self.bLandscape = bLandscape
        self.tableName = "PerfectDealPop"
        self.transform = self.gameObject.transform
        LuaAutoBindMonoBehaviour.Bind(self.gameObject, self)
        VipIcon:new(self.transform:FindDeepChild("VipImage").gameObject)
        self.popController = PopController:new(self.gameObject)
        local btn = self.transform:FindDeepChild("CloseButton"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(btn)
        btn.onClick:AddListener(function()
            self:onCloseBtnClicked()
        end)
        self.fullLoadingGameObject = self.transform:FindDeepChild("FullLoading").gameObject

        self.elementsArray = {}
        local itemsContainer = self.transform:FindDeepChild("ItemsContainer")
        for i = 0, itemsContainer.childCount - 1 do
            local item = itemsContainer:GetChild(i)
            local coinCountText = item:FindDeepChild ("CoinValueText"):GetComponent(typeof(TextMeshProUGUI))
            local priceText = item:FindDeepChild("PriceText"):GetComponent(typeof(TextMeshProUGUI))
            local vipPointText = item:FindDeepChild("VipPointText"):GetComponent(typeof(TextMeshProUGUI))
            local elements = {}
            elements.coinCountText = coinCountText
            elements.priceText = priceText
            elements.vipPointText = vipPointText
            elements.button = item:GetComponent(typeof(UnityUI.Button))
            self.elementsArray[#self.elementsArray+1] = elements
        end
    end
    self.lastPopTime = self.lastPopTime or 0
    local lastPopDiff = os.time() - self.lastPopTime
    if not bForceShow and lastPopDiff < 120 then
        return
    end
    self.lastPopTime = os.time()
    self.skuArrayIndex = math.floor(os.time() / (60 * 60 * 2)) % (#allDealSkusArray) + 1
    for i, productId in ipairs(allDealSkusArray[self.skuArrayIndex]) do
        local skuInfo = GameHelper:GetSimpleSkuInfoById(productId)
        if i == 3 then
            skuInfo.finalCoins = MoneyFormatHelper.normalizeCoinCount(skuInfo.finalCoins * 1.3)
        end
        self.elementsArray[i].coinCountText.text = MoneyFormatHelper.numWithCommas(skuInfo.finalCoins)
        self.elementsArray[i].priceText.text = "$"..skuInfo.nDollar
        self.elementsArray[i].vipPointText.text = string.format( "+%s VIP Pts.", MoneyFormatHelper.numWithCommas(skuInfo.vipPoint))
        self.elementsArray[i].button.onClick:RemoveAllListeners()
        DelegateCache:addOnClickButton(self.elementsArray[i].button)
        self.elementsArray[i].button.onClick:AddListener(function()
            IabHandler:purchase(skuInfo)
            self:showLoading()
        end)
        self:setCardsContainer(skuInfo, self.elementsArray[i].button.transform)
    end

    self:hideLoading()
    self.transform:SetParent(LobbyScene.popCanvas, false)
    self.popController:show(nil, nil, true)
end

function PerfectDealPop:setCardsContainer(skuInfo, parent)
    local imgGo = parent:FindDeepChild("Image")
    local cardImgGo = parent:FindDeepChild("CardsImage").gameObject
    local userLevel = PlayerHandler.nLevel
    local isActiveShow = false
    for i=1,#SlotsCardsHandler.m_albumTable do
        local status = SlotsCardsHandler:checkIsActiveTime(i)
        if not isActiveShow then
            isActiveShow = status
        end
    end
    if isActiveShow and (userLevel >= SlotsCardsManager.m_nUnlockLevel) then
        cardImgGo:SetActive(true)
        imgGo.anchoredPosition = Unity.Vector2(-25,0)
    else
        cardImgGo:SetActive(false)
        imgGo.anchoredPosition = Unity.Vector2.zero
        return
    end
    local stars = parent.transform:FindDeepChild("Stars")
    local packCount = parent.transform:FindDeepChild("DoublePack")
    local packTypeContainer = parent.transform:FindDeepChild("KaPaiJieDian")
    for i=1,#SlotsCardsGiftManager.m_skuToSlotsCardsPack do
        if skuInfo.productId == SlotsCardsGiftManager.m_skuToSlotsCardsPack[i].productId then
            local infoCount = SlotsCardsGiftManager.m_skuToSlotsCardsPack[i].info.packCount
            local textPackCount = packCount:GetComponentInChildren(typeof(TextMeshProUGUI))
            if infoCount > 1 then
                textPackCount.text = infoCount .." PACKS"
            else
                textPackCount.text = infoCount .." PACK"
            end
            stars.sizeDelta = Unity.Vector2(20* (SlotsCardsGiftManager.m_skuToSlotsCardsPack[i].info.packType), 20)
            for j = 0, stars.childCount - 1 do
                if j < SlotsCardsGiftManager.m_skuToSlotsCardsPack[i].info.packType then
                    stars:GetChild(j).gameObject:SetActive(true)
                else
                    stars:GetChild(j).gameObject:SetActive(false)
                end
                packTypeContainer:GetChild(j).gameObject:SetActive(j + 1 == SlotsCardsGiftManager.m_skuToSlotsCardsPack[i].info.packType)
            end
            break
        end
    end
end

function PerfectDealPop:Start()
    NotificationHandler:addObserver(self, "onPurchaseDoneNotifycation")
    NotificationHandler:addObserver(self, "onPurchaseFailedNotifycation")
end

function PerfectDealPop:OnEnable()
    NotificationHandler:addObserver(self, "onPurchaseDoneNotifycation")
    NotificationHandler:addObserver(self, "onPurchaseFailedNotifycation")
end

function PerfectDealPop:OnDisable()
    NotificationHandler:removeObserver(self)
end

function PerfectDealPop:onCloseBtnClicked()
    GlobalAudioHandler:PlayBtnSound()
    ViewScaleAni:Hide(self.transform.gameObject)
end


--notification callback
function PerfectDealPop:onPurchaseDoneNotifycation()
    self:hideLoading()
end

function PerfectDealPop:onPurchaseFailedNotifycation()
    self:hideLoading()
    CommonDialogBox:ShowSureUI("Purchase Failed")
end

function PerfectDealPop:showLoading()
	self.fullLoadingGameObject:SetActive(true)
end

function PerfectDealPop:hideLoading()
	self.fullLoadingGameObject:SetActive(false)
end