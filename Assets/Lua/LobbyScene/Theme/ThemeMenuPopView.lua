ThemeMenuPopView = {}

function ThemeMenuPopView:Show()
    if not LuaHelper.OrGameObjectExist(self.transform) then
        local goPrefab = AssetBundleHandler:LoadAsset("lobby", "View/Theme/ThemeMenuPop.prefab")
        local goPanel = Unity.Object.Instantiate(goPrefab)
        self.transform = goPanel:GetComponent(typeof(Unity.RectTransform))
        self.transform:SetParent(ThemeVideoScene.mPopScreenCanvas, false)
        self.transform.localScale = Unity.Vector3.one
        self.transform.localPosition = Unity.Vector3.zero
        LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
        self.transform.gameObject:SetActive(false)
        self.transform.position = UITop.m_transform:FindDeepChild("MenuPopPoint").position

        self.bgRectTransform = self.transform:FindDeepChild("MenuBG"):GetComponent(typeof(Unity.RectTransform))
        self.soundOnGameObject = self.transform:FindDeepChild("SoundOn").gameObject
        self.soundOffGameObject = self.transform:FindDeepChild("SoundOff").gameObject
        self.m_userIdText = self.transform:FindDeepChild("UserId"):GetComponent(typeof(TextMeshProUGUI))

        self.mSoundBtn = self.transform:FindDeepChild("Sound"):GetComponent(typeof(UnityUI.Button))
        self.mSoundBtn.onClick:AddListener(function()
            GlobalAudioHandler:PlayBtnSound()
            self:onClickSoundBtn()
        end)

        self.mPayTable = self.transform:FindDeepChild("PayTableBtn"):GetComponent(typeof(UnityUI.Button))
        self.mPayTable.onClick:AddListener(function()
            GlobalAudioHandler:PlayBtnSound()
            self:onClickPayTableBtn()
        end)
    end

    self.m_userIdText.text = "ID:"..PlayerHandler.nUserId
    self.soundOnGameObject:SetActive(not SettingHandler:isMute())
    self.soundOffGameObject:SetActive(SettingHandler:isMute())
    SceneSlotGame.m_bUIState = true
    SlotsGameLua.m_bReelPauseFlag = true
    ViewScaleAni:Show(self.transform.gameObject)
end

function ThemeMenuPopView:Hide()
    ViewScaleAni:Hide(self.transform.gameObject)
    SceneSlotGame.m_bUIState = false
    SlotsGameLua.m_bReelPauseFlag = false
end

function ThemeMenuPopView:Update()
    if Unity.Input.GetMouseButton(0) or Unity.Input.touchCount == 1 then
        local pointerPosition = (Unity.Input.touchCount == 1) and Unity.Input.touches[0].position or Unity.Vector2(Unity.Input.mousePosition.x, Unity.Input.mousePosition.y)
        if LuaHelper.orScreenPositionOutOfViewFrustumd(pointerPosition) then
            return
        end 
        
        local touchInsidePop = false
        for i = 0, self.bgRectTransform.childCount - 1 do
            local menuItem = self.bgRectTransform:GetChild(i)
            if Unity.RectTransformUtility.RectangleContainsScreenPoint(menuItem, pointerPosition, Unity.Camera.main) then
                touchInsidePop = true
                break
            end
        end

        if not touchInsidePop then
            self:Hide()
        end
    end
end

function ThemeMenuPopView:onClickCloseBtn()
    self:Hide()
end

function ThemeMenuPopView:onClickSoundBtn()
    local isMute = SettingHandler:isMute()
    SettingHandler:setMute(not isMute)
    self.soundOnGameObject:SetActive(isMute)
    self.soundOffGameObject:SetActive(not isMute)
end

function ThemeMenuPopView:onClickPayTableBtn()
    UIPayTable:Show()
end
