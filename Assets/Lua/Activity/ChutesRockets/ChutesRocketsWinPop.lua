

ChutesRocketsWinPop = {}
ChutesRocketsWinPop.m_btnCollect = nil
ChutesRocketsWinPop.m_rewardText = nil

function ChutesRocketsWinPop:Show(parentTransform)
    if self.transform == nil then
        local strPath = "Assets/ActiveNeedLoad/ChutesRockets/ChutesRocketsWinPop.prefab"
        self.transform.gameObject = Unity.Object.Instantiate(Util.getChutesRocketsPrefab(strPath))
        self.transform = self.transform.gameObject.transform
        self.popController = PopController:new(self.transform.gameObject)
        LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)

        local collectButton = self.transform:FindDeepChild("CollectBtn"):GetComponent(typeof(UnityUI.Button))
        collectButton.onClick:AddListener(function()
            self:onCollectBtnClicked()
        end)
        DelegateCache:addOnClickButton(collectButton)
        self.m_btnCollect = collectButton
    end

    self.m_btnCollect.interactable = true
    self:initContent()

    parentTransform = parentTransform or LobbyScene.popCanvas
    self.transform:SetParent(parentTransform, false)
    ViewScaleAni:Show(self.transform.gameObject)
end

function ChutesRocketsWinPop:initContent()
    -- 初始化奖励额度
    self.m_rewardText = self.transform:FindDeepChild("Reward"):GetComponent(typeof(UnityUI.Text))
    self.m_rewardText.text = MoneyFormatHelper.numWithCommas(ChutesRocketsLevelManager.nRewardCoins).." COINS"
end

function ChutesRocketsWinPop:onCollectBtnClicked()
    self.m_btnCollect.interactable = false
    -- 奖励早已经加给玩家了 这里仅仅做动画展示...
    local ftime = 2.5
    local coinPos = self.m_rewardText.transform.position
    CoinFly:fly(coinPos, GlobalTempData.goUITopCollectMoneyEndPos.transform.position, 12)

    LeanTween.delayedCall(ftime, function()
        --动画做完后，显示选择关卡页面
        self.popController:hide(true)
        ChutesRocketsMainUIPop.popController:hide(true)
        ChutesRocketsChoiceLevelPop:Show()
    end)
end

function ChutesRocketsWinPop:OnDestroy()
    
end