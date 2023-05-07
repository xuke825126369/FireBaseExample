using System;
using System.Collections;
using System.Collections.Generic;
using Firebase.Database;
using Firebase.Extensions;
using UnityEngine;

[XLua.LuaCallCSharp]
public class FireBaseDb : SingleTonMonoBehaviour<FireBaseDb>
{
    FirebaseDatabase mFirebaseDatabase = null;
    DatabaseReference mDatabaseRootRef = null;
    
    private const string USER_DB_NAME = "users";
    public void Init(Firebase.FirebaseApp app)
    {
        mFirebaseDatabase = FirebaseDatabase.GetInstance(app);
        mDatabaseRootRef = FirebaseDatabase.DefaultInstance.RootReference;
    }

    public async void UpdateUserData(string UserId, string jsonData, Action<bool> resultFunc = null)
    {
        if (string.IsNullOrWhiteSpace(UserId))
        {
            Debug.LogError("UserId = " + UserId);
            return;
        }

        await mDatabaseRootRef.Child(USER_DB_NAME).Child(UserId).SetRawJsonValueAsync(jsonData).ContinueWithOnMainThread(task =>
        {
            if (FireBaseHelper.CheckTaskCompletion(task, "UpdateUserData"))
            {
                if (resultFunc != null)
                {
                    resultFunc(true);
                }
            }
            else
            {
                if (resultFunc != null)
                {
                    resultFunc(false);
                }
            }
        });
    }

    public async void GetUserData(string UserId, Action<string> resultFunc, Action errorFunc)
    {
        if (string.IsNullOrWhiteSpace(UserId))
        {
            Debug.LogError("UserId = " + UserId);
            return;
        }

        await mDatabaseRootRef.Child(USER_DB_NAME).Child(UserId).GetValueAsync().ContinueWithOnMainThread(task =>
          {
              if (FireBaseHelper.CheckTaskCompletion(task, "GetUserData"))
              {
                  DataSnapshot snapshot = task.Result;
                  string jsonData = snapshot.GetRawJsonValue();
                  resultFunc(jsonData);
              }
              else
              {
                  errorFunc();
              }
          });
    }

    public async void getServerTime(Action<ulong> resultFunc, Action errorFunc)
    {
        await mFirebaseDatabase.GetReference(".info/serverTimeOffset").GetValueAsync().ContinueWithOnMainThread(task =>
        {
            if (FireBaseHelper.CheckTaskCompletion(task, "getServerTime"))
            {
                long offset = (long)task.Result.Value;//这里是毫秒
                long nServerTimeStamp = (long)TimeUtility.GetTimeStampFromLocalTime(DateTime.Now) + offset / 1000;
                Debug.Log("getServerTime: " + offset);
                resultFunc((ulong)nServerTimeStamp);
            }
            else
            {
                errorFunc();
            }
        });
    }
    
    public async void getConnected(Action<bool> resultFunc, Action errorFunc)
    {
        await mFirebaseDatabase.GetReference(".info/connected").GetValueAsync().ContinueWithOnMainThread(task =>
        {
            if (FireBaseHelper.CheckTaskCompletion(task, "getConnected"))
            {
                bool connected = (bool)task.Result.Value;//这里是毫秒
                Debug.Log("getConnected: " + connected);
                resultFunc(connected);
            }
            else
            {
                errorFunc();
            }
        });
    }

    public void DeleteUserData(string UserId, Action<bool> mFinishFuc)
    {
        if (string.IsNullOrWhiteSpace(UserId))
        {
            Debug.LogError("UserId = " + UserId);
            return;
        }

        UpdateUserData(UserId, null, mFinishFuc);
    }

};
