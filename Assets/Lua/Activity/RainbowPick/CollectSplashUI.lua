local CollectSplashUI = {}

function CollectSplashUI:Show()
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

function CollectSplashUI:createAndShow2()
    if not self.m_bInitFlag then
        self.m_bInitFlag = true
        self:Init() 
    end
    if RainbowPickUnloadedUI.bCollectNotify then
        self.popController:show(nil, nil, true)
        self.bCanHide = true
        self.textAction.text = string.format("COIN LEFT:  %d", RainbowPickDataHandler.data.nAction)
        SlotsGameLua.m_bReelPauseFlag = true
    end
end

function CollectSplashUI:Init()
    local prefab = ActivityBundleHandler:loadAssetFromLoadedBundle("Assets/ActiveNeedLoad/"..ActiveManager.activeType.."/Collect.prefab" , typeof(Unity.GameObject))
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

    local playBtn = self.transform:FindDeepChild("btnPlay"):GetComponent(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(playBtn)
    playBtn.onClick:AddListener(function()
        if self.bCanHide then
            GlobalAudioHandler:PlayBtnSound()
            RainbowPickMainUIPop:Show()
            self:hide()
        end
    end)

    local goCheckMark = self.transform:FindDeepChild("goCheckMark").gameObject
    local btnNotify = self.transform:FindDeepChild("btnNotify"):GetComponent(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(btnNotify)
    btnNotify.onClick:AddListener(function()
        if self.bCanHide then
            GlobalAudioHandler:PlayBtnSound()
            RainbowPickUnloadedUI.bCollectNotify = not RainbowPickUnloadedUI.bCollectNotify
            goCheckMark:SetActive(RainbowPickUnloadedUI.bCollectNotify)
        end
    end)
    self.textAction = self.transform:FindDeepChild("textAction"):GetComponent(typeof(UnityUI.Text))
end

function CollectSplashUI:hide()
    self.bCanHide = false
    ViewScaleAni:Hide(self.transform.gameObject)
    ActivityHelper:SetTrigger(self.transform.gameObject, "Hide")
end

return CollectSplashUI