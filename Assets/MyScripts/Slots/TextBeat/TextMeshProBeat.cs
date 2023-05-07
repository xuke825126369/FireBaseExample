﻿using UnityEngine;
using System.Collections;
using TMPro;
using System;
using System.Text;
using System.Collections.Generic;

// 此类 只提供了 文字的跳动，以及跳动的振幅和时间，并没有提供 文字跳动的频率。
namespace TextBeat
{
    [XLua.LuaCallCSharp]
    [RequireComponent(typeof(TextMeshPro))]
    public class TextMeshProBeat : MonoBehaviour
    {
        public float fAlphaTime = 0.4f;
        public float fAniHeight = 100;

        private TextMeshProMeshInfo lastInput = new TextMeshProMeshInfo();
        private TextMeshProMeshInfo Input = new TextMeshProMeshInfo();

        private TextMeshProMeshInfo mWillFillInput = new TextMeshProMeshInfo();
        private List<float> mWorldAniBeginTimeList = new List<float>();
        private List<bool> mWorldisPlayingAniList = new List<bool>();

        private List<int> mVisibleCharacterList1 = new List<int>();
        private List<int> mVisibleCharacterList2 = new List<int>();
        
        private TMP_Text mText;
        private const int oneSize = 4;
        
        void Awake()
        {
            mText = GetComponent<TMP_Text>();
        }

        void OnEnable()
        {
            TMPro_EventManager.TEXT_CHANGED_EVENT.Add(ON_TEXT_CHANGED);
        }

        void OnDisable()
        {
            TMPro_EventManager.TEXT_CHANGED_EVENT.Remove(ON_TEXT_CHANGED);
        }

        private void OnDestroy()
        {
            mWillFillInput.Clear();
            Input.Clear();
            lastInput.Clear();
        }

        void Start()
        {
            mText.ForceMeshUpdate();
            Debug.Assert(mText.textInfo.materialCount == 1, "不支持 多材质");
        }

        private int GetCharacterCount()
        {
            return mText.textInfo.characterCount;
        }

        private bool orOneWoldFinishAni(int index)
        {
            return Time.time - mWorldAniBeginTimeList[index] > fAlphaTime;
        }

        private void AddVertexInfo(int materialIndex, Vector3 pos, Color32 color, Vector2 uv0, Vector2 uv1, Vector3 normal, Vector4 tangent)
        {
            int nIndex = mText.textInfo.meshInfo[materialIndex].vertexCount;

            mText.textInfo.meshInfo[materialIndex].vertices[nIndex] = pos;
            mText.textInfo.meshInfo[materialIndex].colors32[nIndex] = color;
            mText.textInfo.meshInfo[materialIndex].uvs0[nIndex] = uv0;
            mText.textInfo.meshInfo[materialIndex].uvs2[nIndex] = uv1;
            mText.textInfo.meshInfo[materialIndex].normals[nIndex] = normal;
            mText.textInfo.meshInfo[materialIndex].tangents[nIndex] = tangent;

            mText.textInfo.meshInfo[materialIndex].vertexCount = nIndex + 1;
        }

        private void Init()
        {
            InitTextMeshProMeshInfo(lastInput);
            InitTextMeshProMeshInfo(Input);
            InitTextMeshProMeshInfo(mWillFillInput);
        }

        private void ClearOutputMeshInfoList()
        {
            for (int i = 0; i < mText.textInfo.materialCount; i++)
            {
                mText.textInfo.meshInfo[i].vertexCount = 0;
            }
        }

        private void ReSizeWorldAniBeginTimeList(TextMeshProMeshInfo Input, TextMeshProMeshInfo lastInput)
        {
            int nMaxLength = Mathf.Max(Input.mListCharacterInfo.Count, lastInput.mListCharacterInfo.Count);
            for (int i = mWorldAniBeginTimeList.Count; i < nMaxLength; i++)
            {
                mWorldAniBeginTimeList.Add(-fAlphaTime - 1.0f);
                mWorldisPlayingAniList.Add(false);
            }
        }

