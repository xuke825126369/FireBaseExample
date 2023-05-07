--过了一关，给的奖励弹窗
local RewardCoinOnBoard = {}

function RewardCoinOnBoard:Init()
    local prefabObj = AssetBundleHandler:LoadActivityAsset("RewardCoinOnBoard")
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
            self:hide()
        end
    end)
end

function RewardCoinOnBoard:Show()
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
        ActivityAudioHandler:PlaySound("board_reward_pop")
        GlobalAudioHandler:LowerActiveBackgroundMusicVolume()
    end, true)
end

function RewardCoinOnBoard:hide()
    if not self.bCanHide then
        return 
    end
    self.bCanHide = false
    ActivityAudioHandler:PlaySound("board_closeWindow")
    CoinFly:fly2(self.textCoin.transform.position, GlobalTempData.goUITopCollectMoneyEndPos.transform.position, 10, true, self.nPlayerCoin)
    local fDelayTime = 1.5 + 0.12 * 10
    LeanTween.delayedCall(fDelayTime, function()
        ViewScaleAni:Hide(self.transform.gameObject)
        BoardQuestMainUIPop:setInAnimation(false)
    end)
end

return RewardCoinOnBoard
