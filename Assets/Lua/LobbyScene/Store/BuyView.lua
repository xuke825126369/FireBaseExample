BuyView = PopStackViewBase:New()
BuyView.SHOP_VIEW_TYPE = {
    NONE = 0,
    COINTYPE = 1,
    GEMTYPE = 2,
}

function BuyView:Init()
    if LuaHelper.OrGameObjectExist(self.transform) then
        return
    end

    local bundleName = "Lobby"
    local assetPath = "Assets/ResourceABs/Lobby/Shop01/Shop.prefab"
    local goPrefab = AssetBundleHandler:LoadAsset(bundleName, assetPath)
    local goPanel = Unity.Object.Instantiate(goPrefab)
    self.transform = goPanel.transform
    self.transform:SetParent(GlobalScene.popCanvasActivity, false)
    self.transform.localScale = Unity.Vector3.one
    self.transform.localPosition = Unity.Vector3.zero
    LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
    self.transform.gameObject:SetActive(false)

    self.mCommonResSerialization = self.transform:GetComponent(typeof(CS.CommonResSerialization))
    self.mButtonClose = self.transform:FindDeepChild("BtnClose"):GetComponent(typeof(UnityUI.Button))
    self.mButtonClose.onClick:AddListener(function()
        GlobalAudioHandler:PlayBtnSound()
        self:Hide()
    end)
    
    self.mSalesInfoText = self.transform:FindDeepChild("SalesInfoText"):GetComponent(typeof(TextMeshProUGUI))

    self.textCoinCount = self.transform:FindDeepChild("CoinsCountText"):GetComponent(typeof(TextMeshProUGUI))
    self.textSapphireCount = self.transform:FindDeepChild("DiamondsCountText"):GetComponent(typeof(TextMeshProUGUI))
    self.textCoinsAni = NumberAddLuaAni:New(self.textCoinCount)
    self.textSapphireAni = NumberAddLuaAni:New(self.textSapphireCount)

    self.mScrollContent = self.transform:FindDeepChild("ScrollView/ScrollContent"):GetComponent(typeof(Unity.RectTransform))

    self.mBtnCoins = self.transform:FindDeepChild("BtnCoins"):GetComponent(typeof(UnityUI.Button))
    self.mBtnCoins.onClick:AddListener(function()
        GlobalAudioHandler:PlayBtnSound()

        self.mBtnCoins.interactable = false
        self.mBtnEmerald.interactable = true
        LeanTween.value(self.mScrollContent.anchoredPosition.x, 0, 0.2):setOnUpdate(function(fValue)
            self.mScrollContent.anchoredPosition = Unity.Vector2(fValue, 0)
        end)
    end)

    self.mBtnEmerald = self.transform:FindDeepChild("BtnEmerald"):GetComponent(typeof(UnityUI.Button))
    self.mBtnEmerald.onClick:AddListener(function()
        GlobalAudioHandler:PlayBtnSound()

        self.mBtnCoins.interactable = true
        self.mBtnEmerald.interactable = false
        LeanTween.value(self.mScrollContent.anchoredPosition.x, -3300, 0.2):setOnUpdate(function(fValue)
            self.mScrollContent.anchoredPosition = Unity.Vector2(fValue, 0)
        end)
    end)
end

function BuyView:SetCoinsFlyEndPos()
	GlobalTempData.goUITopCollectMoneyEndPos = self.transform:FindDeepChild("CoinsContainer/JinBi").gameObject
end

