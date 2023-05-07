using System;
using System.Collections;
using System.Collections.Generic;
using System.Security.Principal;
using System.Threading.Tasks;
using Firebase.Extensions;
using Google;
using UnityEngine;

[XLua.LuaCallCSharp]
public class FireBaseLogin : SingleTonMonoBehaviour<FireBaseLogin>
{
    Firebase.Auth.FirebaseUser user = null;
    Firebase.Auth.FirebaseAuth auth = null;

    public string displayName = "";
    public string emailAddress = "";
    public string photoUrl = "";
    public string UserId = "";

    public void Init(Firebase.FirebaseApp app)
    {
        auth = Firebase.Auth.FirebaseAuth.GetAuth(app);
        auth.StateChanged += AuthStateChanged;
        auth.IdTokenChanged += IdTokenChanged;
        AuthStateChanged(this, null);
    }
        
    void AuthStateChanged(object sender, System.EventArgs eventArgs)
    {
        if (auth.CurrentUser != user)
        {
            bool signedIn = user != auth.CurrentUser && auth.CurrentUser != null;
            if (!signedIn && user != null)
            {
                Debug.Log("Signed out " + user.UserId);
            }

            user = auth.CurrentUser;
            if (signedIn)
            {
                Debug.Log("Signed in " + user.UserId);
                displayName = user.DisplayName ?? "";
                emailAddress = user.Email ?? "";
                photoUrl = user.PhotoUrl != null ? user.PhotoUrl.AbsolutePath : "";
                UserId = user.UserId ?? "";
            }
        }
    }

    // Track ID token changes.
    void IdTokenChanged(object sender, System.EventArgs eventArgs)
    {
        Firebase.Auth.FirebaseAuth senderAuth = sender as Firebase.Auth.FirebaseAuth;
        if (senderAuth == auth && senderAuth.CurrentUser != null)
        {
            senderAuth.CurrentUser.TokenAsync(false).ContinueWithOnMainThread(
              task => Debug.Log(String.Format("Token[0:8] = {0}", task.Result.Substring(0, 8))));
        }
    }

    public Task UpdateUserProfileAsync(string newDisplayName = null)
    {
        if (auth.CurrentUser == null)
        {
            Debug.Log("Not signed in, unable to update user profile");
            return Task.FromResult(0);
        }
        displayName = newDisplayName ?? displayName;
        Debug.Log("Updating user profile");
        return auth.CurrentUser.UpdateUserProfileAsync(new Firebase.Auth.UserProfile
        {
            DisplayName = displayName,
            PhotoUrl = auth.CurrentUser.PhotoUrl,
        }).ContinueWithOnMainThread(task =>
        {
            if (FireBaseHelper.CheckTaskCompletion(task, "User profile"))
            {

            }
        });
    }

    public void SignOut()
    {
        auth.SignOut();
        GoogleSignIn.DefaultInstance.SignOut();
    }

    public async void LoginAccountWithAnonymously(Action<Firebase.Auth.FirebaseUser> mLoginFinishFunc = null)
    {
        await auth.SignInAnonymouslyAsync().ContinueWithOnMainThread(task =>
        {
            if (FireBaseHelper.CheckTaskCompletion(task, "LoginAccountWithAnonymously"))
            {
                // Firebase user has been created.
                Firebase.Auth.FirebaseUser newUser = task.Result;
                Debug.LogFormat("Firebase user Login successfully: {0} ({1})", newUser.DisplayName, newUser.UserId);

                if (mLoginFinishFunc != null)
                {
                    mLoginFinishFunc(newUser);
                }
            }
            else
            {
                if (mLoginFinishFunc != null)
                {
                    mLoginFinishFunc(null);
                }
            }
        });
    }

    public async void LoginAccountWithCustomToken(Action<Firebase.Auth.FirebaseUser> mLoginFinishFunc)
    {
        string token = SystemInfo.deviceUniqueIdentifier;
        await auth.SignInWithCustomTokenAsync(token).ContinueWithOnMainThread(task =>
        {
            if (FireBaseHelper.CheckTaskCompletion(task, "SignInWithCustomTokenAsync"))
            {
                // Firebase user has been created.
                Firebase.Auth.FirebaseUser newUser = task.Result;
                if (mLoginFinishFunc != null)
                {
                    mLoginFinishFunc(newUser);
                }
            }
            else
            {
                if (mLoginFinishFunc != null)
                {
                    mLoginFinishFunc(null);
                }
            }
        });
    }

    public async void LoginAccountWithGoogle(Action<Firebase.Auth.FirebaseUser> mLoginFinishFunc)
    {
        if (GoogleSignIn.Configuration == null)
        {
            GoogleSignIn.Configuration = new GoogleSignInConfiguration
            {
                RequestIdToken = true,
                // Copy this value from the google-service.json file.
                // oauth_client with type == 3
                WebClientId = "263666666299-8hfe0idgfibv4555d74jon7gq1heidia.apps.googleusercontent.com"
            };
        }

        await GoogleSignIn.DefaultInstance.SignIn().ContinueWithOnMainThread(task =>
        {
            if (FireBaseHelper.CheckTaskCompletion(task, "GoogleSignIn"))
            {
                LoginAccountWithGoogle1(task.Result, mLoginFinishFunc);
            }
            else
            {
                if (mLoginFinishFunc != null)
                {
                    mLoginFinishFunc(null);
                }
            }

        });
    }

    private async void LoginAccountWithGoogle1(GoogleSignInUser signIn, Action<Firebase.Auth.FirebaseUser> mLoginFinishFunc)
    { 
        string googleIdToken = signIn.IdToken;
        string googleAccessToken = null;

        Firebase.Auth.Credential credential = Firebase.Auth.GoogleAuthProvider.GetCredential(googleIdToken, googleAccessToken);
        await auth.SignInWithCredentialAsync(credential).ContinueWithOnMainThread(task =>
        {
            if (FireBaseHelper.CheckTaskCompletion(task, "LoginAccountWithGoogle"))
            {
                Firebase.Auth.FirebaseUser newUser = task.Result;
                if (mLoginFinishFunc != null)
                {
                    mLoginFinishFunc(newUser);
                }
            }
            else
            {
                if (mLoginFinishFunc != null)
                {
                    mLoginFinishFunc(null);
                }
            }
        });
    }

    public void CreateAccountWithEmail(string email, string password)
    {
        auth.CreateUserWithEmailAndPasswordAsync(email, password).ContinueWithOnMainThread(task =>
        {
            if (FireBaseHelper.CheckTaskCompletion(task, "CreateAccountWithEmail"))
            {
                // Firebase user has been created.
                Firebase.Auth.FirebaseUser newUser = task.Result;
                Debug.LogFormat("Firebase user created successfully: {0} ({1})", newUser.DisplayName, newUser.UserId);
            }
        });
    }

    public void LoginAccountWithEmail(string email, string password)
    {
        auth.SignInWithEmailAndPasswordAsync(email, password).ContinueWithOnMainThread(task =>
        {
            if (FireBaseHelper.CheckTaskCompletion(task, "LoginAccountWithEmail"))
            {
                // Firebase user has been created.
                Firebase.Auth.FirebaseUser newUser = task.Result;
                Debug.LogFormat("Firebase user Login successfully: {0} ({1})", newUser.DisplayName, newUser.UserId);
            }
        });
    }

}
