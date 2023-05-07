local BuyViewCoinsItem = {}

function BuyViewCoinsItem:New(go, manager)
    local temp = {}
    self.__index = self
    setmetatable(temp, self)
        
    temp:InitPanel(go, manager)
    return temp
end

function BuyViewCoinsItem:InitPanel(go, manager)
    self.transform = go.transform
    self.mManager = manager
    self.transform.gameObject:SetActive(false)

    self.textCoinCount = self.transform:FindDeepChild("CoinCountDiscount"):GetComponent(typeof(UnityUI.Text))
    self.textOriCoinCount = self.transform:FindDeepChild("CoinCount"):GetComponent(typeof(TextMeshProUGUI))

    self.goDiscountRatioContainer = self.transform:FindDeepChild("DiscountRatioContainer").gameObject
    self.textDiscountRatio = self.transform:FindDeepChild("DiscountRatio"):GetComponent(typeof(TextMeshProUGUI))

    self.mBtnIntroduce = self.transform:FindDeepChild("BtnIntroduce"):GetComponent(typeof(UnityUI.Button))
    self.mBtnIntroduce.onClick:AddListener(function()
        GlobalAudioHandler:PlayBtnSound()
        ShowPurchaseBenifitPop:Show(self.skuInfo)
    end)
    
    self.mButtonBuy = self.transform:FindDeepChild("ButtonBuy"):GetComponent(typeof(UnityUI.Button))
    self.mButtonBuy.onClick:AddListener(function()
        GlobalAudioHandler:PlayBtnSound()
        self:OnClickBuyBtn()
    end)
    self.textPrice = self.transform:FindDeepChild("ButtonBuy/Price"):GetComponent(typeof(TextMeshProUGUI))

    self.textBenefitVipPoint = self.transform:FindDeepChild("VipPoint"):GetComponent(typeof(TextMeshProUGUI))
    self.textBenefitLoungePoint = self.transform:FindDeepChild("Lounge/textCount"):GetComponent(typeof(TextMeshProUGUI))

end

function BuyViewCoinsItem:OnClickBuyBtn()
    WindowLoadingView:Show()
    UnityPurchasingHandler:purchase(self.skuInfo)
end

function BuyViewCoinsItem:Refresh(nItemIndex, nSkuType)
    self.nItemIndex = nItemIndex
    self.nSkuType = nSkuType

    for i = 1, 6 do
        local goCoinImage = self.transform:FindDeepChild("CoinsImgContainer/JinBi"..i).gameObject
        goCoinImage:SetActive(7 - i == nItemIndex)
    end

    local nBuyCFGIndex = StoreBuyIndexs[nItemIndex]
    local productId = AllBuyCFG[nBuyCFGIndex].productId
    self.skuInfo = BuyHandler:getShopSkuInfo(productId, self.nSkuType)

    local bDiscount, nFinalMultuile = BuyHandler:orDiscount(nSkuType)
    
    self.textOriCoinCount.gameObject:SetActive(bDiscount)
    self.textPrice.text = "$"..self.skuInfo.nDollar
    self.textBenefitVipPoint.text = "+"..self.skuInfo.vipPoint

    self.textDiscountRatio.text = "+".. LuaHelper.GetInteger((nFinalMultuile - 1) * 100).."%"
    if nSkuType == SkuInfoType.ShopCoins then
        if bDiscount then
            self.goDiscountRatioContainer:SetActive(true)
            self.textOriCoinCount.text = MoneyFormatHelper.numWithCommas(self.skuInfo.baseCoins)
            self.textCoinCount.text = MoneyFormatHelper.numWithCommas(self.skuInfo.finalCoins)
        else
            self.goDiscountRatioContainer:SetActive(false)
            self.textCoinCount.text = MoneyFormatHelper.numWithCommas(self.skuInfo.finalCoins)
        end
    else
        if bDiscount then
            self.goDiscountRatioContainer:SetActive(true)
            self.textOriCoinCount.text = MoneyFormatHelper.numWithCommas(self.skuInfo.baseDiamonds)
            self.textCoinCount.text = MoneyFormatHelper.numWithCommas(self.skuInfo.finalDiamonds)
        else
            self.goDiscountRatioContainer:SetActive(false)
            self.textCoinCount.text = MoneyFormatHelper.numWithCommas(self.skuInfo.finalDiamonds)
        end
    end

    self:SetItemLoungeContent()
    self:SetItemSlotsCardsUI()
    self:SetItemActiveContent()
end  

function BuyViewCoinsItem:SetItemLoungeContent()
    local goLounge = self.transform:FindDeepChild("SendContainer/Lounge").gameObject
    if not LoungeManager:orActivityOpen() then
        goLounge:SetActive(false)
        return
    end
    goLounge:SetActive(true)

    local skuInfo = self.skuInfo
    local nLoungePoint = 0
    for k, v in pairs(LoungeConfig.m_lsitSkuChestInfo) do
        if v.productId == skuInfo.productId then
            nLoungePoint = v.nLoungePoint
            break
        end
    end

    local textCount = self.transform:FindDeepChild("SendContainer/Lounge/textCount"):GetComponent(typeof(TextMeshProUGUI))
    textCount.text = " +"..nLoungePoint
end

function BuyViewCoinsItem:SetItemActiveContent()
    local skuInfo = self.skuInfo
    for k, v in pairs(ActiveType) do
        local activeType = v
        local goActiviItem = self.transform:FindDeepChild("Active/"..activeType)
        if ActiveManager.activeType == activeType then
            if ActiveManager:orActivityOpen() then
                if goActiviItem then
                    local nCount = _G[activeType.."IAPConfig"].skuMapOther[skuInfo.productId]
                    goActiviItem.gameObject:SetActive(nCount > 0)
                    local textPickCount = goActiviItem:FindDeepChild("textCount"):GetComponent(typeof(TextMeshProUGUI))
                    textPickCount.text = "+"..nCount
                end
            else
                if goActiviItem then
                    goActiviItem.gameObject:SetActive(false)
                end
            end
        else
            if goActiviItem then
                goActiviItem.gameObject:SetActive(false)
            end
        end
    end
end

function BuyViewCoinsItem:SetItemSlotsCardsUI()
    local skuInfo = self.skuInfo
    local cardContent = self.transform:FindDeepChild("SendContainer/Ka").gameObject
    if SlotsCardsManager:orActivityOpen() then
        cardContent:SetActive(true)
        local stars = cardContent.transform:FindDeepChild("Stars")
        local packCount = cardContent.transform:FindDeepChild("PackCount"):GetComponent((typeof(TextMeshProUGUI)))
        local packTypeContainer = cardContent.transform:FindDeepChild("KaPaiJieDian")
        
        for i = 1, #SlotsCardsGiftManager.m_skuToSlotsCardsPack do
            if skuInfo.productId == SlotsCardsGiftManager.m_skuToSlotsCardsPack[i].productId then
                local infoCount = SlotsCardsGiftManager.m_skuToSlotsCardsPack[i].info.packCount
                packCount.text = "+"..infoCount
                stars.sizeDelta = Unity.Vector2(20 * (SlotsCardsGiftManager.m_skuToSlotsCardsPack[i].info.packType), 20)
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

return BuyViewCoinsItem