function BuyView:Show(nShopType)
    self:Init()
    self.transform.gameObject:SetActive(true)
    EventHandler:AddListener("UpdateMyInfo", self)
    EventHandler:AddListener("onPurchaseFailedNotifycation", self)
    EventHandler:AddListener("onPurchaseDoneNotifycation", self)

    self:SetCoinsFlyEndPos()

    if GameHelper:orInTheme() then
        SceneSlotGame.m_bUIState = true
    end

    local bNoAni = false
    if nShopType == self.SHOP_VIEW_TYPE.COINTYPE then
        self.mBtnCoins.interactable = false
        self.mBtnEmerald.interactable = true
        self.mScrollContent.anchoredPosition = Unity.Vector2.zero
    elseif nShopType == self.SHOP_VIEW_TYPE.GEMTYPE then
        bNoAni = true
        self.mBtnCoins.interactable = true
        self.mBtnEmerald.interactable = false
        self.mScrollContent.anchoredPosition = Unity.Vector2(-3300, 0)
    end

    self.textCoinsAni:End(PlayerHandler.nGoldCount)
    self.textSapphireAni:End(PlayerHandler.nSapphireCount)

    local fItemPosX = 330
    local goCoinsItemPrefab = nil
    local goSapphireItemPrefab = nil
    local goBianQianFenGeXianPrefab = nil
    if ScreenHelper:isLandScape() then
        goCoinsItemPrefab = self.mCommonResSerialization:FindPrefab("CoinsSaleItem")
        goSapphireItemPrefab = self.mCommonResSerialization:FindPrefab("DiamondSaleItem")
        goBianQianFenGeXianPrefab = self.mCommonResSerialization:FindPrefab("BianQianFenGeXian")
    else
        goCoinsItemPrefab = self.mCommonResSerialization:FindPrefab("CoinsSalePortraitItem")
        goSapphireItemPrefab = self.mCommonResSerialization:FindPrefab("DiamondSalePortraitItem")
        goBianQianFenGeXianPrefab = self.mCommonResSerialization:FindPrefab("BianQianFenGeXianPortrait")
    end
    
    self.tableCoinsItem = {}
    for i = 1, 6 do
        local goCoinsItem = Unity.Object.Instantiate(goCoinsItemPrefab)
        goCoinsItem.transform:SetParent(self.mScrollContent, false)
        goCoinsItem.transform.localPosition = Unity.Vector3(fItemPosX, 0, 0)
        goCoinsItem.transform.localScale = Unity.Vector3.one

        local CoinsItemGenerator = require("Lua/LobbyScene/Store/BuyViewCoinsItem")
        self.tableCoinsItem[i] = CoinsItemGenerator:New(goCoinsItem, self)
        self.tableCoinsItem[i]:Refresh(i, SkuInfoType.ShopCoins)
        goCoinsItem:SetActive(true)

        fItemPosX = fItemPosX + 500
    end

    fItemPosX = fItemPosX - 100
    local goBianQianFenGeXianItem = Unity.Object.Instantiate(goBianQianFenGeXianPrefab)
    goBianQianFenGeXianItem.transform:SetParent(self.mScrollContent, false)
    goBianQianFenGeXianItem.transform.localPosition = Unity.Vector3(fItemPosX, 0, 0)
    goBianQianFenGeXianItem.transform.localScale = Unity.Vector3.one
    goBianQianFenGeXianItem:SetActive(true)
    fItemPosX = fItemPosX + 400
    self.goBianQianFenGeXianItem = goBianQianFenGeXianItem

    self.tableSapphireItem = {}
    for i = 1, 6 do
        local goSapphireItem = Unity.Object.Instantiate(goSapphireItemPrefab)
        goSapphireItem.transform:SetParent(self.mScrollContent, false)
        goSapphireItem.transform.localPosition = Unity.Vector3(fItemPosX, 0, 0)
        goSapphireItem.transform.localScale = Unity.Vector3.one

        local BuyViewCoinsItemGenerator = require("Lua/LobbyScene/Store/BuyViewCoinsItem")
        self.tableSapphireItem[i] = BuyViewCoinsItemGenerator:New(goSapphireItem, self)
        self.tableSapphireItem[i]:Refresh(i, SkuInfoType.ShopDiamonds)
        goSapphireItem:SetActive(true)

        fItemPosX = fItemPosX + 500
    end 

    self.mScrollContent.sizeDelta = Unity.Vector2(fItemPosX - 160, 0)
    local mScrollView = self.transform:FindDeepChild("ScrollView"):GetComponent(typeof(UnityUI.ScrollRect))
    mScrollView.onValueChanged:RemoveAllListeners()
    mScrollView.onValueChanged:AddListener(function(value)
        if self.mScrollContent.anchoredPosition.x < -2150 then
            self.mBtnCoins.interactable = true
            self.mBtnEmerald.interactable = false
        else
            self.mBtnCoins.interactable = false
            self.mBtnEmerald.interactable = true
        end
    end)

    if bNoAni then
        self.mScrollContent.gameObject:SetActive(true)
        for i = 1, #self.tableCoinsItem do
            local goCoinsItem = self.tableCoinsItem[i].transform
            goCoinsItem.transform.localScale = Unity.Vector3.one
        end
    else
        self.mScrollContent.gameObject:SetActive(false)
        LeanTween.delayedCall(0, function()
            self.mScrollContent.anchoredPosition = Unity.Vector2(3000, 0)
            mScrollView.elasticity = 0.2
            self.mScrollContent.gameObject:SetActive(true)
            LeanTween.delayedCall(0.5, function(fValue)
                mScrollView.elasticity = 0.1
            end)

            local nScaleAniIndex = 0
            for i = 1, #self.tableCoinsItem do
                local goCoinsItem = self.tableCoinsItem[i].transform
                goCoinsItem.transform.localScale = Unity.Vector3.zero
                LeanTween.scale(goCoinsItem, Unity.Vector3.one, 0.3):setEase(LeanTweenType.easeInBack):setDelay(nScaleAniIndex * 0.2)
                nScaleAniIndex = nScaleAniIndex + 1
            end
        end)
    end

    self.trStoreBonusUI = self.transform:FindDeepChild("StoreBonusUI")
    ShopBonusUI:Show(self.trStoreBonusUI)
