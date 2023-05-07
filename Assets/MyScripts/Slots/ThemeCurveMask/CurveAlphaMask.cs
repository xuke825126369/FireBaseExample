using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using XLua;

[ExecuteAlways]
[RequireComponent(typeof(CurveItem))]
[LuaCallCSharp]
[DisallowMultipleComponent]
public class CurveAlphaMask : MonoBehaviour
{
	public bool showMask;
	private CurveItem m_selfItem;
	private List<CurveItem> m_curveItemChildrenList = new List<CurveItem> ();
	private List<CurveSpine> m_curveSpineChildrenList = new List<CurveSpine> ();

	public void AddCurveChild(CurveItem item)
	{
		if (!m_curveItemChildrenList.Contains (item))
		{
			m_curveItemChildrenList.Add(item);
		}
	}

	public void AddCurveSpineChild(CurveSpine item)
	{
		if (!m_curveSpineChildrenList.Contains (item))
		{
			m_curveSpineChildrenList.Add(item);
		}
	}

	void Start()
	{
		m_selfItem = GetComponent<CurveItem> ();
	}

	void LateUpdate()
	{
		Vector3[] worldCorners = m_selfItem.worldCorners;
		for (int i = 0; i < m_curveItemChildrenList.Count; i++)
		{
			m_curveItemChildrenList [i].SetMaskArea (worldCorners[0], worldCorners[1], m_selfItem.m_mainSprite);
		}

		for (int i = 0; i < m_curveSpineChildrenList.Count; i++)
		{
			m_curveSpineChildrenList [i].SetMaskArea (worldCorners[0], worldCorners[1], m_selfItem.m_mainSprite);
		}

		m_selfItem.mVector3Pool.recycle (worldCorners);
	}

}
