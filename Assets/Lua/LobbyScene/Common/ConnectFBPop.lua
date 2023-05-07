

ConnectFBPop = {}

function ConnectFBPop:isActiveShow()
    return self.gameObject and self.gameObject.activeInHierarchy
end

function ConnectFBPop:createAndShow(parentTransform)
    if(not self.gameObject) then
        self.tableName = "ConnectFBPop"
        self.gameObject = Unity.Object.Instantiate(Util.getHotPrefab("Assets/BaseHotAdd/Prefabs/prefab/ConnectFBPop.prefab"))
        self.transform = self.gameObject.transform
        LuaAutoBindMonoBehaviour.Bind(self.gameObject, self)
        self.popController = PopController:new(self.gameObject)
        
        local container = nil
        if GameConfig.IS_SIGNIN_APPLESUPPORT then
            container = self.transform:FindDeepChild("IOSBtnContainer")
            self.appleLoginBtn = container:FindDeepChild("AppleButton"):GetComponent(typeof(UnityUI.Button))
            DelegateCache:addOnClickButton(self.appleLoginBtn)
            self.appleLoginBtn.onClick:AddListener(function()
                self:onAppleConnectBtnClicked()
            end)
        else
            container = self.transform:FindDeepChild("AndroidBtnContainer")
        end
        container.gameObject:SetActive(true)
        self.bonusTipText = self.transform:FindDeepChild("BonusTipText"):GetComponent(typeof(TextMeshProUGUI))
        self.loginBtn = container:FindDeepChild("FBButton"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(self.loginBtn)
        self.loginBtn.onClick:AddListener(function()
            self:onConnectBtnClicked()
        end)
        self.logoutBtn = container:FindDeepChild("LogoutButton"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(self.logoutBtn)
        self.logoutBtn.onClick:AddListener(function()
            self:onLogoutBtnClicked()
        end)
        local btn = self.transform:FindDeepChild("CloseBtn"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(btn)
        btn.onClick:AddListener(function()
            self:onCloseBtnClicked()
        end)
        self.firstInfo = self.transform:FindDeepChild("FirstReward").gameObject
    end
    local bIsLogin = FBHandler:isLoggedIn()
    self.firstInfo:SetActive(not bIsLogin)
    self.loginBtn.gameObject:SetActive(not bIsLogin)
    self.logoutBtn.gameObject:SetActive(bIsLogin)

    if GameConfig.IS_SIGNIN_APPLESUPPORT then
        self.appleLoginBtn.gameObject:SetActive(AppleSignHandler.userId == nil)
    end
    self.bonusTipText.text = string.format("Get $ %s Coins\n For The First Time", MoneyFormatHelper.numWithCommas(GameConfig.CONNECTFB_COINS))
    parentTransform = parentTransform or LobbyScene.popCanvas
    self.transform:SetParent(parentTransform, false)
    ViewScaleAni:Show(self.transform.gameObject)
end

function ConnectFBPop:onConnectBtnClicked()
    AudioHandler:PlayBtnSound()
    FBHandler:login()
    ConnectFBInfoPop:createAndShow()
    ViewScaleAni:Hide(self.transform.gameObject)
end

function ConnectFBPop:onAppleConnectBtnClicked()
    AudioHandler:PlayBtnSound()
    AppleSignHandler:login()
    ConnectAppleInfoPop:createAndShow()
    ViewScaleAni:Hide(self.transform.gameObject)
end

function ConnectFBPop:onLogoutBtnClicked()
    AudioHandler:PlayBtnSound()
    FBHandler:logout()
    ViewScaleAni:Hide(self.transform.gameObject)
end

function ConnectFBPop:onCloseBtnClicked()
    GlobalAudioHandler:PlayBtnSound()
    ViewScaleAni:Hide(self.transform.gameObject)
end