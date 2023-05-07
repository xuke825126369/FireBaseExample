BuildGameGiftBoxPop = {}

BuildGameGiftBoxPop.m_gameObject = nil
BuildGameGiftBoxPop.m_transform = nil
BuildGameGiftBoxPop.m_btnCollect = nil

function BuildGameGiftBoxPop:createAndShow(addCoins, param)
    if not self.m_gameObject then
        local goPrefab = Util.getBuildGamePrefab("Assets/BuildYourCity/GiftBoxPop.prefab")
        self.m_gameObject = Unity.Object.Instantiate(goPrefab)
        self.m_transform = self.m_gameObject.transform
        self.m_transform:SetParent(LobbyScene.popCanvas, false)
        self.m_trContent = self.m_transform:FindDeepChild("RewardContainer")
        self.popController = PopController:new(self.m_gameObject)
        self.m_btnCollect = self.m_transform:FindDeepChild("BtnCollect"):GetComponent(typeof(UnityUI.Button))
    end
    -- self.m_trContent
    self.m_btnCollect.onClick:RemoveAllListeners()
    self.m_btnCollect.onClick:AddListener(function()
        self:hide(param)
    end)
    self:refreshUI(addCoins, param)
    self.m_btnCollect.interactable = true
    ViewScaleAni:Show(self.transform.gameObject)
end

function BuildGameGiftBoxPop:refreshUI(addCoins, param)
    self.m_trContent:GetChild(0):FindDeepChild("Reward"):GetComponent(typeof(TextMeshProUGUI)).text = MoneyFormatHelper.numWithCommas(addCoins)
    local cardGo = self.m_trContent:GetChild(1).gameObject
    local userLevel = PlayerHandler.nLevel
    if userLevel < SlotsCardsManager.m_nUnlockLevel then
        cardGo:SetActive(false)
    else
        if param == nil then
            cardGo:SetActive(false)
        else
            cardGo:SetActive(true)
            cardGo.transform:FindDeepChild("Reward"):GetComponent(typeof(TextMeshProUGUI)).text = "+"..#param
        end
    end
    -- self.m_trContent:GetChild(1):FindDeepChild("Reward"):GetComponent(typeof(TextMeshProUGUI)).text = addCoins
end

function BuildGameGiftBoxPop:hide(param)
    AudioHandler:PlayBuildGameSound("click")
    self.m_btnCollect.interactable = false
    local ftime = 2.5
    local coinPos = self.m_trContent:GetChild(0):FindDeepChild("Reward").transform.position
    CoinFly:fly(coinPos, GlobalTempData.goUITopCollectMoneyEndPos.transform.position, 12)
    LeanTween.delayedCall(ftime, function()
        self.popController:hide(true,function()
            local userLevel = PlayerHandler.nLevel
            if userLevel >= SlotsCardsManager.m_nUnlockLevel and param ~= nil then
                for i=1,#param do
                    SlotsCardsGetPackPop:Show(param[i].packType, true, param[i].packCount)
                end
            end
        end)
    end)
end