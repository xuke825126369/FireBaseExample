ReturnRateManager = nil
SceneSlotGame = nil
SlotsGameLua = nil
SymbolObjectPool = nil
SpinButton = nil
ThemePlayData = nil
LevelType = nil
GameLevelUtil = nil
GameResult = nil
LineLua = nil
VideoSlotSymbolRandomChoice = nil
JackpotTYPE = nil
SymbolObjectPool = nil
SymbolType = nil
SymbolLua = nil
WinItemInfo = nil
SlotsNumber = nil
ReelLua = nil
LevelDataHandler = nil
LevelCommonFunctions = nil
PayLinePayWaysEffectHandler = nil
enumSpinButtonStatus = nil
enumReturnRateTYPE = nil
SplashType = nil
LineLua = nil
UIPayTable = nil
UISplash = nil
SpineEffect = nil
AudioHandler = nil
UITop = nil
SlotsReturnCode = nil
EffectObj = nil
EffectCache = nil
enumEffectType = nil
PayLines = nil
enumSpinBtnType = nil
enumButtonType = nil

MultiClipEffectType = nil
MultiClipEffectObj = nil
StickySymbol = nil
ChoiceCommonFunc = nil
WinItem = nil
WinItemPayWay = nil
TestWinItem = nil
AnimationEventHub = nil
enumCollectBtnType = nil