        private void InitTextMeshProMeshInfo(TextMeshProMeshInfo mOutInfo)
        {
            if (mOutInfo.mListMeshInfo.Count == 0)
            {
                mOutInfo.Clear();

                for (int i = 0; i < mText.textInfo.materialCount; i++)
                {
                    TextMeshProMeshInfo.MeshInfo mMeshInfo = ObjectPool<TextMeshProMeshInfo.MeshInfo>.Pop();
                    mOutInfo.mListMeshInfo.Add(mMeshInfo);
                }
            }
        }

        private void ForceChangeLastInputOffsetXMeshInfo()
        {   
            for (int k = 0; k < mText.textInfo.materialCount; k++)
            {
                if (lastInput.mListMeshInfo[k].vertices.Count > 0 && Input.mListMeshInfo[k].vertices.Count > 0)
                {
                    float fOffsetX = Input.mListMeshInfo[k].vertices[0].x - lastInput.mListMeshInfo[k].vertices[0].x;

                    List<Vector3> vertices = lastInput.mListMeshInfo[k].vertices;
                    for (int i = 0; i < vertices.Count; i++)
                    {
                        Vector3 oriPos = vertices[i];
                        vertices[i] = oriPos + new Vector3(fOffsetX, 0, 0);
                    }
                }
            }
        }

        private void ResetVisibleCharacterList()
        {
            if (mVisibleCharacterList1.Count < mText.textInfo.materialCount || mVisibleCharacterList2.Count < mText.textInfo.materialCount)
            {
                mVisibleCharacterList1.Clear();
                mVisibleCharacterList2.Clear();

                for (int i = 0; i < mText.textInfo.materialCount; i++)
                {
                    mVisibleCharacterList1.Add(0);
                    mVisibleCharacterList2.Add(0);
                }
            }
            else
            {
                for (int i = 0; i < mText.textInfo.materialCount; i++)
                {
                    mVisibleCharacterList1[i] = 0;
                    mVisibleCharacterList2[i] = 0;
                }
            }
        }

