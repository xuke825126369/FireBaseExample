using System.Collections.Generic;
using UnityEngine;
using Firebase.Analytics;

[XLua.LuaCallCSharp]
public static class FireBaseEvent
{
    public static void SendCustomEvent(string strEventName, Dictionary<string, object> paramDic1)
    {
        if(GameConfig.Instance.orTestUser())
        {
            string eventDes = "------------FireBaseEvent[ " + strEventName + " ]: ";
            eventDes += "eventParams: \n";
            foreach (var v in paramDic1)
            {
                eventDes += v.Key + " : " + v.Value.ToString() + "\n";
            }
            Debug.Log(eventDes + "\n");
        }

        List<Parameter> paraArray = new List<Parameter>();
        foreach (var v in paramDic1)
        {
            paraArray.Add(new Parameter(v.Key, v.Value.ToString()));
        }
        FirebaseAnalytics.LogEvent(strEventName, paraArray.ToArray());
    }

    public static void SendBuyEvent(string productId, double fDollar)
    {
        List<Parameter> paraArray = new List<Parameter>();
        paraArray.Add(new Parameter("productId", productId));
        paraArray.Add(new Parameter("fDollar", fDollar));
        FirebaseAnalytics.LogEvent(FirebaseAnalytics.EventPurchase, paraArray.ToArray());
    }

}
