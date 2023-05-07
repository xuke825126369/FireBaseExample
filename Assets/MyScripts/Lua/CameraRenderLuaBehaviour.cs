using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using XLua;
using System;

namespace GameLua 
{
	[LuaCallCSharp]
	public class CameraRenderLuaBehaviour : LuaBindMonoBehaviourGenericsBase<CameraRenderLuaBehaviour>
	{
		public Material _Material;
		public Action<RenderTexture, RenderTexture> renderImageAction;
		private void OnRenderImage(RenderTexture src, RenderTexture dest) {
			if (_Material != null)
			{
				if (renderImageAction != null)
					renderImageAction(src, dest);
			}
			else
			{
				Graphics.Blit(src, dest);
			}
		}
	}
}