        private void FillInput()
        {
            ResetVisibleCharacterList();
            List<int> nWillInputVisibleIndex = mVisibleCharacterList1;
            List<int> nInputVisibleIndex = mVisibleCharacterList2;
            
            ReSizeWorldAniBeginTimeList(mWillFillInput, Input);

            bool bInputCountEqual = mWillFillInput.mListCharacterInfo.Count == Input.mListCharacterInfo.Count;
            bool bForceChangeOffsetXMeshInfo = false;
            if (!bInputCountEqual)
            {
                if (TextBeatUtility.GetAlign(mText.alignment) == TextBeatAlign.Left)
                {
                    bForceChangeOffsetXMeshInfo = false;
                }
                else if (TextBeatUtility.GetAlign(mText.alignment) == TextBeatAlign.Right)
                {
                    bForceChangeOffsetXMeshInfo = true;
                }
                else if (TextBeatUtility.GetAlign(mText.alignment) == TextBeatAlign.Center)
                {
                    bForceChangeOffsetXMeshInfo = true; // 顶点位置 都改变了
                }
            }

            if (bForceChangeOffsetXMeshInfo)
            {
                for (int i = 0; i < Input.mListCharacterInfo.Count; i++)
                {
                    if (!orOneWoldFinishAni(i))
                    {
                        return;
                    }
                }
            }

            // 填充Input
            for (int i = 0; i < mWillFillInput.mListCharacterInfo.Count; i++)
            {
                if (orOneWoldFinishAni(i))
                {
                    bool bChanged = false;
                    if (i < Input.mListCharacterInfo.Count)
                    {
                        bChanged = mWillFillInput.mListCharacterInfo[i].character != Input.mListCharacterInfo[i].character;
                    }
                    else
                    {
                        bChanged = true;
                    }

                    if (bForceChangeOffsetXMeshInfo)
                    {
                        bChanged = true;
                    }

                    if (bChanged)
                    {
                        int WillmaterialIndex = mWillFillInput.mListCharacterInfo[i].materialReferenceIndex;
                        if (i < Input.mListCharacterInfo.Count)
                        {
                            int materialIndex = Input.mListCharacterInfo[i].materialReferenceIndex;

                            int nBeginIndex = nInputVisibleIndex[materialIndex] * oneSize;
                            int nOtherBeginIndex = nWillInputVisibleIndex[WillmaterialIndex] * oneSize;
                            if (Input.mListCharacterInfo[i].isVisible && mWillFillInput.mListCharacterInfo[i].isVisible)
                            {
                                Input.mListMeshInfo[materialIndex].ReplaceQuad(nBeginIndex, mWillFillInput.mListMeshInfo[WillmaterialIndex], nOtherBeginIndex);
                            }
                            else
                            {
                                if (Input.mListCharacterInfo[i].isVisible)
                                {
                                    Input.mListMeshInfo[materialIndex].RemoveQuadAt(nBeginIndex);
                                }
                                else if (mWillFillInput.mListCharacterInfo[i].isVisible)
                                {
                                    Input.mListMeshInfo[materialIndex].AddQuad(mWillFillInput.mListMeshInfo[WillmaterialIndex], nOtherBeginIndex);
                                }
                            }

                            Input.mListCharacterInfo[i].ReplaceCharacter(mWillFillInput.mListCharacterInfo[i]);
                        }
                        else
                        {
                            if (mWillFillInput.mListCharacterInfo[i].isVisible)
                            {
                                int nOtherBeginIndex = nWillInputVisibleIndex[WillmaterialIndex] * oneSize;
                                Input.mListMeshInfo[WillmaterialIndex].AddQuad(mWillFillInput.mListMeshInfo[WillmaterialIndex], nOtherBeginIndex);
                            }

                            TextMeshProMeshInfo.CharacterInfo characterInfo = ObjectPool<TextMeshProMeshInfo.CharacterInfo>.Pop();
                            characterInfo.ReplaceCharacter(mWillFillInput.mListCharacterInfo[i]);
                            Input.mListCharacterInfo.Add(characterInfo);
                        }
                    }
                }

                if (mWillFillInput.mListCharacterInfo[i].isVisible)
                {
                    int WillmaterialIndex = mWillFillInput.mListCharacterInfo[i].materialReferenceIndex;
                    nWillInputVisibleIndex[WillmaterialIndex]++;
                }

                if (i < Input.mListCharacterInfo.Count && Input.mListCharacterInfo[i].isVisible)
                {
                    int materialIndex = Input.mListCharacterInfo[i].materialReferenceIndex;
                    nInputVisibleIndex[materialIndex]++;
                }
            }

            for (int i = mWillFillInput.mListCharacterInfo.Count; i < Input.mListCharacterInfo.Count; i++)
            {
                if (Input.mListCharacterInfo[i].isVisible)
                {
                    int materialIndex = Input.mListCharacterInfo[i].materialReferenceIndex;
                    nInputVisibleIndex[materialIndex]++;
                }
            }

            for (int i = Input.mListCharacterInfo.Count - 1; i >= mWillFillInput.mListCharacterInfo.Count; i--)
            {
                int materialIndex = Input.mListCharacterInfo[i].materialReferenceIndex;
                if (orOneWoldFinishAni(i))
                {
                    if (Input.mListCharacterInfo[i].isVisible)
                    {
                        nInputVisibleIndex[materialIndex]--;
                        int nBeginIndex = nInputVisibleIndex[materialIndex] * oneSize;
                        Input.mListMeshInfo[materialIndex].RemoveQuadAt(nBeginIndex);
                    }

                    Input.RemoveCharacter(i);
                }
            }
            
            if (bForceChangeOffsetXMeshInfo)
            {
                ForceChangeLastInputOffsetXMeshInfo();
            }
        }

