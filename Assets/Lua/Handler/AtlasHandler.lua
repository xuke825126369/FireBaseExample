AtlasHandler = {}
AtlasHandler.globalAtlasDic = {}

function AtlasHandler:GetAtlas(bundleName, atlasName)
    return AssetBundleManager.Instance:LoadAsset(bundleName, atlasName)
end

function AtlasHandler:GetSprite(bundleName, atlasName, spriteName)
    local mAltas = self:GetAtlas(bundleName, atlasName);
    return mAltas:GetSprite(spriteName);
end

function AtlasHandler:GetThemeSprite(atlasName, spriteName)
    local themeName = ThemeLoader.themeKey
    local prefix = "Assets/ResourceABs/Theme/"..themeName.."/UI/Atlas/"
    atlasName = prefix..atlasName..".spriteatlasv2"
    return self:GetSprite(themeName, atlasName, spriteName)
end

------------------------------------------------------------------------
function AtlasHandler:GetCacheAtlas(bundleName, atlasName)
    local mAtlas = self.globalAtlasDic[atlasName]
    if not mAtlas then
        mAtlas = self:GetAtlas(bundleName, atlasName)
    end
    return mAtlas
end



