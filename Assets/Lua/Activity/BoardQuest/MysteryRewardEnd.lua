--LuckyPick结束奖励金币的弹窗
local MysteryRewardEnd = {}

function MysteryRewardEnd:Init()
    local prefabObj = AssetBundleHandler:LoadActivityAsset("MysteryRewardEnd")
    self.transform.gameObject = Unity.Object.Instantiate(prefabObj)
    self.transform.gameObject:SetActive(false)
    self.transform = self.transform.gameObject.transform
    self.transform:SetParent(LobbyScene.popCanvas, false)
    self.popController = PopController:new(self.transform.gameObject, nil, PopTweenType.alpha)

    self.btn = self.transform:GetComponentInChildren(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(self.btn)
    self.btn.onClick:AddListener(function()
        if self.bCanHide then
            ActivityAudioHandler:PlaySound("board_closeWindow")
            self:onClick()
        end
    end)

    self.goCannon = self.transform:FindDeepChild("Cannon").gameObject
    self.goDice = self.transform:FindDeepChild("Dice").gameObject
    self.goCoin = self.transform:FindDeepChild("Coin").gameObject

    self.textWinCoin = self.transform:FindDeepChild("textWinCoin"):GetComponent(typeof(TextMeshProUGUI))
end

function MysteryRewardEnd:Show()
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

    if self.nRewardType == BoardQuestConfig.MYSTERY_REWARD_ITEM.COIN1 
    or self.nRewardType == BoardQuestConfig.MYSTERY_REWARD_ITEM.COIN2 
    or self.nRewardType == BoardQuestConfig.MYSTERY_REWARD_ITEM.COIN3 then
        self.goCannon:SetActive(false)
        self.goCoin:SetActive(true)
        self.goDice:SetActive(false)

        self.textWinCoin.text = MoneyFormatHelper.numWithCommas(self.nCoin)
    elseif self.nRewardType == BoardQuestConfig.MYSTERY_REWARD_ITEM.CANNON then
        self.goCannon:SetActive(true)
        self.goCoin:SetActive(false)
        self.goDice:SetActive(false)
    elseif self.nRewardType == BoardQuestConfig.MYSTERY_REWARD_ITEM.DICE then
        self.goCannon:SetActive(false)
        self.goCoin:SetActive(false)
        self.goDice:SetActive(true)
    end

    self.popController:show(nil, function()
        ActivityAudioHandler:PlaySound("board_reward_pop")
        GlobalAudioHandler:LowerActiveBackgroundMusicVolume()
    end, true)
end

function MysteryRewardEnd:onClick()
    if self.nRewardType == BoardQuestConfig.MYSTERY_REWARD_ITEM.COIN1 
    or self.nRewardType == BoardQuestConfig.MYSTERY_REWARD_ITEM.COIN2 
    or self.nRewardType == BoardQuestConfig.MYSTERY_REWARD_ITEM.COIN3 then
        CoinFly:fly2(self.textWinCoin.transform.position, GlobalTempData.goUITopCollectMoneyEndPos.transform.position, 10, true, self.nPlayerCoin)
        LeanTween.delayedCall(1.5 + 0.12 * 10, function()
            self.popController:hide(false, function()
                BoardQuestMainUIPop:setInAnimation(false)
            end)
        end)
    elseif self.nRewardType == BoardQuestConfig.MYSTERY_REWARD_ITEM.CANNON then
        self.popController:hide(false, function()
            BoardQuestMainUIPop:move(self.nTotal)
        end)
    elseif self.nRewardType == BoardQuestConfig.MYSTERY_REWARD_ITEM.DICE then
        self.popController:hide(false, function()
            BoardQuestMainUIPop:setInAnimation(false)
        end)
    end
end

return MysteryRewardEnd