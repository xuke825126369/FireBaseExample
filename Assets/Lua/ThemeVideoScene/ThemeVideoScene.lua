require("Lua/ThemeVideoScene/CommonVideoSlot/VideoSlotMain")
ThemeVideoScene = {}

function ThemeVideoScene:LoadCameraParam()
    Unity.Camera.main.orthographic = true;
    Unity.Camera.main.orthographicSize = 600
    Unity.Camera.main.nearClipPlane = -2000
    Unity.Camera.main.farClipPlane = 2000
end

function ThemeVideoScene:InitSceneLayout()
    local bundleName = "ThemeVideoCommon"
	local assetPath = "Assets/ResourceABs/ThemeVideoCommon/Prefabs/CommonThemeScene.prefab"
	local goPrefab = AssetBundleHandler:LoadAsset(bundleName, assetPath)
	local go = Unity.Object.Instantiate(goPrefab)
	go.name = "VideoThemeScene+"..ThemeLoader.themeKey

    self.transform = go.transform
    self.transform.localScale = Unity.Vector3.one
    self.transform.localPosition = Unity.Vector3.zero

    self.mNewGameNodeParent = self.transform:FindDeepChild("NewGameNode").transform
    self.mTopBottomUIParent = self.transform:FindDeepChild("TopBottomUI").transform
    self.mPopScreenCanvas = self.transform:FindDeepChild("PopScreenCanvas").transform
    self.mPopWorldCanvas = self.transform:FindDeepChild("PopWorldCanvas").transform
end

function ThemeVideoScene:Init()
	self:InitSceneLayout()
	VideoSlotMain:Init()
end

function ThemeVideoScene:Release()
    self.transform.gameObject:SetActive(false)
	LeanTween.cancelAll()
    CoinFly:clear()
	VideoSlotMain:Release()
	Unity.Object.Destroy(self.transform.gameObject)
end


