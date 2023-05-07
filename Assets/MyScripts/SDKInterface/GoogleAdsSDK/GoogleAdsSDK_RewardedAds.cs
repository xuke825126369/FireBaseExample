using System;
using GoogleMobileAds.Api;
using UnityEngine;
using XLua;

[XLua.LuaCallCSharp]
public class GoogleAdsSDK_RewardedAds : MonoBehaviour
{
    private bool bIsLoadingAds = false;
    private RewardedAd mRewardedAd;
    public void Init()
    {
        CreateAndLoadAd();
    }

    private string GetAdUnitId()
    {
        return GoogleAdsSDKConstConfig.AdsUnit_RewardedAds;
    }

    private void CreateAndLoadAd()
    {
        bIsLoadingAds = true;
        mRewardedAd = null;
        string adUnitId = GetAdUnitId();
        AdRequest request = new AdRequest.Builder().Build();
        RewardedAd.Load(adUnitId, request, HandleOnAdLoaded);
    }

    public bool IsLoaded()
    {
        return mRewardedAd != null && mRewardedAd.CanShowAd();
    }

    public void ShowAds()
    {
        if (IsLoaded())
        {
            mRewardedAd.OnAdFullScreenContentClosed += HandleOnAdFullScreenContentClosed;
            mRewardedAd.OnAdFullScreenContentFailed += HandleOnAdFullScreenContentFailed;
            mRewardedAd.Show(HandleUserEarnedReward);
            Debug.Log("谷歌广告 rewarded Show");
        }
        else
        {
            if (mRewardedAd == null && bIsLoadingAds == false)
            {
                CreateAndLoadAd();
            }

            if (mRewardedAd != null && !mRewardedAd.CanShowAd())
            {
                CreateAndLoadAd();
            }
        }
    }

    private void HandleOnAdLoaded(RewardedAd ads, LoadAdError error)
    {
        bIsLoadingAds = false;
        if (error != null)
        {
            Debug.LogError(string.Format("Failed to load the ad. (reason: {0})", error.GetMessage()));
            return;
        }

        mRewardedAd = ads;
    }

    private void HandleOnAdFullScreenContentFailed(AdError args)
    {
        this.CreateAndLoadAd();
    }

    private void HandleOnAdFullScreenContentClosed()
    {
        this.CreateAndLoadAd();
    }

    private void HandleUserEarnedReward(Reward args)
    {
        AdsMainThreadEventManager.Instance.Brocast("MainThread_HandleUserEarnedReward", AdsTypeUnitName.RewardedAds);
    }

}
