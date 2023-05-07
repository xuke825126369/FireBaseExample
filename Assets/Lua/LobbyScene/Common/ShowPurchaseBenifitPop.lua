ShowPurchaseBenifitPop = {}

function ShowPurchaseBenifitPop:Show(skuInfo)
    if not LuaHelper.OrGameObjectExist(self.transform) then
        local bundleName = "Lobby"
        local goPrefab = AssetBundleHandler:LoadAsset(bundleName, "Assets/ResourceABs/Lobby/Shop01/ShowPurchaseBenifitPop.prefab")
        local goPanel = Unity.Object.Instantiate(goPrefab)
        self.transform = goPanel.transform
        self.transform:SetParent(GlobalScene.popCanvas, false)
        self.transform.localScale = Unity.Vector3.one
        self.transform.localPosition = Unity.Vector3.zero
        LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
        self.transform.gameObject:SetActive(false)
        
        self.textVip = self.transform:FindDeepChild("VipPoint"):GetComponent(typeof(TextMeshProUGUI))
        self.sendContainer = self.transform:FindDeepChild("SendContainer")
        self.IconBG = self.transform:FindDeepChild("IconBG")
    end

    if ScreenHelper:isLandScape() then
        self.IconBG.localScale = Unity.Vector3.one
    else
        self.IconBG.localScale = Unity.Vector3.one * 0.8
    end

    self:UpdateUI(skuInfo)
    ViewScaleAni:Show(self.transform.gameObject)
    GlobalAudioHandler:PlaySound("popup3")

    self.bCanHide = false
    LeanTween.delayedCall(1.0, function()
        self.bCanHide = true
    end)
end

function ShowPurchaseBenifitPop:Update()
    if Unity.Input.GetMouseButtonDown(0) and self.bCanHide then
        ViewScaleAni:Hide(self.transform.gameObject)
    end
end

function ShowPurchaseBenifitPop:UpdateUI(skuInfo)
    self.textVip.text = string.format( "+ %s", MoneyFormatHelper.numWithCommas(skuInfo.vipPoint))

    self:UpdateSlotsCardsUI(skuInfo)
    for k, v in pairs(ActiveType) do
        self:UpdateActiveUI(skuInfo, v)
    end

    self:UpdateLoungeUI(skuInfo)

    local nCount = 0
    local nRow = 0
    for i = 0, self.sendContainer.childCount - 1 do
        local child = self.sendContainer:GetChild(i)
        if child.gameObject.activeSelf then
            nCount = nCount + 1
            if nCount % 3 == 1 then
                nRow = nRow + 1
            end
        end
    end

    if nCount < 3 then
        self.IconBG.sizeDelta = Unity.Vector2(50 + 400*nCount, 178)
    else
        self.IconBG.sizeDelta = Unity.Vector2(1234, 43 + 135 * nRow)
    end
end

function ShowPurchaseBenifitPop:UpdateSlotsCardsUI(skuInfo)
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
                stars.sizeDelta = Unity.Vector2(20* (SlotsCardsGiftManager.m_skuToSlotsCardsPack[i].info.packType), 20)
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

function ShowPurchaseBenifitPop:UpdateActiveUI(skuInfo, activeType)
    self.tableGoActive = self.tableGoActive or {}
    if self.tableGoActive[activeType] == nil then
        local tr = self.transform:FindDeepChild(activeType.."Content")
        if not tr then return end --有可能代码更新了但资源没更新，这里要判断下
        self.tableGoActive[activeType] = tr.gameObject
    end

    local go = self.tableGoActive[activeType]
    if skuInfo.nType == SkuInfoType[activeType] then
        if activeType == ActiveManager.activeType then
            local nCount = skuInfo.activeInfo.nAction
            local textCount = go.transform:FindDeepChild("textCount"):GetComponent(typeof(TextMeshProUGUI))
            textCount.text = " +"..nCount
            go:SetActive(true)
        else
            go:SetActive(false)
        end
    else
        if activeType == ActiveManager.activeType then
            local nCount = _G[activeType.."IAPConfig"].skuMapOther[skuInfo.productId]
            local textCount = go.transform:FindDeepChild("textCount"):GetComponent(typeof(TextMeshProUGUI))
            textCount.text = " +"..nCount
            go:SetActive(true)
        else
            go:SetActive(false)
        end
    end

end

function ShowPurchaseBenifitPop:UpdateLoungeUI(skuInfo)
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
