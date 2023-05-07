require("Lua.Activity.Lounge.MedalMasterMainUI")
require("Lua.Activity.Lounge.LoungeConfig")
require("Lua.Activity.Lounge.LoungeHandler")
require("Lua.Activity.Lounge.MedalChestPopEffect")

MedalMasterEntryUI = {}
function MedalMasterEntryUI:Init()
    if not LuaHelper.OrGameObjectExist(self.transform) then
        self.m_bInitFlag = true
        self.transform = LobbyView.transform:FindDeepChild("BottomMedalMasterEntry")
        LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
        self.transform.gameObject:SetActive(false)

        self.m_entryBtn = self.transform:FindDeepChild("EntryBtn"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(self.m_entryBtn)
        self.m_entryBtn.onClick:AddListener(function()
            self:onMedalMasterClicked(self.m_entryBtn)
        end)
        self.m_goUnloaded = self.transform:FindDeepChild("UnloadedNode").gameObject
        self.m_goUnloaded:SetActive(true)

        local tr = self.transform:FindDeepChild("DownloadProgress")
        self.m_imgDownloadProgress = tr:GetComponent(typeof(UnityUI.Image))
        self.m_imgDownloadProgress.fillAmount = 1

        local tr = self.transform:FindDeepChild("CountDownNode")
        self.m_goCountDownNode = tr.gameObject
        self.m_textMeshProTimeLeft = tr:GetComponentInChildren(typeof(TextMeshProUGUI))
        self.m_goCountDownNode:SetActive(false)

        self.m_goLockNode = self.transform:FindDeepChild("LockNode").gameObject

        local trCountNode = self.transform:FindDeepChild("CountContainer")
        self.m_goCountContainer = trCountNode.gameObject
        self.m_textCount = trCountNode:FindDeepChild("nCountText"):GetComponent(typeof(TextMeshProUGUI))
        self.m_goCountContainer:SetActive(false)

        self.goLevelLockNode = self.transform:FindDeepChild("goLevelLockNode").gameObject
        
        EventHandler:AddListener("onNetTimeNotificationCallback", self)
        EventHandler:AddListener("addLoungeChestNotification", self)
        EventHandler:AddListener("OnLoungeActivityStateChanged", self)
        EventHandler:AddListener("onAssetbundleDownloading", self)
        EventHandler:AddListener("onAssetbundleDownloaded", self)
        EventHandler:AddListener("onAssetbundleDownloadError", self)
    end
    
    self:RefreshState()
end

function MedalMasterEntryUI:OnDestroy()
    EventHandler:RemoveListener("onNetTimeNotificationCallback", self)
    EventHandler:RemoveListener("addLoungeChestNotification", self)
    EventHandler:RemoveListener("OnLoungeActivityStateChanged", self)
    EventHandler:RemoveListener("onAssetbundleDownloading", self)
    EventHandler:RemoveListener("onAssetbundleDownloaded", self)
    EventHandler:RemoveListener("onAssetbundleDownloadError", self)
end

function MedalMasterEntryUI:Hide()
    self.transform.gameObject:SetActive(false)
end

function MedalMasterEntryUI:RefreshState()
    if not LoungeHandler:isLoungeMember() then
        self.transform.gameObject:SetActive(false)
        return
    end

    self.m_goLockNode:SetActive(false)
    self.m_goUnloaded:SetActive(false)
    self.m_entryBtn.gameObject:SetActive(false)

    self.transform.gameObject:SetActive(true)
    if GameConfig.Instance.orUseAssetBundle then
        if LoungeBundleHandler:orExistBundle() then
            self.m_goUnloaded:SetActive(false)
            self.m_entryBtn.gameObject:SetActive(true)
            self.m_goCountContainer:SetActive(true)
        else
            self.m_goUnloaded:SetActive(true)
            self.m_imgDownloadProgress.fillAmount = 1.0
            LoungeBundleHandler:StartDownloadAndLoadBundle()
        end
    else
        self.m_goUnloaded:SetActive(false)
        self.m_entryBtn.gameObject:SetActive(true)
        self.m_goCountContainer:SetActive(true)
    end

    self.m_goCountContainer:SetActive(false)
    if LoungeManager:orActivityOpen() then
        local nChestCount = self:GetChestCount()
        self.m_goCountContainer:SetActive(nChestCount > 0)
        self.m_textCount.text = nChestCount
    end
    
end

function MedalMasterEntryUI:GetChestCount()
    local data = LoungeHandler.data.activityData.listMedalMasterData
    local nChestNum = 0
    for i = 1, 4 do
        nChestNum = nChestNum + data.listChestCount[i]
    end
    return nChestNum
end

function MedalMasterEntryUI:onMedalMasterClicked(btn)
    GlobalAudioHandler:PlayBtnSound()

    if not LoungeManager:orLevelOk() then
        LockTip:ShowWithLevel(self.goLevelLockNode, LoungeManager.m_nUnlockLevel)
        return
    end 

    LoungeHallUI:Show()
end

function MedalMasterEntryUI:addLoungeChestNotification(nChestNum)
    self:RefreshState()
end

function MedalMasterEntryUI:OnLoungeActivityStateChanged()
    self:RefreshState()
end

function MedalMasterEntryUI:onNetTimeNotificationCallback()
    self:RefreshState()
end

function MedalMasterEntryUI:onAssetbundleDownloading(bundleName, fProgress)
    if bundleName ~= LoungeManager:GetBundleName() then
        return
    end
    
    self.m_imgDownloadProgress.fillAmount = 1.0 - fProgress
end

function MedalMasterEntryUI:onAssetbundleDownloaded(bundleName)
    if bundleName ~= LoungeManager:GetBundleName() then
        return
    end

    self:RefreshState()
end

function MedalMasterEntryUI:onAssetbundleDownloadError(bundleName)
    if bundleName ~= LoungeManager:GetBundleName() then
        return
    end

    self:RefreshState()
end