using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[XLua.LuaCallCSharp]
[ExecuteAlways]
public class SortingLayerExposer : MonoBehaviour {

	public string SortingLayerName = "Default";
	public int SortingOrder = 0;


	void Awake()
	{
		gameObject.GetComponent<Renderer> ().sortingLayerName = SortingLayerName;
		gameObject.GetComponent<Renderer> ().sortingOrder = SortingOrder;
	}

	public void SetSortingOrder(int value) 
	{
		gameObject.GetComponent<Renderer> ().sortingLayerName = SortingLayerName;
		SortingOrder = value;
		gameObject.GetComponent<Renderer> ().sortingOrder = value;
	}

	#if UNITY_EDITOR
	void Update ()
	{
		gameObject.GetComponent<Renderer> ().sortingLayerName = SortingLayerName;
		gameObject.GetComponent<Renderer> ().sortingOrder = SortingOrder;
	}
	#endif
}
