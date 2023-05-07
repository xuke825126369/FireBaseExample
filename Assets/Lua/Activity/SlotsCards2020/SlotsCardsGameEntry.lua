SlotsCardsGameEntry = {}
function SlotsCardsGameEntry:Show(parent)
    if not LuaHelper.OrGameObjectExist(self.transform) then
        self.transform = parent:FindDeepChild("SlotsCardsEntry")
        self.m_entryBtn = self.transform:FindDeepChild("EntryBtn"):GetComponent(typeof(UnityUI.Button))
        self.m_entryBtn.gameObject:SetActive(false)
        DelegateCache:addOnClickButton(self.m_entryBtn)
        self.m_entryBtn.onClick:AddListener(function()
            self:onSlotsCardsClicked()
        end)
        
        self.m_goUnloaded = self.transform:FindDeepChild("SlotsCardsUnloaded").gameObject
        self.m_goUnloaded:SetActive(true)

        local tr = self.transform:FindDeepChild("DownloadProgress")
        self.m_imgDownloadProgress = tr:GetComponent(typeof(UnityUI.Image))

        LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject,self)
        self.packContainer = self.transform:FindDeepChild("SlotsCardsPackCountContainer").gameObject
        self.packCountText = self.transform:FindDeepChild("PackCountText"):GetComponent(typeof(TextMeshProUGUI))

        self.goLevelSuo = self.transform:FindDeepChild("LockNode").gameObject
        self.mTimeOutGenerator = TimeOutGenerator:New()
        EventHandler:AddListener("OnSlotsCardsActivityStateChanged", self)
        EventHandler:AddListener("onAssetbundleDownloading", self)
        EventHandler:AddListener("onAssetbundleDownloaded", self)
        EventHandler:AddListener("onAssetbundleDownloadError", self)
    end

    self:refreshButtonStatus()
end

function SlotsCardsGameEntry:OnDestroy()
    EventHandler:RemoveListener("OnSlotsCardsActivityStateChanged", self)
    EventHandler:RemoveListener("onAssetbundleDownloading", self)
    EventHandler:RemoveListener("onAssetbundleDownloaded", self)
    EventHandler:RemoveListener("onAssetbundleDownloadError", self)
end

function SlotsCardsGameEntry:OnSlotsCardsActivityStateChanged()
    self:refreshButtonStatus()
end

function SlotsCardsGameEntry:onAssetbundleDownloading(bundleName, downloadProgress)
    if SlotsCardsManager:GetBundleName() ~= bundleName then
        return
    end
    self.m_imgDownloadProgress.fillAmount = 1 - downloadProgress
end

function SlotsCardsGameEntry:onAssetbundleDownloaded(bundleName)
    if SlotsCardsManager:GetBundleName() ~= bundleName then
        return
    end
    self:refreshButtonStatus()
end

function SlotsCardsGameEntry:onAssetbundleDownloadError(bundleName)
    if SlotsCardsManager:GetBundleName() ~= bundleName then
        return
    end
    self:refreshButtonStatus()
end

function SlotsCardsGameEntry:refreshButtonStatus()
    if not SlotsCardsManager:orActivityOpen() then
        self.transform.gameObject:SetActive(false)
        return
    end
    
    self.goLevelSuo:SetActive(not SlotsCardsManager:orLevelOk())
    self.transform.gameObject:SetActive(true)
    if SlotsCardsBundleHandler:orExistBundle() then
        self.m_entryBtn.gameObject:SetActive(true)
        self.m_goUnloaded:SetActive(false)
    else
        self.m_entryBtn.gameObject:SetActive(false)
        self.m_goUnloaded:SetActive(true)
        self.m_imgDownloadProgress.fillAmount = 1.0
        SlotsCardsBundleHandler:StartDownloadAndLoadBundle()
    end     

    self:CheckPackCount()
end

function SlotsCardsGameEntry:CheckPackCount()
    local count = SlotsCardsHandler:getAllPackCount()

    if count > 99 then
        self.packCountText.text = "+99"
    else
        self.packCountText.text = count
    end
    
    self.packContainer:SetActive(count > 0)
end

function SlotsCardsGameEntry:onSlotsCardsClicked()
    if ActiveThemeEntry:orInMove() then
        return
    end

    if not SlotsCardsManager:orLevelOk() then
        local des = string.format("UnLock Level: <color=yellow>%d</color>",  SlotsCardsManager.m_nUnlockLevel)
        TipPoolView:Show(des)
        return
    end
    
    GlobalAudioHandler:PlayBtnSound()
    ThemeLoader:ReturnToLobby()
    SlotsCardsMainUIPop:Show()
end
