GlobalScene = {}

function GlobalScene:InitSceneLayout()
    local bundleName = "Global"
	local assetPath = "Assets/ResourceABs/Global/View/GlobalScene.prefab"
	local goPrefab = AssetBundleHandler:LoadAsset(bundleName, assetPath)
	local go = Unity.Object.Instantiate(goPrefab)
    
    self.transform = go.transform
    self.transform.localScale = Unity.Vector3.one
    self.transform.localPosition = Unity.Vector3.zero
    LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)

    self.popCanvasActivity = self.transform:FindDeepChild("UIRoot/Canvas_Activity")
    self.popCanvas = self.transform:FindDeepChild("UIRoot/Canvas_Pop")
    self.LoadingCanvas = self.transform:FindDeepChild("UIRoot/Canvas_Loading")
    self.Canvas_CoinsFly = self.transform:FindDeepChild("UIRoot/Canvas_CoinsFly")
end

function GlobalScene:Update()
    if Unity.Input.GetKeyDown(Unity.KeyCode.Escape) then
		if QuitPop and not QuitPop:isActiveShow() then
			QuitPop:Show()
		end
	end
end

function GlobalScene:Init()
    self:InitSceneLayout()

    require("Lua/GlobalScene/WindowLoadingView")
    require("Lua/GlobalScene/CommonDialogBox")
    require("Lua/GlobalScene/CommonLoadingView")

    require("Lua/GlobalScene/TipPoolView")
    require "Lua/GlobalScene/GlobalEffect"
    require "Lua/GlobalScene/ThemeSceneLoadView"
    require "Lua/GlobalScene/ScreenSwitchView"

    self:InitShaderAutoFind()
        
    CommonDialogBox:Init()
    CommonLoadingView:Init()
    WindowLoadingView:Init()
    TipPoolView:Init()
    GlobalEffect:Init()
    ThemeSceneLoadView:Init()
    ScreenSwitchView:Init()
end

function GlobalScene:InitShaderAutoFind()
    local bundleName = "Global"
    local assetPath = "Assets/ResourceABs/Global/Shader/ShaderAutoFind.prefab"
    local goPrefab = AssetBundleHandler:LoadAsset(bundleName, assetPath)
    local mShaderAutoFindObj = Unity.Object.Instantiate(goPrefab)
    mShaderAutoFindObj:SetActive(true)
end

function GlobalScene:SwitchScreenOp(bLandScape)
    local popCanvasScaler = self.popCanvas:GetComponentInChildren(typeof(UnityUI.CanvasScaler), true)
    local popCanvasActivityScaler = self.popCanvasActivity:GetComponentInChildren(typeof(UnityUI.CanvasScaler), true)
    self:SetCanvasScaler(popCanvasScaler, bLandScape)
    self:SetCanvasScaler(popCanvasActivityScaler, bLandScape)
end

function GlobalScene:SetCanvasScaler(mCanvasScaler, bLandScape)
    if bLandScape then
		mCanvasScaler.referenceResolution = Unity.Vector2(1920, 1080)
        mCanvasScaler.matchWidthOrHeight = 1
	else
		mCanvasScaler.referenceResolution = Unity.Vector2(1080, 1920)
        mCanvasScaler.matchWidthOrHeight = 0
	end
end

function GlobalScene:ThemeSwitch()
    for i = 0, self.popCanvas.transform.childCount - 1 do
        local goChild = self.popCanvas.transform:GetChild(i).gameObject
        goChild:SetActive(false)
    end
end

function GlobalScene:release()
    
end

