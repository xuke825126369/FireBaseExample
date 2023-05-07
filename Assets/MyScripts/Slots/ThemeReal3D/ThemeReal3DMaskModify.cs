using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ThemeReal3DMaskModify : MonoBehaviour
{
    public Transform _WorldPosMaskPosUp;
    public Transform _WorldPosMaskPosDown;

    public Material[] mOriMaterialList = null;

    public void ModifyMaterialInfo()
    {
        foreach(var v in mOriMaterialList)
        {
            Vector4 pos1 = new Vector4(_WorldPosMaskPosUp.position.x, _WorldPosMaskPosUp.position.y, _WorldPosMaskPosUp.position.z, 1.0f);
            Vector4 pos2 = new Vector4(_WorldPosMaskPosDown.position.x, _WorldPosMaskPosDown.position.y, _WorldPosMaskPosDown.position.z, 1.0f);
            v.SetVector("_WorldPosMaskPosUp", pos1);
            v.SetVector("_WorldPosMaskPosDown", pos2);
        }
    }
}