local function InitGlobalVaribale() 
	SplashType = require("Lua/ThemeVideoScene/CommonVideoSlot/GameLogic/SplashType")
	JackpotTYPE = require("Lua/ThemeVideoScene/CommonVideoSlot/GameLogic/JackpotTYPE")
	SymbolType = require("Lua/ThemeVideoScene/CommonVideoSlot/GameLogic/SymbolType")
	enumReturnRateTYPE = require("Lua/ThemeVideoScene/CommonVideoSlot/GameLogic/enumReturnRateTYPE")
	enumSpinButtonStatus = require("Lua/ThemeVideoScene/CommonVideoSlot/GameLogic/enumSpinButtonStatus")
	SlotsReturnCode = require("Lua/ThemeVideoScene/CommonVideoSlot/GameLogic/SlotsReturnCode")
	enumEffectType = require("Lua/ThemeVideoScene/CommonVideoSlot/Effect/enumEffectType")
	enumSpinBtnType = require("Lua/ThemeVideoScene/CommonVideoSlot/GameLogic/enumSpinBtnType")
	enumCollectBtnType = require("Lua/ThemeVideoScene/CommonVideoSlot/GameLogic/enumCollectBtnType")
	enumButtonType = require("Lua/ThemeVideoScene/CommonVideoSlot/GameLogic/enumButtonType")

	LineLua = require "Lua/ThemeVideoScene/CommonVideoSlot/GameLogic/LineLua"
	GameResult = require("Lua/ThemeVideoScene/CommonVideoSlot/GameLogic/GameResult")
	SymbolLua = require("Lua/ThemeVideoScene/CommonVideoSlot/GameLogic/SymbolLua")
	WinItem = require("Lua/ThemeVideoScene/CommonVideoSlot/GameLogic/WinItem")
	WinItemPayWay = require("Lua/ThemeVideoScene/CommonVideoSlot/GameLogic/WinItemPayWay")
	TestWinItem = require("Lua/ThemeVideoScene/CommonVideoSlot/GameLogic/TestWinItem")
	
	PayLines = require "Lua/ThemeVideoScene/CommonVideoSlot/GameLogic/PayLines"
	VideoSlotSymbolRandomChoice = require("Lua/ThemeVideoScene/CommonVideoSlot/GameLogic/VideoSlotSymbolRandomChoice")
	ReturnRateManager = require "Lua/ThemeVideoScene/CommonVideoSlot/GameLogic/ReturnRateManager"
	ChoiceCommonFunc = require "Lua/ThemeVideoScene/CommonVideoSlot/GameLogic/ChoiceCommonFunc"

	SlotsGameLua = require "Lua/ThemeVideoScene/CommonVideoSlot/GameLogic/SlotsGameLua"
	ReelLua = require("Lua/ThemeVideoScene/CommonVideoSlot/GameLogic/ReelLua")
	SymbolObjectPool = require "Lua/ThemeVideoScene/CommonVideoSlot/GameLogic/SymbolObjectPool"
	
	ThemePlayData = require("Lua/ThemeVideoScene/CommonVideoSlot/GameLogic/ThemePlayData")
	GameLevelUtil = require("Lua/ThemeVideoScene/CommonVideoSlot/GameLogic/GameLevelUtil")
	
	SlotsNumber = require("Lua/ThemeVideoScene/CommonVideoSlot/GameLogic/SlotsNumber")
	LevelCommonFunctions = require("Lua/ThemeVideoScene/CommonVideoSlot/GameLogic/LevelCommonFunctions")

	SceneSlotGame = require "Lua/ThemeVideoScene/CommonVideoSlot/GameLogic/SceneSlotGame"
	UITop = require("Lua/ThemeVideoScene/CommonVideoSlot/GameLogic/UITop")
	SpinButton = require "Lua/ThemeVideoScene/CommonVideoSlot/GameLogic/SpinButton"
	UIPayTable = require("Lua/ThemeVideoScene/CommonVideoSlot/GameLogic/UIPayTable")
	UISplash = require("Lua/ThemeVideoScene/CommonVideoSlot/GameLogic/UISplash")

	AudioHandler = require("Lua/ThemeVideoScene/CommonVideoSlot/GameLogic/AudioHandler")
	LevelDataHandler = require("Lua/ThemeVideoScene/CommonVideoSlot/GameLogic/LevelDataHandler")
	PayLinePayWaysEffectHandler = require("Lua/ThemeVideoScene/CommonVideoSlot/GameLogic/PayLinePayWaysEffectHandler")
	StickySymbol = require("Lua/ThemeVideoScene/CommonVideoSlot/GameLogic/StickySymbol")
	
	SpineEffect = require("Lua/ThemeVideoScene/CommonVideoSlot/Effect/SpineEffect")
 	EffectObj = require("Lua/ThemeVideoScene/CommonVideoSlot/Effect/EffectObj")
	EffectCache = require("Lua/ThemeVideoScene/CommonVideoSlot/Effect/EffectCache")
	MultiClipEffectType = require("Lua/ThemeVideoScene/CommonVideoSlot/Effect/MultiClipEffectType")
	MultiClipEffectObj = require("Lua/ThemeVideoScene/CommonVideoSlot/Effect/MultiClipEffectObj")
	AnimationEventHub = require("Lua/ThemeVideoScene/CommonVideoSlot/Effect/AnimationEventHub")
end

local function ReleaseGlobalVaribale()
	enumCollectBtnType = nil
	AnimationEventHub = nil
	WinItem = nil
	WinItemPayWay = nil
	TestWinItem = nil
	ChoiceCommonFunc = nil
	ReturnRateManager = nil
	SceneSlotGame = nil
	SlotsGameLua = nil
	SymbolObjectPool = nil
	SpinButton = nil
	enumButtonType = nil
	ThemePlayData = nil
	LevelType = nil
	GameLevelUtil = nil
	GameResult = nil
	LineLua = nil
	VideoSlotSymbolRandomChoice = nil
	JackpotTYPE = nil
	SymbolObjectPool = nil
	SymbolType = nil
	SymbolLua = nil
	WinItemInfo = nil
	SlotsNumber = nil
	ReelLua = nil
	LevelDataHandler = nil
	LevelCommonFunctions = nil
	PayLinePayWaysEffectHandler = nil
	enumSpinButtonStatus = nil
	enumReturnRateTYPE = nil
	SplashType = nil
	LineLua = nil
	UIPayTable = nil
	UISplash = nil
	SpineEffect = nil
	AudioHandler = nil
	UITop = nil
	SplashType = nil
	SlotsReturnCode = nil
	EffectObj = nil
	EffectCache = nil
	enumEffectType = nil
	PayLines = nil
	enumSpinBtnType = nil
	MultiClipEffectType = nil
	MultiClipEffectObj = nil
	StickySymbol = nil
