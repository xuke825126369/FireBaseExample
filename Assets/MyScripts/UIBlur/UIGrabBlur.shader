﻿// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

Shader "Customer/UIGrabBlur"
{
    Properties
    {
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
        _Color ("Tint", Color) = (1,1,1,1)
        
        _StencilComp ("Stencil Comparison", Float) = 8
        _Stencil ("Stencil ID", Float) = 0
        _StencilOp ("Stencil Operation", Float) = 0
        _StencilWriteMask ("Stencil Write Mask", Float) = 255
        _StencilReadMask ("Stencil Read Mask", Float) = 255
        
        _ColorMask ("Color Mask", Float) = 15
        
        [Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip ("Use Alpha Clip", Float) = 0
        
		_BlurSizeX("Blure SizeX", Float) = 1.0
        _BlurSizeY("Blure SizeY", Float) = 1.0
    }

    SubShader
    {
        Tags
        {
            "Queue"="Transparent"
            "IgnoreProjector"="True"
            "RenderType"="Transparent"
            "PreviewType"="Plane"
            "CanUseSpriteAtlas"="True"
        }

        Stencil
        {
            Ref [_Stencil]
            Comp [_StencilComp]
            Pass [_StencilOp]
            ReadMask [_StencilReadMask]
            WriteMask [_StencilWriteMask]
        }

        Cull Off
        Lighting Off
        ZWrite Off
        ZTest [unity_GUIZTestMode]
        Blend One OneMinusSrcAlpha
        ColorMask [_ColorMask]
        
        GrabPass {}
        
        Pass
        {
            Name "Default"
        CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0

            #include "UnityCG.cginc"
            #include "UnityUI.cginc"

            #pragma multi_compile_local _ UNITY_UI_CLIP_RECT
            #pragma multi_compile_local _ UNITY_UI_ALPHACLIP

            struct appdata_t
            {
                float4 vertex   : POSITION;
                float4 color    : COLOR;
                float2 texcoord : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 vertex   : SV_POSITION;
                fixed4 color    : COLOR;
                float2 texcoord  : TEXCOORD0;
                float4 worldPosition : TEXCOORD1;
                float4  mask : TEXCOORD2;
                float4 grabPassPosition : TEXCOORD3;
                UNITY_VERTEX_OUTPUT_STEREO
            };

			float _BlurSizeX;
			float _BlurSizeY;
            // 通过 GrabPass 自动赋值的变量
            sampler2D _GrabTexture;
            float4 _GrabTexture_TexelSize;
            
            sampler2D _MainTex;
            fixed4 _Color;
            fixed4 _TextureSampleAdd;
            float4 _ClipRect;
            float4 _MainTex_ST;
            float _UIMaskSoftnessX;
            float _UIMaskSoftnessY;
            
            v2f vert(appdata_t v)
            {
                v2f OUT;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
                float4 vPosition = UnityObjectToClipPos(v.vertex);
                OUT.worldPosition = v.vertex;
                OUT.vertex = vPosition;

                float2 pixelSize = vPosition.w;
                pixelSize /= float2(1, 1) * abs(mul((float2x2)UNITY_MATRIX_P, _ScreenParams.xy));

                float4 clampedRect = clamp(_ClipRect, -2e10, 2e10);
                float2 maskUV = (v.vertex.xy - clampedRect.xy) / (clampedRect.zw - clampedRect.xy);
                OUT.texcoord = TRANSFORM_TEX(v.texcoord.xy, _MainTex);
                OUT.mask = float4(v.vertex.xy * 2 - clampedRect.xy - clampedRect.zw, 0.25 / (0.25 * half2(_UIMaskSoftnessX, _UIMaskSoftnessY) + abs(pixelSize.xy)));

                OUT.color = v.color * _Color;
                
                OUT.grabPassPosition = ComputeGrabScreenPos(OUT.vertex);
                return OUT;
            }
            
            float4 GRABPIXEL(float4 grabPassPosition, int i, int j)
            {
                float4 grabPosUV = UNITY_PROJ_COORD(grabPassPosition); 
                grabPosUV.xy /= grabPosUV.w;
                return tex2D(_GrabTexture, float2(grabPosUV.x + _GrabTexture_TexelSize.x * i * _BlurSizeX, grabPosUV.y + _GrabTexture_TexelSize.y * j * _BlurSizeY));
            }
            
            float4 frag(v2f IN) : COLOR
            {
                const float weightArray[3][3] = {
                    0.0947416, 0.118318, 0.0947416,
                    0.118318, 0.147761, 0.118318,
                    0.0947416, 0.118318, 0.0947416
                };
                
                float4 averageColor = float4(0, 0, 0, 0);
                for(int i = 0; i <= 2; i++)
                {
                    for(int j = 0; j <= 2; j++)
                    {
                        float4 color = GRABPIXEL(IN.grabPassPosition, i - 1, j - 1);
                        averageColor += color * weightArray[i][j];
                    }
                }
                
                averageColor.rgb *= averageColor.a;
                return averageColor;
            }
        ENDCG
        }
    }
}
