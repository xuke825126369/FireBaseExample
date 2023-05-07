using System;
using System.Collections;
using System.Collections.Generic;
using Firebase.Extensions;
using Firebase.Firestore;
using UnityEngine;

[XLua.LuaCallCSharp]
public class FireBaseCloudFireStore : MonoBehaviour
{
    FirebaseFirestore mFirebaseFirestore = null;
    private const string USER_DB_NAME = "users";

    public void Init(Firebase.FirebaseApp app)
    {
        mFirebaseFirestore = Firebase.Firestore.FirebaseFirestore.GetInstance(app);
    }

    public async void UpdateUserData(string UserId, string jsonData)
    {
        if (string.IsNullOrWhiteSpace(UserId))
        {
            Debug.LogError("UserId = " + UserId);
            return;
        }

        await mFirebaseFirestore.Collection(USER_DB_NAME).Document(UserId).SetAsync(jsonData).ContinueWithOnMainThread(task =>
            {
                FireBaseHelper.CheckTaskCompletion(task, "UpdateUserData");
            });
    }

    public async void GetUserData(string UserId, Action<string> resultFunc, Action errorFunc)
    {
        if (string.IsNullOrWhiteSpace(UserId))
        {
            Debug.LogError("UserId = " + UserId);
            return;
        }

        await mFirebaseFirestore.Collection(USER_DB_NAME).Document(UserId).GetSnapshotAsync().ContinueWithOnMainThread(task =>
            {
                if (FireBaseHelper.CheckTaskCompletion(task, "GetUserData"))
                {
                    DocumentSnapshot snapshot = task.Result;
                    string jsonData = snapshot.ToString();
                    resultFunc(jsonData);
                }
                else
                {
                    errorFunc();
                }
            });
    }
   

}
