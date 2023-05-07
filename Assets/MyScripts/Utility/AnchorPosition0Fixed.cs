using UnityEngine;
using System.Collections;

[ExecuteAlways]
[XLua.LuaCallCSharp]
public class AnchorPosition0Fixed : MonoBehaviour
{
	public Vector2 anchorMin;
	public Vector2 anchorMax;

	private void Start()
	{
		RectTransform mRectTransform = transform.GetComponent<RectTransform>();
		mRectTransform.anchorMin = anchorMin;
		mRectTransform.anchorMax = anchorMax;
		mRectTransform.offsetMin = Vector2.zero;
		mRectTransform.offsetMax = Vector2.zero;
	}
}

