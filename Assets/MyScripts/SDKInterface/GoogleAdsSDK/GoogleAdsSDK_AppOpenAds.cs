using System;
using GoogleMobileAds.Api;
using GoogleMobileAds.Common;
using UnityEngine;
using XLua;

//开屏广告是一种特殊的广告格式，适合希望通过应用加载屏幕变现的发布商。开屏广告在用户将您的应用切换为在前台运行时展示，[用户可随时关闭]。
public class GoogleAdsSDK_AppOpenAds : MonoBehaviour
{
    private bool bIsLoadingAds = false;
    private AppOpenAd mAppOpenAd = null;

    public void Init()
    {
        CreateAndLoadAd();
        AppStateEventNotifier.AppStateChanged += OnAppStateChanged;
    }

    private void OnAppStateChanged(AppState state)
    {
        UnityEngine.Debug.Log("App State is " + state);
        if (state == AppState.Foreground)
        {
            ShowAds();
        }
    }

    private string GetAdUnitId()
    {
        return GoogleAdsSDKConstConfig.AdsUnit_AppOpenAds;
    }

    private void CreateAndLoadAd()
    {
        mAppOpenAd = null;
        bIsLoadingAds = true;
        AdRequest request = new AdRequest.Builder().Build();
        AppOpenAd.Load(GetAdUnitId(), ScreenOrientation.AutoRotation, request, adLoadCallback);
    }

    private bool IsLoaded()
    {
        return mAppOpenAd != null && mAppOpenAd.CanShowAd();
    }

    private void ShowAds()
    {
        if (GameConfig.PLATFORM_EDITOR) return;

        if (IsLoaded())
        {
            mAppOpenAd.OnAdFullScreenContentFailed += HandleOnAdFullScreenContentFailed;
            mAppOpenAd.OnAdFullScreenContentClosed += HandleOnAdFullScreenContentClosed;
            mAppOpenAd.Show();
        }
        else
        {
            if (mAppOpenAd == null && bIsLoadingAds == false)
            {
                CreateAndLoadAd();
            }

            if (mAppOpenAd != null && !mAppOpenAd.CanShowAd())
            {
                CreateAndLoadAd();
            }
        }
    }

    private void adLoadCallback(AppOpenAd appOpenAd, LoadAdError error)
    {
        bIsLoadingAds = false;
        if (error != null)
        {
            Debug.LogError(string.Format("Failed to load the ad. (reason: {0})", error.GetMessage()));
            return;
        }

        mAppOpenAd = appOpenAd;
    }

    private void HandleOnAdFullScreenContentFailed(AdError error)
    {
        CreateAndLoadAd();
    }

    private void HandleOnAdFullScreenContentClosed()
    {
        CreateAndLoadAd();
    }
}

