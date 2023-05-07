
local yield_return = (require 'cs_coroutine').yield_return

FriendsPop = {}

function FriendsPop:isActiveShow()
    return self.gameObject and self.gameObject.activeInHierarchy
end

function FriendsPop:createAndShow(parentTransform)
    if(not self.gameObject) then
        self.tableName = "FriendsPop"
        self.openCount  = 0
        self.gameObject = Unity.Object.Instantiate(Util.getBasePrefab("PopPanel/FriendsPop.prefab"))
        self.itemPrefab = Util.getHotPrefab("Assets/BaseHotAdd/Friends/FriendsPopItem.prefab")
        self.transform = self.gameObject.transform
        LuaAutoBindMonoBehaviour.Bind(self.gameObject, self)
        self.popController = PopController:new(self.gameObject)
        self.fullLoading = self.transform:FindDeepChild("FullLoading")
        self.scrollContent = self.transform:FindDeepChild("ScrollContent")
        local btn = self.transform:FindDeepChild("CloseBtn"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(btn)
        btn.onClick:AddListener(function()
            self:onCloseBtnClicked()
        end)
        local btn = self.transform:FindDeepChild("InviteBtn"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(btn)
        btn.onClick:AddListener(function()
            GlobalAudioHandler:PlayBtnSound()
            FBHandler:inviteFriends()
        end)
    end
    self.openCount  = self.openCount + 1
    self.scrollContent:DestroyAllChildren()
    self.fullLoading.gameObject:SetActive(true)

    parentTransform = parentTransform or LobbyScene.popCanvas
    self.transform:SetParent(parentTransform, false)
    self.popController:show(function ()
        self:popDone()
    end)
end

function FriendsPop:popDone()
    self.fullLoading.gameObject:SetActive(false)
    self.scrollContent.anchoredPosition = Unity.Vector2.zero
    self.scrollContent.sizeDelta = Unity.Vector2(self.scrollContent.sizeDelta.x, 0)
    self:setFriendsContent()
    self:countDown(self.openCount)
    NotificationHandler:addObserver(self, "onFetchFriendsNotifictation")
    NotificationHandler:addObserver(self, "onFetchAvatarNotifictation")
    NotificationHandler:addObserver(self, "onSendedFreeCoinToFriendNotifycation")
    NotificationHandler:addObserver(self, "onAskFreeCoinToFriendNotifycation")
end

function FriendsPop:setFriendsContent()
    self.friendDict = {}
    local e = FBHandler:getFriends():GetEnumerator()
    while e:MoveNext() do
        local friendId = e.Current.Key
		local friend = e.Current.Value
        local itemRectTransform = Unity.Object.Instantiate(self.itemPrefab):GetComponent(typeof(Unity.RectTransform))
        self.friendDict[friendId] = itemRectTransform
        itemRectTransform:SetParent(self.scrollContent, false)
        itemRectTransform.anchoredPosition = Unity.Vector2(0, -self.scrollContent.sizeDelta.y)
        self.scrollContent.sizeDelta = Unity.Vector2(self.scrollContent.sizeDelta.x, self.scrollContent.sizeDelta.y + itemRectTransform.sizeDelta.y)
        local nameText = itemRectTransform:FindDeepChild("Name"):GetComponent(typeof(UnityUI.Text))
        nameText.text = friend.name
        local sendBtn = itemRectTransform:FindDeepChild ("SendBtn"):GetComponent(typeof(UnityUI.Button))
        local askBtn = itemRectTransform:FindDeepChild ("AskBtn"):GetComponent(typeof(UnityUI.Button))
        local rawImage = itemRectTransform:FindDeepChild("FrameMask/Avatar"):GetComponent(typeof(UnityUI.RawImage))
        rawImage.texture = FBHandler:getAvatar(friendId)
        if DBHandler:getLastSendFriendCoinTime(friendId) + GameConfig.FRIEND_FREECOIN_SECOND_INTERVAL - os.time() <= 0 then
            sendBtn.interactable = true
        else 
            sendBtn.interactable = false
        end
        if DBHandler:getLastAskFriendCoinTime(friendId) + GameConfig.FRIEND_FREECOIN_SECOND_INTERVAL - os.time() <= 0 then
            askBtn.interactable = true
        else 
            askBtn.interactable = false
        end
        DelegateCache:addOnClickButton(sendBtn)
        sendBtn.onClick:AddListener(function()
            local lastSendTime = DBHandler:getLastSendFriendCoinTime(friendId)
            local now = os.time()
            local remainTime = lastSendTime + GameConfig.FRIEND_FREECOIN_SECOND_INTERVAL - now
            if(remainTime <= 0) then
                FBHandler:sendFreeCoin(friendId)
                self.fullLoading.gameObject:SetActive(true)
                -- DBHandler:sendFreeCoinToFriend(friendId, now)
            end
        end)
        DelegateCache:addOnClickButton(askBtn)
        askBtn.onClick:AddListener(function()
            local lastAskTime = DBHandler:getLastAskFriendCoinTime(friendId)
            local now = os.time()
            local remainTime = lastAskTime + GameConfig.FRIEND_FREECOIN_SECOND_INTERVAL - now
            if(remainTime <= 0) then
                FBHandler:askForFreeCoin(friendId)
                self.fullLoading.gameObject:SetActive(true)
                -- DBHandler:askFreeCoinToFriend(friendId, now)
            end
        end)
    end
end

function FriendsPop:countDown(openCount)
    local co = StartCoroutine(function()
		local waitOneSecond = Unity.WaitForSeconds(1)
		while(self.gameObject.activeInHierarchy and openCount == self.openCount) do
			for friendId, itemRectTransform in pairs(self.friendDict) do
                local sendCountDownText = itemRectTransform:FindDeepChild ("SendBtn/CountDown"):GetComponent(typeof(UnityUI.Text))
                local sendBtn = itemRectTransform:FindDeepChild ("SendBtn"):GetComponent(typeof(UnityUI.Button))
                local askBtn = itemRectTransform:FindDeepChild ("AskBtn"):GetComponent(typeof(UnityUI.Button))
                local askCountDownText = itemRectTransform:FindDeepChild ("AskBtn/CountDown"):GetComponent(typeof(UnityUI.Text))
                local lastSendTime = DBHandler:getLastSendFriendCoinTime(friendId)
                local lastAskTime = DBHandler:getLastAskFriendCoinTime(friendId)
                local now = os.time()
                local remainSendTime = lastSendTime + GameConfig.FRIEND_FREECOIN_SECOND_INTERVAL - now
                local remainAskTime = lastAskTime + GameConfig.FRIEND_FREECOIN_SECOND_INTERVAL - now
                if remainSendTime > 0 then
                    sendCountDownText.gameObject:SetActive (true)
                    sendCountDownText.text = os.date("!%X", remainSendTime)
                    sendBtn.interactable = false
                else
                    sendCountDownText.gameObject:SetActive (false)
                    sendBtn.interactable = true
                end
                if remainAskTime > 0 then
                    askCountDownText.gameObject:SetActive (true)
                    askCountDownText.text = os.date("!%X", remainAskTime)
                    askBtn.interactable = false
                else
                    askCountDownText.gameObject:SetActive (false)
                    askBtn.interactable = true
                end
            end
			yield_return(waitOneSecond)
		end
	end)
end

function FriendsPop:OnDisable()
    NotificationHandler:removeObserver(self)
end

function FriendsPop:onCloseBtnClicked()
    GlobalAudioHandler:PlayBtnSound()
    ViewScaleAni:Hide(self.transform.gameObject)
end

function FriendsPop:onFetchFriendsNotifictation()
    self:setFriendsContent()
end

function FriendsPop:onFetchAvatarNotifictation(data)
    local fbId = data.fbId
    local itemRectTransform = self.friendDict[fbId]
    if itemRectTransform then
        local rawImage = itemRectTransform:FindDeepChild("FrameMask/Avatar"):GetComponent(typeof(UnityUI.RawImage))
        rawImage.texture = FBHandler:getAvatar(fbId)
    end
end

function FriendsPop:onSendedFreeCoinToFriendNotifycation()
    self.fullLoading.gameObject:SetActive(false)
end

function FriendsPop:onAskFreeCoinToFriendNotifycation()
    self.fullLoading.gameObject:SetActive(false)
end