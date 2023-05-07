--打开箱子，奖励钻石、金币、卡包的弹窗
local ChestRewardSplashUI = {}

function ChestRewardSplashUI:Init()
    local prefabObj = AssetBundleHandler:LoadActivityAsset("ChestRewardSplashUI")
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
    
    self.goCardPack = self.transform:FindDeepChild("Reward/CardPack").gameObject
    self.goCoin = self.transform:FindDeepChild("Reward/Coin").gameObject
    self.goDiamond = self.transform:FindDeepChild("Reward/Diamond").gameObject
    self.goLuckyPick = self.transform:FindDeepChild("Reward/LuckyPick").gameObject

    self.tableGoReward = {self.goCardPack, self.goCoin, self.goDiamond, self.goLuckyPick}

    self.cardPackUI = CardPackUI:new(self.goCardPack)
    self.textWinCoin = self.goCoin.transform:FindDeepChild("textWinCoin"):GetComponent(typeof(UnityUI.Text))
    self.textDiamond = self.goDiamond.transform:FindDeepChild("textDiamond"):GetComponent(typeof(UnityUI.Text))
end

function ChestRewardSplashUI:show(info)
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
    ActivityAudioHandler:PlaySound("rainbow_normal_pop")
    GlobalAudioHandler:LowerActiveBackgroundMusicVolume()
    self.info = info
    for i = 1, 4 do
        self.tableGoReward[i]:SetActive(i == info.nRewardType)
    end
    if info.nRewardType == RainbowPickConfig.ChestReward.CardPack then
        self.cardPackUI:set(info.nCardPackType, info.nCount)
    elseif info.nRewardType == RainbowPickConfig.ChestReward.Coin then
        self.textWinCoin.text = MoneyFormatHelper.numWithCommas(info.nCount)
        self.nPlayerCoin = info.nPlayerCoin
    elseif info.nRewardType == RainbowPickConfig.ChestReward.Diamond then
        self.textDiamond.text = "+"..math.floor(info.nCount)
    end
    self.popController:show(nil, nil, true)
end

function ChestRewardSplashUI:hide()
    if not self.bCanHide then
        return 
    end
    self.bCanHide = false
    ActivityAudioHandler:PlaySound("rainbow_closeWindow")
    if self.info.nRewardType == RainbowPickConfig.ChestReward.Coin then
        CoinFly:fly2(self.textWinCoin.transform.position, GlobalTempData.goUITopCollectMoneyEndPos.transform.position, 10, true, self.nPlayerCoin)
        local fDelayTime = 1.5 + 0.12 * 10
        LeanTween.delayedCall(fDelayTime, function()
            self.popController:hide(false, function() RainbowPickMainUIPop.bCanClick = true end)
        end)
    else
        ActivityHelper:SetTrigger(self.transform.gameObject, "Hide")
        self.popController:hide(false, function()
            RainbowPickMainUIPop.bCanClick = true
        end)
    end
end

return ChestRewardSplashUI