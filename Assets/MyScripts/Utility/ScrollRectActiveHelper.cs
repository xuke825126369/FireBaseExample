using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

[XLua.LuaCallCSharp]
[Obsolete]
public class ScrollRectActiveHelper : MonoBehaviour
{
    public int nShowItemCount = 10;
    public int ItemWidth = 450;
    public bool bHor = false;
    ScrollRect mScrollRect = null;
    RectTransform mScrollRectTransform = null;
    private float fMoveDistance = 0f;

    private int nShowMinIndex = 0;
    private int nShowMaxIndex = 0;
    private List<RectTransform> mGoItemList;
    private Vector2 lastItemParentPos;

    private bool bInit = false;
    private bool bActive = false;

    void Init()
    {
        if (bInit)
        {
            return;
        }
        bInit = true;

        mScrollRect = GetComponentInParent<ScrollRect>();
        mScrollRectTransform = mScrollRect.GetComponent<RectTransform>();
        nShowMinIndex = 0;
        nShowMaxIndex = nShowItemCount;
        Active();
    }

    void Start()
    {
        Init();
    }

    public void DeActive()
    {
        bActive = false;
    }

    public void Active(int nActivityDataCount = -1)
    {
        bActive = true;
        if (!gameObject.activeInHierarchy)
        {
            return;
        }

        Init();

        if (mGoItemList == null)
        {
            mGoItemList = new List<RectTransform>();
        }
        else
        {
            mGoItemList.Clear();
        }

        if (nActivityDataCount == -1)
        {
            nActivityDataCount = mScrollRect.content.childCount;
        }

        int nItemCount = Math.Min(nActivityDataCount, mScrollRect.content.childCount);
        for (int i = 0; i < nItemCount; i++)
        {
            RectTransform t = mScrollRect.content.GetChild(i).GetComponent<RectTransform>();
            mGoItemList.Add(t);
        }

        Debug.Log("mGoItemList.Count: " + mGoItemList.Count + " | " + nShowMaxIndex + " | " + nActivityDataCount);
        if (orNeedHideShowItem())
        {
            foreach (RectTransform v in mGoItemList)
            {
                v.gameObject.SetActive(false);
            }

            nShowMinIndex = 0;
            nShowMaxIndex = nShowItemCount;

            mScrollRect.content.anchoredPosition = Vector2.zero;
            lastItemParentPos = mScrollRect.content.anchoredPosition;
            fMoveDistance = 0f;
            ShowItemList();
        }
        else
        {
            foreach (RectTransform v in mGoItemList)
            {
                v.gameObject.SetActive(true);
            }

        }
    }

    private void HideItemList()
    {
        for (int i = nShowMinIndex; i <= nShowMaxIndex && i < mGoItemList.Count; i++)
        {
            if (i < mGoItemList.Count && mGoItemList[i] != null)
            {
                mGoItemList[i].gameObject.SetActive(false);
            }
        }
    }

    private bool orNeedHideShowItem()
    {
        return mGoItemList.Count > nShowItemCount;
    }

