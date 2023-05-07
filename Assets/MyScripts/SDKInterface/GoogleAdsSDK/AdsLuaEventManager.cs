using System;

[XLua.LuaCallCSharp]
public class AdsTypeUnitName
{
    public const string AppOpenAds = "AppOpenAds";
    public const string BannerAds = "BannerAds";
    public const string InterstitialAds = "InterstitialAds";
    public const string RewardedAds = "RewardedAds";
    public const string RewardedInterstitialAds = "RewardedInterstitialAds";
}

[XLua.LuaCallCSharp]
public class AdsLuaEventManager : Singleton<AdsLuaEventManager>
{
    private Action<string> mLuaOnReceivedRewardEvent;
    private Action<string> mLuaOnAdLoadedEvent;

    public void Init()
    {
        AdsMainThreadEventManager.Instance.AddListener("MainThread_HandleUserEarnedReward", this);
        AdsMainThreadEventManager.Instance.AddListener("MainThread_HandleOnAdLoaded", this);
    }

    public void SetLuaOnReceivedRewardEvent(Action<string> mEvent)
    {
        mLuaOnReceivedRewardEvent = mEvent;
    }

    public void SetLuaOnAdLoadedEvent(Action<string> mEvent)
    {
        mLuaOnAdLoadedEvent = mEvent;
    }

    private void MainThread_HandleUserEarnedReward(object o)
    {
        //开屏广告有可能还没有Lua事件绑定
        if (mLuaOnReceivedRewardEvent != null)
        {
            mLuaOnReceivedRewardEvent((string)o);
        }
    }

    private void MainThread_HandleOnAdLoaded(object o)
    {
        //开屏广告有可能还没有Lua事件绑定
        if (mLuaOnAdLoadedEvent != null)
        {
            mLuaOnAdLoadedEvent((string)o);
        }
    }

}