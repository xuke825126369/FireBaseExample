using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine.Networking;
using Newtonsoft.Json;
using XLua;
using System;

[XLua.LuaCallCSharp]
public class InitSceneHotUpdateManager : MonoBehaviour
{
    private int nCheckUpdateCount = 0;
    private float fProgress = 0.0f;

    private int nSumDownloadUpdateCount = 0;
    private int nDownloadUpdateCount = 0;
    private long nDownloadedSize = 0;
    private long nSumDownloadedSize = 0;
    private LuaTable mLuaTable;

    private Action<LuaTable> mLuaOnCSharpVersionUpdateFunc;
    private Action<LuaTable, string> mLuaOnNetErrorFunc;
    private Action<LuaTable, float> mLuaOnUpdateDownloadProgress;
    private Action<LuaTable, long, long, int, int> mLuaOnUpdateDownloadSizeInfo;
    private Action<LuaTable> mLuaOnLoadAllBundleFinish;
    private bool bHaveError = false;
    
    public void Init()
    {
        mLuaTable = InitSceneLuaEnv.Instance.GetEnv().Global.GetInPath<LuaTable>("InitScene");
        
        mLuaOnNetErrorFunc = mLuaTable.GetInPath<Action<LuaTable, string>>("OnNetErrorFunc");
        mLuaOnCSharpVersionUpdateFunc = mLuaTable.GetInPath<Action<LuaTable>>("OnCSharpVersionUpdate");
        mLuaOnUpdateDownloadSizeInfo = mLuaTable.GetInPath<Action<LuaTable, long, long, int, int>>("OnUpdateDownloadSizeInfo");
        mLuaOnUpdateDownloadProgress = mLuaTable.GetInPath<Action<LuaTable, float>>("OnUpdateDownloadProgress");
        mLuaOnLoadAllBundleFinish = mLuaTable.GetInPath<Action<LuaTable>>("OnLoadAllBundleFinish");
    }

    public void RemoveLuaEvent()
    {
        mLuaTable = null;
        mLuaOnNetErrorFunc = null;
        mLuaOnCSharpVersionUpdateFunc = null;
        mLuaOnUpdateDownloadProgress = null;
        mLuaOnLoadAllBundleFinish = null;
        mLuaOnUpdateDownloadSizeInfo = null;
    }

    private void OnDestroy()
    {
        RemoveLuaEvent();
    }

    private void LoadCSharpVersionFinishInit()
    {
        LogShowSecret.Instance.LoadLogManager();
    }

    public IEnumerator CheckUpdate()
    {
        ++nCheckUpdateCount;
        AssetBundleManager.Instance.InitSceneReStart();
        bHaveError = false;
        fProgress = 0f;
        nSumDownloadUpdateCount = 0;
        nDownloadUpdateCount = 0;
        nSumDownloadedSize = 0;
        nDownloadedSize = 0;
        mLuaOnUpdateDownloadSizeInfo(mLuaTable, 0, 0, 0, 0);

        if (GameConfig.Instance.orUseAssetBundle)
        {
            yield return null;
            if (mLuaOnUpdateDownloadProgress != null)
            {
                mLuaOnUpdateDownloadProgress(mLuaTable, fProgress);
            }
            yield return CheckCSharpVersionConfig();
        }
        else
        {
            TextAsset mAssets = Resources.Load<TextAsset>("CSharpVersionConfig");
            CSharpVersionConfig mWebConfig = JsonConvert.DeserializeObject<CSharpVersionConfig>(mAssets.text);
            GameBootConfig.Instance.mCSharpVersionConfig = mWebConfig;
            LoadCSharpVersionFinishInit();
        }

        if (!bHaveError)
        {
            AssetBundleManager.Instance.SetInitSceneResUpdateFinish();
            fProgress = 1.0f;
            mLuaOnLoadAllBundleFinish(mLuaTable);
            if (mLuaOnUpdateDownloadProgress != null)
            {
                mLuaOnUpdateDownloadProgress(mLuaTable, fProgress);
            }
        }
    }

