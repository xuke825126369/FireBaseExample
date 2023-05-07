RocketFortuneReadyToPlayPop = {}
RocketFortuneReadyToPlayPop.m_btnShowToggle = nil
RocketFortuneReadyToPlayPop.m_goShowTrue = nil
RocketFortuneReadyToPlayPop.m_goShowFalse = nil
RocketFortuneReadyToPlayPop.m_textSpinCount = nil
RocketFortuneReadyToPlayPop.m_trContainer = nil
RocketFortuneReadyToPlayPop.m_bIsShowHint = false
RocketFortuneReadyToPlayPop.m_bPortraitFlag = false

function RocketFortuneReadyToPlayPop:Show(parentTransform)
    if self.transform.gameObject == nil then
        local strPath = "Assets/ActiveNeedLoad/RocketFortune/RocketFortuneReadyToPlayPop.prefab"
        self.transform.gameObject = Unity.Object.Instantiate(Util.getRocketFortunePrefab(strPath))
        self.transform = self.transform.gameObject.transform

        local trPlay = self.transform:FindDeepChild("PlayNowBtn")
        local btnPlayNow = trPlay:GetComponent(typeof(UnityUI.Button))
        self.m_btnShowToggle = self.transform:FindDeepChild("Show"):GetComponent(typeof(UnityUI.Button))
        self.m_goShowTrue = self.m_btnShowToggle.transform:FindDeepChild("ShowTrue").gameObject
        self.m_goShowFalse = self.m_btnShowToggle.transform:FindDeepChild("ShowFalse").gameObject
        self.m_textSpinCount = self.transform:FindDeepChild("SpinCount"):GetComponent(typeof(TextMeshProUGUI))
        self.m_trContainer = self.transform:FindDeepChild("Container")

        self.m_btnShowToggle.onClick:AddListener(function()
            self:onShowToggleBtnClick()
        end)
        DelegateCache:addOnClickButton(self.m_btnShowToggle)
        btnPlayNow.onClick:AddListener(function()
            self:onPlayNowBtnClick()
        end)
        DelegateCache:addOnClickButton(btnPlayNow)
        local btn = self.transform:FindDeepChild("LaterBtn"):GetComponent(typeof(UnityUI.Button))
        btn.onClick:AddListener(function()
            self:onLaterBtnClicked()
        end)
        DelegateCache:addOnClickButton(btn)
        self.popController = PopController:new(self.transform.gameObject)
    end

    self.m_textSpinCount.text = "SPIN LEFT: "..RocketFortuneDataHandler.data.nAction
    self.m_bIsShowHint = RocketFortuneDataHandler.bIsShowHint

    self.m_goShowTrue:SetActive(self.m_bIsShowHint)
    self.m_goShowFalse:SetActive(not self.m_bIsShowHint)

    parentTransform = parentTransform or LobbyScene.popCanvas
    self.transform:SetParent(parentTransform, false)
    self.popController:show(function()
        self.m_bPortraitFlag = false
        if ThemeLoader.themeKey ~= nil then
            self.m_bPortraitFlag = GameLevelUtil:isPortraitLevel()
        end
        if self.m_bPortraitFlag then
            self.m_trContainer.localScale = Unity.Vector3.one * 0.9
        else
            self.m_trContainer.localScale = Unity.Vector3.one
        end
    end)
end

function RocketFortuneReadyToPlayPop:onLaterBtnClicked()
    --TODO 关闭音效
    self.popController:hide(true)
end

function RocketFortuneReadyToPlayPop:onPlayNowBtnClick()
    ViewScaleAni:Hide(self.transform.gameObject)
    RocketFortuneMainUIPop:Show()
end

function RocketFortuneReadyToPlayPop:OnDestroy()
    
end

function RocketFortuneReadyToPlayPop:onShowToggleBtnClick()
    self.m_bIsShowHint = not self.m_bIsShowHint
    self.m_goShowTrue:SetActive(self.m_bIsShowHint)
    self.m_goShowFalse:SetActive(not self.m_bIsShowHint)
    RocketFortuneDataHandler.bIsShowHint = self.m_bIsShowHint
end