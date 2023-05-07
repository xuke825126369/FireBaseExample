using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.U2D;
using UnityEngine.UI;

[XLua.LuaCallCSharp]
[ExecuteAlways]
public class UIFrameAnimation : MonoBehaviour
{
    public SpriteAtlas mSpriteAtlas = null;
    public float fPerFrameTime = 0.2f;
    public int nBeginIndex = 1;
    public int nEndIndex = 10;
    public string prefix = "_";
    public bool bLoop = true;

    private Image mImage;
    private float fCdTime = 0.0f;
    private int nFrameIndex = 0;

    private bool bInit = false;
    void Start()
    {
        Init();
    }

    private void Init()
    {
        if(bInit)
        {
            return;
        }
        bInit = true;
        mImage = GetComponent<Image>();
        nFrameIndex = nBeginIndex;
        fCdTime = 0.0f;
        mImage.sprite = mSpriteAtlas.GetSprite(prefix + nFrameIndex);
    }

    void Update()
    {
        if (!bLoop && nFrameIndex > nEndIndex)
        {
            return;
        }

        fCdTime += Time.deltaTime;
        if (fCdTime > fPerFrameTime)
        {
            fCdTime = 0f;
            mImage.sprite = mSpriteAtlas.GetSprite(prefix + nFrameIndex);

            if (bLoop)
            {
                if (nFrameIndex >= nEndIndex)
                {
                    nFrameIndex = nBeginIndex;
                }
                else
                {
                    nFrameIndex++;
                }
            }
            else
            {
                nFrameIndex++;
            }
        }
    }

    public void SwitchAnimation(SpriteAtlas mSpriteAtlas, string prefix, int nBeginIndex, int nEndIndex, bool bLoop)
    {
        this.mSpriteAtlas = mSpriteAtlas;
        this.prefix = prefix;
        this.nBeginIndex = nBeginIndex;
        this.nEndIndex = nEndIndex;
        this.bLoop = bLoop;
        
        nFrameIndex = nBeginIndex;
        fCdTime = 0.0f;

        Init();
        mImage.sprite = mSpriteAtlas.GetSprite(prefix + nFrameIndex);
    }
    
    public void SwitchAnimation(string prefix, int nBeginIndex, int nEndIndex, bool bLoop)
    {
        this.prefix = prefix;
        this.nBeginIndex = nBeginIndex;
        this.nEndIndex = nEndIndex;
        this.bLoop = bLoop;

        nFrameIndex = nBeginIndex;
        fCdTime = 0.0f;

        Init();
        mImage.sprite = mSpriteAtlas.GetSprite(prefix + nFrameIndex);
    }

    public void SwitchAnimation(int nBeginIndex, int nEndIndex, bool bLoop)
    {
        this.nBeginIndex = nBeginIndex;
        this.nEndIndex = nEndIndex;
        this.bLoop = bLoop;

        nFrameIndex = nBeginIndex;
        fCdTime = 0.0f;

        Init();
        mImage.sprite = mSpriteAtlas.GetSprite(prefix + nFrameIndex);
    }

}
