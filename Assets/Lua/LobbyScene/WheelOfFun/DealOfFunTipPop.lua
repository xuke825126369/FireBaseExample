DealOfFunTipPop = {}

function DealOfFunTipPop:Init()
    if LuaHelper.OrGameObjectExist(self.transform) then
        return
    end

    local bundleName = "Lobby"
	local assetPath = "NowDealOfFun/DealOfFunTipPop.prefab"
	local goPrefab = AssetBundleHandler:LoadAsset(bundleName, assetPath)
	local goPanel = Unity.Object.Instantiate(goPrefab)
    
    local goParent = LobbyScene .popCanvas
    self.transform = goPanel.transform
    self.transform:SetParent(goParent, false)
    self.transform.localScale = Unity.Vector3.one
	self.transform.localPosition = Unity.Vector3.zero
	LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
	self.transform.gameObject:SetActive(false)
    
    self.container = self.transform:FindDeepChild("Container")
    self.spinButton = self.transform:FindDeepChild("ButtonPlay"):GetComponent(typeof(UnityUI.Button))
    self.closeButton = self.transform:FindDeepChild("CloseBtn"):GetComponent(typeof(UnityUI.Button))

    DelegateCache:addOnClickButton(self.spinButton)
    self.spinButton.onClick:AddListener(function()
        self:onSpinBtnClicked()
    end)
    DelegateCache:addOnClickButton(self.closeButton)
    self.closeButton.onClick:AddListener(function()
        self:onCloseBtnClicked()
    end)
    self.dealPriceText = self.transform:FindDeepChild("DealPrizeText"):GetComponent(typeof(TextMeshProUGUI))
    self.mulText = self.transform:FindDeepChild("TextMeshProBeiShu"):GetComponent(typeof(TextMeshProUGUI))
    self.finalRewardText = self.transform:FindDeepChild("FinalRewardText"):GetComponent(typeof(UnityUI.Text))

end

function DealOfFunTipPop:Show(sku)
    self:Init()
    self.transform:SetAsLastSibling()

    local skuInfo = GameHelper:GetSimpleSkuInfoById(sku)
    self.mulText.text = DealOfFunPopView.mulText.text
    self.closeButton.gameObject:SetActive(true)
    self.dealPriceText.text = "For Only $"..skuInfo.nDollar
    local bonusValue = DealOfFunPopView.bonusArray[1]
    self.finalRewardText.text = MoneyFormatHelper.numWithCommas(bonusValue)
    ViewScaleAni:Show(self.transform.gameObject)
end

function DealOfFunTipPop:onCloseBtnClicked()
    GlobalAudioHandler:PlaySound("dealoffun_cancel")
    DealOfFunPopView:onCollectBtnClicked()
    ViewScaleAni:Hide(self.transform.gameObject)
end

function DealOfFunTipPop:onSpinBtnClicked()
    GlobalAudioHandler:PlayBtnSound()
    ViewScaleAni:Hide(self.transform.gameObject)
end
