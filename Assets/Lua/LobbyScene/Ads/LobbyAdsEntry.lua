LobbyAdsEntry = {}

function LobbyAdsEntry:Init()
    if LuaHelper.OrGameObjectExist(self.transform) then
        return
    end

    self.transform = LobbyView.transform:FindDeepChild("RewardContainer")
    LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
    self.transform.gameObject:SetActive(true)

    self.onClickBtn = self.transform:FindDeepChild("RewardVideoButton"):GetComponent(typeof(UnityUI.Button))
    self.onClickBtn.onClick:AddListener(function()
        GlobalAudioHandler:PlayBtnSound()
        if GoogleAdsHandler:RewardedAds_IsLoadFinish() then
            EventHandler:RemoveListener("OnRewardedAdReceivedRewardEvent")
            EventHandler:AddListener("OnRewardedAdReceivedRewardEvent", self)
            GoogleAdsHandler:Show_RewardAds()
        else
            TipPoolView:Show("Oops, wait a minute")
        end
    end)
    self.onClickBtn.gameObject:SetActive(true)
    
    self.goAni = self.transform:FindDeepChild("AdsAni").gameObject
end

function LobbyAdsEntry:Show()
    self:Init()
    local bIsLoadFinish = GoogleAdsHandler:RewardedAds_IsLoadFinish()
    self.transform.gameObject:SetActive(bIsLoadFinish)
    if bIsLoadFinish then
        self:DoAni()
    else
        self:CancelAni()
    end
end

function LobbyAdsEntry:Hide()
    self.transform.gameObject:SetActive(false)
    self:CancelAni()
    EventHandler:RemoveListener("OnRewardedAdReceivedRewardEvent", self)
end

function LobbyAdsEntry:OnRewardedAdReceivedRewardEvent()
    self:Hide()
	CoinFly:fly(self.transform.position, GlobalTempData.goUITopCollectMoneyEndPos.transform.position, 10)
end

function LobbyAdsEntry:DoAni()
    if self.tableLtd ~= nil then
        return
    end

    self.tableLtd = {}
    local ltd = LeanTween.scale(self.goAni, Unity.Vector3.one * 0.6, 0.3):setLoopPingPong(-1):setDelay(math.random() * 0.5).id
    table.insert(self.tableLtd, ltd)
    local ltd = LeanTween.scale(self.transform.gameObject, Unity.Vector3.one * 1.1, 0.3):setLoopPingPong(-1).id
    table.insert(self.tableLtd, ltd)
end

function LobbyAdsEntry:CancelAni()
    if self.tableLtd ~= nil then
        LuaHelper.CancelLeanTween(self.tableLtd)
        self.tableLtd = nil
    end
end

