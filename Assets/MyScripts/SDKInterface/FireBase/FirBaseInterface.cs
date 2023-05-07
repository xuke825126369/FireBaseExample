using System;
using System.Collections.Generic;

[XLua.LuaCallCSharp]
public static class FirBaseInterface
{
    public static void SetUserId(string nUserId)
    {
        Firebase.Crashlytics.Crashlytics.SetUserId(nUserId);
        Firebase.Analytics.FirebaseAnalytics.SetUserId(nUserId);
    }

    public static void DeleteAccount(string UserId, Action<bool> mFinishFunc)
    {
        FireBaseDb.Instance.DeleteUserData(UserId, (bSuccess) =>
        {
            if (bSuccess)
            {
                FireBaseLogin.Instance.SignOut();
            }
            mFinishFunc(bSuccess);
        });
    }

}
