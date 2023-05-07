using UnityEngine;
using System;
using System.Collections.Generic;

namespace SlotsMania
{
	public class ThemeReal3DModelChangeSkin : MonoBehaviour
	{
		public GameObject model = null;
		public List<Material> mSkinMaterialList = null;
		public void Execute()
		{	
			for(int i = 0; i < mSkinMaterialList.Count; i++)
			{
				Material mSkin = mSkinMaterialList[i];
				GameObject obj = Instantiate(model);
				obj.name = mSkin.name;
				obj.SetActive(true);

				SkinnedMeshRenderer[] mSkinList = obj.GetComponentsInChildren<SkinnedMeshRenderer>();
				foreach(var v in mSkinList)
				{
					v.sharedMaterial = mSkin;
				}
			}
		}
	}
	
}
