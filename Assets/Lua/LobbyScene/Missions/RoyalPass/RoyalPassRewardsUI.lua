RoyalPassRewardsUI = {}

function RoyalPassRewardsUI:Show(items, bHasCoins) --items table包含所有的领取奖励
    if not LuaHelper.OrGameObjectExist(self.transform) then
        local goPrefab = AssetBundleHandler:LoadMissionAsset("Missions/RoyalPass/PopPrefab/RoyalPassRewardsUI.prefab")
        local goPanel = Unity.Object.Instantiate(goPrefab)
        self.transform = goPanel.transform
        self.transform:SetParent(MissionMainUIPop.m_trPopNode, false)
        self.transform.localScale = Unity.Vector3.one
        self.transform.localPosition = Unity.Vector3.zero
        LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
        self.transform.gameObject:SetActive(false)

        self.m_trContent = self.transform:FindDeepChild("Content")
        self.m_goPassContainer = self.transform:FindDeepChild("PassContainer").gameObject

        self.m_goMultipleContainer = self.transform:FindDeepChild("MultipleContainer").gameObject
        self.m_trPassContent = self.transform:FindDeepChild("PassContent")
        self.m_btnCollect = self.transform:FindDeepChild("BtnCollect"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(self.m_btnCollect)
        self.m_btnCollect.onClick:AddListener(function()
            self:onCollectClicked(self.m_btnCollect)
        end)
    end

    self.m_bHasCoins = bHasCoins
    self:updateUI(items)
    local bPortraitFlag = not ScreenHelper:isLandScape()
    if bPortraitFlag then
        self.m_trContent.localScale = Unity.Vector3.one * 0.65
    else
        self.m_trContent.localScale = Unity.Vector3.one
    end
    
    ViewScaleAni:Show(self.transform.gameObject, nil, function()
        self.m_btnCollect.interactable = true
    end)
end

function RoyalPassRewardsUI:updateUI(items)
    local nLength = LuaHelper.tableSize(items)
    
    self.m_goMultipleContainer:SetActive(nLength > 1)
    self.m_goPassContainer:SetActive(nLength <= 1)
    
    local parent = nLength > 1 and self.m_trPassContent or self.m_goPassContainer.transform
    -- 删除上一次领取的奖励
    if nLength > 1 then
        for i = 0, self.m_trPassContent.childCount - 1 do
            local childObj = self.m_trPassContent:GetChild(i).gameObject
            Unity.Object.Destroy(childObj)
        end
        local heigth = 200 * math.ceil(nLength / 4)
        self.m_trPassContent.sizeDelta = Unity.Vector2(self.m_trPassContent.sizeDelta.x, heigth)
    else
        for i = 0, self.m_goPassContainer.transform.childCount - 1 do
            local childObj = self.m_goPassContainer.transform:GetChild(i).gameObject
            Unity.Object.Destroy(childObj)
        end
    end
    for k,v in pairs(items) do
        local obj = Unity.Object.Instantiate(v)
        obj.transform:SetParent(parent, false)
        obj.anchoredPosition3D = Unity.Vector3.zero
        obj:GetComponent(typeof(UnityUI.Button)).interactable = false
        obj.transform:FindDeepChild("DuiHao").gameObject:SetActive(false)
        obj.transform.anchoredPosition = Unity.Vector2.zero
    end
end

function RoyalPassRewardsUI:Hide()
    RoyalPassMainUI:updateBtnStatus()
    ViewScaleAni:Hide(self.transform.gameObject)
    EventHandler:Brocast("UpdateMyInfo")
    EventHandler:Brocast("OnSlotsCardsActivityStateChanged")
end

function RoyalPassRewardsUI:onCollectClicked(btn)
    GlobalAudioHandler:PlayBtnSound()
    self.m_btnCollect.interactable = false
    if self.m_bHasCoins then
        CoinFly:fly(btn.transform.position, GlobalTempData.goUITopCollectMoneyEndPos.transform.position, 6, true)
        LeanTween.delayedCall(1.5, function()
            self:Hide()
        end)
    else
        self:Hide()
    end

    if RoyalPassHandler.m_bClaimLoungeDayPassFlag then
        local param = RoyalPassHandler.m_LoungeDayPassParam
        if param.nPrizeCoin > 0 then
            PassCardToLoungeRewardUI:Show(param.nDayPass, param.nPrizeCoin)
        else
            LoungePassCardUI:Show(param.nDayPass)
        end
    end
    RoyalPassHandler.m_bClaimLoungeDayPassFlag = false
    RoyalPassHandler.m_LoungeDayPassParam = {nDayPass = 0, nPrizeCoin = 0}
    
end