using System;
using System.Threading.Tasks;
using Firebase.Extensions;
using UnityEngine;

[XLua.LuaCallCSharp]
public class FireBaseMessageManager : SingleTonMonoBehaviour<FireBaseMessageManager>
{
    public string OnTokenReceived_pushToken;
    public string GetTokenAsync_pushToken;
    private string topic = "GameTopic";

    public void Init()
    {
        Firebase.Messaging.FirebaseMessaging.TokenReceived += OnTokenReceived;
        Firebase.Messaging.FirebaseMessaging.MessageReceived += OnMessageReceived;
        Firebase.Messaging.FirebaseMessaging.SubscribeAsync(topic).ContinueWithOnMainThread(task =>
        {
            LogTaskCompletion(task, "SubscribeAsync");
        });

        Firebase.Messaging.FirebaseMessaging.RequestPermissionAsync().ContinueWithOnMainThread(
          task =>
          {
              LogTaskCompletion(task, "RequestPermissionAsync");
          }
        );

        GetTokenAsync();
    }

    private void OnTokenReceived(object sender, Firebase.Messaging.TokenReceivedEventArgs token)
    {
        Debug.Log("OnTokenReceived: Received Registration Token: " + token.Token);
        OnTokenReceived_pushToken = token.Token;
    }

    private void OnMessageReceived(object sender, Firebase.Messaging.MessageReceivedEventArgs e)
    {
        if (!string.IsNullOrWhiteSpace(e.Message.Error))
        {
            Debug.LogError(e.Message.MessageId + " | " + e.Message.Error + " | " + e.Message.ErrorDescription);
            return;
        }

        Debug.Log(this.GetType().FullName + ": OnMessageReceived:");
        var notification = e.Message.Notification;
        if (notification != null)
        {
            Debug.Log("title: " + notification.Title);
            Debug.Log("body: " + notification.Body);
            var android = notification.Android;
            if (android != null)
            {
                Debug.Log("android channel_id: " + android.ChannelId);
            }
        }
        if (e.Message.From.Length > 0)
            Debug.Log("from: " + e.Message.From);
        if (e.Message.Link != null)
        {
            Debug.Log("link: " + e.Message.Link.ToString());
        }
        if (e.Message.Data.Count > 0)
        {
            Debug.Log("data:");
            foreach (System.Collections.Generic.KeyValuePair<string, string> iter in e.Message.Data)
            {
                Debug.Log("  " + iter.Key + ": " + iter.Value);
            }
        }
    }

    protected bool LogTaskCompletion(Task task, string operation)
    {
        bool complete = false;
        if (task.IsCanceled)
        {
            Debug.Log(operation + " canceled.");
        }
        else if (task.IsFaulted)
        {
            Debug.Log(operation + " encounted an error.");
            foreach (Exception exception in task.Exception.Flatten().InnerExceptions)
            {
                string errorCode = "";
                Firebase.FirebaseException firebaseEx = exception as Firebase.FirebaseException;
                if (firebaseEx != null)
                {
                    errorCode = String.Format("Error.{0}: ",
                      ((Firebase.Messaging.Error)firebaseEx.ErrorCode).ToString());
                }
                Debug.Log(errorCode + exception.ToString());
            }
        }
        else if (task.IsCompleted)
        {
            Debug.Log(operation + " completed");
            complete = true;
        }
        return complete;
    }

    private void SubscribeAsync()
    {
        Firebase.Messaging.FirebaseMessaging.SubscribeAsync(topic).ContinueWithOnMainThread(
          task =>
          {
              LogTaskCompletion(task, "SubscribeAsync");
          }
        );
        Debug.Log("Subscribed to " + topic);

    }

    private void UnsubscribeAsync()
    {
        Firebase.Messaging.FirebaseMessaging.UnsubscribeAsync(topic).ContinueWithOnMainThread(
          task =>
          {
              LogTaskCompletion(task, "UnsubscribeAsync");
          }
        );
        Debug.Log("Unsubscribed from " + topic);

    }

    public void ToggleTokenOnInit(bool bEnable)
    {
        Firebase.Messaging.FirebaseMessaging.TokenRegistrationOnInitEnabled = bEnable;
    }

    private void GetTokenAsync()
    {
        Firebase.Messaging.FirebaseMessaging.GetTokenAsync().ContinueWithOnMainThread(
          task =>
          {
              GetTokenAsync_pushToken = task.Result;
              LogTaskCompletion(task, "GetTokenAsync");
          }
        );
    }

    private void DeleteTokenAsync()
    {
        Firebase.Messaging.FirebaseMessaging.DeleteTokenAsync().ContinueWithOnMainThread(
          task =>
          {
              LogTaskCompletion(task, "DeleteTokenAsync");
          }
        );
    }

}