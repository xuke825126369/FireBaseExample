DailyBonusChestRewardPop = {}

function DailyBonusChestRewardPop:Show(nChestIndex)
    if not LuaHelper.OrGameObjectExist(self.transform) then
        local go = Unity.Object.Instantiate(AssetBundleHandler:LoadAsset("lobby", "DailyBonus/DailyBonusChestRewardPop.prefab"))
        self.transform = go.transform
        self.transform.gameObject.name = "DailyBonusChestRewardPop"

        self.transform:SetParent(LobbyScene.popCanvas, false)
        self.sendContainer = self.transform:FindDeepChild("SendContainer")
        self.textDays = self.transform:FindDeepChild("DaysText"):GetComponent(typeof(UnityUI.Text))
        self.btnCollect = self.transform:FindDeepChild("BtnCollect"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(self.btnCollect)
        self.btnCollect.onClick:AddListener(function()
            self.btnCollect.interactable = false
            GlobalAudioHandler:PlayBtnSound()
            if self.bHasCoins then
                CoinFly:fly(self.btnCollect.transform.position, GlobalTempData.goUITopCollectMoneyEndPos.transform.position, 12, true)
                LeanTween.delayedCall(1, function()
                    self:Hide()
                end)
            else
                self:Hide()
            end

            if self.bHasDiamond then
                EventHandler:Brocast("UpdateMyInfo")
            end
        end)
    end

    self.btnCollect.interactable = true
    local str = ""
    if nChestIndex == 1 then
        str = "7"
    elseif nChestIndex == 2 then
        str = "15"
    elseif nChestIndex == 3 then
        str = "22"
    elseif nChestIndex == 4 then
        str = "30"
    end
    
    self.textDays.text = str.."TH"
    self:UpdateUI(nChestIndex)
    ViewScaleAni:Show(self.transform.gameObject, nil, function()
        DailyBonusPop.closeBtn.interactable = true
    end)

end

function DailyBonusChestRewardPop:Hide()
    ViewScaleAni:Hide(self.transform.gameObject, function()
        Unity.Object.Destroy(self.transform.gameObject)
    end)
end

function DailyBonusChestRewardPop:UpdateUI(nChestIndex)
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

    local chestReward = DailyBonusDataHandler.MAP_CHESTREWARD[nChestIndex]
    local nLength = LuaHelper.tableSize(chestReward)
    for i = 1, nLength do
        local info = chestReward[i]
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
        elseif nRewardType == DailyBonusDataHandler.nRewardType.Activty then
            local active = ActiveManager.activeType
            if active then
                for k, v in pairs(ActiveType) do
                    if self.tableGoActiveItem[k] then
                        self.tableGoActiveItem[k]:SetActive(k == active)
                    end
                end
                if self.tableGoActiveItem[active] then
                    local textCount = self.tableGoActiveItem[active]:FindDeepChild("CountText"):GetComponent(typeof(TextMeshProUGUI))
                    local nCount = ActivityHelper:GetAddMsgCountBySku(info.sku)
                    textCount.text = "+"..nCount
                end
            else
                for k, v in pairs(ActiveType) do
                    if self.tableGoActiveItem[k] then
                        self.tableGoActiveItem[k]:SetActive(false)
                    end
                end
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