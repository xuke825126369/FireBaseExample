ConnectAppleInfoPop = {}

function ConnectAppleInfoPop:isActiveShow()
    return self.gameObject and self.gameObject.activeInHierarchy
end

function ConnectAppleInfoPop:createAndShow()
    if(not self.gameObject) then
        self.tableName = "ConnectAppleInfoPop"
        self.gameObject = Unity.Object.Instantiate(Util.getHotPrefab("Assets/BaseHotAdd/Prefabs/prefab/ConnectFBInfoPop.prefab"))
        self.transform = self.gameObject.transform
        LuaAutoBindMonoBehaviour.Bind(self.gameObject, self)
        self.infoText = self.transform:FindDeepChild("InfoText"):GetComponent(typeof(TextMeshProUGUI))
    end
    self.transform:SetParent(LobbyScene.popCanvas, false)
    self.gameObject:SetActive(true)
    NotificationHandler:addObserver(self, "onAppleConnectChangedNotifictation")
    NotificationHandler:addObserver(self, "onSynDataToNetDoneNotificationCallback")
    self.infoText.text = "Sign in with Apple, please wait"
end

function ConnectAppleInfoPop:OnDisable()
    NotificationHandler:removeObserver(self)
end

function ConnectAppleInfoPop:onAppleConnectChangedNotifictation()
    if AppleSignHandler.userId ~= nil then
        self.infoText.text = "Synchronizing data from Server"
        NetHandler:synDataToNetRequest()
    else
        self.infoText.text = "Login Failed, Please Retry!"
        LeanTween.delayedCall(2, function()
            self.gameObject:SetActive(false)
        end)
    end    
end

function ConnectAppleInfoPop:onSynDataToNetDoneNotificationCallback()
    if (not DBHandler:hasConnectedApple()) and (not DBHandler:hasConnectedFB()) then
        self.infoText.text = string.format("Added %s Coins", MoneyFormatHelper.numWithCommas(GameConfig.CONNECTFB_COINS))
        PlayerHandler:AddCoin(GameConfig.CONNECTFB_COINS)
        DBHandler:setConnectedApple()
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
