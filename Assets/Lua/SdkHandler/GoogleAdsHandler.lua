GoogleAdsHandler = {}

function GoogleAdsHandler:Init()
    CS.AdsLuaEventManager.Instance:SetLuaOnAdLoadedEvent(function(adsTypeName)
        self:HandleAdsLoadEvent(adsTypeName)
    end)

    CS.AdsLuaEventManager.Instance:SetLuaOnReceivedRewardEvent(function(adsTypeName)
        self:HandleReceivedRewardEvent(adsTypeName)
    end)
end

function GoogleAdsHandler:Show_BannerAds()
    local mBannerBottomAds = CS.GoogleAdsSDK_AdsInterface.Instance:GetBannerAds()

    local bTrigger = AdsConfigHandler:orTriggerBannerAds()
    if mBannerBottomAds then
        mBannerBottomAds:HideAds()
        if mBannerBottomAds:IsLoaded() and bTrigger then
            mBannerBottomAds:ShowAds()
        end
    end
    
    if bTrigger then
        if mBannerBottomAds and mBannerBottomAds:IsLoaded() then
            local value1 = mBannerBottomAds:GetBannerViewSize().y / Unity.Screen.height
            Unity.Camera.main.rect = Unity.Rect(0, value1, 1, 1 - value1)
        else
            Unity.Camera.main.rect = Unity.Rect(0, 0, 1, 1)
        end
    else
        Unity.Camera.main.rect = Unity.Rect(0, 0, 1, 1)
    end

end

function GoogleAdsHandler:Show_InterstitialAds()
    if math.random() < 0.5 then
        local adsMannager = CS.GoogleAdsSDK_AdsInterface.Instance:GetInterstitialAds()
        if adsMannager then
            adsMannager:ShowAds()
        end
    else
        local adsMannager = CS.GoogleAdsSDK_AdsInterface.Instance:GetRewardedInterstitialAds()
        if adsMannager then
            adsMannager:ShowAds()
        end
    end
end

function GoogleAdsHandler:RewardedAds_IsLoadFinish()
    local adsMannager = CS.GoogleAdsSDK_AdsInterface.Instance:GetRewardAds()
    if adsMannager then
        return adsMannager:IsLoaded()
    end
end

function GoogleAdsHandler:Show_RewardAds()
    local adsMannager = CS.GoogleAdsSDK_AdsInterface.Instance:GetRewardAds()
    if adsMannager then
        adsMannager:ShowAds()
    end
end

function GoogleAdsHandler:HandleAdsLoadEvent(adsTypeName)
    if CS.GlobalVariable.bMainSceneInitFinish == false then
        return
    end
    
    Debug.Log("GoogleAdsHandler:HandleAdsLoadEvent(adsTypeName): "..adsTypeName)
    if adsTypeName == CS.AdsTypeUnitName.BannerAds then
        GoogleAdsHandler:Show_BannerAds()
    end
end

function GoogleAdsHandler:HandleReceivedRewardEvent(adsTypeName)
    if CS.GlobalVariable.bMainSceneInitFinish == false then
        return
    end

    local nMoneyCount = AdsConfigHandler:GetAdsAwardMoneyCount()
    PlayerHandler:AddCoin(nMoneyCount)
    AppLocalEventHandler:OnWatchRewardAdsFinishEvt()
    
    Debug.Log("GoogleAdsHandler:HandleReceivedRewardEvent(adsTypeName): "..adsTypeName)
    if adsTypeName == CS.AdsTypeUnitName.RewardedAds then
        EventHandler:Brocast("OnRewardedAdReceivedRewardEvent")
    else
        CoinFly:fly(Unity.Vector3.zero, GlobalTempData.goUITopCollectMoneyEndPos.transform.position, 10)
    end
end

