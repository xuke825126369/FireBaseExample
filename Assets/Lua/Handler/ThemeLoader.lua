require("Lua.ThemeVideoScene.ThemeVideoScene")

ThemeLoader = {}
ThemeLoader.bInTheme = false
ThemeLoader.configItem = nil
ThemeLoader.themeName = ""
ThemeLoader.nThemeType = -1
ThemeLoader.themeKey = ""
ThemeLoader.mLoadAllAudioClips = {}
ThemeLoader.luaThemeKey = ""

function ThemeLoader:GetThemeBundleName()
    return ThemeHelper:GetThemeBundleName(self.themeKey)
end

function ThemeLoader:LoadGame(configItem)
    Unity.Screen.sleepTimeout = Unity.SleepTimeout.NeverSleep
    math.randomseed(TimeHandler:GetServerTimeStamp())

    self.bInTheme = true
    self.configItem = configItem
    self.themeName = configItem.themeName
    self.themeKey = configItem.themeName

    enumThemeType:Init()
    ThemeReturnRateDyncmaicSwitch:Init()
    
    self.nThemeType =  enumThemeType[self.themeName]
    if ThemeHelper:isClassicLevel(self.themeName) then
        self.luaThemeKey = string.sub(self.themeName, 5)
    else
        self.luaThemeKey = self.themeName
    end

    self.mLoadAllAudioClips = {}
    ThemeSceneLoadView:Show(function()
        LobbyScene:Hide()
        if ThemeHelper:isClassicLevel() then
            ThemeClassicScene:Init()
        else
            ThemeVideoScene:Init()
        end
    end)        

    StartCoroutine(function()
        if GameConfig.Instance.orUseAssetBundle then
            local bundleName = ""
            if ThemeHelper:isClassicLevel() then
                bundleName = "ThemeClassicCommon"
            else
                bundleName = "ThemeVideoCommon"
            end

            local bundle = AssetBundleHandler:GetBundle(bundleName)
            if bundle == nil then
                return
            end

            --加载Prefab
            local assetBundleRequest = bundle:LoadAllAssetsAsync(typeof(Unity.GameObject))
            while assetBundleRequest.isDone == false do
                ThemeSceneLoadView:SetUIProgress(0.6 + 0.1 * assetBundleRequest.progress)
                yield_return(0)
            end 

            --加载AudioClip
            local assetBundleRequest = bundle:LoadAllAssetsAsync(typeof(Unity.AudioClip))
            while assetBundleRequest.isDone == false do
                ThemeSceneLoadView:SetUIProgress(0.7 + 0.1 * assetBundleRequest.progress)
                yield_return(0)
            end 

            local audioClips = LuaHelper.GetCSharpListTable(assetBundleRequest.allAssets)
            for k, v in pairs(audioClips) do
                table.insert(self.mLoadAllAudioClips, v)
            end
        else
            local folderName = ""
            if ThemeHelper:isClassicLevel() then
                folderName = "ThemeClassicCommon"
            else
                folderName = "ThemeVideoCommon"
            end 

            local guids = CS.UnityEditor.AssetDatabase.FindAssets("", {"Assets/ResourceABs/"..folderName})
            for i = 0, guids.Length - 1 do
                local path = CS.UnityEditor.AssetDatabase.GUIDToAssetPath(guids[i])
                local clip = CS.UnityEditor.AssetDatabase.LoadAssetAtPath(path, typeof(Unity.AudioClip))
                table.insert(self.mLoadAllAudioClips, clip)
            end
        end

        if GameConfig.Instance.orUseAssetBundle then
            self:AsyncLoadThemeBundle()

            local bundleName = ThemeLoader:GetThemeBundleName()
            local bundle = AssetBundleHandler:GetBundle(bundleName)
            if bundle == nil then
                return
            end
            
            --加载Prefab
            local assetBundleRequest = bundle:LoadAllAssetsAsync(typeof(Unity.GameObject))
            while assetBundleRequest.isDone == false do
                ThemeSceneLoadView:SetUIProgress(0.8 + 0.1 * assetBundleRequest.progress)
                yield_return(0)
            end 
            
            --加载AudioClip
            local assetBundleRequest = bundle:LoadAllAssetsAsync(typeof(Unity.AudioClip))
            while assetBundleRequest.isDone == false do
                ThemeSceneLoadView:SetUIProgress(0.9 + 0.1 * assetBundleRequest.progress)
                yield_return(0)
            end

            local audioClips = LuaHelper.GetCSharpListTable(assetBundleRequest.allAssets)
            for k, v in pairs(audioClips) do
                table.insert(self.mLoadAllAudioClips, v)
            end
        else
            local EditorThemeFolderPath = ""
            if ThemeHelper:isClassicLevel() then
                EditorThemeFolderPath = "Assets/ResourceABs/ThemeClassicSlot/"..self.themeKey
            else
                EditorThemeFolderPath = "Assets/ResourceABs/ThemeVideoSlot/"..self.themeKey
            end

            local guids = CS.UnityEditor.AssetDatabase.FindAssets("", {EditorThemeFolderPath})
            for i = 0, guids.Length - 1 do
                local path = CS.UnityEditor.AssetDatabase.GUIDToAssetPath(guids[i])
                local clip = CS.UnityEditor.AssetDatabase.LoadAssetAtPath(path, typeof(Unity.AudioClip))
                table.insert(self.mLoadAllAudioClips, clip)
            end
        end

        ThemeSceneLoadView:SetUIProgress(1.0)
        ThemeSceneLoadView:SetLoadingFinish()
    end)
