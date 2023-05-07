using UnityEngine;
using System.Collections;
using UnityEngine.EventSystems;
using UnityEngine.UI;
using System;
using UnityEngine.Events;

[XLua.LuaCallCSharp]
public class EventTriggerListener : EventTrigger
{
    public static EventTriggerListener Get(GameObject go)
    {
        EventTriggerListener listener = go.GetComponent<EventTriggerListener>();
        if (listener == null) listener = go.AddComponent<EventTriggerListener>();
        return listener;
    }

    public void AddListener(EventTriggerType nType, UnityAction<BaseEventData> func)
    {
        EventTrigger.Entry mEntry1 = base.triggers.Find((EventTrigger.Entry mEntry) =>
       {
           return mEntry.eventID == nType;
       });

        if (mEntry1 != null)
        {
            mEntry1.callback.AddListener(func);
        }
        else
        {
            mEntry1 = new EventTrigger.Entry();
            mEntry1.eventID = nType;
            mEntry1.callback.AddListener(func);

            base.triggers.Add(mEntry1);
        }
    }

    public void RemoveListener(EventTriggerType nType, UnityAction<BaseEventData> func)
    {
        EventTrigger.Entry mEntry1 = base.triggers.Find((EventTrigger.Entry mEntry) =>
        {
            return mEntry.eventID == nType;
        });

        if (mEntry1 != null)
        {
            mEntry1.callback.RemoveListener(func);
        }
    }

    public void RemoveAllListener()
    {
        base.triggers.Clear();
    }

    public void TestAllEvent(UnityAction<BaseEventData> func = null)
    {
        for (int i = 0; i <= Enum.GetValues(typeof(EventTriggerType)).Length - 1; i++)
        {
            EventTriggerType type = (EventTriggerType)i;
            AddListener(type, (BaseEventData x) =>
            {
                Debug.Log(type.ToString());
            });

            if(func != null)
            {
                AddListener(type, func);
            }
        }
    }
}