        private void FillLastInput()
        {
            ReSizeWorldAniBeginTimeList(lastInput, Input);

            ResetVisibleCharacterList();
            List<int> nLastVisibleIndex = mVisibleCharacterList1;
            List<int> nNowVisibleIndex = mVisibleCharacterList2;

            for (int i = 0; i < Input.mListCharacterInfo.Count; i++)
            {
                if (orOneWoldFinishAni(i) && mWorldisPlayingAniList[i])
                {
                    int materialIndex = Input.mListCharacterInfo[i].materialReferenceIndex;

                    if (i < lastInput.mListCharacterInfo.Count)
                    {
                        int LastMaterialIndex = lastInput.mListCharacterInfo[i].materialReferenceIndex;

                        int nBeginIndex = nLastVisibleIndex[LastMaterialIndex] * oneSize;
                        int nOtherBeginIndex = nNowVisibleIndex[materialIndex] * oneSize;
                        if (lastInput.mListCharacterInfo[i].isVisible && Input.mListCharacterInfo[i].isVisible)
                        {
                            lastInput.mListMeshInfo[LastMaterialIndex].ReplaceQuad(nBeginIndex, Input.mListMeshInfo[materialIndex], nOtherBeginIndex);
                        }
                        else
                        {
                            if (lastInput.mListCharacterInfo[i].isVisible)
                            {
                                lastInput.mListMeshInfo[LastMaterialIndex].RemoveQuadAt(nBeginIndex);
                            }
                            else if (Input.mListCharacterInfo[i].isVisible)
                            {
                                lastInput.mListMeshInfo[LastMaterialIndex].AddQuad(Input.mListMeshInfo[materialIndex], nOtherBeginIndex);
                            }
                        }

                        lastInput.mListCharacterInfo[i].ReplaceCharacter(Input.mListCharacterInfo[i]);
                    }
                    else
                    {
                        if (Input.mListCharacterInfo[i].isVisible)
                        {
                            int nOtherBeginIndex = nNowVisibleIndex[materialIndex] * oneSize;
                            lastInput.mListMeshInfo[materialIndex].AddQuad(Input.mListMeshInfo[materialIndex], nOtherBeginIndex);
                        }

                        TextMeshProMeshInfo.CharacterInfo characterInfo = ObjectPool<TextMeshProMeshInfo.CharacterInfo>.Pop();
                        characterInfo.ReplaceCharacter(Input.mListCharacterInfo[i]);
                        lastInput.mListCharacterInfo.Add(characterInfo);
                    }
                }

                if (Input.mListCharacterInfo[i].isVisible)
                {
                    int materialIndex = Input.mListCharacterInfo[i].materialReferenceIndex;
                    nNowVisibleIndex[materialIndex]++;
                }

                if (i < lastInput.mListCharacterInfo.Count && lastInput.mListCharacterInfo[i].isVisible)
                {
                    int LastMaterialIndex = lastInput.mListCharacterInfo[i].materialReferenceIndex;
                    nLastVisibleIndex[LastMaterialIndex]++;
                }
            }

            for (int i = Input.mListCharacterInfo.Count; i < lastInput.mListCharacterInfo.Count; i++)
            {
                if (lastInput.mListCharacterInfo[i].isVisible)
                {
                    int LastMaterialIndex = lastInput.mListCharacterInfo[i].materialReferenceIndex;
                    nLastVisibleIndex[LastMaterialIndex]++;
                }
            }

            for (int i = lastInput.mListCharacterInfo.Count - 1; i >= Input.mListCharacterInfo.Count; i--)
            {
                int materialIndex = lastInput.mListCharacterInfo[i].materialReferenceIndex;
                if (orOneWoldFinishAni(i) && mWorldisPlayingAniList[i])
                {
                    if (lastInput.mListCharacterInfo[i].isVisible)
                    {
                        nLastVisibleIndex[materialIndex]--;
                        int nBeginIndex = nLastVisibleIndex[materialIndex] * oneSize;
                        lastInput.mListMeshInfo[materialIndex].RemoveQuadAt(nBeginIndex);
                    }

                    lastInput.RemoveCharacter(i);
                }
            }

        }

