ShopPortraitPop = {}

function ShopPortraitPop:isActiveShow()
    return self.gameObject and self.gameObject.activeInHierarchy
end

function ShopPortraitPop:createAndShow(nType)
    if self.gameObject == nil then
        self.gameObject = Unity.Object.Instantiate(Util.getHotPrefab("Assets/BaseHotAdd/Shop01/ShopPortrait.prefab"))
        self.gameObject.name = "ShopPortraitPop"
        self.transform = self.gameObject.transform
        self.transform:SetParent(LobbyScene.popCanvas, false)

        LuaAutoBindMonoBehaviour.Bind(self.gameObject, self)
        self.popController = PopController:new(self.gameObject)
        local btn =  self.transform:FindDeepChild("BtnClose"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(btn)
        btn.onClick:AddListener(function()
            self:onCloseBtnClicked()
        end)
        self.trContent = self.transform:FindDeepChild("Content")
        self.btnCoins = self.transform:FindDeepChild("BtnCoins"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(self.btnCoins)
        self.btnCoins.onClick:AddListener(function()
            self:onCoinsBtnClicked()
        end)
        self.btnEmerald = self.transform:FindDeepChild("BtnEmerald"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(self.btnEmerald)
        self.btnEmerald.onClick:AddListener(function()
            self:onEmeraldBtnClicked()
        end)
        self.textSalesInfo = self.transform:FindDeepChild("SalesInfoText"):GetComponent(typeof(TextMeshProUGUI))
        self.scrollContent = self.transform:FindDeepChild("ScrollContent")
        local scrollRect = self.scrollContent.parent:GetComponent(typeof(UnityUI.ScrollRect))
        DelegateCache:addOnValueChanged(scrollRect)
        scrollRect.onValueChanged:AddListener(function()
            self:setBtnStatus()
        end)
        self.fullLoadingGameObject = self.transform:FindDeepChild("FullLoading").gameObject
        self:InstantiateItem()
        
        self.textCoins = self.transform:FindDeepChild("CoinsCountText"):GetComponent(typeof(TextMeshProUGUI))
        self.textDiamonds = self.transform:FindDeepChild("DiamondsCountText"):GetComponent(typeof(TextMeshProUGUI))

        self.trCloverStamp = self.transform:FindDeepChild("CloverStamp")
        self.trStoreBonusUI = self.transform:FindDeepChild("StoreBonusUI")
        local screenRatio = Unity.Screen.width / Unity.Screen.height
        if screenRatio < 1.0 then
            screenRatio = 1.0 / screenRatio
        end
        self.scale = (screenRatio / 1.6) < 1 and 1 or (screenRatio / 1.6)
        self.scrollContent.localScale = Unity.Vector3.one * self.scale
        if GameConfig.IS_NOTCH_SCREEN then
            self.trContent.offsetMin = Unity.Vector2(0, 80)
            self.trContent.offsetMax = Unity.Vector2(0, -80)
        end
    end

    self.coinCountInUI = PlayerHandler.nGoldCount
    self.diamondCountInUI = DBHandler:getDiamondsCount()

    self.shopSkus = self:getShopSkus()
    self:UpdateUI()
    
    self.popController:show(function()
        if nType == BuyView.SHOP_VIEW_TYPE.GEMTYPE then
            self:onEmeraldBtnClicked()
        end
    end)
    
    if ThemeLoader.themeKey ~= nil then
        SlotsGameLua.m_bReelPauseFlag = true
    end
    self.textCoins.text = MoneyFormatHelper.numWithCommas(self.coinCountInUI)
    self.textDiamonds.text = MoneyFormatHelper.numWithCommas(self.diamondCountInUI)
    ShopStampCardUI:checkAndShow(self.trCloverStamp)
    ShopBonusUI:checkAndShow(self.trStoreBonusUI)
    self.btnEmerald.interactable = true
    self.btnCoins.interactable = false
end

function ShopPortraitPop:updateCoinCountInUi(time)
    if not self:isActiveShow() then
        return
    end
	if(self.coinNumTween and self.coinNumTween.isTweening) then
		NumberTween:cancel(self.coinNumTween)
	end
	time = time or 1.5

	if time == 0 then -- C#的spin扣金币的情况。。
		time = 0.5
	end

	self.coinNumTween = NumberTween:value(self.coinCountInUI, PlayerHandler.nGoldCount, time):setOnUpdate(function(value) 
		self.coinCountInUI = value
		self.textCoins.text = MoneyFormatHelper.numWithCommas(value)
	end)
end

function ShopPortraitPop:updateDiamondCountInUi(time)
    if not self:isActiveShow() then
        return
    end
    if(self.diamondNumTween and self.diamondNumTween.isTweening) then
		NumberTween:cancel(self.diamondNumTween)
	end
	time = time or 1.5

	if time == 0 then -- C#的spin扣金币的情况。。
		time = 0.5
	end

	self.diamondNumTween = NumberTween:value(self.diamondCountInUI, DBHandler:getDiamondsCount(), time):setOnUpdate(function(value) 
		self.diamondCountInUI = value
		self.textDiamonds.text = MoneyFormatHelper.numWithCommas(value)
	end)
end

function ShopPortraitPop:InstantiateItem()
    self.m_coinItems = {}
    local strPrefabPath = "Assets/BaseHotAdd/Shop01/NewShopItem/CoinsSalePortraitItem.prefab"

    local prefab = Util.getHotPrefab(strPrefabPath)
    local lastPosY = -167
    local height = 303
    for i = 1, 6 do
        local item = Unity.Object.Instantiate(prefab).transform
        self.m_coinItems[i] = item
        item:SetParent(self.scrollContent, false)
        item.localScale = Unity.Vector3.one * 0.65
        item.anchoredPosition3D = Unity.Vector3(0, lastPosY, 0)
        lastPosY = lastPosY - height
    end
    
    lastPosY = lastPosY + height - 230
    local prefab = Util.getHotPrefab("Assets/BaseHotAdd/Shop01/BianQianFenGeXianPortrait.prefab")
    self.trFenGeXian = Unity.Object.Instantiate(prefab).transform
    self.trFenGeXian:SetParent(self.scrollContent, false)
    self.trFenGeXian.anchoredPosition3D = Unity.Vector3(0, lastPosY, 0)

    lastPosY = lastPosY - 50 - height/2

    self.m_diamondItems = {}
    local strPrefabPath = "Assets/BaseHotAdd/Shop01/NewShopItem/DiamondSalePortraitItem.prefab"

    local prefab = Util.getHotPrefab(strPrefabPath)
    for i = 1, 6 do
        local item = Unity.Object.Instantiate(prefab).transform
        self.m_diamondItems[i] = item
        item:SetParent(self.scrollContent, false)
        item.localScale = Unity.Vector3.one * 0.65
        item.anchoredPosition3D = Unity.Vector3(0, lastPosY, 0)
        lastPosY = lastPosY - height
    end

    self.scrollContent.sizeDelta = Unity.Vector2(self.scrollContent.sizeDelta.x, - lastPosY - 130 )
end

function ShopPortraitPop:UpdateUI()
    local bHasCoinCoupon = DBHandler:checkHasCoinCouponFormShop()

    local shopDiscountRatio = BonusUtil.shopDiscountRatio()
    local allSalesRatio = nil
    local text = nil
    local isSales = shopDiscountRatio == 1
    if isSales then
        allSalesRatio,text = BonusUtil.shopAllSalesRatio()
        if allSalesRatio ~= nil then
            -- self.bestValueGameObject:SetActive(false)
            -- self.mostPopularGameOjbect:SetActive(false)
        end
    else
        text = BonusUtil.shopDiscountText()
    end
    if bHasCoinCoupon then
        if self.textSalesInfo.gameObject.activeSelf then
            self.textSalesInfo.gameObject:SetActive(false)
        end
    else
        if text ~= nil then
            if not self.textSalesInfo.gameObject.activeSelf then
                self.textSalesInfo.gameObject:SetActive(true)
            end
            self.textSalesInfo.text = text
        else
            if self.textSalesInfo.gameObject.activeSelf then
                self.textSalesInfo.gameObject:SetActive(false)
            end
        end
    end
    for i = 1, 6 do
        local coinItem = self.m_coinItems[i]
        self:UpdateCoinsItemUI(coinItem, i, allSalesRatio, isSales, shopDiscountRatio)
        local diamondItem = self.m_diamondItems[i]
        self:UpdateDiamondItemUI(diamondItem, i, allSalesRatio, isSales, shopDiscountRatio)
    end
end

function ShopPortraitPop:UpdateCoinsItemUI(item, nIndex, allSalesRatio, isSales, shopDiscountRatio)
    local imgContainer = item:FindDeepChild("CoinsImgContainer")
    for i = 0, imgContainer.childCount-1 do
        imgContainer:GetChild(i).gameObject:SetActive(i == (nIndex - 1))
    end
    local productId = self.shopSkus[#self.shopSkus - (nIndex-1)]
    local skuInfo = GameHelper:GetSimpleSkuInfoById(productId)
    if isSales and allSalesRatio ~= nil then
        skuInfo = BonusUtil.getShopSalesSkuInfo(productId, nIndex)
    end

    local bHasCoinCoupon, fCoinCouponRatio = DBHandler:checkHasCoinCouponFormShop()
    if bHasCoinCoupon then
        skuInfo.finalCoins = MoneyFormatHelper.normalizeCoinCount(skuInfo.baseCoins * fCoinCouponRatio)
    end

    local btnIntroduce = item:FindDeepChild ("BtnIntroduce"):GetComponent(typeof(UnityUI.Button))
    btnIntroduce.onClick:RemoveAllListeners() 
    DelegateCache:addOnClickButton(btnIntroduce)   
    btnIntroduce.onClick:AddListener(function()
        ShowPurchaseBenifitPop:createAndShow(skuInfo)
    end)

    local button = item:FindDeepChild ("ButtonBuy"):GetComponent(typeof(UnityUI.Button))
    button.onClick:RemoveAllListeners()
    DelegateCache:addOnClickButton(button)   
    button.onClick:AddListener(function()
        IabHandler:purchase(skuInfo)
        self:showLoading()
    end)

    local coinCountText = item:FindDeepChild ("CoinCount"):GetComponent(typeof(TextMeshProUGUI))
    local coinCountDiscountText = item:FindDeepChild ("CoinCountDiscount"):GetComponent(typeof(UnityUI.Text))
    local discountRatioContainer = item:FindDeepChild ("DiscountRatioContainer").gameObject
    local discountRatioText = item:FindDeepChild("DiscountRatio"):GetComponent(typeof(TextMeshProUGUI))
    local priceText = item:FindDeepChild("ButtonBuy/Price"):GetComponent(typeof(TextMeshProUGUI))
    local vipPointText = item:FindDeepChild("VipPoint"):GetComponent(typeof(TextMeshProUGUI))
    local strokeLine = item:FindDeepChild ("CoinCount/StrokeLine"):GetComponent(typeof(UnityUI.Image))
    
    coinCountText.text = MoneyFormatHelper.numWithCommas(skuInfo.baseCoins)
    priceText.text = "$"..skuInfo.nDollar
    vipPointText.text = string.format( "+%s", MoneyFormatHelper.numWithCommas(skuInfo.vipPoint))

    item.localScale = Unity.Vector3.zero
    strokeLine.gameObject:SetActive (false)
    discountRatioContainer:SetActive(false)

    coinCountDiscountText.text = MoneyFormatHelper.numWithCommas(skuInfo.finalCoins)

    LeanTween.scale(item, Unity.Vector3.one * 0.8, 0.3):setEase(LeanTweenType.easeOutQuad):setOnComplete(function()
        LeanTween.scale (item, Unity.Vector3.one * 0.65, 0.08)
    end):setDelay (nIndex * 0.1 + 0.1)
    if bHasCoinCoupon then
        coinCountText.gameObject:SetActive(bHasCoinCoupon)
        discountRatioContainer:SetActive(true)
        discountRatioText.text = string.format( "+%.0f%%", (fCoinCouponRatio - 1) * 100 )
        strokeLine.gameObject:SetActive (true)
    else
        coinCountText.gameObject:SetActive((shopDiscountRatio > 1.0) or allSalesRatio ~= nil)
        if(shopDiscountRatio > 1.0) then
            discountRatioContainer:SetActive(true)
            discountRatioText.text = string.format( "+%.0f%%", (shopDiscountRatio - 1) * 100 )
            strokeLine.gameObject:SetActive (true)
        end
        if isSales and allSalesRatio ~= nil then
            discountRatioContainer:SetActive(true)
            discountRatioText.text = string.format( "+%.0f%%", (allSalesRatio[nIndex] - 1) * 100 )
            strokeLine.gameObject:SetActive (true)
        end
    end
    self:SetItemSlotsCardsUI(item, skuInfo)
    self:SetItemActiveContent(item, skuInfo)
    self:SetItemLoungeContent(item, skuInfo)
end

function ShopPortraitPop:SetItemSlotsCardsUI(item, skuInfo)
    local container = item:FindDeepChild("SendContainer")
    local cardContent = container:FindDeepChild("Ka").gameObject
    local userLevel = PlayerHandler.nLevel
    local isActiveShow = false
    for i=1,#SlotsCardsHandler.m_albumTable do
        local status = SlotsCardsHandler:checkIsActiveTime(i)
        if not isActiveShow then
            isActiveShow = status
        end
    end
    if GameConfig.SLOTSCARDS_FLAG and isActiveShow and userLevel >= SlotsCardsManager.m_nUnlockLevel then
        cardContent:SetActive(true)
        local stars = cardContent.transform:FindDeepChild("Stars")
        local packCount = cardContent.transform:FindDeepChild("PackCount"):GetComponent((typeof(TextMeshProUGUI)))
        local packTypeContainer = cardContent.transform:FindDeepChild("KaPaiJieDian")
        for i=1,#SlotsCardsGiftManager.m_skuToSlotsCardsPack do
            if skuInfo.productId == SlotsCardsGiftManager.m_skuToSlotsCardsPack[i].productId then
                local infoCount = SlotsCardsGiftManager.m_skuToSlotsCardsPack[i].info.packCount
                packCount.text = "+"..infoCount
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
    else
        cardContent:SetActive(false)
    end
end

function ShopPortraitPop:SetItemActiveContent(item, skuInfo)
    local activeContent = item:FindDeepChild("SendContainer/Active")
    for k, activeType in pairs(ActiveType) do
        local tr = activeContent:FindDeepChild(activeType)
        if tr then 
            local go = tr.gameObject
            if ActiveManager.activeType == activeType then
                local nCount = _G[activeType.."IAPConfig"].skuMapOther[skuInfo.productId]
                local textCount = go.transform:FindDeepChild("textCount"):GetComponent(typeof(TextMeshProUGUI))
                textCount.text = " +"..nCount
                go:SetActive(true)
            else
                go:SetActive(false)
            end
        else
            --Debug.Log("ShopPopItem "..activeType.." 没有资源")
        end 
    end
end

function ShopPortraitPop:SetItemLoungeContent(item, skuInfo)
    local nLoungePoint = 0
    for k, v in pairs(LoungeConfig.m_lsitSkuChestInfo) do
        if v.productId == skuInfo.productId then
            nLoungePoint = v.nLoungePoint
        end
    end
    local textCount = item:FindDeepChild("SendContainer/Lounge/textCount"):GetComponent(typeof(TextMeshProUGUI))
    textCount.text = " +"..nLoungePoint
end

-- 暂时没有打折，等定好了在写
function ShopPortraitPop:UpdateDiamondItemUI(item, nIndex, allSalesRatio, isSales, shopDiscountRatio)
    local allSalesRatio, isSales, shopDiscountRatio = nil, false, 1
    local imgContainer = item:FindDeepChild("CoinsImgContainer")
    for i = 0, imgContainer.childCount-1 do
        imgContainer:GetChild(i).gameObject:SetActive(i == (nIndex - 1))
    end

    local productId = self.shopSkus[#self.shopSkus - (nIndex-1)]
    local skuInfo = GameHelper:GetSimpleSkuInfoById(productId)
    if isSales and allSalesRatio ~= nil then
        local ratioArray = BonusUtil.shopAllSalesRatio()
        local ratio = ratioArray[nIndex]
        skuInfo.finalDiamonds = MoneyFormatHelper.normalizeCoinCount(skuInfo.normalDiamonds * ratio)
    end
    local bHasDiamondCoupon, fDiamondCouponRatio = DBHandler:checkHasDiamondCouponFormShop()
    if bHasDiamondCoupon then
        skuInfo.finalDiamonds = MoneyFormatHelper.normalizeCoinCount(skuInfo.normalDiamonds * fDiamondCouponRatio)
    end

    local btnIntroduce = item:FindDeepChild ("BtnIntroduce"):GetComponent(typeof(UnityUI.Button))
    btnIntroduce.onClick:RemoveAllListeners()    
    DelegateCache:addOnClickButton(btnIntroduce)   
    btnIntroduce.onClick:AddListener(function()
        ShowPurchaseBenifitPop:createAndShow(skuInfo)
    end)

    local button = item:FindDeepChild ("ButtonBuy"):GetComponent(typeof(UnityUI.Button))
    button.onClick:RemoveAllListeners()
    DelegateCache:addOnClickButton(button)   
    button.onClick:AddListener(function()
        IabHandler:purchase(skuInfo)
        self:showLoading()
    end)

    local coinCountText = item:FindDeepChild ("CoinCount"):GetComponent(typeof(TextMeshProUGUI))
    local coinCountDiscountText = item:FindDeepChild ("CoinCountDiscount"):GetComponent(typeof(UnityUI.Text))
    local discountRatioContainer = item:FindDeepChild ("DiscountRatioContainer").gameObject
    local discountRatioText = item:FindDeepChild("DiscountRatio"):GetComponent(typeof(TextMeshProUGUI))
    local priceText = item:FindDeepChild("ButtonBuy/Price"):GetComponent(typeof(TextMeshProUGUI))
    local vipPointText = item:FindDeepChild("VipPoint"):GetComponent(typeof(TextMeshProUGUI))
    local strokeLine = item:FindDeepChild ("CoinCount/StrokeLine"):GetComponent(typeof(UnityUI.Image))
    
    coinCountText.text = MoneyFormatHelper.numWithCommas(skuInfo.normalDiamonds)
    priceText.text = "$"..skuInfo.nDollar
    vipPointText.text = string.format( "+%s", MoneyFormatHelper.numWithCommas(skuInfo.vipPoint))

    item.localScale = Unity.Vector3.zero
    strokeLine.gameObject:SetActive (false)
    discountRatioContainer:SetActive(false)

    coinCountDiscountText.text = MoneyFormatHelper.numWithCommas(skuInfo.finalDiamonds)

    LeanTween.scale(item, Unity.Vector3.one * 0.8, 0.3):setEase(LeanTweenType.easeOutQuad):setOnComplete(function()
        LeanTween.scale (item, Unity.Vector3.one * 0.65, 0.08)
    end):setDelay (nIndex * 0.1 + 0.1)

    if bHasDiamondCoupon then
        coinCountText.gameObject:SetActive(bHasDiamondCoupon)
        discountRatioContainer:SetActive(true)
        discountRatioText.text = string.format( "+%.0f%%", (fDiamondCouponRatio - 1) * 100 )
        strokeLine.gameObject:SetActive (true)
    else
        coinCountText.gameObject:SetActive((shopDiscountRatio > 1.0) or allSalesRatio ~= nil)
        if(shopDiscountRatio > 1.0) then
            discountRatioContainer:SetActive(true)
            discountRatioText.text = string.format( "+%.0f%%", (shopDiscountRatio - 1) * 100 )
            strokeLine.gameObject:SetActive (true)
        end
        if isSales and allSalesRatio ~= nil then
            discountRatioContainer:SetActive(true)
            discountRatioText.text = string.format( "+%.0f%%", (allSalesRatio[nIndex] - 1) * 100 )
            strokeLine.gameObject:SetActive (true)
        end
    end

    self:SetItemSlotsCardsUI(item, skuInfo)
    self:SetItemActiveContent(item, skuInfo)
    self:SetItemLoungeContent(item, skuInfo)
end

function ShopPortraitPop:getShopSkus()
    local nUserLevel = PlayerHandler.nLevel
    local fTotalPrice = DBHandler:getTotalIapPrice()

    local nType = 2

    if (nUserLevel < 100) and (fTotalPrice == 0) then
        nType = 1 -- 低等级并且没有购买过
    end

    if nUserLevel >= 100 then
        nType = 2
    end

    if nUserLevel >= 500 then
        nType = 3
    end
    
    if nUserLevel >= 1000 then
        nType = 4
    end
    
    if nUserLevel >= 2000 then
        nType = 5
    end

    if fTotalPrice > 5 then
        if nType < 2 then
            nType = 2
        end
    end

    if fTotalPrice > 100 then
        if nType < 3 then
            nType = 3
        end
    end

    if fTotalPrice > 500 then
        if nType < 4 then
            nType = 4
        end
    end

    if fTotalPrice > 1000 then
        if nType < 5 then
            nType = 5
        end
    end

    -- 1 2 3 4 5 6 7 8 9 10 15 20 50 100
    local listShopSkus = {"com.slots.goldfever.coins001", "com.slots.goldfever.coins004",
                     "com.slots.goldfever.coins005", "com.slots.goldfever.coins010",
                     "com.slots.goldfever.coins020", "com.slots.goldfever.coins050"}

    if nType == 1 then
        listShopSkus = {"com.slots.goldfever.coins001", "com.slots.goldfever.coins004",
                     "com.slots.goldfever.coins005", "com.slots.goldfever.coins010",
                     "com.slots.goldfever.coins020", "com.slots.goldfever.coins050"}
    elseif nType == 2 then
        listShopSkus = {"com.slots.goldfever.coins001", "com.slots.goldfever.coins005",
                     "com.slots.goldfever.coins010", "com.slots.goldfever.coins020",
                     "com.slots.goldfever.coins050", "com.slots.goldfever.coins100"}
    elseif nType == 3 then
        listShopSkus = {"com.slots.goldfever.coins002", "com.slots.goldfever.coins005",
                        "com.slots.goldfever.coins010", "com.slots.goldfever.coins020",
                        "com.slots.goldfever.coins050", "com.slots.goldfever.coins100"}
    elseif nType == 4 then
        listShopSkus = {"com.slots.goldfever.coins002", "com.slots.goldfever.coins005",
                        "com.slots.goldfever.coins010", "com.slots.goldfever.coins020",
                        "com.slots.goldfever.coins050", "com.slots.goldfever.coins100"}
    elseif nType == 5 then
        listShopSkus = {"com.slots.goldfever.coins002", "com.slots.goldfever.coins010",
                        "com.slots.goldfever.coins020", "com.slots.goldfever.coins030",
                        "com.slots.goldfever.coins050", "com.slots.goldfever.coins100"}
    end

    return listShopSkus
end

function ShopPortraitPop:Start()
    NotificationHandler:addObserver(self, "onPurchaseDoneNotifycation")
    NotificationHandler:addObserver(self, "onPurchaseFailedNotifycation")
end

function ShopPortraitPop:OnEnable()
    NotificationHandler:addObserver(self, "onPurchaseDoneNotifycation")
    NotificationHandler:addObserver(self, "onPurchaseFailedNotifycation")
end

function ShopPortraitPop:OnDisable()
    NotificationHandler:removeObserver(self)
end

function ShopPortraitPop:onCloseBtnClicked()
    GlobalAudioHandler:PlayBtnSound()
    self.popController:hide(false, function()
        if self.moveLocalId and LeanTween.isTweening(self.moveLocalId) then
            LeanTween.cancel(self.moveLocalId)
        end
        self.scrollContent.anchoredPosition = Unity.Vector2.zero
    end)

    if ThemeLoader.themeKey ~= nil then
        if SlotsCardsMainUIPop.m_gameObject ~= nil then
            if not SlotsCardsMainUIPop.m_gameObject.activeSelf then
                SlotsGameLua.m_bReelPauseFlag = false
            end
        else
            SlotsGameLua.m_bReelPauseFlag = false
        end
    end

    ShopStampCardUI:ShopStampQuit()
end

function ShopPortraitPop:onCoinsBtnClicked()
    if self.moveLocalId and LeanTween.isTweening(self.moveLocalId) then
        LeanTween.cancel(self.moveLocalId)
    end
    self.btnCoins.interactable = false
    local targetPosY = 0
    self.moveLocalId = LeanTween.moveLocalY(self.scrollContent.gameObject, targetPosY, 0.5).id
end

function ShopPortraitPop:onEmeraldBtnClicked()
    if self.moveLocalId and LeanTween.isTweening(self.moveLocalId) then
        LeanTween.cancel(self.moveLocalId)
    end
    self.btnEmerald.interactable = false
    local targetPosY = -self.m_diamondItems[1].anchoredPosition.y
    self.moveLocalId = LeanTween.moveLocalY(self.scrollContent.gameObject, targetPosY, 0.5).id
end

function ShopPortraitPop:setBtnStatus()
    self.btnCoins.interactable = self.trFenGeXian.position.y > 0
    self.btnEmerald.interactable = self.trFenGeXian.position.y <= 0
end

--notification callback
function ShopPortraitPop:onPurchaseDoneNotifycation()
    self:hideLoading()
end

function ShopPortraitPop:onPurchaseFailedNotifycation()
    self:hideLoading()
    CommonDialogBox:ShowSureUI("Purchase Failed")
end

function ShopPortraitPop:showLoading()
	self.fullLoadingGameObject:SetActive(true)
end

function ShopPortraitPop:hideLoading()
	self.fullLoadingGameObject:SetActive(false)
end

