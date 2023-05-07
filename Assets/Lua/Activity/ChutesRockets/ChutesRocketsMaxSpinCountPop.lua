

ChutesRocketsMaxSpinCountPop = {}
ChutesRocketsMaxSpinCountPop.m_textSpinCount = nil
ChutesRocketsMaxSpinCountPop.m_trContainer = nil
ChutesRocketsMaxSpinCountPop.m_bIsTip = false

function ChutesRocketsMaxSpinCountPop:Show(parentTransform)
    if self.m_bIsTip then
        return
    end
    if ChutesRocketsMainUIPop.transform ~= nil then
        if ChutesRocketsMainUIPop.transform.gameObject.activeSelf then
            return
        end
    end
    if self.transform.gameObject == nil then
        local strPath = "Assets/ActiveNeedLoad/ChutesRockets/ChutesRocketsMaxSpinCountPop.prefab"
        self.transform.gameObject = Unity.Object.Instantiate(Util.getChutesRocketsPrefab(strPath))
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

    self.m_textSpinCount.text = "SPINS SAVED: "..ChutesRocketsDataHandler.data.nAction
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

function ChutesRocketsMaxSpinCountPop:onPlayNowBtnClick()
    self.btnPlayNow.interactable = false
    ViewScaleAni:Hide(self.transform.gameObject)
    ChutesRocketsMainUIPop:Show()
    self.m_bIsTip = true
end

function ChutesRocketsMaxSpinCountPop:OnDestroy()
    
end

function ChutesRocketsMaxSpinCountPop:Hide()
    self.m_closeBtn.interactable = false
    self.popController:hide(true)
end