end

VideoSlotMain = {}

function VideoSlotMain:Init()
	InitGlobalVaribale()
	
	self:LoadTopUI()
	self:LoadBottomUI()
	self:LoadThemeNote()
	self:SwitchCameraOp()
	self:SwitchScreenOp()

	LevelDataHandler:Init()
	ReturnRateManager:InitGameSetReturnRate()
	AudioHandler:Init()
	AudioHandler:loadThemeAudio(ThemeLoader.mLoadAllAudioClips)
	UITop:Init()
	SceneSlotGame:Init()
end

function VideoSlotMain:Release()
	LeanTweenHelper:WaitFrame(2, function()
		ReleaseGlobalVaribale()
	end)
end

function VideoSlotMain:LoadTopUI()
	local bundleName = "ThemeVideoCommon"
	local assetPath = nil
	if GameLevelUtil:isPortraitLevel() then
		assetPath = "Assets/ResourceABs/ThemeVideoCommon/Prefabs/ThemeTopUI_Portrait.prefab"
	else
		assetPath = "Assets/ResourceABs/ThemeVideoCommon/Prefabs/ThemeTopUI_Landscape.prefab"
	end

	local goPrefab = AssetBundleHandler:LoadAsset(bundleName, assetPath)
	local go = Unity.Object.Instantiate(goPrefab)
	go.transform:SetParent(ThemeVideoScene.mTopBottomUIParent, false)
	go.name = "UITop"
end

function VideoSlotMain:LoadBottomUI()
	local bundleName = "ThemeVideoCommon"
	local assetPath = nil
	if GameLevelUtil:isPortraitLevel() then
		assetPath = "Assets/ResourceABs/ThemeVideoCommon/Prefabs/VideoSlotBottomUI_Portrait.prefab"
	else
		assetPath = "Assets/ResourceABs/ThemeVideoCommon/Prefabs/VideoSlotBottomUI_Landscape.prefab"
	end
	
	local goPrefab = AssetBundleHandler:LoadAsset(bundleName, assetPath)
	local go = Unity.Object.Instantiate(goPrefab)
	go.transform:SetParent(ThemeVideoScene.mTopBottomUIParent, false)
	go.name = "UIBottom"

	ThemeVideoScene.mUIBottomCanvas = go.transform
end

function VideoSlotMain:LoadThemeNote()
	local bundleName = ThemeLoader:GetThemeBundleName()
	local assetPath = "Assets/ResourceABs/ThemeVideoSlot/"..ThemeLoader.themeName.."/LevelInfo.prefab"
	local goPrefab = AssetBundleHandler:LoadAsset(bundleName, assetPath)
	local go = Unity.Object.Instantiate(goPrefab)
	go.transform:SetParent(ThemeVideoScene.mNewGameNodeParent, false)
	go.name = "LevelInfo"
end

