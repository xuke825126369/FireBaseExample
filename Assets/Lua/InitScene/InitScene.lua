require "Lua/CSharpApiToLua"
require "Lua/LogManager"
require "Lua/LuaAutoBindMonoBehaviour"
require "Lua/DelegateCache"
require "Lua/ViewScaleAni"
require "Lua/LuaHelper"
local cs_coroutine = (require 'cs_coroutine')

Debug.SetPrefix("InitScene")
Debug.SetOpen(true)

InitScene = {}
function InitScene:InitSceneLayout()
    local bundleName = "InitScene"
	local assetPath = "Assets/ResourceABs/InitScene/View/InitScene.prefab"
    local goPrefab = CS.AssetBundleManager.Instance:LoadAsset(bundleName, assetPath)
	local go = Unity.Object.Instantiate(goPrefab)

    self.transform = go.transform
    self.transform.localScale = Unity.Vector3.one
    self.transform.localPosition = Unity.Vector3.zero

    self.windowCanvas = self.transform:FindDeepChild("UIRoot/Canvas_Game").transform
    self.popCanvas = self.transform:FindDeepChild("UIRoot/Canvas_Pop").transform
end

function InitScene:Init()
    self:InitSceneLayout()

    self.mInitSceneHotUpdateManager = self.transform:GetComponent(typeof(CS.InitSceneHotUpdateManager))
    self.mInitSceneView = require "Lua/InitSceneView"
    self.mNetErrorView = require "Lua/NetErrorView"
    self.mUpdateNewVersionView = require "Lua/UpdateNewVersionView"

    self.mNetErrorView:Init()
    self.mInitSceneView:Init()
    self.mUpdateNewVersionView:Init()
    self.mInitSceneHotUpdateManager:Init()
    self:ReStartUpdate()
end

function InitScene:ReStartUpdate()
    CS.GlobalVariable.bInitSceneViewProgressFullShow = false
    self.mInitSceneView:Show(function()
        CS.GlobalVariable.bInitSceneViewProgressFullShow = true
    end)

    if GameConfig.Instance.orUseAssetBundle then
        if Unity.Application.internetReachability == Unity.NetworkReachability.NotReachable then
            self.mNetErrorView:Show("Oops, there's a problem with the network!")
            return
        end 

        cs_coroutine.start(function()
            coroutine.yield(self.mInitSceneHotUpdateManager:CheckUpdate())
        end)
    else
        self.mInitSceneView:SetUIProgress(1.0)
        self:OnLoadAllBundleFinish()
    end

end

function InitScene:OnCSharpVersionUpdate()
    self.mUpdateNewVersionView:Show()
end

function InitScene:OnNetErrorFunc(errorDes)
    Debug.LogError(errorDes)
    CS.GlobalVariable.bInitSceneViewProgressFullShow = false
    self.mNetErrorView:Show()
end

function InitScene:OnUpdateDownloadSizeInfo(nDownloadSize, nSumDownloadSize, nDownloadUpdateCount, nSumUpdateCount)
    if nSumDownloadSize > 0 then
        local sizeDes = CS.WebDownloadSizeHelper.GetDownLoadSizeStr(nDownloadSize).."/"..CS.WebDownloadSizeHelper.GetDownLoadSizeStr(nSumDownloadSize)
        local updateCountDes = nDownloadUpdateCount.."/"..nSumUpdateCount
        local tipDes = "<color=#FFFFFF><size=40>"..sizeDes.."</size></color>"
        self.mInitSceneView:SetTip(tipDes)
    else
        self.mInitSceneView:SetTip(nil)
    end
end

function InitScene:OnUpdateDownloadProgress(fProgress)
    self.mInitSceneView:SetUIProgress(fProgress)
end

function InitScene:OnLoadAllBundleFinish()
    cs_coroutine.start(function()
        Debug.Log("-------------------- 加载 MainEnv -----------------------")
        CS.LuaMainEnv.Instance:Init()
        while not CS.GlobalVariable.bMainSceneInitFinish do
            coroutine.yield(0)
        end
        self:Release()
    end)
end

function InitScene:Release()
    DelegateCache:dispose()
    Unity.Object.Destroy(self.transform.gameObject)
    
    local bundleName = "initscene"
    AssetBundleManager.Instance:UnLoadBundle(bundleName, true)
    Unity.Object.Destroy(CS.InitSceneLuaEnv.readOnlyInstance.gameObject)
end

InitScene:Init()

