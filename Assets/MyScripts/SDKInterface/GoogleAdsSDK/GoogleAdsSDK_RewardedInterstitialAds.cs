using System;
using GoogleMobileAds.Api;
using UnityEngine;
using XLua;

public class GoogleAdsSDK_RewardedInterstitialAds : MonoBehaviour
{
    private bool bIsLoadingAds = false;
    private RewardedInterstitialAd mRewardedInterstitialAd;
    private string GetAdUnitId()
    {
        return GoogleAdsSDKConstConfig.AdsUnit_InterstitialRewardedAds;
    }

    public void Init()
    {
        CreateAndLoadAd();
    }

    private bool IsLoaded()
    {
        return mRewardedInterstitialAd != null && mRewardedInterstitialAd.CanShowAd();
    }

    public void ShowAds()
    {
        if (IsLoaded())
        {
            mRewardedInterstitialAd.OnAdFullScreenContentFailed += HandleOnAdFullScreenContentFailed;
            mRewardedInterstitialAd.OnAdFullScreenContentClosed += HandleOnAdFullScreenContentClosed;
            mRewardedInterstitialAd.Show(HandleUserEarnedReward);
            Debug.Log("谷歌广告 RewardedInterstitialAds Show");
        }
        else
        {
            if (mRewardedInterstitialAd == null && bIsLoadingAds == false)
            {
                CreateAndLoadAd();
            }

            if (mRewardedInterstitialAd != null && !mRewardedInterstitialAd.CanShowAd())
            {
                CreateAndLoadAd();
            }
        }
    }

    private void CreateAndLoadAd(object o = null)
    {
        mRewardedInterstitialAd = null;
        bIsLoadingAds = true;
        AdRequest request = new AdRequest.Builder().Build();
        RewardedInterstitialAd.Load(GetAdUnitId(), request, adLoadCallback);
    }

    private void adLoadCallback(RewardedInterstitialAd ad, LoadAdError error)
    {
        bIsLoadingAds = false;
        if (error != null)
        {
            Debug.LogError(string.Format("Failed to load the ad. (reason: {0})", error.GetMessage()));
            return;
        }

        mRewardedInterstitialAd = ad;
    }

    private void HandleOnAdFullScreenContentFailed(AdError args)
    {
        CreateAndLoadAd();
    }

    private void HandleOnAdFullScreenContentClosed()
    {
        CreateAndLoadAd();
    }

    private void HandleUserEarnedReward(Reward args)
    {
        AdsMainThreadEventManager.Instance.Brocast("MainThread_HandleUserEarnedReward", AdsTypeUnitName.RewardedInterstitialAds);
    }
}

