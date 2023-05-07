require "Lua/LobbyScene/WheelOfFun/DealOfFunTipPop"

DealOfFunPopView = {}
DealOfFunPopView.m_nHitIndex = 1
DealOfFunPopView.DealOfFunConfig = {
    orders = {15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1},
    probs = {10, 20, 5, 20, 20, 10, 5, 20, 10, 10, 10, 10, 10, 5, 10},
    basicMul = { 50, 5, 3, 5, 15, 3, 2, 20, 5, 3, 5, 10, 5, 2, 20 } 
}

DealOfFunPopView.m_nCurrentBasePrize = 1750000
local nBasePrize = 1750000 --以这个为主

function DealOfFunPopView:Init()
    if LuaHelper.OrGameObjectExist(self.transform) then
        return
    end
    
    local bundleName = "Lobby"
	local assetPath = "NowDealOfFun/DealOfFunPop.prefab"
	local goPrefab = AssetBundleHandler:LoadAsset(bundleName, assetPath)
	local goPanel = Unity.Object.Instantiate(goPrefab)

    local goParent = LobbyScene .popCanvas
    self.transform = goPanel.transform
    self.transform:SetParent(goParent, false)
    self.transform.localScale = Unity.Vector3.one
	self.transform.localPosition = Unity.Vector3.zero
	LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
	self.transform.gameObject:SetActive(false)

    self.popAni = self.transform.gameObject:GetComponent(typeof(Unity.Animator))
    self.container = self.transform:FindDeepChild("Container")
    self.wheelRectTransform = self.transform:FindDeepChild("innerMask")

    self.mulText = self.transform:FindDeepChild("MulText"):GetComponent(typeof(TextMeshProUGUI))
    self.basePrizeText = self.transform:FindDeepChild("BasePrizeText"):GetComponent(typeof(TextMeshProUGUI))

    self.dealButton = self.transform:FindDeepChild("DealButton"):GetComponent(typeof(UnityUI.Button))
    self.dealPriceText = self.transform:FindDeepChild("DealPriceText"):GetComponent(typeof(TextMeshProUGUI))

    self.spinButton = self.transform:FindDeepChild("SpinButton"):GetComponent(typeof(UnityUI.Button))
    self.closeButton = self.transform:FindDeepChild("CloseBtn"):GetComponent(typeof(UnityUI.Button))

    self.fullLoadingGameObject = self.transform:FindDeepChild("FullLoading").gameObject
    self.getGiftEffect = self.transform:FindDeepChild("zhongjianglizi").gameObject
    self.goSpinLogo = self.transform:FindDeepChild("Spin").gameObject

    self.trZhiZhen = self.transform:FindDeepChild("zhizhen")

    self.bonusTextArray = {}
    local textContainer = self.transform:FindDeepChild("WheelRewardContainer")
    for i = 0, textContainer.childCount - 1 do
        local bonusText = textContainer:GetChild(i):GetComponent(typeof(TextMeshProUGUI))
        self.bonusTextArray[i + 1] = bonusText
    end

    DelegateCache:addOnClickButton(self.dealButton)
    self.dealButton.onClick:AddListener(function()
        self:onDealBtnClicked()
    end)
    DelegateCache:addOnClickButton(self.spinButton)
    self.spinButton.onClick:AddListener(function()
        self:onSpinBtnClicked()
    end)
    DelegateCache:addOnClickButton(self.closeButton)
    self.closeButton.onClick:AddListener(function()
        self:onCloseBtnClicked()
    end)
end

