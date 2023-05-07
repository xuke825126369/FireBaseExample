using System;
using System.Collections.Generic;
using System.Reflection;
using UnityEngine;

public class AdsEventName
{
    public const string MainThread_GoogleAdsSDK_AdsInterface_Init = "MainThread_GoogleAdsSDK_AdsInterface_Init";
    public const string MainThread_HandleOnAdLoaded = "MainThread_HandleOnAdLoaded";
    public const string MainThread_HandleUserEarnedReward = "MainThread_HandleUserEarnedReward";
}

public class AdsMainThreadEventManager : SingleTonMonoBehaviour<AdsMainThreadEventManager>
{
    private Queue<KeyValuePair<string, object>> mEventQueue;
    Dictionary<string, List<object>> mEventDic;

    public void Init()
    {
        mEventDic = new Dictionary<string, List<object>>();
        mEventQueue = new Queue<KeyValuePair<string, object>>();
    }

    public void AddListener(string funcName, object obj)
    {
        MethodInfo mMethodInfo = obj.GetType().GetMethod(funcName, BindingFlags.Static | BindingFlags.Instance | BindingFlags.NonPublic | BindingFlags.Public);
        if (mMethodInfo == null)
        {
            Debug.LogError(obj.GetType() + " 不存在方法: " + funcName);
        }

        lock (mEventDic)
        {
            List<object> mListT = null;
            if (!mEventDic.TryGetValue(funcName, out mListT))
            {
                mListT = new List<object>();
                mEventDic[funcName] = mListT;
            }
            mListT.Add(obj);
        }
    }

    public void Brocast(string funcName, object o = null)
    {
        lock (mEventQueue)
        {
            mEventQueue.Enqueue(new KeyValuePair<string, object>(funcName, o));
        }
    }

    private void MainThreadBrocast(string funcName, object param = null)
    {
        lock (mEventDic)
        {
            List<object> mListT = null;
            if (mEventDic.TryGetValue(funcName, out mListT))
            {
                foreach (var v in mListT)
                {
                    MethodInfo mMethodInfo = v.GetType().GetMethod(funcName, BindingFlags.Static | BindingFlags.Instance | BindingFlags.NonPublic | BindingFlags.Public);
                    if (mMethodInfo != null)
                    {
                        mMethodInfo.Invoke(v, new object[] { param });
                    }
                    else
                    {
                        Debug.LogError(v.GetType() + " 不存在方法: " + funcName);
                    }
                }
            }
        }
    }

    private void Update()
    {
        lock (mEventQueue)
        {
            while (mEventQueue.Count > 0)
            {
                KeyValuePair<string, object> mEvent = mEventQueue.Dequeue();
                MainThreadBrocast(mEvent.Key, mEvent.Value);
            }
        }
    }

    public void RemoveListener(string funcName, object o = null)
    {
        lock (mEventDic)
        {
            if (o == null)
            {
                mEventDic.Remove(funcName);
            }
            else
            {
                List<object> mListT = null;
                if (mEventDic.TryGetValue(funcName, out mListT))
                {
                    mListT.Remove(o);
                };
            }
        }
    }

    public void Clear()
    {
        lock (mEventDic)
        {
            mEventDic.Clear();
        }
    }
}
