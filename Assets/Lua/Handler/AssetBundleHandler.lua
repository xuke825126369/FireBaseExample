AssetBundleHandler = {}

function AssetBundleHandler:ContainsAsset(bundleName, assetPath)
    return AssetBundleManager.Instance:ContainsAsset(bundleName, assetPath)
end

function AssetBundleHandler:LoadAsset(bundleName, assetPath)
    return AssetBundleManager.Instance:LoadAsset(bundleName, assetPath)
end

function AssetBundleHandler:ContainsBundle(bundleName)
    return AssetBundleManager.Instance:ContainsBundle(bundleName)
end

function AssetBundleHandler:GetBundle(bundleName)
    return AssetBundleManager.Instance:GetBundle(bundleName)
end

function AssetBundleHandler:AddBundle(bundleName, bundle)
    AssetBundleManager.Instance:SaveBundleToDic(bundleName, bundle)
end

function AssetBundleHandler:UnLoadBundle(bundleName, unloadAllAssets)
    AssetBundleManager.Instance:UnLoadBundle(bundleName, unloadAllAssets)
end

-----------------------------------------------------------------------------------
function AssetBundleHandler:orInitSceneResUpdateFinish()
    return AssetBundleManager.Instance:orInitSceneResUpdateFinish()
end

function AssetBundleHandler:ContainsThemeAsset(assetName)
    local prefix = ""
    if ThemeHelper:isClassicLevel(ThemeLoader.themeKey) then
        prefix = "Assets/ResourceABs/ThemeClassicSlot/"..ThemeLoader.themeKey.."/"
    else
        prefix = "Assets/ResourceABs/ThemeVideoSlot/"..ThemeLoader.themeKey.."/"
    end

    if not string.match(assetName, prefix) then
        assetName = prefix ..assetName
    end

    local bundleName = ThemeLoader:GetThemeBundleName()
    return self:ContainsAsset(bundleName, assetName)
end

function AssetBundleHandler:LoadThemeAsset(assetName)
    local prefix = ""
    if ThemeHelper:isClassicLevel(ThemeLoader.themeKey) then
        prefix = "Assets/ResourceABs/ThemeClassicSlot/"..ThemeLoader.themeKey.."/"
    else
        prefix = "Assets/ResourceABs/ThemeVideoSlot/"..ThemeLoader.themeKey.."/"
    end
    
    if not string.match(assetName, prefix) then
        assetName = prefix ..assetName
    end

    local bundleName = ThemeLoader:GetThemeBundleName()
    return self:LoadAsset(bundleName, assetName)
end

function AssetBundleHandler:LoadMissionAsset(assetName)
    local prefix = "Assets/ResourceABs/Lobby/"
    if not string.match(assetName, prefix) then
        assetName = prefix..assetName
    end
    
    local bundleName = "Lobby"
    return self:LoadAsset(bundleName, assetName)
end

function AssetBundleHandler:LoadSlotsCardsAsset(assetName)
    local prefix = "Assets/ResourceABs/Activity/"..SlotsCardsManager.path.."/"
    if not string.match(assetName, prefix) then
        assetName = prefix..assetName
    end
    
    local bundleName = SlotsCardsManager:GetBundleName()
    return self:LoadAsset(bundleName, assetName)
end

function AssetBundleHandler:LoadGoldenLoungeAsset(assetName)
    local prefix = "Assets/ResourceABs/Activity/Lounge/"
    if not string.match(assetName, prefix) then
        assetName = prefix..assetName
    end
    
    local bundleName = LoungeManager:GetBundleName()
    return self:LoadAsset(bundleName, assetName)
end

function AssetBundleHandler:LoadActivityAsset(assetName)
    local prefix = "Assets/ResourceABs/Activity/"..ActiveManager.activeType.."/"
    if not string.match(assetName, prefix) then
        assetName = prefix..assetName
    end
    
    local bundleName = ActiveManager:GetBundleName()
    return self:LoadAsset(bundleName, assetName)
end

function AssetBundleHandler:LoadActivityCommonAsset(assetName)
    local prefix = "Assets/ResourceABs/ActivityCommon/"..ActiveManager.activeType.."/"
    if not string.match(assetName, prefix) then
        assetName = prefix..assetName
    end
    local bundleName = "ActivityCommon"
    return self:LoadAsset(bundleName, assetName)
end
