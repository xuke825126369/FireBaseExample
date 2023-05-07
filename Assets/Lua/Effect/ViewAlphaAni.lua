ViewAlphaAni = {}
ViewAlphaAni.mShowMapLtd = {}
ViewAlphaAni.mHideMapLtd = {}

function ViewAlphaAni:CacheGoLtd(go)
    if self.mShowMapLtd[go] == nil then
        self.mShowMapLtd[go] = {}
    end

    if self.mHideMapLtd[go] == nil then
        self.mHideMapLtd[go] = {}
    end
end

function ViewAlphaAni:Show(go, showfunc)
    self:CacheGoLtd(go)
    go:SetActive(true)

    local alphaAniObj = go.transform:FindDeepChild("alphaAniObj")
    if not alphaAniObj then
        alphaAniObj = go.transform:FindDeepChild("Container")
    end
    
    if not alphaAniObj then
        return
    end
    
    local mCanvasGroup = alphaAniObj:GetComponent(typeof(Unity.CanvasGroup))
    if not mCanvasGroup then
        return
    end

    local mHideLtdList = self.mHideMapLtd[go]
    if mHideLtdList then
        LuaHelper.CancelLeanTween(mHideLtdList)
    end
    self.mHideMapLtd[go] = {}

    local ltd = LeanTween.value(0.0, 1.0, 0.3):setOnUpdate(function(fValue)
        mCanvasGroup.alpha = fValue
    end):setOnComplete(function()
        if showfunc then
            showfunc()
        end
    end).id
    table.insert(self.mShowMapLtd[go], ltd)

end 

function ViewAlphaAni:Hide(go, Hidefunc)
    self:CacheGoLtd(go)

    local alphaAniObj = go.transform:FindDeepChild("alphaAniObj")
    if not alphaAniObj then
        alphaAniObj = go.transform:FindDeepChild("Container")
    end

    if not alphaAniObj then
        go:SetActive(false)
        return
    end

    local mCanvasGroup = alphaAniObj:GetComponent(typeof(Unity.CanvasGroup))
    if not mCanvasGroup then
        go:SetActive(false)
        return
    end

    local mShowLtdList = self.mShowMapLtd[go]
    if mShowLtdList then
        LuaHelper.CancelLeanTween(mShowLtdList)
    end
    self.mShowMapLtd[go] = {}

    local ltd = LeanTween.value(1.0, 0.0, 0.3):setOnUpdate(function(fValue)
        mCanvasGroup.alpha = fValue
    end):setOnComplete(function()
        go:SetActive(false)
        if Hidefunc then
            Hidefunc()
        end
    end).id
    table.insert(self.mHideMapLtd[go], ltd)

end
