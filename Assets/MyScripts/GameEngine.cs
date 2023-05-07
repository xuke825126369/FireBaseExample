using System.Collections;
using System.Net;
using UnityEngine;

[XLua.LuaCallCSharp]
public class GameEngine : SingleTonMonoBehaviour<GameEngine>
{
    private void Start()
    {
        DontDestroyOnLoad(this);
        Application.targetFrameRate = 60;
        Application.runInBackground = true;

        GameConfig.Instance.Init();
        AppsFlyerSDKInterface.Instance.Init();
        FireBaseInit.Instance.Init();
        GoogleAdsSDK_AdsInterface.Instance.Init();

        Camera.main.clearFlags = CameraClearFlags.Skybox;
        Camera.main.backgroundColor = Color.black;
        Camera.main.orthographic = true;
        Camera.main.orthographicSize = 600;
        Camera.main.nearClipPlane = -2000;
        Camera.main.farClipPlane = 2000;
        Camera.main.fieldOfView = 60;

        ServicePointManager.ServerCertificateValidationCallback +=
    (sender, certificate, chain, sslPolicyErrors) => true;
        StartCoroutine(StartInitSystem());
    }

    public IEnumerator StartInitSystem()
    {
        GameBootConfig.Instance.Init();
        InitSceneLuaEnv.Instance.Init();
        yield return InitSceneLuaEnv.Instance.LoadInitScene();
    }
}