        private void PlayAni()
        {
            ClearOutputMeshInfoList();

            FillLastInput();
            FillInput();
            
            for(int i = 0; i < mWorldisPlayingAniList.Count; i++)
            {
                if (orOneWoldFinishAni(i) && mWorldisPlayingAniList[i])
                {
                    mWorldisPlayingAniList[i] = false;
                }
            }

            ResetVisibleCharacterList();
            List<int> nLastVisibleIndex = mVisibleCharacterList1;
            List<int> nNowVisibleIndex = mVisibleCharacterList2;

            ReSizeWorldAniBeginTimeList(Input, lastInput);

            for (int i = 0; i < Input.mListCharacterInfo.Count; i++)
            {
                int materialIndex = Input.mListCharacterInfo[i].materialReferenceIndex;
                if (orOneWoldFinishAni(i) && !mWorldisPlayingAniList[i])
                {
                    bool bChanged = false;
                    if (i < lastInput.mListCharacterInfo.Count)
                    {
                        bChanged = lastInput.mListCharacterInfo[i].character != Input.mListCharacterInfo[i].character;
                    }
                    else
                    {
                        bChanged = true;
                    }

                    if (!Input.mListCharacterInfo[i].isVisible)
                    {
                        bChanged = false;
                    }

                    if (bChanged)
                    {
                        mWorldisPlayingAniList[i] = true;
                        mWorldAniBeginTimeList[i] = Time.time;
                    }
                }

                if (!orOneWoldFinishAni(i))
                {
                    float fTimePercent = Mathf.Clamp01((Time.time - mWorldAniBeginTimeList[i]) / fAlphaTime);

                    if (i < lastInput.mListCharacterInfo.Count && lastInput.mListCharacterInfo[i].isVisible)
                    {
                        int LastMaterialIndex = lastInput.mListCharacterInfo[i].materialReferenceIndex;
                        for (int j = 0; j < oneSize; j++)
                        {
                            int nOirIndex = nLastVisibleIndex[LastMaterialIndex] * oneSize + j;
                            Vector3 oriPos = lastInput.mListMeshInfo[LastMaterialIndex].vertices[nOirIndex];
                            Color32 oriColor32 = lastInput.mListMeshInfo[LastMaterialIndex].colors32[nOirIndex];
                            Vector2 uv0 = lastInput.mListMeshInfo[LastMaterialIndex].uvs0[nOirIndex];
                            Vector2 uv2 = lastInput.mListMeshInfo[LastMaterialIndex].uvs2[nOirIndex];
                            Vector3 normal = lastInput.mListMeshInfo[LastMaterialIndex].normals[nOirIndex];
                            Vector4 tangent = lastInput.mListMeshInfo[LastMaterialIndex].tangents[nOirIndex];

                            float fScaleY = lastInput.mListMeshInfo[LastMaterialIndex].uvs2ScaleY[nOirIndex];

                            Vector3 targetPos = new Vector3(oriPos.x, oriPos.y + fTimePercent * fAniHeight, oriPos.z);
                            Color32 targetColor32 = new Color32(oriColor32.r, oriColor32.g, oriColor32.b, (byte)((1 - fTimePercent) * 255));

                            GetUV2(ref uv2, ref fScaleY);
                            AddVertexInfo(LastMaterialIndex, targetPos, targetColor32, uv0, uv2, normal, tangent);
                        }
                    }

                    if (Input.mListCharacterInfo[i].isVisible)
                    {
                        for (int j = 0; j < oneSize; j++)
                        {
                            int nOirIndex = nNowVisibleIndex[materialIndex] * oneSize + j;
                            Vector3 oriPos = Input.mListMeshInfo[materialIndex].vertices[nOirIndex];
                            Color32 oriColor32 = Input.mListMeshInfo[materialIndex].colors32[nOirIndex];
                            Vector2 uv0 = Input.mListMeshInfo[materialIndex].uvs0[nOirIndex];
                            Vector2 uv2 = Input.mListMeshInfo[materialIndex].uvs2[nOirIndex];
                            Vector3 normal = Input.mListMeshInfo[materialIndex].normals[nOirIndex];
                            Vector4 tangent = Input.mListMeshInfo[materialIndex].tangents[nOirIndex];
                            float fScaleY = Input.mListMeshInfo[materialIndex].uvs2ScaleY[nOirIndex];

                            Vector3 targetPos = new Vector3(oriPos.x, oriPos.y - (1 - fTimePercent) * fAniHeight, oriPos.z);
                            Color32 targetColor32 = new Color32(oriColor32.r, oriColor32.g, oriColor32.b, (byte)(fTimePercent * 255));
                            
                            GetUV2(ref uv2, ref fScaleY);
                            AddVertexInfo(materialIndex, targetPos, targetColor32, uv0, uv2, normal, tangent);
                        };


                    }
                }
                else
                {
                    if (Input.mListCharacterInfo[i].isVisible)
                    {
                        for (int j = 0; j < oneSize; j++)
                        {
                            int nOirIndex = nNowVisibleIndex[materialIndex] * oneSize + j;
                            Vector3 oriPos = Input.mListMeshInfo[materialIndex].vertices[nOirIndex];
                            Color32 oriColor32 = Input.mListMeshInfo[materialIndex].colors32[nOirIndex];
                            Vector2 uv0 = Input.mListMeshInfo[materialIndex].uvs0[nOirIndex];
                            Vector2 uv2 = Input.mListMeshInfo[materialIndex].uvs2[nOirIndex];
                            Vector3 normal = Input.mListMeshInfo[materialIndex].normals[nOirIndex];
                            Vector4 tangent = Input.mListMeshInfo[materialIndex].tangents[nOirIndex];
                            float fScaleY = Input.mListMeshInfo[materialIndex].uvs2ScaleY[nOirIndex];

                            GetUV2(ref uv2, ref fScaleY);
                            AddVertexInfo(materialIndex, oriPos, oriColor32, uv0, uv2, normal, tangent);
                        };
                    }
                }

                if (Input.mListCharacterInfo[i].isVisible)
                {
                    nNowVisibleIndex[materialIndex]++;
                }

                if (i < lastInput.mListCharacterInfo.Count && lastInput.mListCharacterInfo[i].isVisible)
                {
                    int LastMaterialIndex = lastInput.mListCharacterInfo[i].materialReferenceIndex;
                    nLastVisibleIndex[LastMaterialIndex]++;
                }

            }

            for (int i = Input.mListCharacterInfo.Count; i < lastInput.mListCharacterInfo.Count; i++)
            {
                int LastMaterialIndex = lastInput.mListCharacterInfo[i].materialReferenceIndex;

                if (orOneWoldFinishAni(i) && !mWorldisPlayingAniList[i])
                {
                    bool bChanged = true;
                    if (!lastInput.mListCharacterInfo[i].isVisible)
                    {
                        bChanged = false;
                    }

                    if (bChanged)
                    {
                        mWorldAniBeginTimeList[i] = Time.time;
                        mWorldisPlayingAniList[i] = true;
                    }
                }

                if (!orOneWoldFinishAni(i))
                {
                    float fTimePercent = Mathf.Clamp01((Time.time - mWorldAniBeginTimeList[i]) / fAlphaTime);
                    for (int j = 0; j < oneSize; j++)
                    {
                        int nOirIndex = nLastVisibleIndex[LastMaterialIndex] * oneSize + j;
                        Vector3 oriPos = lastInput.mListMeshInfo[LastMaterialIndex].vertices[nOirIndex];
                        Color32 oriColor32 = lastInput.mListMeshInfo[LastMaterialIndex].colors32[nOirIndex];
                        Vector2 uv0 = lastInput.mListMeshInfo[LastMaterialIndex].uvs0[nOirIndex];
                        Vector2 uv2 = lastInput.mListMeshInfo[LastMaterialIndex].uvs2[nOirIndex];
                        Vector3 normal = lastInput.mListMeshInfo[LastMaterialIndex].normals[nOirIndex];
                        Vector4 tangent = lastInput.mListMeshInfo[LastMaterialIndex].tangents[nOirIndex];
                        float fScaleY = lastInput.mListMeshInfo[LastMaterialIndex].uvs2ScaleY[nOirIndex];

                        Vector3 targetPos = new Vector3(oriPos.x, oriPos.y + fTimePercent * fAniHeight, oriPos.z);
                        Color32 targetColor32 = new Color32(oriColor32.r, oriColor32.g, oriColor32.b, (byte)((1 - fTimePercent) * 255));
                        GetUV2(ref uv2, ref fScaleY);
                        AddVertexInfo(LastMaterialIndex, targetPos, targetColor32, uv0, uv2, normal, tangent);
                    }
                }

                if (lastInput.mListCharacterInfo[i].isVisible)
                {
                    nLastVisibleIndex[LastMaterialIndex]++;
                }

            }
            
            UpdateMesh();
        }
        