function VideoSlotMain:SwitchCameraOp()
	Unity.Camera.main.fieldOfView = 60
	if GameLevelUtil:is3DLevel() then
		ThemeVideoScene.mNewGameNodeParent.localPosition = Unity.Vector3.zero
		Unity.Camera.main.orthographic = false
		
		LevelCommonFunctions:Set3DPortraitScreenCustomCameraSize()
	elseif GameLevelUtil:is3DModelCurvedLevel() then
		ThemeVideoScene.mNewGameNodeParent.localPosition = Unity.Vector3.zero
		Unity.Camera.main.orthographic = false
		Unity.Camera.main.fieldOfView = 30

		LevelCommonFunctions:Set3DModelCurvedLevelLandScapeScreenCustomCameraSize()
	else
		ThemeVideoScene.mNewGameNodeParent.localPosition = Unity.Vector3.zero
		Unity.Camera.main.orthographic = true
	end
	
	if GameLevelUtil:isPortraitLevel() then
		local mCanvasScaler = ThemeVideoScene.mPopScreenCanvas:GetComponentInChildren(typeof(UnityUI.CanvasScaler), true)
		mCanvasScaler.referenceResolution = Unity.Vector2(1080, 1920)
		mCanvasScaler.matchWidthOrHeight = 0
	else
		local mCanvasScaler = ThemeVideoScene.mPopScreenCanvas:GetComponentInChildren(typeof(UnityUI.CanvasScaler), true)
		mCanvasScaler.referenceResolution = Unity.Vector2(1920, 1080)
		mCanvasScaler.matchWidthOrHeight = 0
	end
end

-- 切换屏幕操作
function VideoSlotMain:SwitchScreenOp()
	local bLandScape = not GameLevelUtil:isPortraitLevel()
    local ratio = ScreenHelper:GetScreenWidthHeightRatio(bLandScape)
    local mCamera = Unity.Camera.main
    mCamera.rect = Unity.Rect(0.0, 0.0, 1.0, 1.0)
	
	Debug.Log( "宽高比："..Unity.Screen.width .."/".. Unity.Screen.height.."=".. ratio)
    if mCamera.orthographic then
        if ratio >= 1.0 then
			if ratio > 2.0 then
            	mCamera.orthographicSize = 560
			else
				mCamera.orthographicSize = 540
			end
        else 
            mCamera.orthographicSize = 540 / ratio + (ratio - 0.5) * 720
        end
    end

	if bLandScape then

	else
		LevelCommonFunctions:SetPortraitScreenCustomCameraSize(ratio)
	end

	GlobalScene:SwitchScreenOp(bLandScape)

    local mCanvasScaler = ThemeVideoScene.mTopBottomUIParent:FindDeepChild("UIBottom"):GetComponentInChildren(typeof(UnityUI.CanvasScaler), true)
	if bLandScape then
		mCanvasScaler.referenceResolution = Unity.Vector2(1920, 1080)
	else
		mCanvasScaler.referenceResolution = Unity.Vector2(1080, 1920)
	end
	mCanvasScaler.matchWidthOrHeight = 0

	local mCanvasScaler = ThemeVideoScene.mTopBottomUIParent:FindDeepChild("UITop"):GetComponentInChildren(typeof(UnityUI.CanvasScaler), true)
	if bLandScape then
		mCanvasScaler.referenceResolution = Unity.Vector2(1920, 1080)
	else
		mCanvasScaler.referenceResolution = Unity.Vector2(1080, 1920)
	end
	mCanvasScaler.matchWidthOrHeight = 0

    local mCanvasScaler = ThemeVideoScene.mPopScreenCanvas:GetComponentInChildren(typeof(UnityUI.CanvasScaler), true)
	if bLandScape then
		mCanvasScaler.referenceResolution = Unity.Vector2(1920, 1080)
		mCanvasScaler.matchWidthOrHeight = 1
	else
		mCanvasScaler.referenceResolution = Unity.Vector2(1080, 1920)
		mCanvasScaler.matchWidthOrHeight = 0
	end

	-- 设置屏幕 旋转（PC 平台无效）
	if bLandScape then
		Unity.Screen.orientation = Unity.ScreenOrientation.Landscape
	else
		Unity.Screen.orientation = Unity.ScreenOrientation.Portrait
	end
		
	if not bLandScape then
    	ScreenSwitchView:Show()
		LeanTween.delayedCall(1.0, function()
			ScreenSwitchView:Hide()
		end)
	end
end
