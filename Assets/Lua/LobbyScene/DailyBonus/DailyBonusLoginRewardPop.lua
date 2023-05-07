DailyBonusLoginRewardPop = {}

function DailyBonusLoginRewardPop:Show(mapType, callback)
    if not LuaHelper.OrGameObjectExist(self.transform) then
        local go = Unity.Object.Instantiate(AssetBundleHandler:LoadAsset("lobby", "DailyBonus/DailyBonusLoginRewardPop.prefab"))
        self.transform = go.transform
        self.transform.gameObject.name = "DailyBonusLoginRewardPop"
        self.transform:SetParent(LobbyScene.popCanvas, false)

        self.sendContainer = self.transform:FindDeepChild("SendContainer")
        self.btnCollect = self.transform:FindDeepChild("BtnCollect"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(self.btnCollect)
        self.btnCollect.onClick:AddListener(function()
            self.btnCollect.interactable = false
            GlobalAudioHandler:PlayBtnSound()

            local delayTime = 0
            if self.bHasCoins then
                CoinFly:fly(self.btnCollect.transform.position, GlobalTempData.goUITopCollectMoneyEndPos.transform.position, 6, true)
                LeanTween.delayedCall(0.5, function()
                    self:Hide()
                end)
                delayTime = 1.5
            else
                self:Hide()
            end

            if self.bHasDiamond then
                EventHandler:Brocast("UpdateMyInfo")
            end
            
            if self.bHasLoungePoints then
                EventHandler:Brocast("OnLoungeActivityStateChanged")
            end

            LeanTween.delayedCall(delayTime, function()
                callback()
            end)
        end)
    end

    self.btnCollect.interactable = true
    self:UpdateUI(mapType)
    ViewScaleAni:Show(self.transform.gameObject)
end

function DailyBonusLoginRewardPop:Hide()
    ViewScaleAni:Hide(self.transform.gameObject, function()
        Unity.Object.Destroy(self.transform.gameObject)
    end)
end

function DailyBonusLoginRewardPop:UpdateUI(mapType)
    self.tableGoActiveItem = {}
    for k, v in pairs(ActiveType) do
        local tr = self.sendContainer:FindDeepChild(v.."Item")
        if tr then
            local go = tr.gameObject
            self.tableGoActiveItem[k] = go
            go:SetActive(false)
        end
    end

    local coinsItem = self.sendContainer:FindDeepChild("CoinsItem")
    local slotsCardsItem = self.sendContainer:FindDeepChild("SlotsCardsItem")
    local vipItem = self.sendContainer:FindDeepChild("VipItem")
    local diamondItem = self.sendContainer:FindDeepChild("DiamondItem")
    local loungePointsItem = self.sendContainer:FindDeepChild("LoungePointsItem")

    coinsItem.gameObject:SetActive(false)
    slotsCardsItem.gameObject:SetActive(false)
    vipItem.gameObject:SetActive(false)
    diamondItem.gameObject:SetActive(false)
    loungePointsItem.gameObject:SetActive(false)

    self.bHasCoins = false
    self.bHasDiamond = false
    self.bHasLoungePoints = false

    local nLength = LuaHelper.tableSize(mapType)
    for i = 1, nLength do
        local info = mapType[i]
        local nRewardType = info.nType
        if nRewardType == DailyBonusDataHandler.nRewardType.Coins then
            coinsItem.gameObject:SetActive(true)
            local textCoins = coinsItem:FindDeepChild("CoinsText"):GetComponent(typeof(TextMeshProUGUI))
            local nCoins = DailyBonusDataHandler:getBaseCoinsPrize() * info.fRatio
            textCoins.text = MoneyFormatHelper.coinCountOmit(nCoins)
            self.bHasCoins = true
        elseif nRewardType == DailyBonusDataHandler.nRewardType.SlotsCards then
            local bIsOpen = SlotsCardsManager:orActivityOpen()
            slotsCardsItem.gameObject:SetActive(bIsOpen)
            if bIsOpen then
                local textCount = slotsCardsItem:FindDeepChild("PackCountText"):GetComponent(typeof(TextMeshProUGUI))
                textCount.text = "+"..info.nCount
                local stars = slotsCardsItem:FindDeepChild("Stars")
                local packTypeContainer = slotsCardsItem:FindDeepChild("IconContainer")
                local packType = info.nSlotsType
                stars.sizeDelta = Unity.Vector2(20* (packType), 20)
                for j = 0, stars.childCount - 1 do
                    if j < packType then
                        stars:GetChild(j).gameObject:SetActive(true)
                    else
                        stars:GetChild(j).gameObject:SetActive(false)
                    end
                    packTypeContainer:GetChild(j).gameObject:SetActive(j + 1 == packType)
                end
            else
                coinsItem.gameObject:SetActive(true)
                local textCoins = coinsItem:FindDeepChild("CoinsText"):GetComponent(typeof(TextMeshProUGUI))
                local nCoins = DailyBonusDataHandler:getBaseCoinsPrize()
                textCoins.text = MoneyFormatHelper.coinCountOmit(nCoins)
                self.bHasCoins = true
            end
        elseif nRewardType == DailyBonusDataHandler.nRewardType.VipPoint then
            vipItem.gameObject:SetActive(true)
            local textCount = vipItem:FindDeepChild("VipPoint"):GetComponent(typeof(TextMeshProUGUI))
            textCount.text = info.nCount
        elseif nRewardType == DailyBonusDataHandler.nRewardType.Diamond then
            diamondItem.gameObject:SetActive(true)
            local textCount = diamondItem:FindDeepChild("DiamondCount"):GetComponent(typeof(TextMeshProUGUI))
            textCount.text = info.nCount
            self.bHasDiamond = true
        elseif nRewardType == DailyBonusDataHandler.nRewardType.LoungePoints then
            loungePointsItem.gameObject:SetActive(true)
            local textCount = loungePointsItem:FindDeepChild("textCount"):GetComponent(typeof(TextMeshProUGUI))
            textCount.text = info.nCount
            self.bHasLoungePoints = true
        elseif nRewardType == DailyBonusDataHandler.nRewardType.Activty then
            local active = ActiveManager.activeType
            if active then
                for k, v in pairs(ActiveType) do
                    if self.tableGoActiveItem[k] then
                        self.tableGoActiveItem[k]:SetActive(k == active)
                    end
                end

                if self.tableGoActiveItem[active] then
                    local textCount = self.tableGoActiveItem[active].transform:FindDeepChild("CountText"):GetComponent(typeof(TextMeshProUGUI))
                    local nAction = ActivityHelper:GetAddMsgCountBySku(info.sku)
                    textCount.text = "+"..nAction
                end
            else
                for k, v in pairs(ActiveType) do
                    if self.tableGoActiveItem[k] then
                        self.tableGoActiveItem[k]:SetActive(false)
                    end
                end

                coinsItem.gameObject:SetActive(true)
                local textCoins = coinsItem:FindDeepChild("CoinsText"):GetComponent(typeof(TextMeshProUGUI))
                local nCoins = DailyBonusDataHandler:getBaseCoinsPrize()
                textCoins.text = MoneyFormatHelper.coinCountOmit(nCoins)
                self.bHasCoins = true
            end
        end
    end
    
    local nFirstIndex = 0
    for i = 0, self.sendContainer.childCount - 1 do
        local child = self.sendContainer:GetChild(i)
        if child.gameObject.activeSelf then
            nFirstIndex = nFirstIndex + 1
            child:FindDeepChild("Add").gameObject:SetActive(nFirstIndex ~= 1)
        end
    end

end