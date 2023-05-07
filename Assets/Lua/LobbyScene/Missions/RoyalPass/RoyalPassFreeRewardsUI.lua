RoyalPassFreeRewardsUI = {}
RoyalPassFreeRewardsUI.m_nCurrentIndex = 1
RoyalPassFreeRewardsUI.m_nMaxIndex = 1

function RoyalPassFreeRewardsUI:Show(items, bHasCoins) --items table包含所有的领取奖励
    if not LuaHelper.OrGameObjectExist(self.transform) then
        local goPrefab = AssetBundleHandler:LoadMissionAsset("Missions/RoyalPass/PopPrefab/FreePassRewardsUI.prefab")
        local goPanel = Unity.Object.Instantiate(goPrefab)
        self.transform = goPanel.transform
        self.transform:SetParent(MissionMainUIPop.m_trPopNode, false)
        self.transform.localScale = Unity.Vector3.one
        self.transform.localPosition = Unity.Vector3.zero
        LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
        self.transform.gameObject:SetActive(false)

        self.m_trContent = self.transform:FindDeepChild("Content")
        self.m_trFreePassScrollView = self.transform:FindDeepChild("FreePassScrollView")
        self.m_trFreePassContent = self.transform:FindDeepChild("FreePassContent")

        self.m_btnUnlockRoyalPass = self.transform:FindDeepChild("BtnUnlockRoyalPass"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(self.m_btnUnlockRoyalPass)
        self.m_btnUnlockRoyalPass.onClick:AddListener(function()
            self:onUnlockRoyalPassBtnClicked()
            EventHandler:Brocast("UpdateMyInfo")
        end)

        self.m_btnCollect = self.transform:FindDeepChild("BtnCollect"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(self.m_btnCollect)
        self.m_btnCollect.onClick:AddListener(function()
            self:onCollectClicked(self.m_btnCollect)
        end)

        self.m_goNoPurchaseContent = self.transform:FindDeepChild("NoPurchaseContent").gameObject
        self.m_trRoyalPassContent = self.transform:FindDeepChild("RoyalPassContent")
        self.m_btnCollectAll = self.transform:FindDeepChild("BtnCollectRewards"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(self.m_btnCollectAll)
        self.m_btnCollectAll.onClick:AddListener(function()
            self:onCollectClicked(self.m_btnCollectAll)
        end)
        
        self.m_btnUnlockRoyalPass = self.transform:FindDeepChild("BtnUnlockRoyalPass"):GetComponent(typeof(UnityUI.Button))
        self.m_btnRight = self.transform:FindDeepChild("BtnRight"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(self.m_btnRight)
        self.m_btnRight.onClick:AddListener(function()
            self:changeIndex(1)
        end)
        
        self.m_btnLeft = self.transform:FindDeepChild("BtnLeft"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(self.m_btnLeft)
        self.m_btnLeft.onClick:AddListener(function()
            self:changeIndex(-1)
        end)
    end
    self.m_bHasCoins = bHasCoins
    self.m_nCurrentIndex = 1
    self:updateUI(items)
    self:refreshBtnStatus()

    local bPortraitFlag = not ScreenHelper:isLandScape()
    if bPortraitFlag then
        self.m_trContent.localScale = Unity.Vector3.one * 0.65
    else
        self.m_trContent.localScale = Unity.Vector3.one
    end
    
    ViewScaleAni:Show(self.transform.gameObject, nil, function()
        self.m_btnCollect.interactable = true
        self.m_btnCollectAll.interactable = true
        self.m_btnUnlockRoyalPass.interactable = true
    end)

end

function RoyalPassFreeRewardsUI:updateUI(items)
    local nLength = LuaHelper.tableSize(items)
    local bHasPurchase = RoyalPassDbHandler.data.m_bIsPurchase
    self.m_goNoPurchaseContent:SetActive(not bHasPurchase)
    self.m_btnCollect.gameObject:SetActive(bHasPurchase)
    if bHasPurchase then
        self.m_trFreePassScrollView.anchoredPosition = Unity.Vector2(0, -42)
    else
        self.m_trFreePassScrollView.anchoredPosition = Unity.Vector2.zero
        for i = 0, self.m_trRoyalPassContent.childCount - 1 do
            local childObj = self.m_trRoyalPassContent:GetChild(i).gameObject
            Unity.Object.Destroy(childObj)
        end

        local nChildCount = 0
        for i = 0, RoyalPassHandler.m_nLevel do
            local prizeInfo = RoyalPassConfig:GetRoyalPassLevelPrize(i + 1)
            local nPrizeLength = LuaHelper.tableSize(prizeInfo)
            for j = 1, nPrizeLength do
                nChildCount = nChildCount + 1
                if j == 1 then
                    local passItem1 = Unity.Object.Instantiate(RoyalPassScollView.royalPassPrizeInfos[i][j].item):GetComponent(typeof(Unity.RectTransform))
                    passItem1:GetComponent(typeof(UnityUI.Button)).interactable = false
                    passItem1:SetParent(self.m_trRoyalPassContent, false)
                    passItem1.anchoredPosition3D = Unity.Vector3.zero
                    passItem1.localScale = Unity.Vector3.one * 0.7
                else
                    local passItem2 = Unity.Object.Instantiate(RoyalPassScollView.royalPassLimitedInfos[i].passItem):GetComponent(typeof(Unity.RectTransform))
                    passItem2:GetComponent(typeof(UnityUI.Button)).interactable = false
                    passItem2:SetParent(self.m_trRoyalPassContent, false)
                    passItem2.anchoredPosition3D = Unity.Vector3.zero
                    passItem2.localScale = Unity.Vector3.one * 0.7
                end
            end
        end

        local width = ((160 + 30) * nChildCount + 10) * 0.7
        if width < 900 then
            self.m_nMaxIndex = 1
        else
            if width % 900 == 0 then
                self.m_nMaxIndex = width / 900
            else
                self.m_nMaxIndex = math.floor(width / 900) + 1
            end
        end
        width = self.m_nMaxIndex * 900
        self.m_trRoyalPassContent.sizeDelta = Unity.Vector2(width, self.m_trRoyalPassContent.sizeDelta.y)
    end
    
    -- 删除上一次领取的奖励
    for i = 0, self.m_trFreePassContent.childCount - 1 do
        local childObj = self.m_trFreePassContent:GetChild(i).gameObject
        Unity.Object.Destroy(childObj)
    end

    for k,v in pairs(items) do
        local obj = Unity.Object.Instantiate(v)
        obj.transform:SetParent(self.m_trFreePassContent, false)
        obj.anchoredPosition3D = Unity.Vector3.zero
        obj:GetComponent(typeof(UnityUI.Button)).interactable = false
        obj.transform:FindDeepChild("DuiHao").gameObject:SetActive(false)
    end

    local width = (160 + 25) * nLength + 10
    local resultWidth = width > 1100 and width or 1100
    self.m_trFreePassContent.sizeDelta = Unity.Vector2(resultWidth, self.m_trFreePassContent.sizeDelta.y)
end

function RoyalPassFreeRewardsUI:beginMoving()
    self.m_btnLeft.gameObject:SetActive(false)
    self.m_btnRight.gameObject:SetActive(false)    
    LeanTween.moveX(self.m_trRoyalPassContent, -900 * (self.m_nCurrentIndex - 1), 0.5):setOnComplete(function()
        self:refreshBtnStatus()
    end)
end

function RoyalPassFreeRewardsUI:changeIndex(count)
    GlobalAudioHandler:PlayBtnSound()
    self.m_nCurrentIndex = self.m_nCurrentIndex + count
    self:beginMoving()
end

function RoyalPassFreeRewardsUI:refreshBtnStatus()
    if self.m_nMaxIndex == 1 then
        self.m_btnLeft.gameObject:SetActive(false)
        self.m_btnRight.gameObject:SetActive(false)
    else
        if self.m_nCurrentIndex == 1 then
            self.m_btnLeft.gameObject:SetActive(false)
            self.m_btnRight.gameObject:SetActive(true)
        elseif self.m_nCurrentIndex == self.m_nMaxIndex then
            self.m_btnLeft.gameObject:SetActive(true)
            self.m_btnRight.gameObject:SetActive(false)
        else
            self.m_btnLeft.gameObject:SetActive(true)
            self.m_btnRight.gameObject:SetActive(true)
        end
    end
end

function RoyalPassFreeRewardsUI:Hide()
    RoyalPassMainUI:updateBtnStatus()
    ViewScaleAni:Hide(self.transform.gameObject)
    EventHandler:Brocast("UpdateMyInfo")
    EventHandler:Brocast("OnSlotsCardsActivityStateChanged")
end

function RoyalPassFreeRewardsUI:onCollectClicked(btn)
    btn.interactable = false
    GlobalAudioHandler:PlayBtnSound()
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

function RoyalPassFreeRewardsUI:onUnlockRoyalPassBtnClicked()
    self.m_btnUnlockRoyalPass.interactable = false
    GlobalAudioHandler:PlayBtnSound()
    self:Hide()
    RoyalPassShopUI:Show()
end

function RoyalPassFreeRewardsUI:OnDestroy()
    
end