local yield_return = (require 'cs_coroutine').yield_return

ActiveLobbyEntry = {}
ActiveLobbyEntry.m_entryBtn = nil
ActiveLobbyEntry.m_bInitFlag = false
ActiveLobbyEntry.m_imgDownloadProgress = nil
ActiveLobbyEntry.m_bAssetReady = false -- 每次登入游戏都检查一下..

function ActiveLobbyEntry:Init()
    EventHandler:AddListener("onActiveSeasonStart", self)
    EventHandler:AddListener("onActiveSeasonEnd", self)
    EventHandler:AddListener("onLevelUp", self)
    EventHandler:AddListener("onActiveMsgCountChanged", self)
    EventHandler:AddListener("onAssetbundleDownloading", self)
    EventHandler:AddListener("onAssetbundleDownloaded", self)
    EventHandler:AddListener("onAssetbundleDownloadError", self)
    
    if ActiveManager:orActivityOpen() then
        self:onActiveSeasonStart()
    end
end

function ActiveLobbyEntry:initUI(parent)
    if LuaHelper.OrGameObjectExist(self.transform) then
        return
    end

    self.transform = parent:FindDeepChild((ActiveManager.activeType).."Entry")
    LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)

    self.m_entryBtn = self.transform:FindDeepChild("EntryBtn"):GetComponent(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(self.m_entryBtn)
    self.m_entryBtn.onClick:AddListener(function()
        self:onClicked()
    end)    

    self.m_goLoaded = self.m_entryBtn.gameObject
    self.m_goLoaded:SetActive(false)
    self.m_goUnloaded = self.transform:FindDeepChild("Unloaded").gameObject
    self.m_goUnloaded:SetActive(false)

    local tr = self.transform:FindDeepChild("DownloadProgress")
    self.m_imgDownloadProgress = tr:GetComponent(typeof(UnityUI.Image))
    self.m_imgDownloadProgress.fillAmount = 1

    self.goCountBg = self.transform:FindDeepChild("CountBg").gameObject
    self.m_textCount = self.transform:FindDeepChild("textCount"):GetComponent(typeof(TextMeshProUGUI))

    self.goActivityRemainTime = self.transform:FindDeepChild("goActivityRemainTime").gameObject
    self.goActivityRemainTime:SetActive(true)
    self.textDate = self.transform:FindDeepChild("textDate"):GetComponent(typeof(TextMeshProUGUI))
    self.goLevelLockNode = self.transform:FindDeepChild("goLevelLockNode").gameObject
    self.goLevelSuo = self.transform:FindDeepChild("LockNode").gameObject
    self.mTimeOutGenerator = TimeOutGenerator:New()
end

function ActiveLobbyEntry:Update()
    if self.mTimeOutGenerator:orTimeOut() then
        self:onActiveTimeChanged()
    end
end

function ActiveLobbyEntry:onActiveMsgCountChanged()
    if self.transform == nil then return end
    local nAction = ActiveManager.dataHandler.data["nAction"]
    self.goCountBg:SetActive(nAction > 0)
    self.m_textCount.text = nAction
end

function ActiveLobbyEntry:onClicked()
    GlobalAudioHandler:PlayBtnSound()

    if not ActiveManager:orLevelOk() then
        LockTip:ShowWithLevel(self.goLevelLockNode, ActiveManager.nUnlockLevel)
        return
    end
    
    ActiveManager.mainUIPop:Show()
end 

function ActiveLobbyEntry:onActiveSeasonStart()
    self:initUI(LobbyScene.transform)
    self.transform.gameObject:SetActive(true)
    self:RefreshState()
end

function ActiveLobbyEntry:onActiveSeasonEnd()
    if not LuaHelper.OrGameObjectExist(self.transform) then
        return
    end

    self.transform.gameObject:SetActive(false)
    self.transform = nil
end

function ActiveLobbyEntry:onLevelUp()
    if not LuaHelper.OrGameObjectExist(self.transform) then
        return
    end

    self:RefreshState()
end

function ActiveLobbyEntry:onActiveTimeChanged()
    if not ActiveManager:orActivityOpen() then
        return
    end
    
    if not LuaHelper.OrGameObjectExist(self.transform) then
        return
    end

    local time = ActiveManager:GetRemainTime()
    if time <= 0 then
        self.transform.gameObject:SetActive(false)
    else
        self.textDate.text = GameHelper:GetRemainTimeDes(time)
    end
end

function ActiveLobbyEntry:onAssetbundleDownloading(bundleName, downloadProgress)
    if not LuaHelper.OrGameObjectExist(self.transform) then
        return
    end
    
    if ActiveManager:GetBundleName() ~= bundleName then
        return
    end

    self.m_imgDownloadProgress.fillAmount = 1 - downloadProgress
end

function ActiveLobbyEntry:onAssetbundleDownloaded(bundleName)
    if not LuaHelper.OrGameObjectExist(self.transform) then
        return
    end

    if ActiveManager:GetBundleName() ~= bundleName then
        return
    end

    self:RefreshState()
end

function ActiveLobbyEntry:onAssetbundleDownloadError(bundleName)
    if not LuaHelper.OrGameObjectExist(self.transform) then
        return
    end

    if ActiveManager:GetBundleName() ~= bundleName then
        return
    end

    self:RefreshState()
end

function ActiveLobbyEntry:RefreshState()
    if not LuaHelper.OrGameObjectExist(self.transform) then
        return
    end 

    if not ActiveManager:orActivityOpen() then
        self.transform.gameObject:SetActive(false)
        return
    end

    self.m_goLoaded:SetActive(false)
    self.m_goUnloaded:SetActive(false)
    self.goLevelSuo:SetActive(not ActiveManager:orLevelOk())
    
    if GameConfig.Instance.orUseAssetBundle then
        if ActivityBundleHandler:orExistBundle() then
            self.m_goLoaded:SetActive(true)
        else
            self.m_goUnloaded:SetActive(true)
            ActivityBundleHandler:StartDownloadAndLoadBundle()
        end
    else
        self.m_goLoaded:SetActive(true)
    end

    self:onActiveTimeChanged()
    self:onActiveMsgCountChanged()
end