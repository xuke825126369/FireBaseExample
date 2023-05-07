using System.Collections;
using System.Collections.Generic;
using GoogleMobileAds.Api;
using UnityEngine;

[XLua.LuaCallCSharp]
public class GoogleAdsSDK_AdsInterface : SingleTonMonoBehaviour<GoogleAdsSDK_AdsInterface>
{
    private GoogleAdsSDK_InterstitialAds mInterstitialAds = null;
    private GoogleAdsSDK_RewardedAds mRewardedAds = null;
    private GoogleAdsSDK_RewardedInterstitialAds mRewardedInterstitialAds = null;
    private GoogleAdsSDK_AppOpenAds mAppOpenAds = null;
    private GoogleAdsSDK_BannerAds mBannerAds = null;

    private InitializationStatus mInitializationStatus;
    public void Init()
    {
        AdsMainThreadEventManager.Instance.Init();
        AdsLuaEventManager.Instance.Init();
        AdsMainThreadEventManager.Instance.AddListener("MainThread_GoogleAdsSDK_AdsInterface_Init", this);

        var mBuilder = new RequestConfiguration.Builder();
        mBuilder.SetSameAppKeyEnabled(true);
        RequestConfiguration requestConfiguration = mBuilder.build();
        MobileAds.SetRequestConfiguration(requestConfiguration);
        MobileAds.Initialize(HandleInitCompleteAction);

        string adId = AdsHelper.GetAdvertisingID();
        string deviceId = SystemInfo.deviceUniqueIdentifier;
        DebugUtility.LogWithColor("adId: " + adId + " | " + deviceId);
    }

    private void HandleInitCompleteAction(InitializationStatus obj)
    {
        AdsMainThreadEventManager.Instance.Brocast("MainThread_GoogleAdsSDK_AdsInterface_Init", obj);
    }

    private void MainThread_GoogleAdsSDK_AdsInterface_Init(object o = null)
    {
        mInitializationStatus = o as InitializationStatus;

        mAppOpenAds = gameObject.AddComponent<GoogleAdsSDK_AppOpenAds>();
        mRewardedAds = gameObject.AddComponent<GoogleAdsSDK_RewardedAds>();
        mRewardedInterstitialAds = gameObject.AddComponent<GoogleAdsSDK_RewardedInterstitialAds>();
        mInterstitialAds = gameObject.AddComponent<GoogleAdsSDK_InterstitialAds>();

        mAppOpenAds.Init();
        mRewardedAds.Init();
        mRewardedInterstitialAds.Init();
        mInterstitialAds.Init();

        mBannerAds = gameObject.AddComponent<GoogleAdsSDK_BannerAds>();
        mBannerAds.Init(AdSize.GetLandscapeAnchoredAdaptiveBannerAdSizeWithWidth(AdSize.FullWidth), AdPosition.Bottom);
    }

    public bool orGoogleAdsSDKInitFinish()
    {
        return mInitializationStatus != null;
    }

    public GoogleAdsSDK_InterstitialAds GetInterstitialAds()
    {
        return mInterstitialAds;
    }

    public GoogleAdsSDK_RewardedAds GetRewardAds()
    {
        return mRewardedAds;
    }

    public GoogleAdsSDK_RewardedInterstitialAds GetRewardedInterstitialAds()
    {
        return mRewardedInterstitialAds;
    }

    public GoogleAdsSDK_AppOpenAds GetAppOpenAds()
    {
        return mAppOpenAds;
    }

    public GoogleAdsSDK_BannerAds GetBannerAds()
    {
        return mBannerAds;
    }
}
