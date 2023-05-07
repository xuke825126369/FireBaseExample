ConnectFBInfoPop = {}

function ConnectFBInfoPop:isActiveShow()
    return self.gameObject and self.gameObject.activeInHierarchy
end

function ConnectFBInfoPop:createAndShow()
    if(not self.gameObject) then
        self.tableName = "ConnectFBInfoPop"
        self.gameObject = Unity.Object.Instantiate(Util.getHotPrefab("Assets/BaseHotAdd/Prefabs/prefab/ConnectFBInfoPop.prefab"))
        self.transform = self.gameObject.transform
        LuaAutoBindMonoBehaviour.Bind(self.gameObject, self)
        self.infoText = self.transform:FindDeepChild("InfoText"):GetComponent(typeof(TextMeshProUGUI))
    end
    self.transform:SetParent(LobbyScene.popCanvas, false)
    self.gameObject:SetActive(true)
    NotificationHandler:addObserver(self, "onFBConnectChangedNotifictation")
    NotificationHandler:addObserver(self, "onProfileNotifictation")
    NotificationHandler:addObserver(self, "onSynDataToNetDoneNotificationCallback")
    self.infoText.text = "Login to Facebook, please wait"
end

function ConnectFBInfoPop:OnDisable()
    NotificationHandler:removeObserver(self)
end

function ConnectFBInfoPop:onFBConnectChangedNotifictation()
    if FBHandler:isLoggedIn() then
        self.infoText.text = "Login success, Fetching Profile"
    else
        self.infoText.text = "Login Failed, Please Retry!"
        LeanTween.delayedCall(2, function()
            self.gameObject:SetActive(false)
        end)
    end    
end

function ConnectFBInfoPop:onProfileNotifictation()
    self.infoText.text = "Synchronizing data from Server"
    NetHandler:synDataToNetRequest()
end

function ConnectFBInfoPop:onSynDataToNetDoneNotificationCallback()
    if (not DBHandler:hasConnectedFB()) and (not DBHandler:hasConnectedApple()) then
        self.infoText.text = string.format("Added %s Coins", MoneyFormatHelper.numWithCommas(GameConfig.CONNECTFB_COINS))
        PlayerHandler:AddCoin(GameConfig.CONNECTFB_COINS)
        DBHandler:setConnectedFB()
        UITop:updateCoinCountInUi()
        LeanTween:delayedCall(2, function()
            self.gameObject:SetActive(false)
            Scene:loadLobby()
        end)
    else
        self.gameObject:SetActive(false)
        Scene:loadLobby()
    end
end