    private IEnumerator CheckCSharpVersionConfig()
    {
        string url = GameBootConfig.Instance.CSharpVersionWebUrl;
        UnityWebRequest www = UnityWebRequest.Get(url);
        yield return www.SendWebRequest();
        if (www.isDone)
        {
            if (www.result != UnityWebRequest.Result.Success)
            {
                bHaveError = true;
                string netErrorDes = "www Load Error:" + www.responseCode + " | " + url + " | " + www.error;
                mLuaOnNetErrorFunc(mLuaTable, netErrorDes);
                www.Dispose();
                yield break;
            }
        }

        string jsonStr = www.downloadHandler.text;
        www.Dispose();
        Debug.Log("CSharpVersionConfig: " + jsonStr);
        CSharpVersionConfig mWebConfig = JsonConvert.DeserializeObject<CSharpVersionConfig>(jsonStr);
        if (CheckVersionNeedUpdate(mWebConfig))
        {
            mLuaOnCSharpVersionUpdateFunc(mLuaTable);
            bHaveError = true;
            yield break;
        }
        else
        {
            GameBootConfig.Instance.mCSharpVersionConfig = mWebConfig;
            LoadCSharpVersionFinishInit();
            fProgress = 0.1f;
            if (mLuaOnUpdateDownloadProgress != null)
            {
                mLuaOnUpdateDownloadProgress(mLuaTable, fProgress);
            }
            yield return CheckHotUpdateConfig();
        }
    }

    private bool CheckVersionNeedUpdate(CSharpVersionConfig mWebConfig)
    {
        int nLocalVersion = int.Parse(Application.version);
        if (!mWebConfig.versionList.Contains(Application.version))
        {
            bool bLocalIsMinVersion = true;
            foreach (string v in mWebConfig.versionList)
            {
                int nServerVersion = int.Parse(v);
                if (nServerVersion <= nLocalVersion)
                {
                    bLocalIsMinVersion = false;
                    break;
                }
            }

            if (bLocalIsMinVersion)
            {
                return true;
            }
        }

        return false;
    }

    private IEnumerator CheckHotUpdateConfig()
    {
        string hotUpdateConfigFileName = GameBootConfig.mHotUpdateConfigFileName;
        string url = Path.Combine(GameBootConfig.Instance.ResUrlRoot, hotUpdateConfigFileName);
        UnityWebRequest www = UnityWebRequest.Get(url);
        yield return www.SendWebRequest();
        if (www.isDone)
        {
            if (www.result != UnityWebRequest.Result.Success)
            {
                bHaveError = true;
                string netErrorDes = "www Load Error:" + www.responseCode + " | " + url + " | " + www.error;
                mLuaOnNetErrorFunc(mLuaTable, netErrorDes);
                www.Dispose();
                yield break;
            }
        }

        string jsonStr = www.downloadHandler.text;
        www.Dispose();

        AssetBundleHotUpdateConfig mWebConfig = JsonConvert.DeserializeObject<AssetBundleHotUpdateConfig>(jsonStr);
        PlayerPrefs.SetString(GameBootConfig.mHotUpdateConfigDBName, jsonStr);
        PlayerPrefs.Save();
        AssetBundleConfig.readOnlyInstance.mAssetBundleHotUpdateConfig = mWebConfig;

        nSumDownloadUpdateCount = 0;
        nDownloadUpdateCount = 0;
        var mDownloadUrlList = new List<string>();
        foreach (var k in mWebConfig.mInitSceneWebItemDic)
        {
            string bundleName = k.Key;
            AssetBundleHotUpdateConfig.AssetBundleHotUpdateItem mHotUpdateItem = k.Value;
            if (!mHotUpdateItem.IsVersionCached())
            {
                nSumDownloadUpdateCount++;
                mDownloadUrlList.Add(mHotUpdateItem.GetUrl());
            }
        }

        InitRequestDownloadInfo(mDownloadUrlList, nCheckUpdateCount);
        foreach (var k in mWebConfig.mInitSceneWebItemDic)
        {
            if (bHaveError)
            {
                break;
            }
            else
            {
                AssetBundleHotUpdateConfig.AssetBundleHotUpdateItem mHotUpdateItem = k.Value;
                yield return DownLoadSingleBundle(mHotUpdateItem);
            }
        }
    }

