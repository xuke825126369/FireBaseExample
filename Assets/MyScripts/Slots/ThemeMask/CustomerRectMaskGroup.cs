using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using XLua;

[LuaCallCSharp]
[ExecuteAlways]
[DisallowMultipleComponent]
public class CustomerRectMaskGroup : MonoBehaviour
{
    public SpriteRenderer m_SpriteMask = null;

    private List<CustomerRectMaskGroupChildren> mChildrenList = new List<CustomerRectMaskGroupChildren>();

    private Rect mMaskRect = Rect.zero;

    private Bounds mLastMaskBounds = new Bounds(Vector3.zero, Vector3.zero);

    private bool bChildrenLost = false;

    private void Awake()
    {
        Init();

        if (Application.isPlaying)
        {
            m_SpriteMask.enabled = false;
            mChildrenList.Clear();
        }
    }

#if UNITY_EDITOR
    private void OnValidate()
    {
        if (m_SpriteMask == null) return;

        SetWorldRect();
        UpdateAllMaskChild();
    }
#endif

    private void Init()
    {
        if (m_SpriteMask == null)
        {
            m_SpriteMask = gameObject.GetComponent<SpriteRenderer>();
        }

        SetWorldRect();
    }

    private void Start()
    {
        InitAllMaskChild();
        UpdateAllMaskChild();
    }

    private void OnDestroy()
    {
        mChildrenList.Clear();
        mChildrenList = null;
    }

    private void Update()
    {
        ClearLostChildren();

        if (m_SpriteMask == null)
        {
            return;
        }

        if (m_SpriteMask.bounds != mLastMaskBounds)
        {
            SetWorldRect();
            UpdateAllMaskChild();
        }
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
        if (m_SpriteMask == null)
        {
            return;
        }

        mLastMaskBounds = m_SpriteMask.bounds;

        Vector3 maskSize = m_SpriteMask.bounds.size;
        Vector3 maskPos = m_SpriteMask.transform.position;
        Vector2 maskAreaMin = new Vector2(maskPos.x - maskSize.x / 2, maskPos.y - maskSize.y / 2);
        Vector2 maskAreaMax = new Vector2(maskPos.x + maskSize.x / 2, maskPos.y + maskSize.y / 2);

        mMaskRect = Rect.MinMaxRect(maskAreaMin.x, maskAreaMin.y, maskAreaMax.x, maskAreaMax.y);

    }

    public Rect GetWorldRect()
    {
        return mMaskRect;
    }

    private void InitAllMaskChild()
    {
        CustomerRectMaskGroupChildren[] mchildrenList = GetComponentsInChildren<CustomerRectMaskGroupChildren>(false);
        foreach (var v in mchildrenList)
        {
            if (v.ValidParentMaskGroup)
            {
                AddMaskChild(v);
            }
        }
    }

    public void AddMaskChild(CustomerRectMaskGroupChildren child)
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

    public void RemoveMaskChild(CustomerRectMaskGroupChildren child)
    {
        if (mChildrenList != null && child != null)
        {
            bool bRemove = mChildrenList.Remove(child);
        }

        bChildrenLost = true;
    }

    // 孩子节点销毁后，会导致 List 部分槽点处于 缺失引用的状态
    private void ClearLostChildren()
    {
        if (bChildrenLost)
        {
            mChildrenList.RemoveAll((x) => x == null || x.gameObject == null);
            bChildrenLost = false;
        }
    }

}
