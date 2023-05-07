using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System.Xml;
using System.IO;
using UnityEngine.Networking;
using System.Linq;
using System;

[XLua.LuaCallCSharp]
public class AssetBundleManager : SingleTonMonoBehaviour<AssetBundleManager>
{
    private const string bundleRootDir = "Assets/ResourceABs/";
    private Dictionary<string, AssetBundle> mBundleDic = new Dictionary<string, AssetBundle>();

    private bool m_bInitSceneResUpdateFinish = false;
    public void InitSceneReStart()
    {
        m_bInitSceneResUpdateFinish = false;
        List<string> bundleNameList = mBundleDic.Keys.ToList<string>();
        foreach (var v in bundleNameList)
        {
            if (v != GameBootConfig.mInitSceneBundleName)
            {
                UnLoadBundle(v, true);
                mBundleDic.Remove(v);
            }
        }
    }

    public void SetInitSceneResUpdateFinish()
    {
        m_bInitSceneResUpdateFinish = true;
    }

    public bool orInitSceneResUpdateFinish()
    {
        return m_bInitSceneResUpdateFinish;
    }

    public void UnLoadBundle(string bundleName, bool unloadAllAssets)
    {
        if (string.IsNullOrWhiteSpace(bundleName))
        {
            Debug.Assert(!string.IsNullOrWhiteSpace(bundleName), bundleName);
            return;
        }

        if (GameConfig.Instance.orUseAssetBundle)
        {
            bundleName = getRealBundleName(bundleName);
            if (mBundleDic.ContainsKey(bundleName))
            {
                mBundleDic[bundleName].Unload(unloadAllAssets);
                mBundleDic.Remove(bundleName);
            }
        }

        Resources.UnloadUnusedAssets();
    }

    private string getRealBundleName(string bundleName)
    {
        return bundleName.ToLower();
    }

    private string getRealAssetName(AssetBundle bundle, string assetPath)
    {
        string[] allasseetNames = null;
        string assetLowerpath = assetPath.ToLower();
        allasseetNames = bundle.GetAllAssetNames();
        foreach (var v in allasseetNames)
        {
            if (v.IndexOf(assetLowerpath) != -1)
            {
                return v;
            }
        }

        Debug.LogError("此 资源名 未找到 ！！！: " + assetPath);
        return assetPath;
    }

    public void SaveBundleToDic(string bundleName, AssetBundle bundle)
    {
        bundleName = getRealBundleName(bundleName);
        Debug.Assert(bundle, "未保存的Bundle为空:" + bundleName);
        if (!mBundleDic.ContainsKey(bundleName))
        {
            mBundleDic[bundleName] = bundle;
        }
        else
        {
            Debug.LogError("Bundle资源 重复:" + bundleName);
        }
    }

    public IEnumerator AsyncLoadLocalBundle(string ExternalStorePath, AssetBundleHotUpdateConfig.AssetBundleHotUpdateItem mItem)
    {
        if (GameConfig.Instance.orUseAssetBundle)
        {
            string bundleName = getRealBundleName(mItem.bundleName);
            if (!ContainsBundle(bundleName))
            {
                string path = Path.Combine(ExternalStorePath, mItem.GetBundleFileName());
                AssetBundleCreateRequest mCurrentAssetBundleCreateRequest = AssetBundle.LoadFromFileAsync(path);
                yield return mCurrentAssetBundleCreateRequest;
                AssetBundle bundle = mCurrentAssetBundleCreateRequest.assetBundle;
                SaveBundleToDic(bundleName, bundle);
            }
        }
    }

    public IEnumerator AsyncLoadWebBundle(AssetBundleHotUpdateConfig.AssetBundleHotUpdateItem mItem)
    {
        if (GameConfig.Instance.orUseAssetBundle)
        {
            string url = mItem.GetUrl();
            UnityWebRequest www = UnityWebRequestAssetBundle.GetAssetBundle(url, mItem.GetHash128());
            UnityWebRequestAsyncOperation mUnityWebRequestAsyncOperation = www.SendWebRequest();
            yield return mUnityWebRequestAsyncOperation;
            if (mUnityWebRequestAsyncOperation.webRequest.result != UnityWebRequest.Result.Success)
            {
                Debug.LogError("www Load Error:" + www.responseCode + " | " + url + " | " + www.error);
                www.Dispose();
                yield break;
            }

            AssetBundle bundle = DownloadHandlerAssetBundle.GetContent(www);
            AssetBundleManager.Instance.SaveBundleToDic(mItem.bundleName, bundle);
            www.Dispose();
        }
    }

    public AssetBundle GetBundle(string bundleName)
    {
        bundleName = getRealBundleName(bundleName);
        return mBundleDic[bundleName];
    }

