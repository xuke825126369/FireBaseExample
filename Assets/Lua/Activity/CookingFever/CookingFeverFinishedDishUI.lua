CookingFeverFinishedDishUI = {}

function CookingFeverFinishedDishUI:Init()
    local prefabObj = AssetBundleHandler:LoadActivityAsset("FinishedDish")
    Debug.Assert(prefabObj)
    self.transform.gameObject = Unity.Object.Instantiate(prefabObj)
    self.transform.gameObject:SetActive(false)
    self.transform = self.transform.gameObject.transform
    self.transform:SetParent(LobbyScene.popCanvas, false)
    self.popController = PopController:new(self.transform.gameObject, nil, PopTweenType.alpha)

    self.textCoin = self.transform:FindDeepChild("textCoin"):GetComponent(typeof(UnityUI.Text))
    self.btnCollect = self.transform:FindDeepChild("btnCollect"):GetComponent(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(self.btnCollect)
    self.btnCollect.onClick:AddListener(function()
        ActivityAudioHandler:PlaySound("cook_button")
        self:hide()
    end)

    self.imageDish = self.transform:FindDeepChild("imageDish"):GetComponent(typeof(UnityUI.Image))
end

function CookingFeverFinishedDishUI:show(nDishId, nDishCoin, nPlayerCoin)
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
    
    self.btnCollect.interactable = true
    self.imageDish.sprite = CookingFeverSymbolPool:getDishSprite(nDishId)
    self.textCoin.text = MoneyFormatHelper.numWithCommas(nDishCoin)
    self.nPlayerCoin = nPlayerCoin
    self.popController:show(nil , function()
        ActivityAudioHandler:PlaySound("cook_food_cheer")
        GlobalAudioHandler:LowerActiveBackgroundMusicVolume()
    end ,true)
end

function CookingFeverFinishedDishUI:hide()
    self.btnCollect.interactable = false
    CoinFly:fly2(self.textCoin.transform.position, GlobalTempData.goUITopCollectMoneyEndPos.transform.position, 10, true, self.nPlayerCoin)
    LeanTween.delayedCall(1.5 + 0.12 * 10, function() 
        ViewScaleAni:Hide(self.transform.gameObject)
        ActivityHelper:SetTrigger(self.transform.gameObject, "Hide")
    end)
end