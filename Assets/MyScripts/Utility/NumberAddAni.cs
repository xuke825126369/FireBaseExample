using System;
using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

[XLua.LuaCallCSharp]
public class NumberAddAni : MonoBehaviour
{
    private Text mUGUIText;
    private TextMesh mTextMesh;
    private TextMeshPro mTextMeshPro;
    private TextMeshProUGUI mTextMeshProUGUI;

    private Int64 nTargetNumber = 0;
    private Int64 nAddNumber;
    private float fBeginUpdateTime;
    private float fDuringTime;
    private bool bUpdate = false;

    void Start()
    {
        mUGUIText = GetComponent<Text>();
        mTextMesh = GetComponent<TextMesh>();
        mTextMeshPro = GetComponent<TextMeshPro>();
        mTextMeshProUGUI = GetComponent<TextMeshProUGUI>();

        if (bUpdate)
        {
            Update();
        }
        else
        {
            End(nTargetNumber);
        }
    }

    private void UpdateText(string des = null)
    {
        if (mUGUIText)
        {
            mUGUIText.text = des;
        }
        else if (mTextMesh)
        {
            mTextMesh.text = des;
        }
        else if (mTextMeshPro)
        {
            mTextMeshPro.text = des;
        }
        else if (mTextMeshProUGUI)
        {
            mTextMeshProUGUI.text = des;
        }
    }

    private void FormatText(Int64 nNumber)
    {
        if (nNumber == 0)
        {
            UpdateText(string.Empty);
        }
        else
        {
            string strNumberFormat = nNumber.ToString("N0");
            UpdateText(strNumberFormat);
        }
    }

    public void End(Int64 nTarget)
    {
        nTargetNumber = nTarget;
        FormatText(nTargetNumber);
        bUpdate = false;
    }

    public void ChangeTo(Int64 nTarget, float fDuringTime = 2.0f)
    {
        End(this.nTargetNumber);
        if (nTarget > this.nTargetNumber && fDuringTime > Mathf.Epsilon)
        {
            nAddNumber = nTarget - this.nTargetNumber;

            this.nTargetNumber = nTarget;
            this.fBeginUpdateTime = Time.time;
            this.fDuringTime = fDuringTime;

            bUpdate = true;
        }
        else
        {
            this.nTargetNumber = nTarget;
            End(nTargetNumber);
        }
    }

    private void Update()
    {
        if (bUpdate)
        {
            float fTime = Time.time - fBeginUpdateTime;
            if (fTime <= fDuringTime && fDuringTime > Mathf.Epsilon)
            {
                float fPercent = 1.0f - fTime / fDuringTime;
                fPercent = Mathf.Clamp01(fPercent);
                Int64 fTargetNumber = (Int64)(nTargetNumber - fPercent * nAddNumber);
                FormatText(fTargetNumber);
            }
            else
            {
                End(nTargetNumber);
            }
        }
    }

}
