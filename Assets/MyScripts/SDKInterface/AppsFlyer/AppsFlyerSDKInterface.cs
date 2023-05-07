using System.Collections.Generic;
using AppsFlyerSDK;

[XLua.LuaCallCSharp]
public class AppsFlyerSDKInterface : SingleTonMonoBehaviour<AppsFlyerSDKInterface>, IAppsFlyerConversionData
{
    const string devKey = "rZgpcZcPZwLZxUYuJDD6bj";

#if UNITY_IOS
    const string appID = "";
#else
    const string appID = "";
#endif

    public void Init()
    {
        
    }

    private void Start()
    { 
        AppsFlyer.setIsDebug(false);
        AppsFlyer.initSDK(devKey, appID, this);
        AppsFlyer.startSDK();

        AppPurchaseAFValidation.Instance.Init();
    }

    public void onConversionDataSuccess(string conversionData)
    {
        AppsFlyer.AFLog("onConversionDataSuccess", conversionData);
        Dictionary<string, object> conversionDataDictionary = AppsFlyer.CallbackStringToDictionary(conversionData);
        // add deferred deeplink logic here
    }

    public void onConversionDataFail(string error)
    {
        AppsFlyer.AFLog("onConversionDataFail", error);
    }

    public void onAppOpenAttribution(string attributionData)
    {
        AppsFlyer.AFLog("onAppOpenAttribution", attributionData);
        Dictionary<string, object> attributionDataDictionary = AppsFlyer.CallbackStringToDictionary(attributionData);
        // add direct deeplink logic here
    }

    public void onAppOpenAttributionFailure(string error)
    {
        AppsFlyer.AFLog("onAppOpenAttributionFailure", error);
    }
}