    public bool ContainsBundle(string bundleName)
    {
        bundleName = getRealBundleName(bundleName);
        return mBundleDic.ContainsKey(bundleName);
    }

    public bool ContainsAsset(string bundleName, string assetPath)
    {
        if (GameConfig.Instance.orUseAssetBundle)
        {
            AssetBundle mBundle = GetBundle(bundleName);
            string assetLowerpath = assetPath.ToLower();
            foreach (var v in mBundle.GetAllAssetNames())
            {
                if (v.IndexOf(assetLowerpath) != -1)
                {
                    return true;
                }
            }
        }
        else
        {
#if UNITY_EDITOR
            assetPath = getEditorRealAssetName(bundleName, assetPath, true);
            return File.Exists(assetPath);
#endif
        }

        return false;
    }

    public UnityEngine.Object LoadAsset(string bundleName, string assetPath, Type resType = null)
    {
        if (GameConfig.Instance.orUseAssetBundle)
        {
            bundleName = getRealBundleName(bundleName);
            if (mBundleDic.ContainsKey(bundleName))
            {
                AssetBundle bundle = mBundleDic[bundleName];
                assetPath = getRealAssetName(bundle, assetPath);
                UnityEngine.Object mm = null;
                if (resType != null)
                {
                    mm = bundle.LoadAsset(assetPath, resType);
                    Debug.Assert(mm.GetType().FullName == resType.FullName, "加载资源类型错误: " + resType.FullName + " | " + assetPath);
                }
                else
                {
                    mm = bundle.LoadAsset(assetPath);
                }
                return mm;
            }
            else
            {
                Debug.LogError(bundleName + " Not Exist! ");
            }

            return null;
        }
        else
        {
#if UNITY_EDITOR
            assetPath = getEditorRealAssetName(bundleName, assetPath);
            return GetAssetFromEditorDic(bundleName, assetPath);
#else
                return null;
#endif
        }
    }

#if UNITY_EDITOR
    private string GetEditorBundleDirName(string bundleName)
    {
        string dirName = string.Empty;
        int nIndex = bundleName.IndexOf("_");
        if (nIndex > 0)
        {
            dirName = bundleName.Substring(0, nIndex) + "/" + bundleName.Substring(nIndex + 1);
        }
        else
        {
            dirName = bundleName;
        }

        return bundleRootDir + dirName;
    }

    private string GetEditorAssetPathDir(string bundleName, string assetPath, bool bSuppressPrint = false)
    {
        string nBundleDirName = GetEditorBundleDirName(bundleName).ToLower();
        string dirPath = null;

        List<string> topDirList = new List<string>();
        foreach (var v in Directory.GetDirectories(bundleRootDir, "*", SearchOption.TopDirectoryOnly))
        {
            topDirList.Add(v);
            if (v.ToLower() == nBundleDirName)
            {
                dirPath = v;
                break;
            }
        }

        if (string.IsNullOrWhiteSpace(dirPath))
        {
            foreach (var dir in topDirList)
            {
                foreach (var v in Directory.GetDirectories(dir, "*", SearchOption.TopDirectoryOnly))
                {
                    if (v.ToLower() == nBundleDirName)
                    {
                        dirPath = v;
                        break;
                    }
                }
            }
        }

        if (!Directory.Exists(dirPath))
        {
            if (!bSuppressPrint)
            {
                Debug.LogError("目录不存在: " + nBundleDirName + " | " + dirPath + " | " + assetPath);
            }
        }

        return dirPath;
    }

    private string getEditorRealAssetName(string bundleName, string assetPath, bool bSuppressPrint = false)
    {
        string dirPath = GetEditorAssetPathDir(bundleName, assetPath, bSuppressPrint);
        if (!Directory.Exists(dirPath))
        {
            return assetPath;
        }

        foreach (string v in Directory.GetFiles(dirPath, "*", SearchOption.AllDirectories))
        {
            if (v.ToLower().Contains(assetPath.ToLower()))
            {
                return v;
            }
        }

        if (!bSuppressPrint)
        {
            Debug.LogError("此 资源名 未找到 ！！！: " + assetPath);
        }

        return assetPath;
    }

    private UnityEngine.Object GetAssetFromEditorDic(string bundleName, string assetPath)
    {
        UnityEngine.Object asset = asset = UnityEditor.AssetDatabase.LoadAssetAtPath<UnityEngine.Object>(assetPath);

        if (asset != null)
        {
            return asset;
        }
        else
        {
            Debug.LogError("找不到资源：" + bundleName + " | " + assetPath);
        }

        return null;
    }
#endif
}