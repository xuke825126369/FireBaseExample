using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[XLua.LuaCallCSharp]
[ExecuteAlways]
[DisallowMultipleComponent]
public class CurveGroup : MonoBehaviour
{
	public float m_curveRadius;
	public Vector2 m_areaSize;

    private Vector2 m_LastAreaSize;
    private Vector3 m_LastPosition;
    private float m_LastCurveRadius;

    private Rect mMaskRect = Rect.zero;
    private List<CurveGroupChildren> mChildrenList = new List<CurveGroupChildren>();
    private bool bChildrenLost;

    private void Start()
    {
        InitAllMaskChild();
        UpdateAllMaskChild();
    }

    private void Update()
    {
        ClearLostChildren();

        if (orChangedMaskZone())
        {
            SetWorldRect();
            UpdateAllMaskChild();
        }
    }

    private bool orChangedMaskZone()
    {
        return m_LastAreaSize != m_areaSize || m_LastPosition != transform.position || m_LastCurveRadius != m_curveRadius;
    }

    public void UpdateAllMaskChild()
    {
        if (mChildrenList == null) return;

        ClearLostChildren();

        for (int i = 0; i < mChildrenList.Count; i++)
        {
            mChildrenList[i].UpdateMaskGroupClipRect();
        }
    }

    private void SetWorldRect()
    {
        if (orChangedMaskZone())
        {
            m_LastAreaSize = m_areaSize;
            m_LastPosition = transform.position;
            m_LastCurveRadius = m_curveRadius;

            Vector3 maskSize = m_areaSize;
            Vector3 maskPos = transform.position;
            Vector2 maskAreaMin = new Vector2(maskPos.x - maskSize.x / 2, maskPos.y - maskSize.y / 2);
            Vector2 maskAreaMax = new Vector2(maskPos.x + maskSize.x / 2, maskPos.y + maskSize.y / 2);

            mMaskRect = Rect.MinMaxRect(maskAreaMin.x, maskAreaMin.y, maskAreaMax.x, maskAreaMax.y);
        }
    }

    public Rect GetWorldRect()
    {
        SetWorldRect();
        return mMaskRect;
    }

    private void InitAllMaskChild()
    {
        CurveGroupChildren[] mchildrenList = GetComponentsInChildren<CurveGroupChildren>(false);
        foreach (var v in mchildrenList)
        {
            if (v.ValidParentMaskGroup)
            {
                AddMaskChild(v);
            }
        }
    }

    public void AddMaskChild(CurveGroupChildren child)
    {
        if (child != null)
        {
            if (mChildrenList != null)
            {
                if (!mChildrenList.Contains(child))
                {
                    mChildrenList.Add(child);
                }
            }
            else
            {

            }
        }
    }

    public void RemoveMaskChild(CurveGroupChildren child)
    {
        if (mChildrenList != null && child != null)
        {
            bool bRemove = mChildrenList.Remove(child);
        }

        bChildrenLost = true;
    }

    //孩子节点销毁后，会导致 List 部分槽点处于 缺失引用的状态
    private void ClearLostChildren()
    {
        if (bChildrenLost)
        {
            mChildrenList.RemoveAll((x) => x == null || x.gameObject == null);
            bChildrenLost = false;
        }
    }
}
