using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[XLua.LuaCallCSharp]
public class LogShowSecret : SingleTonMonoBehaviour<LogShowSecret>
{
    private int nContinueClickCount = 0;
    private const int nMaxContinueClickCount = 10;

    private float fLastClickTime = 0f;
    private GameObject mLogObj = null;
    private int nPassword = 0;

    public void LoadLogManager()
    {
        GameObject mLogObjPrefab = Resources.Load<GameObject>("IngameDebugConsole");
        mLogObj = Instantiate<GameObject>(mLogObjPrefab);

#if UNITY_EDITOR
        mLogObj.SetActive(false);
        Debug.unityLogger.logEnabled = true;
#else
        if (GameConfig.Instance.orTestUser())
        {
            mLogObj.SetActive(true);
            Debug.unityLogger.logEnabled = true;
            GameBootConfig.Instance.bOpenDebugTest = true;
        }
        else
        {
            mLogObj.SetActive(false);
            Debug.unityLogger.logEnabled = false;
        }
#endif
    }

    //private void Update()
    //{
    //    if (!GameConfig.Instance.orTestUser())
    //    {
    //        return;
    //    }

    //    if (Input.GetMouseButtonDown(0))
    //    {
    //        bool bContinue = false;
    //        nPassword %= 4;
    //        if (nPassword == 0)
    //        {
    //            if (orMouseInLeftTopZone())
    //            {
    //                bContinue = true;
    //            }
    //            else
    //            {
    //                bContinue = false;
    //            }
    //        }
    //        else if (nPassword == 1)
    //        {
    //            if (orMouseInLeftBottomZone())
    //            {
    //                bContinue = true;
    //            }
    //            else
    //            {
    //                bContinue = false;
    //            }
    //        }
    //        if (nPassword == 2)
    //        {
    //            if (orMouseInRightBottomZone())
    //            {
    //                bContinue = true;
    //            }
    //            else
    //            {
    //                bContinue = false;
    //            }
    //        }
    //        if (nPassword == 3)
    //        {
    //            if (orMouseInRightTopZone())
    //            {
    //                bContinue = true;
    //            }
    //            else
    //            {
    //                bContinue = false;
    //            }
    //        }

    //        if (bContinue && Time.time - fLastClickTime < 1.0f)
    //        {
    //            nPassword++;
    //            nContinueClickCount++;
    //            if (nContinueClickCount >= nMaxContinueClickCount)
    //            {
    //                if (mLogObj != null)
    //                {
    //                    mLogObj.SetActive(true);
    //                    Debug.unityLogger.logEnabled = true;
    //                    GameBootConfig.Instance.bOpenDebugTest = true;
    //                    AdsBlackListHelper.Instance.SetLocalAdsBlack();
    //                    Debug.Log("mTestUserId: " + TestUserHelper.Instance.GetTestUserId());
    //                }
    //            }
    //        }
    //        else
    //        {
    //            nContinueClickCount = 0;
    //            nPassword = 0;
    //        }

    //        fLastClickTime = Time.time;
    //    }
    //}

    //bool orMouseInLeftTopZone()
    //{
    //    Vector2 nowPressPos = Input.mousePosition;
    //    return nowPressPos.x < Screen.width / 4f && nowPressPos.y < Screen.height / 4f;
    //}

    //bool orMouseInLeftBottomZone()
    //{
    //    Vector2 nowPressPos = Input.mousePosition;
    //    return nowPressPos.x < Screen.width / 4f && nowPressPos.y >= Screen.height * 3 / 4f;
    //}

    //bool orMouseInRightTopZone()
    //{
    //    Vector2 nowPressPos = Input.mousePosition;
    //    return nowPressPos.x > Screen.width * 3 / 4f && nowPressPos.y < Screen.height / 4f;
    //}

    //bool orMouseInRightBottomZone()
    //{
    //    Vector2 nowPressPos = Input.mousePosition;
    //    return nowPressPos.x > Screen.width * 3 / 4f && nowPressPos.y >= Screen.height * 3 / 4f;
    //}

}
