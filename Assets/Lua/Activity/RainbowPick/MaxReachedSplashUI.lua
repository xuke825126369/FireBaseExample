local MaxReachedSplashUI = {}

function MaxReachedSplashUI:Show()
    if not GameConfig.PLATFORM_EDITOR and ActivityBundleHandler.m_bundleInfo.assetBundle == nil then
        local co = StartCoroutine(function()
            local www = Unity.WWW.LoadFromCacheOrDownload(ActivityBundleHandler.m_bundleInfo.url, ActivityBundleHandler.m_bundleInfo.version)
            yield_return(www)
            ActivityBundleHandler.m_bundleInfo.assetBundle = www.assetBundle
            Util.cacheAssetBundle(www.assetBundle, ActivityBundleHandler.m_bundleInfo.url)
            self:createAndShow2()
        end)
    else
        self:createAndShow2()
    end
end

function MaxReachedSplashUI:createAndShow2()
    if not self.m_bInitFlag then
        self.m_bInitFlag = true
        self:Init() 
    end
    if self.bShowed then return end
    self.bShowed = true
    self.popController:show(nil, nil, true)
    self.bCanHide = true
    SlotsGameLua.m_bReelPauseFlag = true
end

function MaxReachedSplashUI:Init()
    local prefab = ActivityBundleHandler:loadAssetFromLoadedBundle("Assets/ActiveNeedLoad/"..ActiveManager.activeType.."/MaxReached.prefab" , typeof(Unity.GameObject))
    Debug.Assert(prefab)
    self.transform.gameObject = Unity.Object.Instantiate(prefab)
    self.transform.gameObject:SetActive(false)
    self.transform = self.transform.gameObject.transform
    self.transform:SetParent(LobbyScene.popCanvas, false)
    self.transform.localScale = Unity.Vector3.one
    self.transform.anchoredPosition3D = Unity.Vector3.zero
    self.popController = PopController:new(self.transform.gameObject, nil, PopTweenType.alpha)
    if GameConfig.IS_GREATER_169 then
        self.popController.adapterContainer.localScale = Unity.Vector3.one * 0.9
    end

    local btnClose = self.transform:FindDeepChild("btnClose"):GetComponent(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(btnClose)
    btnClose.onClick:AddListener(function()
        if self.bCanHide then
            GlobalAudioHandler:PlayBtnSound()
            self:hide()
            SlotsGameLua.m_bReelPauseFlag = false
        end
    end)
    local btnPlay = self.transform:FindDeepChild("btnPlay"):GetComponent(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(btnPlay)
    btnPlay.onClick:AddListener(function()
        if self.bCanHide then
            GlobalAudioHandler:PlayBtnSound()
            RainbowPickMainUIPop:Show()
            self:hide()
        end
    end)

    self.bShowed = false
end

function MaxReachedSplashUI:hide()
    self.bCanHide = false
    ViewScaleAni:Hide(self.transform.gameObject)
    --ActivityHelper:SetTrigger(self.transform.gameObject, "Hide")
end

return MaxReachedSplashUI