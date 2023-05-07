LobbyScene = {}

function LobbyScene:InitSceneLayout()
    local bundleName = "Lobby"
	local assetPath = "Assets/ResourceABs/Lobby/View/LobbyScene.prefab"
	local goPrefab = AssetBundleHandler:LoadAsset(bundleName, assetPath)
	local go = Unity.Object.Instantiate(goPrefab)

    self.transform = go.transform
    self.transform.localScale = Unity.Vector3.one
    self.transform.localPosition = Unity.Vector3.zero
    self.transform.gameObject:SetActive(false)

    self.windowCanvas = self.transform:FindDeepChild("UIRoot/Canvas_Game").transform
    self.popCanvas = self.transform:FindDeepChild("UIRoot/Canvas_Pop").transform
    self.LoadingCanvas = self.transform:FindDeepChild("UIRoot/Canvas_Loading").transform
end

function LobbyScene:LoadCameraParam()
    Unity.Camera.main.orthographic = true
    Unity.Camera.main.orthographicSize = 540
end

function LobbyScene:InitView() 
    require "Lua/LobbyScene/LobbyView"
    require("Lua/LobbyScene/Store/BuyView")
    require("Lua/LobbyScene/Store/ShopBonusUI")

    require("Lua/LobbyScene/DailyBonus/DailyBonusPop")
    require("Lua/LobbyScene/FreeBonusGame/FreeBonusGamePopView")

    require("Lua/LobbyScene/WheelOfFun/DealOfFunPopView")
    require("Lua/LobbyScene/WheelOfFun/WheelOfFunPopView")
    require("Lua/LobbyScene/MegaBall/MegaballPremiumUI")

    require("Lua/LobbyScene/Ads/LobbyAdsEntry")
    require("Lua/LobbyScene/Ads/ThemeAdsEntry")
    
    require("Lua/LobbyScene/Missions/MissionMainUIPop")
    require("Lua/LobbyScene/Missions/MissionLevelEntry")
    require("Lua/LobbyScene/Missions/MissionUnloadedUI")

    require("Lua/LobbyScene/Common/ShowPurchaseBenifitPop")
    require("Lua/LobbyScene/Common/ShopEndPop")
    require "Lua/LobbyScene/Common/LockTip"
        
    require("Lua/LobbyScene/Common/VipInfoPop")
    require("Lua/LobbyScene/Common/QuitPop")
    require("Lua/LobbyScene/Common/MenuPop")
    require("Lua/LobbyScene/Common/DeleteAccountView")
    require("Lua/LobbyScene/Common/UpdateNewVersionView")
    require("Lua/LobbyScene/Common/WelcomeBonusView")

    require("Lua/LobbyScene/Theme/ThemeMenuPopView")
    require("Lua/LobbyScene/Inbox/InboxPop")

    require("Lua/LobbyScene/FlashSale/FirstIAPTipPop")
    require("Lua/LobbyScene/FlashSale/NoCoinsDealPop")
    require("Lua/LobbyScene/FlashSale/NoCoinsTimeLimitHugePackPop")
    
    LobbyView:Init()
end

function LobbyScene:Init()
    self:InitSceneLayout()

    self.mInitLoginLoadingView = require("Lua/LobbyScene/Login/InitLoginLoadingView")
    self.mInitLoginLoadingView:Show()

    StartCoroutine(function()
        local mLoadAllAudioClips = {}
        if GameConfig.Instance.orUseAssetBundle then
            local tableBundleName = {"lobby", "global"}
            for k, v in pairs(tableBundleName) do
                local bundleName = v
                local bundle = AssetBundleHandler:GetBundle(bundleName)

                --加载Prefab
                local assetBundleRequest = bundle:LoadAllAssetsAsync(typeof(Unity.GameObject))
                while assetBundleRequest.isDone == false do
                    yield_return(0)
                end 

                --加载AudioClip
                local assetBundleRequest = bundle:LoadAllAssetsAsync(typeof(Unity.AudioClip))
                while assetBundleRequest.isDone == false do
                    yield_return(0)
                end

                local audioClips = LuaHelper.GetCSharpListTable(assetBundleRequest.allAssets)
                for k, v in pairs(audioClips) do
                    table.insert(mLoadAllAudioClips, v)
                end
            end
        else
            local audioClips = {}
            local tableFolderName = {"Lobby", "Global"}
            for k, v in pairs(tableFolderName) do
                local guids = CS.UnityEditor.AssetDatabase.FindAssets("", {"Assets/ResourceABs/"..v.."/"})
                for i = 0, guids.Length - 1 do
                    local path = CS.UnityEditor.AssetDatabase.GUIDToAssetPath(guids[i])
                    local clip = CS.UnityEditor.AssetDatabase.LoadAssetAtPath(path, typeof(Unity.AudioClip))
                    table.insert(audioClips, clip)
                end
            end

            for k, v in pairs(audioClips) do
                table.insert(mLoadAllAudioClips, v)
            end
        end 

        GlobalAudioHandler:LoadAllAudio(mLoadAllAudioClips)
        self:InitView()
        self.bInitViewFinish = true
    end)    

    self:WaitLoadFinish()
end 

function LobbyScene:Show()
    self:LoadCameraParam()
    self.transform.gameObject:SetActive(true)
    LobbyView:Show()
    LobbyAdsEntry:Show()
end

function LobbyScene:Hide()
    LobbyView:Hide()
    LobbyAdsEntry:Hide()
    self.transform.gameObject:SetActive(false)
    LeanTween.value(GlobalAudioHandler.musicTweenObject, GlobalAudioHandler.musicAudioSource.volume, 0.0, 1.0):setOnUpdate(function(value)
		GlobalAudioHandler.musicAudioSource.volume = value
    end)
end

function LobbyScene:SetInitLoginFinish()
    self.bInitLoginFinish = true
end

function LobbyScene:WaitLoadFinish()
    StartCoroutine(function()
        while (not self.bInitLoginFinish) or (not self.bInitViewFinish) do
            yield_return(0)
        end

        while not CS.GlobalVariable.bInitSceneViewProgressFullShow do
            yield_return(0)
        end
        
        CS.GlobalVariable.bMainSceneInitFinish = true
        Debug.Log("===================LobbyScene:InitShowPopView()====================")
        self:Show()
        ----------------------------------- 活动管理器初始化  ------------------------------

        BoostHandler:CheckAwardPrize()
        ActiveManager:Init()
        SlotsCardsManager:Init()
        PickBonusManager:Init()
        LoungeManager:Init()

        ----------------------------------- 活动入口初始化  ------------------------------
        ActiveLobbyEntry:Init()
        SlotsCardsUnloadedUI:Init()
        LoungeEntryUI:Init()
        MedalMasterEntryUI:Init()
        MissionUnloadedUI:Init()
        SystemAwardHandler:Init()

        yield_return(Unity.WaitForSeconds(1))
        self.mInitLoginLoadingView:Hide()
        self:InitShowPopView()
    end)
end

function LobbyScene:InitShowPopView()
    ----------------------------------- 初始化弹窗  ------------------------------
    if CSharpVersionHandler:orCSharpVersionDiff() then
        PopStackViewHandler:Show(UpdateNewVersionView)
        return
    end 

    if GlobalTempData.bShowWelcomeBonusView then
        PopStackViewHandler:Show(WelcomeBonusView)
    end

    if DailyBonusDataHandler:orDifferentDay() then
        PopStackViewHandler:Show(DailyBonusPop)
    end 

    FlashSaleHandler:Show()
end

