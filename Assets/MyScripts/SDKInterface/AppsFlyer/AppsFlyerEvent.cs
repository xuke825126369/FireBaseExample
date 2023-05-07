using System.Collections.Generic;
using AppsFlyerSDK;
using UnityEngine;

[XLua.LuaCallCSharp]
public static class AppsFlyerEvent 
{
    public static void SendCustomEvent(string strEventName, Dictionary<string, object> paramDic1)
    {
        if (GameConfig.Instance.orTestUser())
        {
            string eventDes = "------------AppsFlyerEvent[ " + strEventName + " ]: ";
            eventDes += "eventParams: \n";
            foreach (var v in paramDic1)
            {
                eventDes += v.Key + " : " + v.Value.ToString() + "\n";
            }
            Debug.Log(eventDes + "\n");
        }

        Dictionary<string, string> paramDic = new Dictionary<string, string>();
        foreach (var v in paramDic1)
        {
            paramDic.Add(v.Key, v.Value.ToString());
        }
        AppsFlyer.sendEvent(strEventName, paramDic);
    }

    public static void SendBuyEvent(string productId, double fDollar)
    {
        Dictionary<string, string> purchaseEvent = new Dictionary<string, string>();
        purchaseEvent.Add(AFInAppEvents.REVENUE, fDollar.ToString());
        purchaseEvent.Add(AFInAppEvents.CONTENT_ID, productId);
        AppsFlyer.sendEvent(AFInAppEvents.PURCHASE, purchaseEvent);
    }

}
