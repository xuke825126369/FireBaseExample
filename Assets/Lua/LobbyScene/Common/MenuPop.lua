MenuPop = {}

function MenuPop:Show()
    if not LuaHelper.OrGameObjectExist(self.transform) then
        local goPrefab = AssetBundleHandler:LoadAsset("lobby", "View/MenuPop.prefab")
        local goPanel = Unity.Object.Instantiate(goPrefab)
        self.transform = goPanel:GetComponent(typeof(Unity.RectTransform))
        self.transform:SetParent(LobbyScene.popCanvas, false)
        self.transform.localScale = Unity.Vector3.one
        self.transform.localPosition = Unity.Vector3.zero
        LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
        self.transform.gameObject:SetActive(false)
        self.transform.position = LobbyView.mMenuBtn.transform:FindDeepChild("MenuPopPoint").position

        self.bgRectTransform = self.transform:FindDeepChild("MenuBG"):GetComponent(typeof(Unity.RectTransform))
        self.soundOnGameObject = self.transform:FindDeepChild("SoundOn").gameObject
        self.soundOffGameObject = self.transform:FindDeepChild("SoundOff").gameObject
        self.m_userIdText = self.transform:FindDeepChild("UserId"):GetComponent(typeof(TextMeshProUGUI))

        self.mSoundBtn = self.transform:FindDeepChild("Sound"):GetComponent(typeof(UnityUI.Button))
        self.mSoundBtn.onClick:AddListener(function()
            GlobalAudioHandler:PlayBtnSound()
            self:onClickSoundBtn()
        end)

        self.mDeleteAccountBtn = self.transform:FindDeepChild("DeleteAccount"):GetComponent(typeof(UnityUI.Button))
        self.mDeleteAccountBtn.onClick:AddListener(function()
            GlobalAudioHandler:PlayBtnSound()
            self:onClickDeleteAccountBtn()
        end)

        self.mContactUsBtn = self.transform:FindDeepChild("ContactUs"):GetComponent(typeof(UnityUI.Button))
        self.mContactUsBtn.onClick:AddListener(function()
            GlobalAudioHandler:PlayBtnSound()
            self:onClickContactUsBtn()
        end)

        self.mRateUsBtn = self.transform:FindDeepChild("RateUs"):GetComponent(typeof(UnityUI.Button))
        self.mRateUsBtn.onClick:AddListener(function()
            GlobalAudioHandler:PlayBtnSound()
            self:onClickRateUsBtn()
        end)

        self.mLogOutBtn = self.transform:FindDeepChild("LogOut"):GetComponent(typeof(UnityUI.Button))
        self.mLogOutBtn.onClick:AddListener(function()
            GlobalAudioHandler:PlayBtnSound()
            self:onClickLogOutBtn()
        end)
    end

    self.m_userIdText.text = "ID:"..PlayerHandler.nUserId
    self.soundOnGameObject:SetActive(not SettingHandler:isMute())
    self.soundOffGameObject:SetActive(SettingHandler:isMute())

    ViewScaleAni:Show(self.transform.gameObject)
end

function MenuPop:Hide()
    ViewScaleAni:Hide(self.transform.gameObject)
end

function MenuPop:Update()
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

function MenuPop:onClickCloseBtn()
    self:Hide()
end

function MenuPop:onClickSoundBtn()
    local isMute = SettingHandler:isMute()
    SettingHandler:setMute(not isMute)
    self.soundOnGameObject:SetActive(isMute)
    self.soundOffGameObject:SetActive(not isMute)
end 

function MenuPop:onClickContactUsBtn()
    --联系我们
    self:Hide()
        
    WindowLoadingView:Show()
    local data = rapidjson.encode(UserInfoHandler.data)
	CS.FireBaseDb.Instance:UpdateUserData(PlayerHandler.nUserId, data, function(bSuccess)
        WindowLoadingView:Hide()
        if bSuccess then
            local mailto = "support@firexgame.com"
            local subject = Unity.Application.productName.." Support"
            local body = "User ID: "..PlayerHandler.nUserId.."\r\n"
            body = body.."Version: "..Unity.Application.version.."\r\n"
            body = body.."\r\n--------------add message below----------\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n"
            subject = string.gsub(UnityWebRequest.EscapeURL(subject), "+", "%%20")
            body = string.gsub(UnityWebRequest.EscapeURL(body), "+", "%%20")
            Unity.Application.OpenURL("mailto:"..mailto.."?subject="..subject.."&body="..body)
        else
            CommonDialogBox:ShowSureUI("Connection failure!")
        end
    end)
end

function MenuPop:onClickRateUsBtn()
    -- 点赞
    self:Hide()
    if GameConfig.PLATFORM_ANDROID then
        Unity.Application.OpenURL("market://details?id="..Unity.Application.identifier)
    elseif GameConfig.PLATFORM_IOS then
        Unity.Application.OpenURL("https://itunes.apple.com/app/id1523002041?action=write-review")
    end
end

function MenuPop:onClickDeleteAccountBtn()
    -- 删除账户
    self:Hide()
    DeleteAccountView:Show()
end

function MenuPop:onClickLogOutBtn()
    --退出登陆
    WindowLoadingView:Show()
    CS.FireBaseLogin.Instance:SignOut()
    LeanTween.delayedCall(2.0, function()
        Unity.Application.Quit()
    end)
end
