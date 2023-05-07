RocketFortuneWinPop = {}
RocketFortuneWinPop.m_btnCollect = nil
RocketFortuneWinPop.m_rewardText = nil

function RocketFortuneWinPop:Show(parentTransform)
    if self.transform == nil then
        self.transform.gameObject = Unity.Object.Instantiate(AssetBundleHandler:LoadActivityAsset("LevelPrize"))
        self.transform = self.transform.gameObject.transform
        self.popController = PopController:new(self.transform.gameObject)
        LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
        local collectButton = self.transform:FindDeepChild("CollectBtn"):GetComponent(typeof(UnityUI.Button))
        collectButton.onClick:AddListener(function()
            self:onCollectBtnClicked()
        end)
        DelegateCache:addOnClickButton(collectButton)
        self.m_btnCollect = collectButton
        ActivityHelper:addUIEventObserver(self, function(b)
            self.m_btnCollect.interactable = b
        end)
    end
    ActivityHelper:postUIEvent(self, true)
    self:initContent()

    parentTransform = parentTransform or LobbyScene.popCanvas
    self.transform:SetParent(parentTransform, false)
    ViewScaleAni:Show(self.transform.gameObject)
end

function RocketFortuneWinPop:initContent()
    self.m_rewardText = self.transform:FindDeepChild("Reward"):GetComponent(typeof(UnityUI.Text))
    self.m_rewardText.text = MoneyFormatHelper.numWithCommas(RocketFortuneLevelManager.nRewardCoins)
end

function RocketFortuneWinPop:onCollectBtnClicked()
    ActivityHelper:postUIEvent(self, false)
    local ftime = 2.5
    local coinPos = self.m_rewardText.transform.position
    CoinFly:fly(coinPos, GlobalTempData.goUITopCollectMoneyEndPos.transform.position, 12)
    LeanTween.delayedCall(ftime, function()
        --动画做完后，显示选择关卡页面
        self.popController:hide(true)
        RocketFortuneMainUIPop.popController:hide(true)
        RocketFortuneMainUIPop.Menu:Show()
    end)
end

function RocketFortuneWinPop:OnDestroy()
    
end