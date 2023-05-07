/*
 * Tencent is pleased to support the open source community by making xLua available.
 * Copyright (C) 2016 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
*/

using System.Collections.Generic;
using System;
using UnityEngine;
using XLua;
using System.Linq;
using System.Reflection;
using UnityEngine.Events;
using System.Runtime.InteropServices;

//配置的详细介绍请看Doc下《XLua的配置.doc》
public static class LuaGenConfig1
{
    //lua中要使用到C#库的配置，比如C#标准库，或者Unity API，第三方库等。
    [LuaCallCSharp]
    public static List<Type> LuaCallCSharp = new List<Type>() {
        typeof(System.Object),
        typeof(UnityEngine.Object),
        typeof(Vector2),
        typeof(Vector3),
        typeof(Vector4),
        typeof(Quaternion),
        typeof(Color),
        typeof(Ray),
        typeof(Bounds),
        typeof(Ray2D),
        typeof(Time),
        typeof(GameObject),
        typeof(Component),
        typeof(Behaviour),
        typeof(Transform),
        typeof(Resources),
        typeof(TextAsset),
        typeof(Keyframe),
        typeof(AnimationCurve),
        typeof(AnimationClip),
        typeof(MonoBehaviour),
        typeof(ParticleSystem),
        typeof(ParticleSystemRenderer),
        typeof(SkinnedMeshRenderer),
        typeof(Renderer),
        typeof(UnityEngine.WWWForm),
        typeof(UnityEngine.Networking.UnityWebRequest),
        typeof(UnityEngine.Networking.UnityWebRequestAssetBundle),
        typeof(UnityEngine.Networking.UnityWebRequestTexture),
        typeof(UnityEngine.Networking.DownloadHandlerAssetBundle),
        typeof(UnityEngine.Networking.DownloadHandlerTexture),
        typeof(UnityEngine.Networking.DownloadHandlerFile),
        typeof(UnityEngine.Networking.DownloadHandlerAudioClip),
        typeof(UnityEngine.Networking.DownloadHandlerBuffer),
        typeof(System.Collections.Generic.List<int>),
        typeof(Action<string>),
        typeof(System.IO.File),
        typeof(System.IO.Directory),

        typeof(UnityEngine.Debug),
        typeof(UnityEngine.Application),
        typeof(UnityEngine.SystemLanguage),
        typeof(UnityEngine.MeshCollider),
        typeof(UnityEngine.MeshRenderer),
        typeof(UnityEngine.BoxCollider2D),
        typeof(UnityEngine.MeshFilter),
        typeof(UnityEngine.RaycastHit),
        typeof(UnityEngine.RaycastHit2D),
        typeof(UnityEngine.Physics2D),
        typeof(UnityEngine.Physics),
        typeof(UnityEngine.Ray),
        typeof(UnityEngine.Ray2D),
        typeof(UnityEngine.RectTransform),
        typeof(UnityEngine.RectTransformUtility),
        typeof(UnityEngine.Material),
        typeof(UnityEngine.Shader),
        typeof(UnityEngine.Camera),
        
        typeof(LeanTween),
        typeof(LTDescr),
        typeof(LeanTweenType),
        typeof(Action<float>),
        typeof(Action<bool>),
        typeof(DateTime),
        typeof(TimeSpan),

        typeof(UnityEngine.PlayerPrefs),
        typeof(UnityEngine.Caching),
        typeof(UnityEngine.EventSystems.EventSystem),
        typeof(UnityEngine.UI.Text),
        typeof(UnityEngine.UI.RawImage),
        typeof(UnityEngine.UI.Image),
        typeof(UnityEngine.UI.ScrollRect),
        typeof(UnityEngine.UI.Scrollbar),
        typeof(UnityEngine.UI.InputField),
        typeof(UnityEngine.UI.GridLayoutGroup),
        typeof(UnityEngine.TextMesh),
        typeof(UnityEngine.U2D.SpriteAtlas),
        typeof(UnityEngine.Animator),
        typeof(UnityEngine.Animation),
        typeof(UnityEngine.AudioSource),
        typeof(UnityEngine.AudioClip),
        typeof(UnityEngine.Screen),
        typeof(UnityEngine.SleepTimeout),
        typeof(UnityEngine.SceneManagement.SceneManager),
        typeof(UnityEngine.RenderTexture),
        typeof(UnityEngine.Video.VideoPlayer),
        typeof(UnityEngine.Video.VideoClip),

        typeof(UnityEngine.AssetBundle),
        typeof(UnityEngine.AssetBundleRequest),
        typeof(UnityEngine.AssetBundleCreateRequest),
        typeof(UnityEngine.Networking.UnityWebRequest),
        typeof(UnityEngine.NetworkReachability),

        typeof(Shapes2D.Shape),
        typeof(UnityEngine.U2D.SpriteShape),

        typeof(UnityEngine.Purchasing.ProductType),
        typeof(UnityEngine.Purchasing.StandardPurchasingModule),
        typeof(UnityEngine.Purchasing.ConfigurationBuilder),
        typeof(UnityEngine.Purchasing.UnityPurchasing),
        typeof(UnityEngine.Purchasing.Product),
        typeof(UnityEngine.Purchasing.IStoreController),

        typeof(TMPro.TMP_InputField),
        typeof(TMPro.TextMeshPro),
        typeof(TMPro.TextMeshProUGUI),

        typeof(IngameDebugConsole.ConsoleMethodAttribute),
        typeof(IngameDebugConsole.DebugLogConsole),
        typeof(IngameDebugConsole.DebugLogEntry),
        typeof(IngameDebugConsole.DebugLogItem),
        typeof(IngameDebugConsole.DebugLogManager),
        typeof(IngameDebugConsole.DebugLogPopup),
        typeof(IngameDebugConsole.DebugLogRecycledListView),
        typeof(IngameDebugConsole.DebugsOnScrollListener),

        typeof(UnityEngine.Animation),
        typeof(UnityEngine.Animator),
        typeof(UnityEngine.RuntimeAnimatorController),
        typeof(UnityEngine.AnimationClip),

        typeof(UnityEngine.GameObject),
        typeof(UnityEngine.Transform),
        typeof(UnityEngine.Quaternion),
        typeof(UnityEngine.Mathf),
        typeof(UnityEngine.Random),
        typeof(UnityEngine.Application),

        typeof(UnityEngine.SpriteRenderer),
        typeof(UnityEngine.Rendering.SortingGroup),
        typeof(UnityEngine.SpriteMask),
        typeof(UnityEngine.SpriteMaskInteraction),
        typeof(UnityEngine.LineRenderer),
        typeof(UnityEngine.TrailRenderer),

        typeof(Spine.Unity.SkeletonAnimation),
        typeof(Spine.Unity.SkeletonAnimator),
        typeof(Spine.Unity.SkeletonRenderer),
        typeof(Spine.TrackEntry)
    };

