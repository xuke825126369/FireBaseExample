using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.UI;

[XLua.LuaCallCSharp]
[Obsolete]
public class ScrollRectHorActiveHelper : MonoBehaviour
{
    public int nShowItemCount = 5;
    public int ItemWidth = 450;
    ScrollRect mScrollRect = null;
    RectTransform mScrollRectTransform = null;
    private float fMoveXDistance = 0f;

    private int nShowMinIndex = 0;
    private int nShowMaxIndex = 0;
    private List<RectTransform> mGoItemList;
    private Vector2 lastItemParentPos;

    void Start()
    {
        mScrollRect = GetComponentInParent<ScrollRect>();
        mScrollRectTransform = mScrollRect.GetComponent<RectTransform>();
        nShowMinIndex = 0;
        nShowMaxIndex = nShowItemCount;

        Active();
    }
    
    public void Active()
    {
        if(!gameObject.activeInHierarchy)
        {
            return;
        }

        mGoItemList = new List<RectTransform>();
        foreach (RectTransform v in mScrollRect.content)
        {
            mGoItemList.Add(v);
            v.gameObject.SetActive(false);
        }

        ShowItemList();
        mScrollRect.content.anchoredPosition = Vector2.zero;
        lastItemParentPos = mScrollRect.content.anchoredPosition;
        fMoveXDistance = 0f;
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

    private void ShowItemList()
    {
        for (int i = nShowMinIndex; i <= nShowMaxIndex && i < mGoItemList.Count; i++)
        {
            if (mGoItemList[i] != null)
            {
                Vector2 screenPos = RectTransformUtility.WorldToScreenPoint(Camera.main, mGoItemList[i].position);
                mGoItemList[i].gameObject.SetActive(true);
            }
        }

        for (int i = nShowMinIndex; i >= 0; i--)
        {
            if (mGoItemList[i] != null)
            {
                Vector3 localItemPos = mScrollRectTransform.InverseTransformPoint(mGoItemList[i].position);
                if (localItemPos.x + ItemWidth / 2 >= -mScrollRectTransform.rect.width / 2f)
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
                if (localItemPos.x - ItemWidth / 2 <= mScrollRectTransform.rect.width / 2f)
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

    private void OnValueChanged(Vector2 moveDis)
    {
        //Debug.Log("moveDis: " + moveDis);
        HideItemList();

        fMoveXDistance += moveDis.x;
        while (Mathf.Abs(fMoveXDistance) > ItemWidth)
        {
            if (fMoveXDistance > ItemWidth)
            {
                fMoveXDistance -= ItemWidth;
                if (nShowMinIndex > 0)
                {
                    nShowMinIndex--;
                    nShowMaxIndex--;
                }
            }
            else if (fMoveXDistance < -ItemWidth)
            {
                fMoveXDistance += ItemWidth;
                if (nShowMaxIndex < mGoItemList.Count - 1)
                {
                    nShowMinIndex++;
                    nShowMaxIndex++;
                }
            }
        }

        ShowItemList();
    }

    void Update()
    {
        if (lastItemParentPos != mScrollRect.content.anchoredPosition)
        {
            Vector2 moveDis = mScrollRect.content.anchoredPosition - lastItemParentPos;
            OnValueChanged(moveDis);
            lastItemParentPos = mScrollRect.content.anchoredPosition;
        }
    }

}
