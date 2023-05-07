
local EffectObj = {}

EffectObj.m_effectGo = nil
EffectObj.m_bUsed = false
EffectObj.m_strDefaultStateName = ""
EffectObj.m_strEffectKey = "" -- 特效完整路径 cache里使用的key就是这个

function EffectObj:Show(posEffect, effectType, parent)
    local strEffectName = ""
    if effectType == enumEffectType.Effect_PayLineSymbol then
        strEffectName = "lztukuai"
    elseif effectType == enumEffectType.Effect_ScatterEffect then
        strEffectName = "lzDDFreeSpin"
    end

    local strEffectPath = "SpecialEffectAnimation/" .. strEffectName .. ".prefab"
    local res = self:CreateAndShowByFullPath(posEffect, strEffectPath, effectType, parent)
    return res
end

function EffectObj:CreateAndShowByName(posEffect, strEffectName, parent)
    local strEffectPath = "SpecialEffectAnimation/" .. strEffectName .. ".prefab"
    local effectType = enumEffectType.Effect_Custom
    local bres = self:CreateAndShowByFullPath(posEffect, strEffectPath, effectType, parent)
    return bres
end

function EffectObj:CreateAndShowByFullPath(posEffect, strEffectPath, effectType, parent)
    local o = {}
	setmetatable(o, self)
    self.__index = self
    
    o.m_strEffectKey = strEffectPath

    local effectGo = EffectCache:getCacheEffect(strEffectPath) -- 返回值 GameObject
    if effectGo ~= nil then
        o.m_effectGo = effectGo
        o.m_bUsed = true
        effectGo.transform.localPosition = posEffect
        effectGo:SetActive(true)
        o.m_enumEffectType = effectType

        if parent ~= nil then
             o.m_effectGo.transform:SetParent(parent)
        end

        return o
    end
    
    local objprefab = AssetBundleHandler:LoadThemeAsset(strEffectPath, typeof(Unity.GameObject))
    if objprefab ~= nil then
        local QuaterParam = Unity.Quaternion.identity
        local effectGo = Unity.Object.Instantiate(objprefab, posEffect, QuaterParam)
        effectGo.transform:SetParent(EffectCache.cacheObjTr, false)
        o.m_effectGo = effectGo
        o.m_enumEffectType = effectType
        o.m_bUsed = true

        if effectType ~= enumEffectType.Effect_RedHatScatterToStickyEffect then
            EffectCache:addCacheEffect(strEffectPath, effectGo)
        end
    else
        Debug.LogError("---load effect prefab error!!---strEffectPath : " .. strEffectPath)
    end

    if parent ~= nil then
        o.m_effectGo.transform:SetParent(parent)
    end

    return o

end

function EffectObj:playAni()
    if self.m_animator==nil then
        self.m_animator = self.m_effectGo:GetComponentInChildren(typeof(Unity.Animator))
    end

    if self.m_animator~=nil and self.m_strDefaultStateName=="" then
        self.m_strDefaultStateName = self.m_animator.runtimeAnimatorController.animationClips[0].name
    end

    if self.m_animator~=nil then
        self.m_animator:Play(self.m_strDefaultStateName, -1, 0)
    end
end

function EffectObj:reuseCacheEffect()
    if self.m_effectGo == nil then
        return
    end
    
    local flag = self.m_enumEffectType==enumEffectType.Effect_ArabGem1Collect or
                 self.m_enumEffectType==enumEffectType.Effect_ArabGem2Collect or
                 self.m_enumEffectType==enumEffectType.Effect_ArabGem3Collect or
                 self.m_enumEffectType==enumEffectType.Effect_RedHatFlyCollectSymbol or
                 self.m_enumEffectType==enumEffectType.Effect_RedHatFlyCoinEffect or
                 self.m_enumEffectType==enumEffectType.Effect_FlyCollectElemEffect or
                 self.m_enumEffectType==enumEffectType.Effect_RewardLockElemValueEffect or
                 self.m_enumEffectType==enumEffectType.Effect_ThreePigsCollect or
                 self.m_enumEffectType==enumEffectType.Effect_PayLineSymbol or
                 self.m_enumEffectType==enumEffectType.Effect_Custom

    if flag then
        self.m_effectGo.transform.localScale = Unity.Vector3.one
    end

    self.m_effectGo.transform:SetParent(EffectCache.cacheObjTr, false)
    self.m_effectGo:SetActive(false)
    self.m_bUsed = false

    EffectCache:reuseEffect(self.m_strEffectKey, self.m_effectGo)
end

function EffectObj:removeEffect()
    EffectCache:removeEffect(self.m_strEffectKey, self.m_effectGo)
    self.m_bUsed = true
    Unity.Object.Destroy(self.m_effectGo)
    self.m_effectGo = nil
end

function EffectObj:delayReuseEffect(ftime)
    local id = LeanTween.delayedCall(ftime, function()
		self:reuseCacheEffect()
    end).id

    table.insert(SceneSlotGame.m_listLeanTweenIDs, id)
end

function EffectObj:delayDestroyEffect(ftime)
    local id = LeanTween.delayedCall(ftime, function()
        self:removeEffect()
    end).id
    
    table.insert(SceneSlotGame.m_listLeanTweenIDs, id)
end

return EffectObj