        void UpdateMesh()
        {
            for (int i = 0; i < mText.textInfo.materialCount; i++)
            {
                mText.textInfo.meshInfo[i].ClearUnusedVertices();
                mText.textInfo.meshInfo[i].mesh.vertices = mText.textInfo.meshInfo[i].vertices;
                mText.textInfo.meshInfo[i].mesh.uv = mText.textInfo.meshInfo[i].uvs0;
                mText.textInfo.meshInfo[i].mesh.uv2 = mText.textInfo.meshInfo[i].uvs2;
                mText.textInfo.meshInfo[i].mesh.colors32 = mText.textInfo.meshInfo[i].colors32;
                mText.textInfo.meshInfo[i].mesh.normals = mText.textInfo.meshInfo[i].normals;
                mText.textInfo.meshInfo[i].mesh.tangents = mText.textInfo.meshInfo[i].tangents;
                mText.textInfo.meshInfo[i].mesh.RecalculateBounds();
            }
        }

        void ON_TEXT_CHANGED(UnityEngine.Object obj)
        {
            if (obj == mText)
            {
                Init();
                UpdateMaxMeshSize();
                TextBeatUtility.CopyTo(mWillFillInput, mText.textInfo);
                InitUV2ScaleY(mWillFillInput);
                BuildAni();
            }
        }

