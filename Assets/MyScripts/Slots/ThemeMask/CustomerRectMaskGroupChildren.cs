using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using XLua;

[LuaCallCSharp]
[ExecuteAlways]
[DisallowMultipleComponent]
public class CustomerRectMaskGroupChildren : MonoBehaviour
{
    [SerializeField]
    protected CustomerRectMaskGroup m_RectMaskGroup = null;
    [SerializeField]
    private bool m_ValidParentMaskGroup = true;

    protected virtual void Awake()
    {
        
    }

    protected virtual bool orInit()
    {
        return false;
    }

    protected virtual void InitMaskGroup()
    {
        if (ValidParentMaskGroup)
        {
            SwitchParent();
        }
        else
        {
            SetGroupMask(m_RectMaskGroup);
        }
    }

    public bool ValidParentMaskGroup
    {
        get{
            return m_ValidParentMaskGroup;
        }

        set{
            if (m_ValidParentMaskGroup == value) return;
            m_ValidParentMaskGroup = value;
            if (m_ValidParentMaskGroup)
            {
                SwitchParent();
            }
        }
    }

    public void SetGroupMask(CustomerRectMaskGroup m_RectMaskGroup)
    {
        if (!ValidParentMaskGroup)
        {
            if (orInit())
            {
                SwitchMaskGroup(m_RectMaskGroup);
            }
            else
            {
                this.m_RectMaskGroup = m_RectMaskGroup;
            }
        }
        else
        {
            Debug.LogError("自定义 GroupMask，请设置 m_ValidParentMaskGroup 字段 为 false");
        }

    }

    public virtual void UpdateMaskGroupClipRect()
    {

    }

    protected virtual void OnDestroy()
    {
        if (m_RectMaskGroup)
        {
            m_RectMaskGroup.RemoveMaskChild(this);
        }
    }

    protected virtual void OnTransformParentChanged()
    {
        SwitchParent();
    }

    protected virtual void SwitchParent()
    {
        if (ValidParentMaskGroup)
        {
            CustomerRectMaskGroup newGroup = gameObject.GetComponentInParent<CustomerRectMaskGroup>();
            SwitchMaskGroup(newGroup);
        }
    }

    protected virtual void SwitchMaskGroup(CustomerRectMaskGroup newGroup)
    {
        CustomerRectMaskGroup mOldGroup = m_RectMaskGroup;

        if (mOldGroup)
        {
            mOldGroup.RemoveMaskChild(this);
        }

        if (newGroup)
        {
            newGroup.AddMaskChild(this);
        }

        m_RectMaskGroup = newGroup;

        UpdateMaskGroupClipRect();
    }

}
