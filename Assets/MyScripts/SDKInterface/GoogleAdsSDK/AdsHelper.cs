using System;
using UnityEngine;

public static class AdsHelper
{
    //该方法已验证，可以正常得到返回结果，用于获取当前设备的google play服务状态
    public static bool CheckGooglePlayServiceAvailable()
    {
        AndroidJavaClass jc = new AndroidJavaClass("com.unity3d.player.UnityPlayer");
        AndroidJavaObject jo = jc.GetStatic<AndroidJavaObject>("currentActivity");

        AndroidJavaClass jc2 = new AndroidJavaClass("com.google.android.gms.common.GoogleApiAvailability");
        AndroidJavaObject jo2 = jc2.CallStatic<AndroidJavaObject>("getInstance");

        int code = jo2.Call<int>("isGooglePlayServicesAvailable", jo);
        return code == 0;

        // result codes from https://developers.google.com/android/reference/com/google/android/gms/common/ConnectionResult
        // 0 == success
        // 1 == service_missing
        // 2 == update service required
        // 3 == service disabled
        // 18 == service updating
        // 9 == service invalid
    }

    public static string GetAdvertisingID()
    {
        string _strAdvertisingID = "none";
#if UNITY_ANDROID && !UNITY_EDITOR
        try
        {
            using (AndroidJavaClass up = new AndroidJavaClass("com.unity3d.player.UnityPlayer"))
            {
                using (AndroidJavaObject currentActivity = up.GetStatic<AndroidJavaObject>("currentActivity"))
                {
                    using (AndroidJavaClass client = new AndroidJavaClass("com.google.android.gms.ads.identifier.AdvertisingIdClient"))
                    {
                        using (AndroidJavaObject adInfo = client.CallStatic<AndroidJavaObject>("getAdvertisingIdInfo", currentActivity))
                        {
                            if (adInfo != null)
                            {
                                _strAdvertisingID = adInfo.Call<string>("getId");
                                if (string.IsNullOrEmpty(_strAdvertisingID))
                                    _strAdvertisingID = "none";
                            }
                        }
                    }
                }
            }
        }
        catch (System.Exception e)
        {

        }
#endif

        return _strAdvertisingID;
    }
}