        private void OnWillRenderObject()
        {
            BuildAni();
        }

        void BuildAni()
        {
           PlayAni();
        }

        void UpdateMaxMeshSize()
        {
            // 因为一直报错: Mesh.vertices is too small. The supplied vertex array has less vertices than are referenced by the triangles array.
            // 所以 初始化的时候就把尺寸调到最大
            int nMaxStringBuilerCapacity = GetCharacterCount() * 2;
            for (int i = 0; i < mText.textInfo.materialCount; i++)
            {
                if (mText.textInfo.meshInfo[i].vertices.Length / 4 < nMaxStringBuilerCapacity)
                {
                    mText.textInfo.meshInfo[i].ResizeMeshInfo(nMaxStringBuilerCapacity);

                    mText.textInfo.meshInfo[i].mesh.uv = mText.textInfo.meshInfo[i].uvs0;
                    mText.textInfo.meshInfo[i].mesh.uv2 = mText.textInfo.meshInfo[i].uvs2;
                    mText.textInfo.meshInfo[i].mesh.colors32 = mText.textInfo.meshInfo[i].colors32;
                }
            }
        }

        void GetUV2(ref Vector2 uv2, ref float fScale)
        {
            float fNowScaleY = transform.lossyScale.y;
            float scaleDelta = fNowScaleY / fScale;
            if (scaleDelta == 0 || scaleDelta == float.PositiveInfinity)
            {
                return;
            }

            Vector2 oriUV2 = uv2;
            float modifyY = oriUV2.y * Mathf.Abs(scaleDelta);
            uv2 = new Vector2(oriUV2.x, modifyY);
            fScale = fNowScaleY;
        }

        void InitUV2ScaleY(TextMeshProMeshInfo meshInfo)
        {
            for (int materialIndex = 0; materialIndex < mText.textInfo.materialCount; materialIndex++)
            {
                meshInfo.mListMeshInfo[materialIndex].uvs2ScaleY.Clear();
                for (int i = 0; i < meshInfo.mListMeshInfo[materialIndex].uvs2.Count; i++)
                {
                    meshInfo.mListMeshInfo[materialIndex].uvs2ScaleY.Add(transform.lossyScale.y);
                }
            }
        }

    }
}