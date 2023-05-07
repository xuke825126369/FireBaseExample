CookingFeverLevelPrizeSplashUI = {}

function CookingFeverLevelPrizeSplashUI:Init()
    local prefabObj = AssetBundleHandler:LoadActivityAsset("LevelPrizeSplashUI")
    self.transform.gameObject = Unity.Object.Instantiate(prefabObj)
    LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
    self.transform.gameObject:SetActive(false)
    self.transform = self.transform.gameObject.transform
    self.transform:SetParent(LobbyScene.popCanvas, false)

    self.popController = PopController:new(self.transform.gameObject, nil, PopTweenType.alpha)
    self.textWinCoin  = self.transform:FindDeepChild("textWinCoin"):GetComponent(typeof(UnityUI.Text))
    self.textIngredientsWinCoin  = self.transform:FindDeepChild("textIngredientsWinCoin"):GetComponent(typeof(UnityUI.Text))

    self.btn = self.transform:GetComponentInChildren(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(self.btn)
    self.btn.onClick:AddListener(function()
        ActivityAudioHandler:PlaySound("cook_button")
        self:hide()
    end)

    self.goSlotsCards = self.transform:FindDeepChild("SlotsCards").gameObject
    self.tableGoCardPack = LuaHelper.GetTableFindChild(self.transform, 5, "CardPack")
    self.tableGoStar = LuaHelper.GetTableFindChild(self.transform, 5, "Star")
    self.textCardPackCount = self.transform:FindDeepChild("textCardPackCount"):GetComponent(typeof(TextMeshProUGUI))
end

function CookingFeverLevelPrizeSplashUI:show(nLevelWinCoin, nIngredientsCoin, nPlayerCoin, nCardPackType, nCardPackCount)
    if self.transform.gameObject == nil then
        self.m_bInitFlag = false
    else
        if self.transform.gameObject:Equals(nil) then
            self.m_bInitFlag = false
        end
    end
    if not self.m_bInitFlag then
        self.m_bInitFlag = true
        self:Init()
    end

    self.btn.interactable = true
    self.textWinCoin.text = MoneyFormatHelper.numWithCommas(nLevelWinCoin)
    self.textIngredientsWinCoin.text = MoneyFormatHelper.numWithCommas(nIngredientsCoin)
    self.nPlayerCoin = nPlayerCoin

    self.goSlotsCards:SetActive(nCardPackType)
    if nCardPackType then
        local nCardPackLevel = nCardPackType + 1
        for i = 1, 5 do
            self.tableGoCardPack[i]:SetActive(i == nCardPackLevel)
            self.tableGoStar[i]:SetActive(i <= nCardPackLevel)
        end
        self.textCardPackCount.text = math.floor(nCardPackCount)
    else
        self.goSlotsCards:SetActive(false)
    end
    
    self.popController:show(nil , function()
        ActivityAudioHandler:PlaySound("cook_level_cheer")
        GlobalAudioHandler:LowerActiveBackgroundMusicVolume()
    end, true)
end

function CookingFeverLevelPrizeSplashUI:hide()
    self.btn.interactable = false
    CoinFly:fly2(self.textWinCoin.transform.position, GlobalTempData.goUITopCollectMoneyEndPos.transform.position, 10, true, self.nPlayerCoin)
    local fDelayTime = 1.5 + 0.12 * 10
    LeanTween.delayedCall(fDelayTime, function()
        ActivityHelper:SetTrigger(self.transform.gameObject, "Hide")
        ViewScaleAni:Hide(self.transform.gameObject)
    end)
end
