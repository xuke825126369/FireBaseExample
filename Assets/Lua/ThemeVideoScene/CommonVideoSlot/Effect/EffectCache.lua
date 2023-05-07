local EffectCache = {}

EffectCache.m_dictCacheEffects = {}
EffectCache.m_nRefOpenTigerDragonDoorEffect = 249

function EffectCache:CreateEffectCache()
    self.m_dictCacheEffects = {}

    local strEffectCachePath = "NewGameNode/LevelInfo"
    self.cacheObjTr = ThemeVideoScene.transform:FindDeepChild(strEffectCachePath).transform
        
    local EFFECT_NAME = {"lztukuai.prefab"}
    local strPrePath = "SpecialEffectAnimation/"
    for i = 1, #EFFECT_NAME do
        local strPath = strPrePath .. EFFECT_NAME[i]
        if AssetBundleHandler:ContainsThemeAsset(strPath) then
            local objprefab = AssetBundleHandler:LoadThemeAsset(strPath, typeof(Unity.GameObject))
            if objprefab~=nil then
                local nEffectNum = 6
                local listEffects = {}
                for j=1, nEffectNum do
                    local pos = Unity.Vector3.zero
                    local QuaterParam = Unity.Quaternion.identity
                    local effectGo = Unity.Object.Instantiate(objprefab, pos, QuaterParam)
                    effectGo.transform:SetParent(self.cacheObjTr, false)
                    effectGo:SetActive(false)
                    
                    local CacheObj = {gameObj = effectGo, bUsed = false}

                    table.insert( listEffects, CacheObj )
                end

                self.m_dictCacheEffects[strPath] = listEffects
            end
        end
    end
        
end

function EffectCache:addCacheEffect(strEffectKey, obj)
    local CacheObj = {gameObj = obj, bUsed = true}
    local value = self.m_dictCacheEffects[strEffectKey]
    if value ~= nil then
        table.insert(self.m_dictCacheEffects[strEffectKey], CacheObj)
    else
        local listEffects = {}
        table.insert( listEffects, CacheObj )
        self.m_dictCacheEffects[strEffectKey] = listEffects
    end
end

function EffectCache:getCacheEffect(strEffectKey) --这个key是特效的完整路径
    local values = self.m_dictCacheEffects[strEffectKey]
    if(values == nil) then
        return nil
    end

    for k, v in pairs(values) do
        local CacheObj = v --values[k]
        if CacheObj.gameObj~=nil and not CacheObj.bUsed then
            CacheObj.gameObj:SetActive(true)
            CacheObj.bUsed = true

            return CacheObj.gameObj
        end
    end
    return nil
end

function EffectCache:reuseEffect(strEffectKey, effectGo)
    local listEffects = self.m_dictCacheEffects[strEffectKey]
    if listEffects == nil then
        return
    end

    for key, value in pairs(listEffects) do
        if value.gameObj == effectGo then
            value.bUsed = false
        end
    end
end

function EffectCache:removeEffect(strEffectKey, effectGo)
    local listEffects = self.m_dictCacheEffects[strEffectKey]
    if listEffects == nil then
        return
    end

    for key, value in pairs(listEffects) do
        if value.gameObj == effectGo then
        listEffects[key] = nil
        end
    end
end

return EffectCache