    //C#静态调用Lua的配置（包括事件的原型），仅可以配delegate，interface
    [CSharpCallLua]
    private static List<Type> cSharpCallLua = new List<Type>() {
        typeof(Action),
        typeof(Func<double, double, double>),
        typeof(Action<string>),
        typeof(Action<double>),
        typeof(Action<float>),
        typeof(Action<bool>),
        typeof(System.Action<int>),
        typeof(Action<ulong>),
        typeof(Action<DateTime>),
        typeof(System.Action<XLua.LuaTable, bool>),
        typeof(UnityEngine.Events.UnityAction),
        typeof(System.Collections.IEnumerator),

        typeof(UnityAction<UnityEngine.Vector2>),
        typeof(Action<LuaTable, double>),
        typeof(Action<LuaTable, float>),
        typeof(Action<LuaTable, string>),
        typeof(Action<LuaTable, int>),
        typeof(Action<LuaTable>),
        typeof(System.Func<XLua.LuaTable, bool>),

        typeof(System.Action<XLua.LuaTable, float>),
        typeof(System.Action<XLua.LuaTable, long, long, int, int>),
        typeof(Action<bool, long>),
        typeof(Action<byte[]>),
        typeof(Action<LuaTable>),
        typeof(Action<LuaTable, int, int>),
        typeof(Action<Firebase.Auth.FirebaseUser>),
        
        typeof(Action<LuaTable, UnityEngine.Purchasing.IStoreController, UnityEngine.Purchasing.IExtensionProvider>),
        typeof(Action<LuaTable, UnityEngine.Purchasing.InitializationFailureReason>),
        typeof(Action<LuaTable, UnityEngine.Purchasing.Product,  UnityEngine.Purchasing.PurchaseFailureReason>),
        typeof(Action<LuaTable, UnityEngine.Purchasing.PurchaseEventArgs>),
    };


