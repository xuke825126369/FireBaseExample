ThemeSceneLoadView = {}
function ThemeSceneLoadView:Init()
    local goPrefab = AssetBundleHandler:LoadAsset("Global", "Assets/ResourceABs/Global/ThemeLoadScene/ThemeLoadScene.prefab")
    local goPanel = Unity.Object.Instantiate(goPrefab)

    local goParent = GlobalScene.LoadingCanvas
    self.transform = goPanel.transform
    self.transform:SetParent(goParent, false)
    self.transform.localScale = Unity.Vector3.one
    self.transform.localPosition = Unity.Vector3.zero
    LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
    self.transform.gameObject:SetActive(false)

    self.m_progressText = self.transform:FindDeepChild("InfoText"):GetComponent(typeof(TextMeshProUGUI))
    self.mCoinsParent = self.transform:FindDeepChild("GridCoins")
    self.fSingleCoinsPercent =  1 / self.mCoinsParent.childCount

    self.mEffectParent = self.transform:FindDeepChild("CoinsEffectParent")
    local goPrefab = AssetBundleHandler:LoadAsset("Global", "Assets/ResourceABs/Global/ThemeLoadScene/ProgressCoins.prefab")
    self.mCoinsEffectPool = GoPool:New(goPrefab, self.mEffectParent, 10)
    local goPrefab = AssetBundleHandler:LoadAsset("Global", "Assets/ResourceABs/Global/ThemeLoadScene/FlyEndEffect.prefab")
    self.mFlyEndEffectPool = GoPool:New(goPrefab, self.mEffectParent, 10)

    self.mThemeIconParent = self.transform:FindDeepChild("ThemeIconParent")

end

function ThemeSceneLoadView:Show(func)
    self.transform.gameObject:SetActive(true)

    self.fCurrentBeginProgress = 0.0
    self.fCurrentEndProgress = 0.0
    self.fNowMaxProgress = 0.0
    self.bAni = false
    self.fCdTime = 0.0
    self.fAniMaxTime = 0.0
    self.bRealLoadFinish = false
    self:SetJinDuInfo(0)

    self.fSingleCoinsPercent =  1 / self.mCoinsParent.childCount
    self.mCoinsEffectPool:RecycleAllItem()
    self.nCurrentCoinsIndex = 0
    for i = 0, self.mCoinsParent.childCount - 1 do
        self.mCoinsParent:GetChild(i).gameObject:SetActive(false)
    end

    self.finishCf = func
    self:LoadThemeIcon()
end

function ThemeSceneLoadView:Hide()
    self.transform.gameObject:SetActive(false)
    self.mCoinsEffectPool:RecycleAllItem()
    if self.goThemeEntryIcon then
        Unity.Object.Destroy(self.goThemeEntryIcon)
        self.goThemeEntryIcon = nil
    end
end

function ThemeSceneLoadView:LoadThemeIcon()
    local bundleName = ThemeHelper:GetThemeEntryBundleName()
    local assetPath = "Assets/ResourceABs/ThemeVideoEntry/"..ThemeLoader.themeKey.."/smallIcon.prefab"
    if ThemeHelper:isClassicLevel() then
        assetPath = "Assets/ResourceABs/ThemeClassicEntry/"..ThemeLoader.themeKey.."/smallIcon.prefab"
    end 
    
    local goPrefab = AssetBundleHandler:LoadAsset(bundleName, assetPath)
    local goThemeEntryIcon = Unity.Object.Instantiate(goPrefab)
    goThemeEntryIcon.transform:SetParent(self.mThemeIconParent, false)
    goThemeEntryIcon.transform.localPosition = Unity.Vector3.zero
    goThemeEntryIcon.transform.localScale = Unity.Vector3.one
    goThemeEntryIcon:SetActive(true)

    self.goThemeEntryIcon = goThemeEntryIcon
end 

function ThemeSceneLoadView:SetJinDuInfo(fJinDu)
    self.fJinDu = fJinDu
    self.m_progressText.text = string.format("%d%%", fJinDu * 10000 // 100)
end

function ThemeSceneLoadView:SetLoadingFinish()
    self.bRealLoadFinish = true
end

function ThemeSceneLoadView:SetUIProgress(fRealProgress)
    self.fNowMaxProgress = fRealProgress
end

function ThemeSceneLoadView:Update()
    local dt =  Unity.Time.deltaTime
    if self.bAni then
        self.fCdTime = self.fCdTime + dt
        local fPerent = self.fCdTime / self.fAniMaxTime
        fPerent = math.max(0, fPerent)
        fPerent = math.min(1.0, fPerent)

        local fJinDu = self.fCurrentBeginProgress * (1 - fPerent) + self.fCurrentEndProgress * fPerent
        self:SetJinDuInfo(fJinDu)
        if fPerent >= 1.0 then
            self.bAni = false
            self.fCdTime = 0.0
        end
    end     

    if not self.bAni then
        if self.fCurrentEndProgress < self.fNowMaxProgress then
            self.fCurrentBeginProgress = self.fCurrentEndProgress
            self.fCurrentEndProgress = self.fNowMaxProgress
            self.bAni = true
            self.fCdTime = 0.0
            self.fAniMaxTime = (self.fCurrentEndProgress - self.fCurrentBeginProgress) * 1.0
            self.fAniMaxTime = math.max(0.5, self.fAniMaxTime)
            self.fAniMaxTime = math.min(1.0, self.fAniMaxTime)
        else
            if self.fCurrentEndProgress >= 1.0 then
                self.fCdTime = self.fCdTime + dt
                if self.fCdTime >= 1.0 and self.bRealLoadFinish then
                    self:Hide()
                    if self.finishCf then
                        self.finishCf()
                    end
                end
            end
        end
    end
    
    self:UpdateCoinsProgress()
end

ThemeSceneLoadView.fLastCoinAniTime = 0
function ThemeSceneLoadView:UpdateCoinsProgress()
    if self.fJinDu > self.nCurrentCoinsIndex * self.fSingleCoinsPercent then
        local nCurrentCoinsIndex = self.nCurrentCoinsIndex
        self.nCurrentCoinsIndex = self.nCurrentCoinsIndex + 1
        
        local goCoins = self.mCoinsParent:GetChild(nCurrentCoinsIndex)
        if Unity.Time.time - self.fLastCoinAniTime < 0.1 then
            goCoins.gameObject:SetActive(true)
        else
            self.fLastCoinAniTime = Unity.Time.time
            local goCoinsEffect = self.mCoinsEffectPool:GetItem()
            goCoinsEffect.transform.position = goCoins.position
            goCoinsEffect:SetActive(true)

            LeanTween.delayedCall(0.167, function()
                goCoins.gameObject:SetActive(true)

                local nFlyEndCurrentIndex = self.nCurrentCoinsIndex
                if nFlyEndCurrentIndex >= self.mCoinsParent.childCount then
                    nFlyEndCurrentIndex = self.mCoinsParent.childCount - 1
                end

                local goCoins1 = self.mCoinsParent:GetChild(nFlyEndCurrentIndex)
                local goFlyEndEffect = self.mFlyEndEffectPool:GetItem()
                goFlyEndEffect.transform.position = goCoins1.position
                goFlyEndEffect:SetActive(true)

                LeanTween.delayedCall(1.0, function()
                    self.mFlyEndEffectPool:RecycleItem(goFlyEndEffect)
                end)
            end)

            LeanTween.delayedCall(1.0, function()
                self.mCoinsEffectPool:RecycleItem(goCoinsEffect)
            end)
        end
    end

end

