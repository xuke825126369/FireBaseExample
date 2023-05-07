ThemeAdsEntry = {}

function ThemeAdsEntry:Init()
    if LuaHelper.OrGameObjectExist(self.transform) then
        return
    end 

    self.transform = UITop.m_transform:FindDeepChild("RewardContainer")
    LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
    self.transform.gameObject:SetActive(true)

    self.onClickBtn = self.transform:FindDeepChild("RewardVideoButton"):GetComponent(typeof(UnityUI.Button))
    self.onClickBtn.onClick:AddListener(function()
        GlobalAudioHandler:PlayBtnSound()
        if GoogleAdsHandler:RewardedAds_IsLoadFinish() then
            EventHandler:RemoveListener("OnRewardedAdReceivedRewardEvent", self)
            EventHandler:AddListener("OnRewardedAdReceivedRewardEvent", self)
            GoogleAdsHandler:Show_RewardAds()
        else
            self:Hide()
        end
    end)    

    self.goAni = self.transform:FindDeepChild("AdsAni").gameObject
end

function ThemeAdsEntry:Show()
    self:Init()
    self:RefreshState()
end

function ThemeAdsEntry:Hide()
    self:Init()
    self:CancelAni()
    EventHandler:RemoveListener("OnRewardedAdReceivedRewardEvent", self)
end

function ThemeAdsEntry:RefreshState()
    local bIsLoadFinish = GoogleAdsHandler:RewardedAds_IsLoadFinish()
    self.transform.gameObject:SetActive(bIsLoadFinish)
    if bIsLoadFinish then
        self:DoAni()
    else
        self:CancelAni()
    end
end

function ThemeAdsEntry:DoAni()
    if self.tableLtd ~= nil then
        return
    end

    self.tableLtd = {}
    local ltd = LeanTween.scale(self.goAni, Unity.Vector3.one * 0.6, 0.3):setLoopPingPong(-1):setDelay(math.random() * 0.5).id
    table.insert(self.tableLtd, ltd)
    local ltd = LeanTween.scale(self.transform.gameObject, Unity.Vector3.one * 1.1, 0.3):setLoopPingPong(-1).id
    table.insert(self.tableLtd, ltd)
end

function ThemeAdsEntry:CancelAni()
    self.transform.gameObject:SetActive(false)
    if self.tableLtd ~= nil then
        LuaHelper.CancelLeanTween(self.tableLtd)
        self.tableLtd = nil
    end
end

function ThemeAdsEntry:OnRewardedAdReceivedRewardEvent()
    self:Hide()
	CoinFly:fly(self.transform.position, GlobalTempData.goUITopCollectMoneyEndPos.transform.position, 10)
end

function ThemeAdsEntry:OnDestroy()
    self:CancelAni()
    EventHandler:RemoveListener("OnRewardedAdReceivedRewardEvent", self)
end

