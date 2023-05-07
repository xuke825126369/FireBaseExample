using System;
using System.Collections;
using System.Collections.Generic;
using GoogleMobileAds.Api;
using UnityEngine;

[XLua.LuaCallCSharp]
public class GoogleAdsSDK_InterstitialAds : MonoBehaviour
{
    private bool bIsLoadingAds = false;
    private InterstitialAd mInterstitialAd;
    public void Init()
    {
        CreateAndLoadAd();
    }

    private string GetAdUnitId()
    {
        return GoogleAdsSDKConstConfig.AdsUnit_InterstitialAds;
    }

    private void CreateAndLoadAd()
    {
        bIsLoadingAds = true;
        mInterstitialAd = null;
        string adUnitId = GetAdUnitId();
        AdRequest request = new AdRequest.Builder().Build();
        InterstitialAd.Load(adUnitId, request, HandleOnAdLoad);
    }

    public bool IsLoaded()
    {
        return mInterstitialAd != null && this.mInterstitialAd.CanShowAd();
    }

    public void ShowAds()
    {
        if (IsLoaded())
        {
            mInterstitialAd.OnAdFullScreenContentFailed += HandleOnAdFailedToShow;
            mInterstitialAd.OnAdFullScreenContentClosed += HandleOnAdClosed;
            this.mInterstitialAd.Show();
            Debug.Log("谷歌广告 Interstitial Show");
        }
        else
        {
            if (mInterstitialAd == null && bIsLoadingAds == false)
            {
                CreateAndLoadAd();
            }

            if (mInterstitialAd != null && !mInterstitialAd.CanShowAd())
            {
                CreateAndLoadAd();
            }
        }
    }

    private void HandleOnAdLoad(InterstitialAd ads, LoadAdError error)
    {
        bIsLoadingAds = false;
        if (error != null)
        {
            Debug.LogError(string.Format("Failed to load the ad. (reason: {0})", error.GetMessage()));
            return;
        }

        mInterstitialAd = ads;
    }

    private void HandleOnAdFailedToShow(AdError args)
    {
        CreateAndLoadAd();
    }

    private void HandleOnAdClosed()
    {
        CreateAndLoadAd();
    }

}
