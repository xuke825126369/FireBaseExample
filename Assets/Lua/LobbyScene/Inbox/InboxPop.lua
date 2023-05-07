local ItemType = {
    FbFriendFreeCoinGift = 0,
    FbFriendFreeCoinRequest = 1,
    FreeCoinFromGame = 2,
    SpecialOffer = 3,
    BoosterBonus = 4,
    RoyalPass = 5,
    FlashChallenge = 6,
    CoinCoupon = 7,
    DiamondCoupon = 8,
    RoyalTrophy = 9,
    LoungeLuckyPack = 10,
    NewVersionAward = 11,
    GMGfit = 12,
}

local function InboxItem(itemType, rectTransform, fbMessageId, fbFrom)
    local o = {}
    o.itemType = itemType
    o.itemRectTransform = rectTransform
    o.fbMessageId = fbMessageId
    o.fbFrom = fbFrom
    o.otherInfo = {}
    return o
end

InboxPop = {}
function InboxPop:Show()
    if not LuaHelper.OrGameObjectExist(self.transform) then
        local bundleName = "Lobby"
        local goPrefab = AssetBundleHandler:LoadAsset(bundleName, "View/InBox/InboxPop.prefab")
        local goPanel = Unity.Object.Instantiate(goPrefab)
        self.transform = goPanel.transform
        self.transform:SetParent(LobbyScene.popCanvas, false)
        self.transform.localScale = Unity.Vector3.one
        self.transform.localPosition = Unity.Vector3.zero
        LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
        self.transform.gameObject:SetActive(false)

        self.container = self.transform:FindDeepChild("Container")
        self.scrollContent = self.transform:FindDeepChild("ScrollContent")
        self.fullLoadingGameObject = self.transform:FindDeepChild("FullLoading").gameObject

        local btn = self.transform:FindDeepChild("CloseBtn"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(btn)
        btn.onClick:AddListener(function()
            self:onCloseBtnClicked()
        end)
    end

    self.itemArray = {}
    self.scrollContent:DestroyAllChildren()
    self.fullLoadingGameObject:SetActive(true)
    ViewScaleAni:Show(self.transform.gameObject, nil, function()
        self:popDone()
    end)

    self.mTimeOutGenerator = TimeOutGenerator:New()
end

function InboxPop:Hide()
    ViewScaleAni:Hide(self.transform.gameObject)
    EventHandler:Brocast("onInboxMessageChangedNotifycation")
end

function InboxPop:popDone()
    self.fullLoadingGameObject:SetActive(false)
    self.scrollContent.anchoredPosition = Unity.Vector2.zero
    self.scrollContent.sizeDelta = Unity.Vector2(self.scrollContent.sizeDelta.x, 0)

    for i = 1, #CommonDbHandler.data.tableCoinCouponInfo do
        self:addCoinCouponItem(1, i)
    end
    
    for i = 1, #CommonDbHandler.data.tableDiamondCouponInfo do
        self:addCoinCouponItem(2, i)
    end

    for i = 1, #CommonDbHandler.data.tableCollectFreeCoinInfo do
        self:addInboxFreeCoinItem(i)
    end 

    local boosterBonus = CommonDbHandler.data.BonusParams
    if boosterBonus then
        for i = 1,#boosterBonus do
            self:addBoosterBonusItem(boosterBonus[i])
        end
    end

    local royalTrophyReward = CommonDbHandler.data.mapInboxTrophyRewardParams
    if royalTrophyReward and LuaHelper.tableSize(royalTrophyReward) > 0 then
        for i = 1, #royalTrophyReward do
            self:addInboxRoyalTrophyRewardItem(royalTrophyReward[i])
        end
    end

    local royalPassReward = CommonDbHandler.data.mapInboxRoyalPassRewardParams
    if royalPassReward and LuaHelper.tableSize(royalPassReward) > 0 then
        for i = 1, #royalPassReward do
            self:addInboxRoyalPassRewardItem(royalPassReward[i])
        end
    end

    local flashChallengeReward = CommonDbHandler.data.mapInboxFlashChallengeRewardParams
    if flashChallengeReward and LuaHelper.tableSize(flashChallengeReward) > 0 then
        for i = 1, #flashChallengeReward do
            self:addInboxFlashChallengeRewardItem(flashChallengeReward[i])
        end
    end 

    for i = 1, #CommonDbHandler.data.LoungeLuckyPackParam do
        self:addInboxLoungeLuckyPackItem(i)
    end

    if Unity.Application.version ~= PlayerHandler.strAppVersion then
        self:addInboxNewVersionAwardItem()
    end

    if GMGiftHandler.data.nCompensationCoins > 0 then
        self:addGMGiftItem()
    end

end

function InboxPop:addInboxLoungeLuckyPackItem(nIndex)
    local itemRectTransform = Unity.Object.Instantiate(AssetBundleHandler:LoadAsset("lobby","View/InBox/InboxLoungeLuckyPackItem.prefab")):GetComponent(typeof(Unity.RectTransform))
    local inboxItem = InboxItem(ItemType.LoungeLuckyPack, itemRectTransform, nil, nil)
    self.itemArray[#self.itemArray + 1] = inboxItem
    itemRectTransform:SetParent(self.scrollContent, false)
    itemRectTransform.anchoredPosition = Unity.Vector2(0, -self.scrollContent.sizeDelta.y)
    self.scrollContent.sizeDelta = Unity.Vector2(self.scrollContent.sizeDelta.x, self.scrollContent.sizeDelta.y + itemRectTransform.sizeDelta.y)
    local actBtn = itemRectTransform:FindDeepChild("Button"):GetComponent(typeof(UnityUI.Button))
    local removeBtn = itemRectTransform:FindDeepChild("removeBtn").gameObject
    removeBtn:SetActive(false)  
    
    local nInboxId = CommonDbHandler.data.LoungeLuckyPackParam[nIndex].nInboxId

    local nameText =  itemRectTransform:FindDeepChild("Name"):GetComponent(typeof(TextMeshProUGUI))
    local strInfo = "<color=yellow>Winner Lounge Benefit</color>\n1-Lucky Stamp Pack!"
    nameText.text = strInfo
    DelegateCache:addOnClickButton(actBtn)
    actBtn.onClick:AddListener(function()
        local packType = SlotsCardsAllProbTable.PackType.Five
        SlotsCardsHandler:addPackCount(packType, 1)
        SlotsCardsGetPackPop:Show(packType, true, 1)
        InBoxHandler:RemoveInboxArrayItem(CommonDbHandler.data.LoungeLuckyPackParam, nInboxId)
        self:onRemoveBtnClicked(removeBtn)
    end)

end

function InboxPop:addInboxRoyalTrophyRewardItem(otherInfo)
    local itemRectTransform = Unity.Object.Instantiate(AssetBundleHandler:LoadAsset("lobby","View/InBox/InboxRoyalTrophyItem.prefab")):GetComponent(typeof(Unity.RectTransform))
    local inboxItem = InboxItem(ItemType.RoyalTrophy, itemRectTransform, nil, nil)
    inboxItem.otherInfo = otherInfo
    self.itemArray[#self.itemArray + 1] = inboxItem
    itemRectTransform:SetParent(self.scrollContent, false)
    itemRectTransform.anchoredPosition = Unity.Vector2(0, -self.scrollContent.sizeDelta.y)
    self.scrollContent.sizeDelta = Unity.Vector2(self.scrollContent.sizeDelta.x, self.scrollContent.sizeDelta.y + itemRectTransform.sizeDelta.y)
    local actBtn = itemRectTransform:FindDeepChild("Button"):GetComponent(typeof(UnityUI.Button))
    local removeBtn = itemRectTransform:FindDeepChild("removeBtn").gameObject
    removeBtn:SetActive(false)
    --:GetComponent(typeof(UnityUI.Button))
    local nameText =  itemRectTransform:FindDeepChild("Name"):GetComponent(typeof(TextMeshProUGUI))
    local format = "<color=yellow>Royal Trophy</color>\n%s Coins!"
    local nCoins = otherInfo.nCoins
    nameText.text = string.format(format, MoneyFormatHelper.numWithCommas(nCoins))
    DelegateCache:addOnClickButton(actBtn)
    actBtn.onClick:AddListener(function()
        self:onActBtnClicked(actBtn)
    end)
end

function InboxPop:addInboxRoyalPassRewardItem(otherInfo)
    local prefabName = otherInfo.nRoyalPassType == 1 and "InboxFreePassItem" or "InboxRoyalPassItem"
    local itemRectTransform = Unity.Object.Instantiate(AssetBundleHandler:LoadAsset("lobby","View/InBox/"..prefabName..".prefab")):GetComponent(typeof(Unity.RectTransform))
    local inboxItem = InboxItem(ItemType.RoyalPass, itemRectTransform, nil, nil)
    inboxItem.otherInfo = otherInfo
    self.itemArray[#self.itemArray + 1] = inboxItem
    itemRectTransform:SetParent(self.scrollContent, false)
    itemRectTransform.anchoredPosition = Unity.Vector2(0, -self.scrollContent.sizeDelta.y)
    self.scrollContent.sizeDelta = Unity.Vector2(self.scrollContent.sizeDelta.x, self.scrollContent.sizeDelta.y + itemRectTransform.sizeDelta.y)
    local actBtn = itemRectTransform:FindDeepChild("Button"):GetComponent(typeof(UnityUI.Button))
    local removeBtn = itemRectTransform:FindDeepChild("removeBtn").gameObject
    removeBtn:SetActive(false)
    itemRectTransform:FindDeepChild("CoinImage").gameObject:SetActive(otherInfo.nType == RoyalPassConfig.PrizeType.Coins)
    itemRectTransform:FindDeepChild("DiamondImg").gameObject:SetActive(otherInfo.nType == RoyalPassConfig.PrizeType.Diamond)

    Debug.Assert(otherInfo.nSeason >= 0, "otherInfo.nSeason: "..otherInfo.nSeason)
    
    local nameText =  itemRectTransform:FindDeepChild("Name"):GetComponent(typeof(TextMeshProUGUI))
    local format = "Season "..(otherInfo.nSeason + 1)
    format = format..(otherInfo.nRoyalPassType == 1 and " <color=yellow>FreePass</color>\n" or " <color=yellow>Royal Pass</color>\n")
    if otherInfo.nType == RoyalPassConfig.PrizeType.Coins then
        format = format.."$%s Worth of Coins %s"
        local nCoins = otherInfo.nCoins
        nameText.text = string.format(format, otherInfo.strDollar ,MoneyFormatHelper.numWithCommas(nCoins))
    elseif otherInfo.nType == RoyalPassConfig.PrizeType.Diamond then
        format = format.."%s Diamonds!"
        nameText.text = string.format(format, MoneyFormatHelper.numWithCommas(otherInfo.nCount))
    end
    DelegateCache:addOnClickButton(actBtn)
    actBtn.onClick:AddListener(function( )
        self:onActBtnClicked(actBtn)
    end)

end

function InboxPop:addInboxFlashChallengeRewardItem(otherInfo)
    local itemRectTransform = Unity.Object.Instantiate(AssetBundleHandler:LoadAsset("lobby","View/InBox/InboxFlashChallengeItem.prefab")):GetComponent(typeof(Unity.RectTransform))
    local inboxItem = InboxItem(ItemType.FlashChallenge, itemRectTransform, nil, nil)
    inboxItem.otherInfo = otherInfo
    self.itemArray[#self.itemArray + 1] = inboxItem
    itemRectTransform:SetParent(self.scrollContent, false)
    itemRectTransform.anchoredPosition = Unity.Vector2(0, -self.scrollContent.sizeDelta.y)
    self.scrollContent.sizeDelta = Unity.Vector2(self.scrollContent.sizeDelta.x, self.scrollContent.sizeDelta.y + itemRectTransform.sizeDelta.y)
    local actBtn = itemRectTransform:FindDeepChild("Button"):GetComponent(typeof(UnityUI.Button))
    local removeBtn = itemRectTransform:FindDeepChild("removeBtn").gameObject
    removeBtn:SetActive(false)

    local nameText =  itemRectTransform:FindDeepChild("Name"):GetComponent(typeof(TextMeshProUGUI))
    local format = "<color=yellow>FlashChallenge</color>\n%s Coins!"
    local nCoins = otherInfo.nCoins
    nameText.text = string.format(format, MoneyFormatHelper.numWithCommas(nCoins))
    DelegateCache:addOnClickButton(actBtn)
    actBtn.onClick:AddListener(function( )
        self:onActBtnClicked(actBtn)
    end)
end

function InboxPop:addBoosterBonusItem(boosterBonus)
    local strType = ""
    if boosterBonus.nType == BoostHandler.BONUSTYPE.enumCashBack then
        strType = "CashBack Bonus"
    elseif boosterBonus.nType == BoostHandler.BONUSTYPE.enumBoostWin then
        strType = "BoostWin Bonus"
    elseif boosterBonus.nType == BoostHandler.BONUSTYPE.enumRepeatWin then
        strType = "RepeatWin Bonus"
    elseif boosterBonus.nType == BoostHandler.BONUSTYPE.enumJackpotAgain then
        strType = "JackpotAgain Bonus"
    end
    if strType == "" then
        return
    end
    local itemRectTransform = Unity.Object.Instantiate(AssetBundleHandler:LoadAsset("lobby","View/InBox/InboxBoosterBonusItem.prefab")):GetComponent(typeof(Unity.RectTransform))
    local inboxItem = InboxItem(ItemType.BoosterBonus, itemRectTransform, nil, nil)
    inboxItem.otherInfo = boosterBonus
    self.itemArray[#self.itemArray + 1] = inboxItem
    itemRectTransform:SetParent(self.scrollContent, false)
    itemRectTransform.anchoredPosition = Unity.Vector2(0, -self.scrollContent.sizeDelta.y)
    self.scrollContent.sizeDelta = Unity.Vector2(self.scrollContent.sizeDelta.x, self.scrollContent.sizeDelta.y + itemRectTransform.sizeDelta.y)
    local logoContainer = itemRectTransform:FindDeepChild("LogoContainer")
    for i=0,logoContainer.childCount-1 do
        if i+1 == boosterBonus.nType then
            logoContainer:GetChild(i).gameObject:SetActive(true)
        else
            logoContainer:GetChild(i).gameObject:SetActive(false)
        end
    end
    
    local tr = itemRectTransform:FindDeepChild("removeBtn")
    if tr ~= nil then
        tr.gameObject:SetActive(false)
    end

    local nameText =  itemRectTransform:FindDeepChild("Name"):GetComponent(typeof(TextMeshProUGUI))
    local format = "<color=yellow>%s</color>\n%s Coins!"
    nameText.text = string.format(format, strType, MoneyFormatHelper.numWithCommas(boosterBonus.nCoins))

    local actBtn = itemRectTransform:FindDeepChild("Button"):GetComponent(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(actBtn)
    actBtn.onClick:AddListener(function()
        self:onActBtnClicked(actBtn)
    end)
end

function InboxPop:addInboxFreeCoinItem(nIndex)
    local itemRectTransform = Unity.Object.Instantiate(AssetBundleHandler:LoadAsset("lobby", "View/InBox/InboxItem1.prefab")):GetComponent(typeof(Unity.RectTransform))
    local inboxItem = InboxItem(ItemType.FreeCoinFromGame, itemRectTransform, nil, nil)
    self.itemArray[#self.itemArray + 1] = inboxItem
    itemRectTransform:SetParent(self.scrollContent, false)
    itemRectTransform.anchoredPosition = Unity.Vector2(0, -self.scrollContent.sizeDelta.y)
    self.scrollContent.sizeDelta = Unity.Vector2(self.scrollContent.sizeDelta.x, self.scrollContent.sizeDelta.y + itemRectTransform.sizeDelta.y)
    local actBtn = itemRectTransform:FindDeepChild("Button"):GetComponent(typeof(UnityUI.Button))
    local removeBtn = itemRectTransform:FindDeepChild("removeBtn").gameObject
    removeBtn:SetActive(false)

    local nInboxId = CommonDbHandler.data.tableCollectFreeCoinInfo[nIndex].nInboxId
    local fBonus = BonusHandler:getFreeCoinBonus()
    local nameText = itemRectTransform:FindDeepChild("Name"):GetComponent(typeof(TextMeshProUGUI))
    local format = "x%s MULTIPLIER <size=30><color=yellow>%s</color></size>\n<color=yellow>play more get more!</color>"
    nameText.text = string.format(format, tostring(VipHandler:GetVipCoefInfo()), MoneyFormatHelper.numWithCommas(fBonus))
    DelegateCache:addOnClickButton(actBtn)
    actBtn.onClick:AddListener(function()
        PlayerHandler:AddCoin(fBonus)
        InBoxHandler:RemoveInboxArrayItem(CommonDbHandler.data.tableCollectFreeCoinInfo, nInboxId)
        local coinPos = itemRectTransform:FindDeepChild("CoinImage").position
        CoinFly:fly(coinPos, GlobalTempData.goUITopCollectMoneyEndPos.transform.position, 10, true)
        self:onRemoveBtnClicked(removeBtn)
    end)

end

function InboxPop:addInboxNewVersionAwardItem()
    local itemRectTransform = Unity.Object.Instantiate(AssetBundleHandler:LoadAsset("lobby", "View/InBox/SpecialItem.prefab")):GetComponent(typeof(Unity.RectTransform))
    local inboxItem = InboxItem(ItemType.NewVersionAward, itemRectTransform, nil, nil)
    self.itemArray[#self.itemArray + 1] = inboxItem

    itemRectTransform:SetParent(self.scrollContent, false)
    itemRectTransform.anchoredPosition = Unity.Vector2(0, -self.scrollContent.sizeDelta.y)
    self.scrollContent.sizeDelta = Unity.Vector2(self.scrollContent.sizeDelta.x, self.scrollContent.sizeDelta.y + itemRectTransform.sizeDelta.y)
    local actBtn = itemRectTransform:FindDeepChild("Button"):GetComponent(typeof(UnityUI.Button))
    local removeBtn = itemRectTransform:FindDeepChild("removeBtn").gameObject
    removeBtn:SetActive(false)
    
    local fBonus = CSharpVersionHandler.nAwardMoneyCount
    local nameText = itemRectTransform:FindDeepChild("Name"):GetComponent(typeof(TextMeshProUGUI))
    nameText.text = string.format("New Version Bonus\n$%s", MoneyFormatHelper.numWithCommas(fBonus))
    DelegateCache:addOnClickButton(actBtn)
    actBtn.onClick:AddListener(function()
        self:onRemoveBtnClicked(removeBtn)
        PlayerHandler:SetAppVersion()
        PlayerHandler:AddCoin(CSharpVersionHandler.nAwardMoneyCount)
        CoinFly:fly(actBtn.transform.position, GlobalTempData.goUITopCollectMoneyEndPos.transform.position, 10, true)
    end)

end

function InboxPop:addGMGiftItem()
    local itemRectTransform = Unity.Object.Instantiate(AssetBundleHandler:LoadAsset("lobby","View/InBox/SpecialItem.prefab")):GetComponent(typeof(Unity.RectTransform))
    itemRectTransform:SetParent(self.scrollContent, false)
    itemRectTransform.anchoredPosition = Unity.Vector2(0, -self.scrollContent.sizeDelta.y)
    self.scrollContent.sizeDelta = Unity.Vector2(self.scrollContent.sizeDelta.x, self.scrollContent.sizeDelta.y + itemRectTransform.sizeDelta.y)

    local inboxItem = InboxItem(ItemType.GMGfit, itemRectTransform, nil, nil)
    self.itemArray[#self.itemArray + 1] = inboxItem

    local actBtn = itemRectTransform:FindDeepChild("Button"):GetComponent(typeof(UnityUI.Button))
    local removeBtn = itemRectTransform:FindDeepChild("removeBtn").gameObject
    removeBtn:SetActive(false)

    local nameText = itemRectTransform:FindDeepChild("Name"):GetComponent(typeof(TextMeshProUGUI))
    
    local fBonus = GMGiftHandler.data.nCompensationCoins
    nameText.text = string.format("Compensation Coins\n$%s", MoneyFormatHelper.numWithCommas(fBonus))
    DelegateCache:addOnClickButton(actBtn)
    actBtn.onClick:AddListener(function()
        self:onRemoveBtnClicked(removeBtn)
        GMGiftHandler:CollectGMGift(fBonus)
        CoinFly:fly(actBtn.transform.position, GlobalTempData.goUITopCollectMoneyEndPos.transform.position, 10, true)
    end)

end

-- nType == 1是CoinCoupon，nType == 2是DiamondCoupon
function InboxPop:addCoinCouponItem(nType, nIndex)
    local strPath = nType == 1 and "View/InBox/CouponCoinItem.prefab" or "View/InBox/CouponDiamondItem.prefab"
    local prefab = AssetBundleHandler:LoadAsset("lobby", strPath)
    local itemRectTransform = Unity.Object.Instantiate(prefab):GetComponent(typeof(Unity.RectTransform))
    itemRectTransform:SetParent(self.scrollContent, false)
    itemRectTransform.anchoredPosition = Unity.Vector2(0, -self.scrollContent.sizeDelta.y)
    self.scrollContent.sizeDelta = Unity.Vector2(self.scrollContent.sizeDelta.x, self.scrollContent.sizeDelta.y + itemRectTransform.sizeDelta.y)

    local inboxItem = InboxItem(ItemType.CoinCoupon, itemRectTransform, nil, nil)
    self.itemArray[#self.itemArray + 1] = inboxItem


    local actBtn = itemRectTransform:FindDeepChild("Button"):GetComponent(typeof(UnityUI.Button))
    local nameText =  itemRectTransform:FindDeepChild("Name"):GetComponent(typeof(TextMeshProUGUI))
    local countDownText =  itemRectTransform:FindDeepChild("CountDownText"):GetComponent(typeof(TextMeshProUGUI))

    local nInboxId = 0
    local fCoinCouponRatio = 0
    local nCouponTime = 0
    if nType == 1 then
        nInboxId = CommonDbHandler.data.tableCoinCouponInfo[nIndex].nInboxId
        fCoinCouponRatio = CommonDbHandler.data.tableCoinCouponInfo[nIndex].fCouponRatio
        nCouponTime = CommonDbHandler.data.tableCoinCouponInfo[nIndex].nCouponTime
    else
        nInboxId = CommonDbHandler.data.tableDiamondCouponInfo[nIndex].nInboxId
        fCoinCouponRatio = CommonDbHandler.data.tableDiamondCouponInfo[nIndex].fCouponRatio
        nCouponTime = CommonDbHandler.data.tableDiamondCouponInfo[nIndex].nCouponTime
    end

    countDownText.text = GameHelper:GetRemainTimeDes(nCouponTime)
    local fRatio = LuaHelper.GetInteger((fCoinCouponRatio - 1)*100)
    nameText.text = nType == 1 and "+ "..fRatio.."% More" or "+ "..fRatio.."% More"

    DelegateCache:addOnClickButton(actBtn)
    actBtn.onClick:AddListener(function()
        if nType == 1 then
            CommonDbHandler:SetStoreCoinCouponInfo(nCouponTime, fCoinCouponRatio)
            InBoxHandler:RemoveInboxArrayItem(CommonDbHandler.data.tableCoinCouponInfo, nInboxId)
        else
            CommonDbHandler:SetStoreDiamondCouponInfo(nCouponTime, fCoinCouponRatio)
            InBoxHandler:RemoveInboxArrayItem(CommonDbHandler.data.tableDiamondCouponInfo, nInboxId)
        end
            
        self:Hide()
        local shopType = nType == 2 and BuyView.SHOP_VIEW_TYPE.GEMTYPE or nil
        BuyView:Show(shopType)
    end)
end

function InboxPop:removeItem(index)
    local tobeRemovedItem = self.itemArray[index]
    local tobeRemovedItemSize = tobeRemovedItem.itemRectTransform.sizeDelta
    self.scrollContent.sizeDelta = Unity.Vector2(self.scrollContent.sizeDelta.x, self.scrollContent.sizeDelta.y - tobeRemovedItemSize.y)
    table.remove( self.itemArray, index)
    Unity.GameObject.Destroy(tobeRemovedItem.itemRectTransform.gameObject)

    for i = index, #self.itemArray do
        local rectTransform = self.itemArray[i].itemRectTransform
        LeanTween.moveY(rectTransform, rectTransform.anchoredPosition.y + tobeRemovedItemSize.y, 0.5):setEase(LeanTweenType.easeOutCubic)
    end
end

function InboxPop:onCloseBtnClicked()
    self:Hide()
end

function InboxPop:onRemoveBtnClicked(sender)
    for i, v in ipairs(self.itemArray) do
        if v.itemRectTransform == sender.transform.parent then
            self:removeItem(i)
            return
        end
    end
end

function InboxPop:onActBtnClicked(sender )
    if self.removeAnimation then return end
    for i, v in ipairs(self.itemArray) do
        if v.itemRectTransform == sender.transform.parent then
            if v.itemType == ItemType.BoosterBonus then
                PlayerHandler:AddCoin(v.otherInfo.nCoins)
                local coinPos = v.itemRectTransform:FindDeepChild("CoinImage").position
                CoinFly:fly(coinPos, GlobalTempData.goUITopCollectMoneyEndPos.transform.position, 10, true)
                local index = LuaHelper.indexOfTable(CommonDbHandler.data.BonusParams, v.otherInfo)
                table.remove(CommonDbHandler.data.BonusParams, index)
            elseif v.itemType == ItemType.RoyalPass then
                if v.otherInfo.nType == RoyalPassConfig.PrizeType.Coins then
                    PlayerHandler:AddCoin(v.otherInfo.nCoins)
                    local coinPos = v.itemRectTransform:FindDeepChild("CoinImage").position
                    CoinFly:fly(coinPos, GlobalTempData.goUITopCollectMoneyEndPos.transform.position, 10, true)
                elseif v.otherInfo.nType == RoyalPassConfig.PrizeType.Diamond then
                    PlayerHandler:AddSapphire(v.otherInfo.nCount)
                    EventHandler:Brocast("UpdateMyInfo")
                end
                local index = LuaHelper.indexOfTable(CommonDbHandler.data.mapInboxRoyalPassRewardParams, v.otherInfo)
                CommonDbHandler:removeRoyalPassReward(index)
            elseif v.itemType == ItemType.RoyalTrophy then
                PlayerHandler:AddCoin(v.otherInfo.nCoins)

                local coinPos = v.itemRectTransform:FindDeepChild("CoinImage").position
                CoinFly:fly(coinPos, GlobalTempData.goUITopCollectMoneyEndPos.transform.position, 10, true)
                local index = LuaHelper.indexOfTable(CommonDbHandler.data.mapInboxTrophyRewardParams, v.otherInfo)
                CommonDbHandler:removeRoyalTrophyReward(index)
            elseif v.itemType == ItemType.FlashChallenge then
                PlayerHandler:AddCoin(v.otherInfo.nCoins)

                local coinPos = v.itemRectTransform:FindDeepChild("CoinImage").position
                CoinFly:fly(coinPos, GlobalTempData.goUITopCollectMoneyEndPos.transform.position, 10, true)
                local index = LuaHelper.indexOfTable(CommonDbHandler.data.mapInboxFlashChallengeRewardParams, v.otherInfo)
                CommonDbHandler:removeFlashChallengeReward(index)
            end

            self:removeItem(i)
            return
        end
    end

end
