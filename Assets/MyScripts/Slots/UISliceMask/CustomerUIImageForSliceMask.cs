﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.Rendering;

[ExecuteAlways]
[RequireComponent(typeof(Image))]
[DisallowMultipleComponent]
[XLua.LuaCallCSharp]
public class CustomerUIImageForSliceMask : BaseUISoftSliceMasked
{
	[SerializeField] private Material m_CommonMat;
	private Image mImage;

	private Material mMat = null;
	protected override void Start()
	{
		base.Start();
		mImage = GetComponent<Image>();
		if (m_CommonMat != null)
		{
			mMat = m_CommonMat;
		}
		else
		{
			mMat = new Material(ShaderAutoFind.Find("Customer/CustomerUIImageSliceMasked"));
		}

		UpdateMask();
		UpdateSelf();
		mImage.material = mMat;
	}

	void LateUpdate()
	{
		UpdateMask();
		UpdateSelf();
	}

	void UpdateSelf()
	{
		mMat.SetFloat("nSliceCount", nSliceCount);
		mMat.SetFloat("nTiledSliceCount", nTiledSliceCount);
		mMat.SetVectorArray("_SliceClipRect", _ClipRectList);
		mMat.SetVectorArray("_SliceAlphaMask_ST", uvScaleOffsetList);
		mMat.SetVectorArray("_TiledCount", _TiledCountList);
		mMat.SetTexture("_MyAlphaMask", m_mask.mainTexture);
	}

}
