SendIntroducePop = PopStackViewBase:New()

function SendIntroducePop:createAndShow(skuInfo)
    if self.gameObject == nil then
        self.gameObject = Unity.Object.Instantiate(Util.getHotPrefab("Assets/BaseHotAdd/Shop/SendIntroducePop.prefab"))
        self.transform = self.gameObject.transform
        self.transform:SetParent(LobbyScene.popCanvas, false)
        self.bg = self.transform:FindDeepChild("BG")
        self.content = self.transform:FindDeepChild("Content")

        self.popController = PopController:new(self.gameObject)
        local btn = self.transform:FindDeepChild("ButtonClose"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(btn)
        btn.onClick:AddListener(function()
            self:onCloseBtnClicked()
        end)
    end
    self:refreshContent(skuInfo)
    self.popController:show(nil, nil, false)
    local bLandscape = Unity.Screen.width > Unity.Screen.height
    if not bLandscape and BuyView:isActiveShow() then
        self.popController.containerRectTransform.localRotation = Unity.Quaternion.Euler(0,0,-90)
    else
        self.popController.containerRectTransform.localRotation = Unity.Quaternion.Euler(0,0,0)
    end
end

function SendIntroducePop:refreshContent(skuInfo)
    local rocketContent = self.content:FindDeepChild("ChutesRockets").gameObject
    local cardContent = self.content:FindDeepChild("CardContainer").gameObject
    local adContent = self.content:FindDeepChild("NoAd").gameObject
    local depotContent = self.content:FindDeepChild("Depots").gameObject
    local boostWinContent = self.content:FindDeepChild("BoostWin").gameObject
    local cashBackContent = self.content:FindDeepChild("CashBack").gameObject
    local repeatWinContent = self.content:FindDeepChild("RepeatWin").gameObject

    local userLevel = PlayerHandler.nLevel
    local isActiveShow = false
    for i=1,#SlotsCardsHandler.m_albumTable do
        local status = SlotsCardsHandler:checkIsActiveTime(i)
        if not isActiveShow then
            isActiveShow = status
        end
    end
    if isActiveShow and userLevel >= SlotsCardsManager.m_nUnlockLevel then
        cardContent:SetActive(true)
        local cardCountText = cardContent.transform:FindDeepChild("CardCountText"):GetComponent(typeof(TextMeshProUGUI))
        local cardText = cardContent.transform:FindDeepChild("SlotsCardInfoText"):GetComponent(typeof(TextMeshProUGUI))
        local stars = cardContent.transform:FindDeepChild("Stars")
        local packCount = cardContent.transform:FindDeepChild("DoublePack")
        for i=1,#SlotsCardsGiftManager.m_skuToSlotsCardsPack do
            if skuInfo.productId == SlotsCardsGiftManager.m_skuToSlotsCardsPack[i].productId then
                cardText.text = "Min " .. SlotsCardsGiftManager.m_skuToSlotsCardsPack[i].minCardCount .. " of"
                cardCountText.text = "+"..SlotsCardsGiftManager.m_skuToSlotsCardsPack[i].setCardCount
                if SlotsCardsGiftManager.m_skuToSlotsCardsPack[i].packCount > 1 then
                    packCount.gameObject:SetActive(true)
                    packCount:GetComponentInChildren(typeof(TextMeshProUGUI)).text = "x"..SlotsCardsGiftManager.m_skuToSlotsCardsPack[i].packCount
                else
                    packCount.gameObject:SetActive(false)
                end
                for j = 0, stars.childCount - 1 do
                    if j < SlotsCardsGiftManager.m_skuToSlotsCardsPack[i].starCount then
                        stars:GetChild(j).gameObject:SetActive(true)
                    else
                        stars:GetChild(j).gameObject:SetActive(false)
                    end
                end
                break
            end
        end
    else
        cardContent:SetActive(false)
    end

    if GameConfig.CHUTESROCKETS_FLAG and ChutesRocketsAssetBundleHandler.m_bAssetReady and userLevel >= ChutesRocketsDataHandler.m_nUnlockLevel and ChutesRocketsUnloadedUI:checkIsActiveTime() then
        rocketContent:SetActive(true)
        local nCount = ChutesRocketsDataHandler:getChutesRocketsSpinCount(skuInfo.productId)
        rocketContent.transform:FindDeepChild("SpinCountText"):GetComponent(typeof(TextMeshProUGUI)).text = "+"..nCount
    else
        rocketContent:SetActive(false)
    end

    if GameConfig.BUILDGAME_FLAG and BuildGameDataHandler:checkIsActiveTime() and userLevel >= BuildGameDataHandler.m_nUnlockLevel then
        depotContent:SetActive(true)
        for i=1, #BuildGameManager.m_skuToBuildDepots do
            if skuInfo.productId == BuildGameManager.m_skuToBuildDepots[i].productId then
                depotContent.transform:FindDeepChild("BuildCountText"):GetComponent(typeof(TextMeshProUGUI)).text = "+"..BuildGameManager.m_skuToBuildDepots[i].depotsCount
                local depotsLogo = depotContent.transform:FindDeepChild("DepotsLogo")
                for j=0, depotsLogo.childCount-1 do
                    depotsLogo:GetChild(j).gameObject:SetActive(j==BuildGameManager.m_skuToBuildDepots[i].depotsType)
                end
                break
            end
        end
    else
        depotContent:SetActive(false)
    end
    adContent:SetActive(false)
    local isActiveShow = BoostHandler:checkIsBoostWinActive()
    boostWinContent:SetActive(isActiveShow)
    local infoText = boostWinContent.transform:FindDeepChild("Info"):GetComponent(typeof(TextMeshProUGUI))
    local fCoef,nTime = BoostHandler:getBoostWinParamInfoFromSku(skuInfo.productId)
    infoText.text = math.floor(nTime/60).."MINS\n"..( fCoef*100 ).."%" --string.format( "%dMINS\n%.1f", nTime/60, fCoef*100).."%"

    isActiveShow = BoostHandler:checkIsCashBackActive()
    cashBackContent:SetActive(isActiveShow)
    local infoText = cashBackContent.transform:FindDeepChild("Info"):GetComponent(typeof(TextMeshProUGUI))
    local fCoef,nTime = BoostHandler:getCashBackParamInfoFromSku(skuInfo.productId)
    infoText.text = math.floor(nTime/60).."MINS\n"..( fCoef*100 ).."%" --string.format( "%dMINS\n%.1f", nTime/60, fCoef*100).."%"

    isActiveShow = BoostHandler:checkIsRepeatWinActive()
    repeatWinContent:SetActive(isActiveShow)

    self.content:FindDeepChild("VipText"):GetComponent(typeof(TextMeshProUGUI)).text = string.format( "+%s\n VIP Pts.", MoneyFormatHelper.numWithCommas(skuInfo.vipPoint))
    local count = 0
    for i=0,self.content.childCount-1 do
        if self.content:GetChild(i).gameObject.activeSelf then
            count = count + 1
        end
    end
    local v2 = Unity.Vector2(200*count+10, 110)
    if count > 8 then
        local height = count % 8
        if height == 0 then
            height = count / 8
        else
            height = math.floor( count / 8 ) + 1
        end
        v2 = Unity.Vector2(810, height*100+10)
    end
    self.bg.sizeDelta = v2
    self.content.sizeDelta = v2
end

function SendIntroducePop:onCloseBtnClicked()
    GlobalAudioHandler:PlayBtnSound()
    ViewScaleAni:Hide(self.transform.gameObject)
end
