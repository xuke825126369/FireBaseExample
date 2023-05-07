--LuckyPick结束奖励金币的弹窗
local LuckyPickEndSplashUI = {}

function LuckyPickEndSplashUI:Init()
    local prefabObj = AssetBundleHandler:LoadActivityAsset("LuckyPickEndSplashUI")
    self.transform.gameObject = Unity.Object.Instantiate(prefabObj)
    self.transform.gameObject:SetActive(false)
    self.transform = self.transform.gameObject.transform
    self.transform:SetParent(LobbyScene.popCanvas, false)
    self.popController = PopController:new(self.transform.gameObject, nil, PopTweenType.alpha)

    self.btn = self.transform:GetComponentInChildren(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(self.btn)
    self.btn.onClick:AddListener(function()
        if self.bCanHide then
            self:hide()
        end
    end)
    self.textBasePrize = self.transform:FindDeepChild("textBasePrize"):GetComponent(typeof(UnityUI.Text))
    self.textMultiplier = self.transform:FindDeepChild("textMultiplier"):GetComponent(typeof(UnityUI.Text))
    self.textWinCoin = self.transform:FindDeepChild("textWinCoin"):GetComponent(typeof(UnityUI.Text))
end

function LuckyPickEndSplashUI:show(nCoin, nBasePrize, nMultiplier, nPlayerCoin)
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
    self.textWinCoin.text = MoneyFormatHelper.numWithCommas(nCoin)
    self.textBasePrize.text = MoneyFormatHelper.coinCountOmit(nBasePrize)
    self.textMultiplier.text = tostring(nMultiplier)
    self.nPlayerCoin = nPlayerCoin
    self.popController:show(nil, function()
        ActivityAudioHandler:PlaySound("rainbow_reward_pop")
        GlobalAudioHandler:LowerActiveBackgroundMusicVolume()
    end, true)
end

function LuckyPickEndSplashUI:hide()
    if not self.bCanHide then
        return 
    end
    self.bCanHide = false
    ActivityAudioHandler:PlaySound("rainbow_closeWindow")
    CoinFly:fly2(self.textWinCoin.transform.position, GlobalTempData.goUITopCollectMoneyEndPos.transform.position, 10, true, self.nPlayerCoin)
    local fDelayTime = 1.5 + 0.12 * 10
    LeanTween.delayedCall(fDelayTime, function()
        self.popController:hide(false, function()
            RainbowPickMainUIPop.bCanClick = true
        end)
    end)
end

return LuckyPickEndSplashUI