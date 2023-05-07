using System;
using GoogleMobileAds.Api;
using GoogleMobileAds.Common;
using UnityEngine;
using XLua;

public class GoogleAdsSDK_BannerAds : MonoBehaviour
{
    private BannerView mBannerView;
    private bool isLoad = false;

    private AdSize mAdSize = AdSize.Banner;
    private AdPosition mAdPosition = AdPosition.Bottom;
    public void Init(AdSize mAdSize, AdPosition mAdPosition)
    {
        this.mAdSize = mAdSize;
        this.mAdPosition = mAdPosition;
        CreateAndLoadAd();
    }

    private void OnDestroy()
    {
        if (mBannerView != null)
        {
            mBannerView.Destroy();
        }
    }

    private string GetAdUnitId()
    {
        return GoogleAdsSDKConstConfig.AdsUnit_BannerAds;
    }

    private void CreateAndLoadAd()
    {
        mBannerView = new BannerView(GetAdUnitId(), mAdSize, mAdPosition);
        mBannerView.OnBannerAdLoaded += this.HandleOnAdLoaded;
        AdRequest request = new AdRequest.Builder().Build();
        mBannerView.LoadAd(request);
        mBannerView.Hide();
    }

    public bool IsLoaded()
    {
        return isLoad;
    }

    public Vector2 GetBannerViewSize()
    {
        return new Vector2(mBannerView.GetWidthInPixels(), mBannerView.GetHeightInPixels());
    }

    public void ShowAds()
    {
        mBannerView.Show();
    }

    public void HideAds()
    {
        mBannerView.Hide();
    }

    private void HandleOnAdLoaded()
    {
        isLoad = true;
        AdsMainThreadEventManager.Instance.Brocast("MainThread_HandleOnAdLoaded", AdsTypeUnitName.BannerAds);
    }
}

