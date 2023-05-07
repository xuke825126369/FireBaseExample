local FinalPrize = {}

function FinalPrize:Init()
    local prefabObj = AssetBundleHandler:LoadActivityAsset("FinalPrize")
    self.transform.gameObject = Unity.Object.Instantiate(prefabObj)
    LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
    self.transform.gameObject:SetActive(false)
    self.transform = self.transform.gameObject.transform
    self.transform:SetParent(LobbyScene.popCanvas, false)

    self.popController = PopController:new(self.transform.gameObject, nil, PopTweenType.alpha)
    self.textCoin  = self.transform:FindDeepChild("textCoin"):GetComponent(typeof(TextMeshProUGUI))
    self.btn = self.transform:GetComponentInChildren(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(self.btn)
    self.btn.onClick:AddListener(function()
        if self.bCanHide then
            GlobalAudioHandler:PlayBtnSound()
            ActivityAudioHandler:PlaySound("board_closeWindow")
            self:hide()
        end
    end)
end

function FinalPrize:Show()
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

    self.bCanHide = true
    self.textCoin.text = MoneyFormatHelper.numWithCommas(self.nCoin)
    self.popController:show(nil , function()
        ActivityHelper:PlayAni(self.transform.gameObject, "Show")
        ActivityAudioHandler:PlaySound("board_final_cheer")
        GlobalAudioHandler:LowerActiveBackgroundMusicVolume()
    end, true)

	StaticDataHandler:add(ActiveManager.activeType, "nFinalPrizeTime")
end

function FinalPrize:hide()
    if not self.bCanHide then
        return 
    end
    self.bCanHide = false
    CoinFly:fly2(self.textCoin.transform.position, GlobalTempData.goUITopCollectMoneyEndPos.transform.position, 40, true, self.nPlayerCoin)
    local fDelayTime = 1.5 + 0.12 * 40
    LeanTween.delayedCall(fDelayTime, function()
        ViewScaleAni:Hide(self.transform.gameObject)
        ActivityHelper:SetTrigger(self.transform.gameObject, "Hide")
    end)
end

return FinalPrize
