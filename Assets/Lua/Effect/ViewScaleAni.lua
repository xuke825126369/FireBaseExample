ViewScaleAni = {}
ViewScaleAni.mShowMapLtd = {}
ViewScaleAni.mHideMapLtd = {}

function ViewScaleAni:CacheGoLtd(go)
    if self.mShowMapLtd[go] == nil then
        self.mShowMapLtd[go] = {}
    end

    if self.mHideMapLtd[go] == nil then
        self.mHideMapLtd[go] = {}
    end
end

function ViewScaleAni:orInShowAni(go)
    return self.mShowMapLtd[go] ~= nil and #self.mShowMapLtd[go] > 0
end

function ViewScaleAni:orInHideAni(go)
    return self.mHideMapLtd[go] ~= nil and #self.mHideMapLtd[go] > 0
end

function ViewScaleAni:Show(go, targetScale, showfunc)
    self:CacheGoLtd(go)
    go:SetActive(true)
    local goScaleObj = go.transform:FindDeepChild("scaleAniObj")
    if not goScaleObj then
        goScaleObj = go.transform:FindDeepChild("Container")
    end

    if not goScaleObj then
        return
    end

    if not targetScale then
        targetScale = Unity.Vector3.one
    end

    local mHideLtdList = self.mHideMapLtd[go]
    if mHideLtdList then
        LuaHelper.CancelLeanTween(mHideLtdList)
    end
    self.mHideMapLtd[go] = {}

    goScaleObj = goScaleObj.gameObject
    goScaleObj.transform.localScale = Unity.Vector3.zero
    local ltd = LeanTween.scale(goScaleObj, targetScale, 0.5):setEase(LeanTweenType.easeOutBack):setOnComplete(function()
        if showfunc then
            showfunc()
        end
    end).id
    table.insert(self.mShowMapLtd[go], ltd)

end 

function ViewScaleAni:Hide(go, Hidefunc)
    self:CacheGoLtd(go)
    local goScaleObj = go.transform:FindDeepChild("scaleAniObj")
    if not goScaleObj then
        goScaleObj = go.transform:FindDeepChild("Container")
    end
    
    if not goScaleObj then
        go:SetActive(false)
        return
    end 

    local mShowLtdList = self.mShowMapLtd[go]
    if mShowLtdList then
        LuaHelper.CancelLeanTween(mShowLtdList)
    end
    self.mShowMapLtd[go] = {}

    goScaleObj = goScaleObj.gameObject
    local nowScale = goScaleObj.transform.localScale
    local ltd = LeanTween.scale(goScaleObj, Unity.Vector3.zero, 0.5):setEase(LeanTweenType.easeInBack):setOnComplete(function()
        go:SetActive(false)
        if Hidefunc then
            Hidefunc()
        end
    end).id
    table.insert(self.mHideMapLtd[go], ltd)

end
