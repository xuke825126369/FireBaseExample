ShopEndPop = PopStackViewBase:New()

function ShopEndPop:Show(skuInfo, bShowGoldKuang)
    self.bShowGoldKuang = bShowGoldKuang
    if self.bShowGoldKuang == nil then
        self.bShowGoldKuang = true
    end 

    if not LuaHelper.OrGameObjectExist(self.transform) then
        local bundleName = "Lobby"
        local goPrefab = AssetBundleHandler:LoadAsset(bundleName, "Assets/ResourceABs/Lobby/Shop01/ShopEnd.prefab")
        local goPanel = Unity.Object.Instantiate(goPrefab)
        self.transform = goPanel.transform
        self.transform:SetParent(GlobalScene.popCanvasActivity, false)
        self.transform.localScale = Unity.Vector3.one
        self.transform.localPosition = Unity.Vector3.zero
        LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
        self.transform.gameObject:SetActive(false)

        self.m_btnCollect = self.transform:FindDeepChild("BtnCollect"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(self.m_btnCollect)
        self.m_btnCollect.onClick:AddListener(function()
            self:onOKBtnClicked()
        end)
        self.textDiamondsCount = self.transform:FindDeepChild("DiamondsCountText"):GetComponent(typeof(UnityUI.Text))
        self.textCoinsCount = self.transform:FindDeepChild("CoinsCountText"):GetComponent(typeof(UnityUI.Text))
        
        self.textVip = self.transform:FindDeepChild("VipPoint"):GetComponent(typeof(TextMeshProUGUI))
        self.goCoinsContainer = self.transform:FindDeepChild("CoinsContainer").gameObject
        self.goDiamondsContainer = self.transform:FindDeepChild("DiamondsContainer").gameObject
        self.trSendContainer = self.transform:FindDeepChild("SendContainer")
        self.trContent = self.transform:FindDeepChild("Content")
        self.tableGoActive = {}
    end
    
    local coinCount = skuInfo.finalCoins
    local vipPoint = skuInfo.vipPoint
    
    self.transform:SetAsLastSibling()
    ViewScaleAni:Show(self.transform.gameObject, nil, function()
        self.m_btnCollect.interactable = true
    end)

    if ScreenHelper:isLandScape() then
        self.trContent.localScale = Unity.Vector3.one
    else
        self.trContent.localScale = Unity.Vector3.one * 0.7
    end

    self:UpdateUI(skuInfo)
end

function ShopEndPop:UpdateUI(skuInfo)
    self.goDiamondsContainer:SetActive(skuInfo.nType == SkuInfoType.ShopDiamonds)
    self.goCoinsContainer:SetActive(skuInfo.nType ~= SkuInfoType.ShopDiamonds)

    -- 这些类型是没有金币的
    if skuInfo.finalCoins == nil then
        self.goCoinsContainer:SetActive(false)
    else
        if skuInfo.finalCoins == 0 then
           self.goCoinsContainer:SetActive(false)
        else
            self.goCoinsContainer:SetActive(true)
        end
    end

    -- 这三个特殊点 内购返回了加金币 但是不做界面展示
    if skuInfo.nType == SkuInfoType.PiggBank or
        skuInfo.nType == SkuInfoType.DealOfFun or
        skuInfo.nType == SkuInfoType.MegaBall then
        self.goCoinsContainer:SetActive(false)
    end

    if skuInfo.nType == SkuInfoType.ShopDiamonds then
        self.textDiamondsCount.text = MoneyFormatHelper.numWithCommas(skuInfo.finalDiamonds)
    else
        if skuInfo.finalCoins ~= nil then
            self.textCoinsCount.text = MoneyFormatHelper.numWithCommas(skuInfo.finalCoins)
        end
    end

    if (not self.goDiamondsContainer.activeSelf) and (not self.goCoinsContainer.activeSelf) then
        self.trSendContainer.anchoredPosition = Unity.Vector2.zero
    else
        self.trSendContainer.anchoredPosition = Unity.Vector2(0, -135)
    end
    
    self.textVip.text = string.format( "+ %s", MoneyFormatHelper.numWithCommas(skuInfo.vipPoint))
    self:UpdateSlotsCardsUI(skuInfo)
    for k, v in pairs(ActiveType) do
        self:UpdateActiveUI(skuInfo, v)
    end
    
    self:UpdateLoungeUI(skuInfo)
end

function ShopEndPop:UpdateSlotsCardsUI(skuInfo)
    local slotsCardsContent = self.transform:FindDeepChild("SlotsCardsContent")
    if SlotsCardsManager:orActivityOpen() then
        slotsCardsContent.gameObject:SetActive(true)
        local stars = slotsCardsContent:FindDeepChild("Stars")
        local packTypeContainer = slotsCardsContent:FindDeepChild("IconContainer")
        local count = 1
        local packType = SlotsCardsAllProbTable.PackType.Three
        for i = 1, #SlotsCardsGiftManager.m_skuToSlotsCardsPack do
            if skuInfo.productId == SlotsCardsGiftManager.m_skuToSlotsCardsPack[i].productId then
                packType = SlotsCardsGiftManager.m_skuToSlotsCardsPack[i].info.packType
                count = SlotsCardsGiftManager.m_skuToSlotsCardsPack[i].info.packCount
                stars.sizeDelta = Unity.Vector2(20 * (SlotsCardsGiftManager.m_skuToSlotsCardsPack[i].info.packType), 20)
                for j = 0, stars.childCount - 1 do
                    if j < SlotsCardsGiftManager.m_skuToSlotsCardsPack[i].info.packType then
                        stars:GetChild(j).gameObject:SetActive(true)
                    else
                        stars:GetChild(j).gameObject:SetActive(false)
                    end
                    packTypeContainer:GetChild(j).gameObject:SetActive(j + 1 == SlotsCardsGiftManager.m_skuToSlotsCardsPack[i].info.packType)
                end
                break
            end
        end

        local info = SlotsCardsAllProbTable.PackTypeToGift[packType]
        local cardCount = info.setCardCount
        local str = count.." SLOTS CARD PACKS"
        local str1 = "MIN "..cardCount.." OF 1 STARS CARD"
        if info.starCount == 2 then
            str1 = "MIN "..info.minCardCount.." OF 2 STARS CARD"
        elseif info.starCount == 3 then
            str1 = "MIN "..info.minCardCount.." OF 3 STARS CARD"
        elseif info.starCount == 4 then
            str1 = "MIN "..info.minCardCount.." OF 4 STARS CARD"
        elseif info.starCount == 5 then
            str1 = "MIN "..info.minCardCount.." OF 5 STARS CARD"
        end

        local packCountText = slotsCardsContent:FindDeepChild("PackCountText"):GetComponent(typeof(TextMeshProUGUI))
        packCountText.text = str
        local packCountText = slotsCardsContent:FindDeepChild("PackInfoText"):GetComponent(typeof(TextMeshProUGUI))
        packCountText.text = str1
    else
        slotsCardsContent.gameObject:SetActive(false)
    end
end

function ShopEndPop:UpdateActiveUI(skuInfo, activeType)
    if self.tableGoActive[activeType] == nil then
        local tr = self.transform:FindDeepChild(activeType.."Content")
        if not tr then return end --有可能代码更新了但资源没更新，这里要判断下
        self.tableGoActive[activeType] = tr.gameObject
    end

    local bInActivityBuy = skuInfo.nType == SkuInfoType[activeType]
    local go = self.tableGoActive[activeType]
    if not ActiveManager:orActivityOpen() then
        go:SetActive(false)
        return
    end

    if bInActivityBuy then
        --是在活动内购买
        if ActiveManager.activeType == activeType then
            local nCount = skuInfo.activeInfo.nAction
            local textCount = go.transform:FindDeepChild("textCount"):GetComponent(typeof(TextMeshProUGUI))
            textCount.text = " +"..nCount
            go:SetActive(true)
        else
            go:SetActive(false)
        end
    else
        --其他地方购买，附加的活动掉落物品
        if ActiveManager.activeType == activeType then
            local nCount = _G[activeType.."IAPConfig"].skuMapOther[skuInfo.productId]
            local textCount = go.transform:FindDeepChild("textCount"):GetComponent(typeof(TextMeshProUGUI))
            textCount.text = " +"..nCount
            go:SetActive(nCount > 0)
        else
            go:SetActive(false)
        end
    end

end

function ShopEndPop:UpdateLoungeUI(skuInfo)
    local goLoungePoints = self.transform:FindDeepChild("LoungePoints").gameObject
    if not LoungeManager:orActivityOpen() then
        goLoungePoints:SetActive(false)
        return
    end

    goLoungePoints:SetActive(true)
    local data = nil
    for k, v in pairs(LoungeConfig.m_lsitSkuChestInfo) do
        if v.productId == skuInfo.productId then
            data = v
            break
        end
    end

    local nLoungePoint = data.nLoungePoint
    local textCount = goLoungePoints.transform:FindDeepChild("textCount"):GetComponent(typeof(TextMeshProUGUI))
    textCount.text = " +"..nLoungePoint
    
    local nChestType = data.enumType
    local nChestCount = data.nCount

    local tableChest = {}
    for i = 1, 4 do
        tableChest[i] = self.transform:FindDeepChild("LoungeChest"..i).gameObject
        tableChest[i]:SetActive(i == nChestType)
    end

    local textChestCount = tableChest[nChestType].transform:FindDeepChild("textCount"):GetComponent(typeof(TextMeshProUGUI))
    textChestCount.text = " +"..nChestCount
    
end

function ShopEndPop:onOKBtnClicked()
    self.m_btnCollect.interactable = false
    GlobalAudioHandler:PlayBtnSound()
    if self.goCoinsContainer.activeInHierarchy then
        if self.bShowGoldKuang then
            LobbyView:UpCoinsCanvasLayer()
        end
        CoinFly:fly(self.goCoinsContainer.transform.position, GlobalTempData.goUITopCollectMoneyEndPos.transform.position, 10, true)
        LeanTween.delayedCall(1.5 + 0.12 * 10, function()
            ViewScaleAni:Hide(self.transform.gameObject)
            if self.bShowGoldKuang then
                LobbyView:DownCoinsCanvasLayer()
            end
        end)
    else
        ViewScaleAni:Hide(self.transform.gameObject)
    end

end
