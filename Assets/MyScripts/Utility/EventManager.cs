using System;
using System.Collections.Generic;
using UnityEngine;

public class EventManager<T>
{
    public Dictionary<string, Action<T>> mEventDic = new Dictionary<string, Action<T>>();
    
    public void AddListener(string eventId, Action<T> func)
    {
        if (orContainListenFunc(eventId, func))
        {
            return;
        }

        if (mEventDic.ContainsKey(eventId))
        {
            mEventDic[eventId] += func;
        }
        else
        {
            mEventDic[eventId] = func;
        }
    }

    private bool orContainListenFunc(string eventId, Action<T> func)
    {
        if (mEventDic.ContainsKey(eventId))
        {
            return DelegateUtility.CheckFunIsExist<T>(mEventDic[eventId], func);
        }

        return false;
    }

    public void Brocast(string eventId, T o)
    {
        if (mEventDic.ContainsKey(eventId))
        {
            mEventDic[eventId](o);
        }
        else
        {
            Debug.LogWarning("EventManager Warning:  Brocast is Empty: " + eventId);
        }
    }

    public void RemoveListener(string eventId, Action<T> func = null)
    {
        if (func == null)
        {
            mEventDic.Remove(eventId);
        }
        else
        {
            if (mEventDic.ContainsKey(eventId))
            {
                mEventDic[eventId] -= func;
            }
        }
    }

    public void Clear()
    {
        mEventDic.Clear();
    }
}

public class EventManager
{
    EventManager<object> mEventManager;

    public EventManager()
    {
        mEventManager = new EventManager<object>();
    }

    public void AddListener(string eventId, Action<object> func)
    {
        mEventManager.AddListener(eventId, func);
    }

    public void Brocast(string eventId, object o = null)
    {
        mEventManager.Brocast(eventId, o);
    }

    public void RemoveListener(string eventId, Action<object> func = null)
    {
        mEventManager.RemoveListener(eventId, func);
    }

    public void Clear()
    {
        mEventManager.Clear();
    }
}

public class MainThreadEventManager:MonoBehaviour
{
    private Queue<KeyValuePair<string, object>> mEventQueue;
    EventManager<object> mEventManager;

    public MainThreadEventManager()
    {
        mEventManager = new EventManager<object>();
        mEventQueue = new Queue<KeyValuePair<string, object>>();
    }

    public void AddListener(string eventId, Action<object> func)
    {
        lock (mEventManager)
        {
            mEventManager.AddListener(eventId, func);
        }
    }

    public void Brocast(string eventId, object o = null)
    {
        lock(mEventQueue)
        {
            mEventQueue.Enqueue(new KeyValuePair<string, object>(eventId, o));
        }
    }

    private void Update()
    {
        lock (mEventQueue)
        {
            while (mEventQueue.Count > 0)
            {
                KeyValuePair<string, object> mEvent = mEventQueue.Dequeue();
                mEventManager.Brocast(mEvent.Key, mEvent.Value);
            }
        }
    }

    public void RemoveListener(string eventId, Action<object> func = null)
    {
        lock (mEventManager)
        {
            mEventManager.RemoveListener(eventId, func);
        }
    }

    public void Clear()
    {
        lock (mEventManager)
        {
            mEventManager.Clear();
        }
    }
}

public class GlobalEventManager : Singleton<GlobalEventManager>
{
    EventManager mEventManager;

    public GlobalEventManager()
    {
        mEventManager = new EventManager();
    }

    public void AddListener(string eventId, Action<object> func)
    {
        mEventManager.AddListener(eventId, func);
    }

    public void Brocast(string eventId, object o = null)
    {
        mEventManager.Brocast(eventId, o);
    }

    public void RemoveListener(string eventId, Action<object> func = null)
    {
        mEventManager.RemoveListener(eventId, func);
    }

    public void Clear()
    {
        mEventManager.Clear();
    }
}
