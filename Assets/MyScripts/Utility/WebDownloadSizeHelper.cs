using System;
using System.Collections;
using System.IO;
using UnityEngine.Networking;
using UnityEngine;
using System.Collections.Generic;

[XLua.LuaCallCSharp]
public static class WebDownloadSizeHelper
{
    public static void GetAllUrlDownloadSize(List<string> urlList, Action<bool, long> finishFunc = null)
    {
        GlobalMonoBehaviour.Instance.StartCoroutine(GetAllUrlDownloadSizeByIEnumerator(urlList, finishFunc));
    }

    public static IEnumerator GetAllUrlDownloadSizeByIEnumerator(List<string> urlList, Action<bool, long> finishFunc = null)
    {
        long nSumSize = 0;
        bool bHaveNetError = false;
        foreach (var url in urlList)
        {
            UnityWebRequest mWebRequest = UnityWebRequest.Head(url);
            yield return mWebRequest.SendWebRequest();
            if (mWebRequest.result == UnityWebRequest.Result.Success)
            {
                try
                {
                    long flLength = long.Parse(mWebRequest.GetResponseHeader("Content-Length"));
                    if (flLength >= 0)
                    {
                        nSumSize += flLength;
                    }
                }
                catch (Exception e)
                {
                    Debug.LogError(e.Message + " | " + e.StackTrace);
                    bHaveNetError = true;
                }
            }
            else
            {
                Debug.LogError("www Load Error:" + mWebRequest.responseCode + " | " + url + " | " + mWebRequest.error);
                bHaveNetError = true;
            }

            mWebRequest.Dispose();
            mWebRequest = null;

            if (bHaveNetError)
            {
                break;
            }
        }

        if (finishFunc != null)
        {
            finishFunc(bHaveNetError, nSumSize);
        }
    }

    public static string GetDownLoadSizeStr(long nSumSize)
    {
        if (nSumSize >= 1024 * 1024 * 1024)
        {
            return (nSumSize / 1024f / 1024f / 1024f).ToString("N1") + "Gb";
        }
        else if (nSumSize >= 1024 * 1024)
        {
            return (nSumSize / 1024f / 1024f).ToString("N1") + "Mb";
        }
        else if (nSumSize >= 1024)
        {
            return (nSumSize / 1024f).ToString("N1") + "Kb";
        }
        else
        {
            return nSumSize.ToString("N1") + "B";
        }
    }
    
}