end

function ThemeLoader:ReturnToLobby()
    self.bInTheme = false
    LevelDataHandler:SendFBEvent()
    Unity.Screen.sleepTimeout = Unity.SleepTimeout.SystemSetting
    if ThemeHelper:isClassicLevel(self.themeName) then
        ThemeClassicScene:Release()
    else
        ThemeVideoScene:Release()
    end

    local bundleName = ThemeLoader:GetThemeBundleName()
    AssetBundleHandler:UnLoadBundle(bundleName, true)
    LobbyScene:Show()
         
    GlobalScene:ThemeSwitch()
    GlobalScene:SwitchScreenOp(true)
    local bLandScape = ScreenHelper:isLandScape()
    Unity.Screen.orientation = Unity.ScreenOrientation.Landscape
    if bLandScape then
        if AdsConfigHandler:orTriggerAdsInThemeSwitch() then
            GoogleAdsHandler:Show_InterstitialAds()
        end
    else
    	ScreenSwitchView:Show()
		LeanTween.delayedCall(1.0, function()
			ScreenSwitchView:Hide()
            if AdsConfigHandler:orTriggerAdsInThemeSwitch() then
                GoogleAdsHandler:Show_InterstitialAds()
            end
		end)
	end 

    Debug.Log("====================Leave Game ========================");
end

function ThemeLoader:AsyncLoadThemeBundle()
    if GameConfig.Instance.orUseAssetBundle then
        ThemeSceneLoadView:SetUIProgress(0.1)

        local bundleName = ThemeLoader:GetThemeBundleName()
        local mThemeWebItemDic = CS.AssetBundleConfig.Instance.mAssetBundleHotUpdateConfig.mThemeWebItemDic
        local mItem = CS.AssetBundleConfig.Instance.mAssetBundleHotUpdateConfig:GetHotUpdateItem(mThemeWebItemDic, bundleName)
        local url = mItem:GetUrl()
        local www = Unity.Networking.UnityWebRequestAssetBundle.GetAssetBundle(url, mItem:GetHash128())
        local mUnityWebRequestAsyncOperation = www:SendWebRequest()
        while not mUnityWebRequestAsyncOperation.isDone do
            ThemeSceneLoadView:SetUIProgress(0.1 + 0.5 * mUnityWebRequestAsyncOperation.progress)
            yield_return(0)
        end     
        
        if www.result ~= Unity.Networking.UnityWebRequest.Result.Success then
            local netErrorDes = "www Load Error: "..www.responseCode.." | "..url.." | "..www.error
            Debug.LogError(netErrorDes)
            CommonDialogBox:ShowYesNoUI("Failed to load resource, please try again!", title, function()
                self:LoadGame()
            end,
            function()
                LobbyScene:Show()
            end)
            www:Dispose()
            return
        end     
            
        local bundle = Unity.Networking.DownloadHandlerAssetBundle.GetContent(www)
        AssetBundleManager.Instance:SaveBundleToDic(mItem.bundleName, bundle)
        www:Dispose()
    end
end
