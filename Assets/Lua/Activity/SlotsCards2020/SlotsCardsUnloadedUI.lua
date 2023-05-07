SlotsCardsUnloadedUI = {}

function SlotsCardsUnloadedUI:Init()
    if not LuaHelper.OrGameObjectExist(self.transform) then
        self.transform = LobbyView.transform:FindDeepChild("BottomSlotsCards")
        LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject,self)

        self.m_entryBtn = self.transform:FindDeepChild("EntryBtn"):GetComponent(typeof(UnityUI.Button))
        self.m_entryBtn.gameObject:SetActive(false)
        DelegateCache:addOnClickButton(self.m_entryBtn)
        self.m_entryBtn.onClick:AddListener(function()
            self:onSlotsCardsClicked()
        end)

        self.goSlotsCardsUnloaded = self.transform:FindDeepChild("SlotsCardsUnloaded").gameObject
        self.goSlotsCardsUnloaded:SetActive(false)
        
        self.m_textTime = self.transform:FindDeepChild("TimeLeft"):GetComponent(typeof(TextMeshProUGUI))
        self.m_imgDownloadProgress = self.transform:FindDeepChild("DownloadProgress"):GetComponent(typeof(UnityUI.Image))

        self.packContainer = self.transform:FindDeepChild("SlotsCardsPackCountContainer").gameObject
        self.packCountText = self.transform:FindDeepChild("PackCountText"):GetComponent(typeof(TextMeshProUGUI))

        self.goLevelLockNode = self.transform:FindDeepChild("goLevelLockNode").gameObject
        self.goLevelSuo = self.transform:FindDeepChild("LockNode").gameObject
        self.mTimeOutGenerator = TimeOutGenerator:New()
        
        EventHandler:AddListener("onNetTimeNotificationCallback", self)
        EventHandler:AddListener("OnSlotsCardsActivityStateChanged", self)
        EventHandler:AddListener("onAssetbundleDownloading", self)
        EventHandler:AddListener("onAssetbundleDownloaded", self)
        EventHandler:AddListener("onAssetbundleDownloadError", self)
    end

    self:RefreshState()
end

function SlotsCardsUnloadedUI:OnDestroy()
    EventHandler:RemoveListener("onNetTimeNotificationCallback", self)
    EventHandler:RemoveListener("OnSlotsCardsActivityStateChanged", self)
    EventHandler:RemoveListener("onAssetbundleDownloading", self)
    EventHandler:RemoveListener("onAssetbundleDownloaded", self)
    EventHandler:RemoveListener("onAssetbundleDownloadError", self)
end

function SlotsCardsUnloadedUI:Update()
    if self.mTimeOutGenerator:orTimeOut() then
        self:RefreshActivityTime()
    end
end

function SlotsCardsUnloadedUI:RefreshActivityTime()
    local time = SlotsCardsManager:GetRemainTime()
    local str = GameHelper:GetRemainTimeDes(time)
    self.m_textTime.text = str
end

function SlotsCardsUnloadedUI:RefreshUI()
    if not SlotsCardsManager:orActivityOpen() then
        return
    end
        
    local count = SlotsCardsHandler:getAllPackCount()
    if count > 99 then
        self.packCountText.text = "+99"
    else
        self.packCountText.text = count
    end

    self.packContainer:SetActive(count > 0)
end

function SlotsCardsUnloadedUI:OnSlotsCardsActivityStateChanged(time)
    self:RefreshState()
end

function SlotsCardsUnloadedUI:RefreshState()
    if not SlotsCardsManager:orActivityOpen() then
        self.transform.gameObject:SetActive(false)
        return
    end
    
    self.goSlotsCardsUnloaded:SetActive(false)
    self.m_entryBtn.gameObject:SetActive(false)
    self.goLevelSuo:SetActive(not SlotsCardsManager:orLevelOk())

    self.transform.gameObject:SetActive(true)
    if GameConfig.Instance.orUseAssetBundle then
        if SlotsCardsBundleHandler:orExistBundle() then
            self.m_entryBtn.gameObject:SetActive(true)
        else
            self.goSlotsCardsUnloaded:SetActive(true)
            self.m_imgDownloadProgress.fillAmount = 1.0
            SlotsCardsBundleHandler:StartDownloadAndLoadBundle()
        end
    else
        self.m_entryBtn.gameObject:SetActive(true)
    end 

    self:RefreshUI()
end

function SlotsCardsUnloadedUI:onSlotsCardsClicked()
    GlobalAudioHandler:PlayBtnSound()

    if not SlotsCardsManager:orLevelOk() then
        LockTip:ShowWithLevel(self.goLevelLockNode, SlotsCardsManager.m_nUnlockLevel)
        return
    end 

    SlotsCardsMainUIPop:Show()
end

function SlotsCardsUnloadedUI:onNetTimeNotificationCallback()
    self:RefreshState()
end

function SlotsCardsUnloadedUI:onAssetbundleDownloading(bundleName, fProgress)
    if bundleName ~= SlotsCardsManager:GetBundleName() then
        return
    end

    self.m_imgDownloadProgress.fillAmount = 1.0 - fProgress
end

function SlotsCardsUnloadedUI:onAssetbundleDownloaded(bundleName)
    if bundleName ~= SlotsCardsManager:GetBundleName() then
        return
    end

    self:RefreshState()
end

function SlotsCardsUnloadedUI:onAssetbundleDownloadError(bundleName)
    if bundleName ~= SlotsCardsManager:GetBundleName() then
        return
    end

    self:RefreshState()
end