    private void ShowItemList()
    {
        Debug.Assert(nShowMinIndex >= 0 && nShowMinIndex < mGoItemList.Count, "nShowMinIndex: " + nShowMinIndex + " | " + mGoItemList.Count);
        Debug.Assert(nShowMaxIndex >= 0 && nShowMaxIndex < mGoItemList.Count, "nShowMaxIndex: " + nShowMaxIndex + " | " + mGoItemList.Count);

        for (int i = nShowMinIndex; i <= nShowMaxIndex && i < mGoItemList.Count; i++)
        {
            if (mGoItemList[i] != null)
            {
                mGoItemList[i].gameObject.SetActive(true);
            }
        }

        float fMaskZone = GetVectorKeyValue(mScrollRectTransform.rect.size);

        if (bHor)
        {
            for (int i = nShowMinIndex; i >= 0; i--)
            {
                if (mGoItemList[i] != null)
                {
                    Vector3 localItemPos = mScrollRectTransform.InverseTransformPoint(mGoItemList[i].position);
                    if (GetVectorKeyValue(localItemPos) + ItemWidth / 2 >= -fMaskZone / 2f)
                    {
                        mGoItemList[i].gameObject.SetActive(true);
                        nShowMinIndex = i;
                    }
                    else
                    {
                        break;
                    }
                }
            }

            for (int i = nShowMaxIndex; i < mGoItemList.Count; i++)
            {
                if (mGoItemList[i] != null)
                {
                    Vector3 localItemPos = mScrollRectTransform.InverseTransformPoint(mGoItemList[i].position);
                    if (GetVectorKeyValue(localItemPos) - ItemWidth / 2 <= fMaskZone / 2f)
                    {
                        mGoItemList[i].gameObject.SetActive(true);
                        nShowMaxIndex = i;
                    }
                    else
                    {
                        break;
                    }
                }
            }
        }
        else
        {
            for (int i = nShowMinIndex; i >= 0; i--)
            {
                if (mGoItemList[i] != null)
                {
                    Vector3 localItemPos = mScrollRectTransform.InverseTransformPoint(mGoItemList[i].position);
                    float fY = GetVectorKeyValue(localItemPos);
                    if (fY - ItemWidth / 2 <= fMaskZone / 2f)
                    {
                        mGoItemList[i].gameObject.SetActive(true);
                        nShowMinIndex = i;
                    }
                    else
                    {
                        break;
                    }
                }
            }

            for (int i = nShowMaxIndex; i < mGoItemList.Count; i++)
            {
                if (mGoItemList[i] != null)
                {
                    Vector3 localItemPos = mScrollRectTransform.InverseTransformPoint(mGoItemList[i].position);
                    float fY = GetVectorKeyValue(localItemPos);
                    if (fY + ItemWidth / 2 >= -fMaskZone / 2f)
                    {
                        mGoItemList[i].gameObject.SetActive(true);
                        nShowMaxIndex = i;
                    }
                    else
                    {
                        break;
                    }
                }
            }
        }
    }

    private void OnValueChanged(Vector2 moveDis)
    {
        fMoveDistance += GetVectorKeyValue(moveDis);

        bool bHideShow = Mathf.Abs(fMoveDistance) > ItemWidth;
        if (bHideShow)
        {
            HideItemList();
        }

        if (bHor)
        {
            while (Mathf.Abs(fMoveDistance) > ItemWidth)
            {
                if (fMoveDistance > ItemWidth)
                {
                    fMoveDistance -= ItemWidth;
                    if (nShowMinIndex > 0)
                    {
                        nShowMinIndex--;
                        nShowMaxIndex--;
                    }
                }
                else if (fMoveDistance < -ItemWidth)
                {
                    fMoveDistance += ItemWidth;
                    if (nShowMaxIndex < mGoItemList.Count - 1)
                    {
                        nShowMinIndex++;
                        nShowMaxIndex++;
                    }
                }
            }
        }
        else
        {
            while (Mathf.Abs(fMoveDistance) > ItemWidth)
            {
                if (fMoveDistance > ItemWidth) //ItemParent 向上
                {
                    fMoveDistance -= ItemWidth;
                    if (nShowMaxIndex < mGoItemList.Count - 1)
                    {
                        nShowMinIndex++;
                        nShowMaxIndex++;
                    }
                }
                else if (fMoveDistance < -ItemWidth)
                {
                    fMoveDistance += ItemWidth;
                    if (nShowMinIndex > 0)
                    {
                        nShowMinIndex--;
                        nShowMaxIndex--;
                    }
                }
            }
        }

        if (bHideShow)
        {
            ShowItemList();
        }
    }

    void Update()
    {
        if (!bActive)
        {
            return;
        }

        if (!orNeedHideShowItem())
        {
            return;
        }

        if (lastItemParentPos != mScrollRect.content.anchoredPosition)
        {
            Vector2 moveDis = mScrollRect.content.anchoredPosition - lastItemParentPos;
            OnValueChanged(moveDis);
            lastItemParentPos = mScrollRect.content.anchoredPosition;
        }
    }

    private float GetVectorKeyValue(Vector3 vec)
    {
        if (bHor)
        {
            return vec.x;
        }
        else
        {
            return vec.y;
        }
    }
    
    private void SetVectorKeyValue(ref Vector3 vec, float keyValue)
    {
        if (bHor)
        {
            vec.x = keyValue;
        }
        else
        {
            vec.y = keyValue;
        }
    }

}
