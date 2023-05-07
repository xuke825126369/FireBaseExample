using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[XLua.LuaCallCSharp]
public class CustomAnimationCurve : MonoBehaviour
{
    [SerializeField]
    private AnimationCurve m_AnimationCurve;

    public AnimationCurve GetAnimationCurve()
    {
        return m_AnimationCurve;
    }
}
