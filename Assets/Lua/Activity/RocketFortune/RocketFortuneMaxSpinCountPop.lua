RocketFortuneMaxSpinCountPop = {}
RocketFortuneMaxSpinCountPop.m_textSpinCount = nil
RocketFortuneMaxSpinCountPop.m_trContainer = nil
RocketFortuneMaxSpinCountPop.m_bIsTip = false

function RocketFortuneMaxSpinCountPop:Show(parentTransform)
    if self.m_bIsTip then
        return
    end
    if RocketFortuneMainUIPop.transform ~= nil then
        if RocketFortuneMainUIPop.transform.gameObject.activeSelf then
            return
        end
    end
    if self.transform.gameObject == nil then
        local strPath = "Assets/ActiveNeedLoad/RocketFortune/RocketFortuneMaxSpinCountPop.prefab"
        self.transform.gameObject = Unity.Object.Instantiate(Util.getRocketFortunePrefab(strPath))
        self.transform = self.transform.gameObject.transform

        self.m_trContainer = self.transform:FindDeepChild("Container")
        local trPlay = self.transform:FindDeepChild("PlayBtn")
        self.btnPlayNow = trPlay:GetComponent(typeof(UnityUI.Button))
        self.m_textSpinCount = self.transform:FindDeepChild("SpinCount"):GetComponent(typeof(TextMeshProUGUI))

        self.btnPlayNow.onClick:AddListener(function()
            self:onPlayNowBtnClick()
        end)
        DelegateCache:addOnClickButton(self.btnPlayNow)
        self.m_closeBtn = self.transform:FindDeepChild("CloseBtn"):GetComponent(typeof(UnityUI.Button))
        self.m_closeBtn.onClick:AddListener(function()
            self:Hide()
        end)
        DelegateCache:addOnClickButton(self.m_closeBtn)
        self.popController = PopController:new(self.transform.gameObject)
        LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
    end

    self.m_textSpinCount.text = "SPINS SAVED: "..RocketFortuneDataHandler.data.nAction
    self.m_closeBtn.interactable = true
    self.btnPlayNow.interactable = true
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

function RocketFortuneMaxSpinCountPop:onPlayNowBtnClick()
    self.btnPlayNow.interactable = false
    ViewScaleAni:Hide(self.transform.gameObject)
    RocketFortuneMainUIPop:Show()
    self.m_bIsTip = true
end

function RocketFortuneMaxSpinCountPop:OnDestroy()
    
end

function RocketFortuneMaxSpinCountPop:Hide()
    self.m_closeBtn.interactable = false
    self.popController:hide(true)
end