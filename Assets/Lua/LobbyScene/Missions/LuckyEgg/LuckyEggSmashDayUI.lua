local LuckyEggSmashDayUI = {}

function LuckyEggSmashDayUI:Show()
    if not LuaHelper.OrGameObjectExist(self.transform) then
        local goPrefab = AssetBundleHandler:LoadMissionAsset("Missions/LuckyEgg/SmashDay.prefab")
        local goPanel = Unity.Object.Instantiate(goPrefab)
        self.transform = goPanel.transform
        self.transform:SetParent(MissionMainUIPop.m_trPopNode, false)
        self.transform.localScale = Unity.Vector3.one
        self.transform.localPosition = Unity.Vector3.zero
        LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
        self.transform.gameObject:SetActive(false)

        self.m_ani = self.transform:GetComponentInChildren(typeof(Unity.Animator))
        self.m_trContent = self.transform:FindDeepChild("Content")
        self.m_timeLeftText = self.transform:FindDeepChild("TextShiJian"):GetComponent(typeof(TextMeshProUGUI))
        self.m_btnClose = self.transform:FindDeepChild("BtnClose"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(self.m_btnClose)
        self.m_btnClose.onClick:AddListener(function()
            GlobalAudioHandler:PlayBtnSound()
            self:onCloseClicked()
        end)
    end

    local nowSecond = TimeHandler:GetServerTimeStamp()
    local timediff = LuckyEggHandler:GetSeasonEndTime() - nowSecond
    local days = timediff // (3600*24)
    local strTimeInfo = ""
    if days > 0 then
        -- 活动在几天后开启
        strTimeInfo = string.format("%d DAYS!", days)
        self.m_timeLeftText.text = "in "..strTimeInfo
        GlobalAudioHandler:PlaySound("popup")
        local bPortraitFlag = not ScreenHelper:isLandScape()
        if bPortraitFlag then
            self.m_trContent.localScale = Unity.Vector3.one * 0.65
        else
            self.m_trContent.localScale = Unity.Vector3.one
        end
        ViewScaleAni:Show(self.transform.gameObject)
    end
end

function LuckyEggSmashDayUI:Hide()
    ViewScaleAni:Hide(self.transform.gameObject)
end

function LuckyEggSmashDayUI:onCloseClicked()
    GlobalAudioHandler:PlayBtnSound()
    self:Hide()
end

return LuckyEggSmashDayUI