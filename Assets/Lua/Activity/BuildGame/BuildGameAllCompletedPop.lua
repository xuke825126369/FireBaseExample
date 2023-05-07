BuildGameAllCompletedPop = {}

BuildGameAllCompletedPop.m_gameObject = nil
BuildGameAllCompletedPop.m_transform = nil

function BuildGameAllCompletedPop:createAndShow(reward)
    if not self.m_gameObject then
        local goPrefab = Util.getBuildGamePrefab("Assets/BuildYourCity/BuildGameAllCompletedPop.prefab")
        self.m_gameObject = Unity.Object.Instantiate(goPrefab)
        self.m_transform = self.m_gameObject.transform
        self.m_transform:SetParent(LobbyScene.popCanvas, false)
        self.popController = PopController:new(self.m_gameObject)
        
        self.rewardText = self.m_transform:FindDeepChild("RewardText"):GetComponent(typeof(TextMeshProUGUI))
        self.btnClose = self.m_transform:FindDeepChild("BtnClose"):GetComponent(typeof(UnityUI.Button))
        self.btnClose.onClick:AddListener(function()
            self:hide(reward)
        end)

        self.btnClaim = self.m_transform:FindDeepChild("BtnClaim"):GetComponent(typeof(UnityUI.Button))
        self.btnClaim.onClick:AddListener(function()
            self:hide(reward)
        end)
    end
    self.rewardText.text = "$"..MoneyFormatHelper.numWithCommas(reward)
    self.btnClaim.interactable = true
    self.btnClose.interactable = true
    ViewScaleAni:Show(self.transform.gameObject)
    AudioHandler:PlayBuildGameSound("all_city_full_level")
end

function BuildGameAllCompletedPop:hide(reward)
    self.btnClaim.interactable = false
    self.btnClose.interactable = false
    PlayerHandler:AddCoin(reward)
    BuildGameDataHandler.m_data[BuildGameDataHandler.m_curSeason].m_bIsGetCompletedGift = true
    BuildGameDataHandler:writeFile()
    AudioHandler:PlayBuildGameSound("click")
    CoinFly:fly(self.btnClaim.transform.position, GlobalTempData.goUITopCollectMoneyEndPos.transform.position, 12)
    LeanTween.delayedCall(2.5, function()
        self.popController:hide(false, function()
            BuildGameRestarPop:createAndShow()
        end)
    end)
end