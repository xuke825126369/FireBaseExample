using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

[XLua.LuaCallCSharp]
public class ScrollRectZoneHideHelper : MonoBehaviour
{
    public ScrollRect mScrollRect;
    public GameObject leftobj;
    public GameObject rightObj;
    public float hideOffsetValue;

    private List<GameObject> mItemList = null;
    private void Start()
    {
        if (mScrollRect == null)
        {
            mScrollRect = gameObject.GetComponentInParent<ScrollRect>();
        }

        if (mScrollRect == null)
        {
            mScrollRect = gameObject.GetComponentInChildren<ScrollRect>();
        }

        mScrollRect.onValueChanged.AddListener((Vector2 offset) =>
        {
            Active();
        });
    }

    public void ClearAllItem()
    {
        mItemList = null;
    }

    public void AddItem(GameObject goItem)
    {
        if(mItemList == null)
        {
            mItemList = new List<GameObject>();
        }

        mItemList.Add(goItem);
    }

    public void SetAllItem(List<GameObject> mItemList)
    {
        this.mItemList = mItemList;
    }

    public void Active()
    {
        if (mItemList == null) return;
        if (mScrollRect == null) return;
        ShowHide();
    }

    private void ShowHide()
    {
        Vector3 leftLimitPos = mScrollRect.transform.InverseTransformPoint(leftobj.transform.position);
        Vector3 rightLimitPos = mScrollRect.transform.InverseTransformPoint(rightObj.transform.position);

        int nLeftIndex = 0;
        while (nLeftIndex < mItemList.Count)
        {
            Vector3 pos = mScrollRect.transform.InverseTransformPoint(mItemList[nLeftIndex].transform.position);
            if (pos.x + hideOffsetValue < leftLimitPos.x)
            {
                if (mItemList[nLeftIndex].activeSelf)
                {
                    mItemList[nLeftIndex].SetActive(false);
                }
            }
            else
            {
                break;
            }

            nLeftIndex++;
        }

        int nRightIndex = mItemList.Count - 1;
        while (nRightIndex >= 0)
        {
            Vector3 pos = mScrollRect.transform.InverseTransformPoint(mItemList[nRightIndex].transform.position);
            if (pos.x - hideOffsetValue > rightLimitPos.x)
            {
                if (mItemList[nRightIndex].activeSelf)
                {
                    mItemList[nRightIndex].SetActive(false);
                }
            }
            else
            {
                break;
            }

            nRightIndex--;
        }

        for (int i = nLeftIndex; i <= nRightIndex; i++)
        {
            if (!mItemList[i].activeSelf)
            {
                mItemList[i].SetActive(true);
            }
        }
    }
    
}