    private void InitRequestDownloadInfo(List<string> mDownloadUrlList, int nInitRequestInfoCount)
    {
        if (nInitRequestInfoCount != nCheckUpdateCount)
        {
            return;
        }

        if (nSumDownloadUpdateCount == 0)
        {
            mLuaOnUpdateDownloadSizeInfo(mLuaTable, 0, 0, 0, 0);
            return;
        }

        StartCoroutine(WebDownloadSizeHelper.GetAllUrlDownloadSizeByIEnumerator(mDownloadUrlList, (bHaveError1, nSumSize) =>
        {
            if (nInitRequestInfoCount != nCheckUpdateCount)
            {
                return;
            }

            if (!bHaveError1)
            {
                nSumDownloadedSize = nSumSize;
                mLuaOnUpdateDownloadSizeInfo(mLuaTable, nDownloadedSize, nSumDownloadedSize, nDownloadUpdateCount, nSumDownloadUpdateCount);
            }
        }));
    }

    private IEnumerator DownLoadSingleBundle(AssetBundleHotUpdateConfig.AssetBundleHotUpdateItem mItem)
    {
        string url = mItem.GetUrl();
        bool bCache = mItem.IsVersionCached();

        UnityWebRequest www = UnityWebRequestAssetBundle.GetAssetBundle(url, mItem.GetHash128());
        UnityWebRequestAsyncOperation mUnityWebRequestAsyncOperation = www.SendWebRequest();

        long oriDownloadedSize = nDownloadedSize;
        while (!mUnityWebRequestAsyncOperation.isDone)
        {
            if (!bCache)
            {
                nDownloadedSize = oriDownloadedSize + (long)mUnityWebRequestAsyncOperation.webRequest.downloadedBytes;
                fProgress = GetCurrentLoadBundleProgress(mUnityWebRequestAsyncOperation);
                mLuaOnUpdateDownloadProgress(mLuaTable, fProgress);
                mLuaOnUpdateDownloadSizeInfo(mLuaTable, nDownloadedSize, nSumDownloadedSize, nDownloadUpdateCount, nSumDownloadUpdateCount);
            }
            yield return null;
        }

        if (www.result != UnityWebRequest.Result.Success)
        {
            bHaveError = true;
            string netErrorDes = "www Load Error:" + www.responseCode + " | " + url + " | " + www.error;
            mLuaOnNetErrorFunc(mLuaTable, netErrorDes);
            www.Dispose();
            yield break;
        }

        if (!bCache)
        {
            fProgress = GetCurrentLoadBundleProgress(mUnityWebRequestAsyncOperation);
            nDownloadUpdateCount++;
            nDownloadedSize = oriDownloadedSize + (long)mUnityWebRequestAsyncOperation.webRequest.downloadedBytes;

            mLuaOnUpdateDownloadProgress(mLuaTable, fProgress);
            mLuaOnUpdateDownloadSizeInfo(mLuaTable, nDownloadedSize, nSumDownloadedSize, nDownloadUpdateCount, nSumDownloadUpdateCount);
        }

        if (!AssetBundleManager.Instance.ContainsBundle(mItem.bundleName))
        {
            AssetBundle bundle = DownloadHandlerAssetBundle.GetContent(www);
            AssetBundleManager.Instance.SaveBundleToDic(mItem.bundleName, bundle);
        }
        else
        {
            Debug.Log("WWW Cache No Load Bundle :" + mItem.bundleName);
        }

        www.Dispose();
    }

    private float GetCurrentLoadBundleProgress(UnityWebRequestAsyncOperation mUnityWebRequestAsyncOperation)
    {
        float B = Mathf.Clamp01(mUnityWebRequestAsyncOperation.progress);
        float A = 0.1f + 0.9f * ((nDownloadUpdateCount + B) / (float)nSumDownloadUpdateCount);
        A = Mathf.Clamp01(A);
        return A;
    }

}