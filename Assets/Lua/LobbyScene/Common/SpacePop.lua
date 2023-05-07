

SpacePop = {}

SpacePop.gameObject = nil
SpacePop.transform = nil
SpacePop.fullLoadingGameObject = nil

local yield_return = (require 'cs_coroutine').yield_return

function SpacePop:isActiveShow()
    return self.gameObject and self.gameObject.activeInHierarchy
end

function SpacePop:createAndShow(bIsInQueue)
    local endTime, ratio, strType = SaleAdHandler:checkNormalSalesType("SpacePop")
    if strType == nil or strType ~= "SpacePop" then
        return
    end
    if DBHandler:checkHasSpecialSaleList("SpacePop") then
        return
    end
    if self.gameObject == nil then
        self.gameObject = Unity.Object.Instantiate(Util.getHotPrefab("Assets/BaseHotAdd/RocketsSalesShop/SpacePop.prefab"))
        self.transform = self.gameObject.transform

        LuaAutoBindMonoBehaviour.Bind(self.gameObject, self)
        
        self.popController = PopController:new(self.gameObject)
        local btn = self.transform:FindDeepChild("ButtonClose"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(btn)   
        btn.onClick:AddListener(function()
            self:onCloseBtnClicked()
        end)
        local btn = self.transform:FindDeepChild ("ButtonReject"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(btn)   
        btn.onClick:AddListener(function()
            self:onCloseBtnClicked()
        end)
        self.fullLoadingGameObject = self.transform:FindDeepChild("FullLoading").gameObject
        -- self:updateLeftTime(endTime)
        self:refreshContent(ratio)
    end
    self:hideLoading()
    self.button.interactable = true
    self.transform:SetParent(LobbyScene.popCanvas, false)
    bIsInQueue = bIsInQueue or false
    self.popController:show(nil, nil, bIsInQueue)
    
    if ThemeLoader.themeKey ~= nil then
        SlotsGameLua.m_bReelPauseFlag = true
    end
end

function SpacePop:refreshContent(ratio)
    self.shopSkus = self:getShopSkus()
    self.button = self.transform:FindDeepChild ("ButtonCollect"):GetComponent(typeof(UnityUI.Button))
    local getCoinsText = self.transform:FindDeepChild ("GetCoins"):GetComponent(typeof(TextMeshProUGUI))
    local priceText = self.transform:FindDeepChild("Price"):GetComponent(typeof(TextMeshProUGUI))
    local oldPriceText = self.transform:FindDeepChild("PriceOld"):GetComponent(typeof(TextMeshProUGUI))
    local productId = self.shopSkus.productId
    local skuInfo = SaleAdHandler:getSalesSkuInfo(productId, ratio, "SpacePop")
    getCoinsText.text = MoneyFormatHelper.numWithCommas(skuInfo.finalCoins)
    priceText.text = "$"..skuInfo.nDollar
    oldPriceText.text = "WAS  $"..(self.shopSkus.oldPrice)
    DelegateCache:addOnClickButton(self.button)   
    self.button.onClick:AddListener(function()
        self.button.interactable = false
        IabHandler:purchase(skuInfo)
        self:showLoading()
    end)
end

function SpacePop:Start()
    NotificationHandler:addObserver(self, "onPurchaseDoneNotifycation")
    NotificationHandler:addObserver(self, "onPurchaseFailedNotifycation")
end

function SpacePop:OnEnable()
    NotificationHandler:addObserver(self, "onPurchaseDoneNotifycation")
    NotificationHandler:addObserver(self, "onPurchaseFailedNotifycation")
end

function SpacePop:OnDisable()
    NotificationHandler:removeObserver(self)
end

function SpacePop:onCloseBtnClicked()
    GlobalAudioHandler:PlayBtnSound()
    ViewScaleAni:Hide(self.transform.gameObject)
    if ThemeLoader.themeKey ~= nil then
        SlotsGameLua.m_bReelPauseFlag = false
    end
end

--notification callback
function SpacePop:onPurchaseDoneNotifycation()
    self:hideLoading()
    ViewScaleAni:Hide(self.transform.gameObject)
    if ThemeLoader.themeKey ~= nil then
        SlotsGameLua.m_bReelPauseFlag = false
    end
end

function SpacePop:onPurchaseFailedNotifycation()
    self:hideLoading()
    self.button.interactable = true
    CommonDialogBox:ShowSureUI("Purchase Failed")
end

function SpacePop:showLoading()
	self.fullLoadingGameObject:SetActive(true)
end

function SpacePop:hideLoading()
	self.fullLoadingGameObject:SetActive(false)
end

function SpacePop:getShopSkus()
    local skuInfo = {productId = "com.slots.goldfever.coins001", oldPrice = 2.99}

    local reviewList = {{productId = "com.slots.goldfever.coins004", oldPrice = 7.99},
                        {productId = "com.slots.goldfever.coins015", oldPrice = 29.99},
                        {productId = "com.slots.goldfever.coins035", oldPrice = 59.99},
                        {productId = "com.slots.goldfever.coins060", oldPrice = 79.99},
                        {productId = "com.slots.goldfever.coins070", oldPrice = 89.99}}
    skuInfo = reviewList[math.random(1, 5)]
    return skuInfo
end

function SpacePop:updateLeftTime(endTime)
    local co = StartCoroutine( function()
        local timeText = self.transform:FindDeepChild("TimeText"):GetComponent(typeof(TextMeshProUGUI))
        local waitForSecend = Unity.WaitForSeconds(1)
        while endTime ~= nil do
            local nowSecond = os.time()
            local timediff = endTime - nowSecond

            local days = timediff // (3600*24)
            local hours = timediff // 3600 - 24 * days
            local minutes = timediff // 60 - 24 * days * 60 - 60 * hours
            local seconds = timediff % 60
            if days > 0 then
                timeText.text = string.format("Time Left %d days!",days)
            else
                timeText.text = string.format("%02d:%02d:%02d", hours, minutes, seconds) --os.date("%H:%M:%S", time)
            end
            yield_return(waitForSecend)
            if days == 0 and hours == 0 and minutes == 0 and seconds == 0 then
                endTime = nil
                if SaleAdEntry.m_gameObject ~= nil then
                    -- SaleAdEntry:onPurchaseDoneNotifycation()
                end
            end
        end
    end)
    
end

-- function SpacePop:setCardsContainer(parent, skuInfo)
--     local cardText = parent:FindDeepChild("SlotsCardInfoText"):GetComponent(typeof(TextMeshProUGUI))
--     local stars = parent:FindDeepChild("Stars")
--     for i=1,#SlotsCardsGiftManager.m_skuToSlotsCardsPack do
--         if skuInfo.productId == SlotsCardsGiftManager.m_skuToSlotsCardsPack[i].productId then
--             cardText.text = "Min " .. SlotsCardsGiftManager.m_skuToSlotsCardsPack[i].minCardCount .. " of"
--             for j = 0, stars.childCount - 1 do
--                 if j < SlotsCardsGiftManager.m_skuToSlotsCardsPack[i].starCount then
--                     stars:GetChild(j).gameObject:SetActive(true)
--                 else
--                     stars:GetChild(j).gameObject:SetActive(false)
--                 end
--             end
--             break
--         end
--     end
-- end