function DealOfFunPopView:Show()
    self:Init()
    self.transform:SetAsLastSibling()
    local dealFunIndex = math.random(1, #AllBuyCFG)

    self.goSpinLogo:SetActive(true)
    self.trZhiZhen.localRotation = Unity.Quaternion.AngleAxis(0, Unity.Vector3.forward)
    self.closeButton.gameObject:SetActive(true)
    self.fullLoadingGameObject:SetActive(false)
    self.getGiftEffect:SetActive(false)
    self.dealFunIndex = dealFunIndex

    self.productId = AllBuyCFG[dealFunIndex].productId
    self.nDealOfWheelMul = math.random(1, 30)
    self.mulText.text = "x"..self.nDealOfWheelMul

    local levelMultiplier = FormulaHelper:getLevelMultiplier()
    local vipMultiply = VipHandler:GetVipCoefInfo()
    local nMul, fProgress, nIndex = FreeBonusMultiplier:getMultiplier()
    self.m_nCurrentBasePrize = nBasePrize * levelMultiplier * nMul
    self.basePrizeText.text = MoneyFormatHelper.numWithCommas(self.m_nCurrentBasePrize)

    local skuInfo = GameHelper:GetSimpleSkuInfoById(self.productId)
    local baseBonus = {}
    for i = 1, #self.DealOfFunConfig.basicMul do
        baseBonus[i] = self.DealOfFunConfig.basicMul[i] * self.m_nCurrentBasePrize * self.nDealOfWheelMul * vipMultiply
    end
    self.bonusArray = baseBonus
    
    self.dealPriceText.text = "FOR $"..skuInfo.nDollar
    for i, bonusText in ipairs(self.bonusTextArray) do
        bonusText.text = "x"..(self.DealOfFunConfig.basicMul[i] * self.nDealOfWheelMul)
    end 
    
    self.lastIndex = 1
    self.wheelRectTransform.rotation = Unity.Quaternion.Euler(0, 0, 0)
    self.dealButton.gameObject:SetActive(true)
    self.spinButton.gameObject:SetActive(false)
    self.closeButton.gameObject:SetActive(true)

    GlobalAudioHandler:PlaySound("dealoffun_pop")
    self.transform.gameObject:SetActive(true)
    self.transform:SetAsLastSibling()
    LeanTween.delayedCall(1.5, function()
        GlobalAudioHandler:PlayBackMusic("wheel_loop")
    end)
    GlobalAudioHandler:setBGMusicVolume(0.3)
    self.m_nHitIndex = self:getHitIndex()
end

function DealOfFunPopView:onCloseBtnClicked()
    GlobalAudioHandler:PlayBtnSound()
    DealOfFunTipPop:Show(self.productId)
end

function DealOfFunPopView:onDealBtnClicked()
    GlobalAudioHandler:PlayBtnSound()
    WindowLoadingView:Show()
    EventHandler:AddListener("onPurchaseFailedNotifycation", self)
    EventHandler:AddListener("onPurchaseDoneNotifycation", self)

    local skuInfo = GameHelper:GetSimpleSkuInfoById(self.productId)
    skuInfo.nType = SkuInfoType.DealOfFun
    self.bonusValue = self.bonusArray[self.m_nHitIndex]

    UnityPurchasingHandler:purchase(skuInfo)
end

function DealOfFunPopView:onSpinBtnClicked()
    self.goSpinLogo:SetActive(false)
    GlobalAudioHandler:PlaySound("dealoffun_press_spin")
    self.closeButton.gameObject:SetActive(false)
    self.spinButton.interactable = false
    local hitIndex = self.m_nHitIndex

    local toDegree = -360 * 10 - 360 / 15 * (hitIndex - 1)
    LeanTween.value(0, toDegree, 8):setEase(LeanTweenType.easeInOutQuad):setOnStart(function()
        GlobalAudioHandler:PlaySound("wheelTick")
    end):setOnUpdate(function(value)
        self.wheelRectTransform.rotation = Unity.Quaternion.Euler(0, 0, value)
    end):setOnComplete(function()
        GlobalAudioHandler:PlaySound("wheel_cheer")
        self.getGiftEffect:SetActive(true)
        GlobalAudioHandler:PlaySound("dealoffun_wheelstop")
        local iapMultiplier = VipHandler:GetVipCoefInfo()
        -- 展示结算页面
        LeanTween.delayedCall(1.5, function()
            FreeBonusSettleMultiplierFrame:Show(self.m_nCurrentBasePrize, iapMultiplier, self.nDealOfWheelMul * self.DealOfFunConfig.basicMul[self.m_nHitIndex], function()
                self:onCollectBtnClicked()
            end)
        end)
    end)    

end

function DealOfFunPopView:onCollectBtnClicked()
    self.getGiftEffect:SetActive(false)
    self.popAni:Play("Containertuichu")
    LeanTween.delayedCall(1, function()
        self.transform.gameObject:SetActive(false)
        if WheelOfFunPopView.m_bDailyTaskBonusFlag then
            GlobalAudioHandler:PlayMissionMusic("bgm")
        else
            GlobalAudioHandler:PlayLobbyBackMusic()
            GlobalAudioHandler:setBGMusicVolume(1)
        end
    end)
end

function DealOfFunPopView:getHitIndex()
    local index = LuaHelper.GetIndexByRate(self.DealOfFunConfig.probs)
    return index
end

function DealOfFunPopView:onPurchaseDoneNotifycation(data)
    EventHandler:RemoveListener("onPurchaseFailedNotifycation", self)
    EventHandler:RemoveListener("onPurchaseDoneNotifycation", self)

    PlayerHandler:AddCoin(self.bonusValue)
    AppLocalEventHandler:OnPlayLuckyWheelEvt()
    
    self.dealButton.gameObject:SetActive(false)
    self.spinButton.gameObject:SetActive(true)
    self.spinButton.interactable = true
    self.closeButton.gameObject:SetActive(false)

    WindowLoadingView:Hide()
end

function DealOfFunPopView:onPurchaseFailedNotifycation()
    WindowLoadingView:Hide()
    EventHandler:RemoveListener("onPurchaseFailedNotifycation", self)
    EventHandler:RemoveListener("onPurchaseDoneNotifycation", self)
    CommonDialogBox:ShowSureUI("Purchase failed")
end