    [BlackList]
    public static Func<MemberInfo, bool> MethodFilter = (memberInfo) =>
    {
        if (memberInfo.DeclaringType.IsGenericType && memberInfo.DeclaringType.GetGenericTypeDefinition() == typeof(Dictionary<,>))
        {
            if (memberInfo.MemberType == MemberTypes.Constructor)
            {
                ConstructorInfo constructorInfo = memberInfo as ConstructorInfo;
                var parameterInfos = constructorInfo.GetParameters();
                if (parameterInfos.Length > 0)
                {
                    if (typeof(System.Collections.IEnumerable).IsAssignableFrom(parameterInfos[0].ParameterType))
                    {
                        return true;
                    }
                }
            }
            else if (memberInfo.MemberType == MemberTypes.Method)
            {
                var methodInfo = memberInfo as MethodInfo;
                if (methodInfo.Name == "TryAdd" || methodInfo.Name == "Remove" && methodInfo.GetParameters().Length == 2)
                {
                    return true;
                }
            }
        }

        if (memberInfo.DeclaringType == typeof(UnityEngine.Caching))
        {
            if (memberInfo.MemberType == MemberTypes.Method)
            {
                var methodInfo = memberInfo as MethodInfo;
                if (methodInfo.Name == "SetNoBackupFlag" || methodInfo.Name == "ResetNoBackupFlag")
                {
                    return true;
                }
            }
        }

        if (memberInfo.DeclaringType == typeof(System.IO.File) || memberInfo.DeclaringType == typeof(System.IO.Directory))
        {
            if (memberInfo.MemberType == MemberTypes.Method)
            {
                var methodInfo = memberInfo as MethodInfo;
                var parameterInfos = methodInfo.GetParameters();
                foreach(var v in parameterInfos)
                {
                    if (typeof(System.Security.AccessControl.DirectorySecurity).IsAssignableFrom(v.ParameterType))
                    {
                        return true;
                    }

                    if (typeof(System.Security.AccessControl.FileSecurity).IsAssignableFrom(v.ParameterType))
                    {
                        return true;
                    }
                }

                if (methodInfo.Name == "GetAccessControl")
                {
                    return true;
                }
            }
        }
        
        //if (memberInfo.MemberType == MemberTypes.Method)
        //{
        //    var methodInfo = memberInfo as MethodInfo;
        //    foreach (ParameterInfo v in methodInfo.GetParameters())
        //    {
        //        if (v.ParameterType.IsGenericType && v.ParameterType.GetGenericTypeDefinition() == typeof(ReadOnlySpan<>))
        //        {
        //            return true;
        //        }
        //    }
        //}

        return false;
    };

