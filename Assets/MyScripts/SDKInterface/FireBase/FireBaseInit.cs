using System.Collections;
using System.Collections.Generic;
using Firebase;
using Firebase.Extensions;
using UnityEngine;

[XLua.LuaCallCSharp]
public class FireBaseInit : SingleTonMonoBehaviour<FireBaseInit>
{
    public FirebaseApp app;
    public Firebase.DependencyStatus dependencyStatus = Firebase.DependencyStatus.UnavailableOther;

    private bool bInit = false;
    public async void Init()
    {
        Firebase.Crashlytics.Crashlytics.IsCrashlyticsCollectionEnabled = true;
        Firebase.Analytics.FirebaseAnalytics.SetAnalyticsCollectionEnabled(true);
        //Firebase.FirebaseApp.LogLevel = LogLevel.Verbose;

        await Firebase.FirebaseApp.CheckAndFixDependenciesAsync().ContinueWithOnMainThread(task =>
        {
            dependencyStatus = task.Result;
            if (dependencyStatus == Firebase.DependencyStatus.Available)
            {
#if UNITY_EDITOR
                app = Firebase.FirebaseApp.DefaultInstance;
#else
                app = Firebase.FirebaseApp.DefaultInstance;
#endif
                FireBaseLogin.Instance.Init(app);
                FireBaseDb.Instance.Init(app);
                FireBaseMessageManager.Instance.Init();
                bInit = true;
                Debug.Log("----------------------- FireBase Init Finish -----------------------------");
            }
            else
            {
                Debug.LogError("Could not resolve all Firebase dependencies: " + dependencyStatus);
            }
        });
    }

    public bool orInitFinish()
    {
        return bInit;
    }

}