end

function BuyView:Refresh()
    for i = 1, 6 do
        self.tableCoinsItem[i]:Refresh(i, SkuInfoType.ShopCoins)
    end

    for i = 1, 6 do
        self.tableSapphireItem[i]:Refresh(i, SkuInfoType.ShopDiamonds)
    end 
end

function BuyView:Hide()
    LobbyView:SetCoinsFlyEndPos()
    self.transform.gameObject:SetActive(false)
    EventHandler:RemoveListener("UpdateMyInfo", self)
    EventHandler:RemoveListener("onPurchaseFailedNotifycation", self)
    EventHandler:RemoveListener("onPurchaseDoneNotifycation", self)

    Unity.Object.Destroy(self.transform.gameObject)
    if GameHelper:orInTheme() then
        SceneSlotGame.m_bUIState = false
    end
end

function BuyView:onPurchaseFailedNotifycation()
    WindowLoadingView:Hide()
    CommonDialogBox:ShowSureUI("Purchase Failed")
end

function BuyView:onPurchaseDoneNotifycation(skuInfo)
    WindowLoadingView:Hide()
    local nDollar = skuInfo.nDollar  
    local bDiscount, nFinalMultuile = BuyHandler:orDiscount(skuInfo.nType)
    PlayerHandler:AddRecharge(nDollar)
    if skuInfo.nType == SkuInfoType.ShopDiamonds then
        local nSapphireCount = FormulaHelper:GetAddSapphireBySpendDollar(nDollar) * nFinalMultuile
        PlayerHandler:AddSapphire(nSapphireCount)        
    else
        local nMoneyCount = FormulaHelper:GetAddMoneyBySpendDollar(nDollar) * nFinalMultuile
        PlayerHandler:AddCoin(nMoneyCount)
    end     

    PopStackViewHandler:Show(ShopEndPop, skuInfo, false)
    self:Refresh()
end

function BuyView:UpdateMyInfo()
    self.textCoinsAni:ChangeTo(PlayerHandler.nGoldCount)
    self.textSapphireAni:ChangeTo(PlayerHandler.nSapphireCount)
end