    //黑名单
    [BlackList]
    public static List<List<string>> BlackList = new List<List<string>>()  {
                new List<string>(){"UnityEngine.WWW", "movie"},
    #if UNITY_WEBGL
                new List<string>(){"UnityEngine.WWW", "threadPriority"},
    #endif
                new List<string>(){"UnityEngine.Texture2D", "alphaIsTransparency"},
                new List<string>(){"UnityEngine.Security", "GetChainOfTrustValue"},
                new List<string>(){"UnityEngine.CanvasRenderer", "onRequestRebuild"},
                new List<string>(){"UnityEngine.Light", "areaSize"},
                new List<string>(){"UnityEngine.AnimatorOverrideController", "PerformOverrideClipListCleanup"},
    #if !UNITY_WEBPLAYER
                new List<string>(){"UnityEngine.Application", "ExternalEval"},
    #endif
                new List<string>(){"UnityEngine.GameObject", "networkView"}, //4.6.2 not support
                new List<string>(){"UnityEngine.Component", "networkView"},  //4.6.2 not support
                new List<string>(){"System.IO.FileInfo", "GetAccessControl", "System.Security.AccessControl.AccessControlSections"},
                new List<string>(){"System.IO.FileInfo", "SetAccessControl", "System.Security.AccessControl.FileSecurity"},
                new List<string>(){"System.IO.DirectoryInfo", "GetAccessControl", "System.Security.AccessControl.AccessControlSections"},
                new List<string>(){"System.IO.DirectoryInfo", "SetAccessControl", "System.Security.AccessControl.DirectorySecurity"},
                new List<string>(){"System.IO.DirectoryInfo", "CreateSubdirectory", "System.String", "System.Security.AccessControl.DirectorySecurity"},
                new List<string>(){"System.IO.DirectoryInfo", "Create", "System.Security.AccessControl.DirectorySecurity"},
                new List<string>(){"UnityEngine.MonoBehaviour", "runInEditMode"},

                // Custom
                new List<string>(){ "UnityEngine.Light", "SetLightDirty"},
                new List<string>(){ "UnityEngine.Light", "shadowRadius"},
                new List<string>(){ "UnityEngine.Light", "shadowAngle"},
                new List<string>(){ "UnityEngine.UI.Text", "OnRebuildRequested"},

                new List<string>(){ "UnityEngine.AudioSource", "DisableGamepadOutput"},
                new List<string>(){ "UnityEngine.AudioSource", "GamepadSpeakerSupportsOutputType", "UnityEngine.GamepadSpeakerOutputType"},
                new List<string>(){ "UnityEngine.AudioSource", "PlayOnGamepad", "System.Int32"},
                new List<string>(){ "UnityEngine.AudioSource", "SetGamepadSpeakerMixLevel", "System.Int32", "System.Int32"},
                new List<string>(){ "UnityEngine.AudioSource", "SetGamepadSpeakerMixLevelDefault",  "System.Int32"},
                new List<string>(){ "UnityEngine.AudioSource", "SetGamepadSpeakerRestrictedAudio",  "System.Int32",  "System.Boolean"},
                new List<string>(){ "UnityEngine.AudioSource", "gamepadSpeakerOutputType"},
                new List<string>(){ "UnityEngine", "GamepadSpeakerOutputType"},
                new List<string>(){ "UnityEngine.ParticleSystemRenderer", "supportsMeshInstancing"},
                new List<string>(){ "Spine.Unity.SkeletonRenderer", "EditorUpdateMeshFilterHideFlags"},
                new List<string>(){ "Spine.Unity.SkeletonRenderer", "Start"},
                new List<string>(){ "Spine.Unity.SkeletonRenderer", "EditorSkipSkinSync"},
                new List<string>(){ "Spine.Unity.SkeletonRenderer", "fixPrefabOverrideViaMeshFilter"},

                new List<string>(){ "UnityEngine.MeshRenderer", "scaleInLightmap"},
                new List<string>(){ "UnityEngine.MeshRenderer", "receiveGI"},
                new List<string>(){ "UnityEngine.MeshRenderer", "stitchLightmapSeams"},
            };
}
