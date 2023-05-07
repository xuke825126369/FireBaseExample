--过了一关，给的奖励弹窗
local LevelPrize = {}

function LevelPrize:Init()
    local prefabObj = AssetBundleHandler:LoadActivityAsset("LevelPrize")
    self.transform.gameObject = Unity.Object.Instantiate(prefabObj)
    self.transform.gameObject:SetActive(false)
    self.transform = self.transform.gameObject.transform
    self.transform:SetParent(LobbyScene.popCanvas, false)
    self.popController = PopController:new(self.transform.gameObject, nil, PopTweenType.alpha)

    self.textCoin  = self.transform:FindDeepChild("textCoin"):GetComponent(typeof(TextMeshProUGUI))
    local btn = self.transform:GetComponentInChildren(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(btn)
    btn.onClick:AddListener(function()
        if self.bCanHide then
            ActivityAudioHandler:PlaySound("board_closeWindow")
            self:hide()
        end
    end)
end

function LevelPrize:Show()
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
        ActivityAudioHandler:PlaySound("board_level_cheer")
        GlobalAudioHandler:LowerActiveBackgroundMusicVolume()
    end, true)
end

function LevelPrize:hide()
    if not self.bCanHide then
        return 
    end
    self.bCanHide = false
    CoinFly:fly2(self.textCoin.transform.position, GlobalTempData.goUITopCollectMoneyEndPos.transform.position, 10, true, self.nPlayerCoin)
    local fDelayTime = 1.5 + 0.12 * 10
    LeanTween.delayedCall(fDelayTime, function()
        ViewScaleAni:Hide(self.transform.gameObject)
    end)
end

return LevelPrize
