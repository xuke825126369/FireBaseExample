

CoinAddedPop = {}

function CoinAddedPop:isActiveShow()
    return self.gameObject and self.gameObject.activeInHierarchy
end

function CoinAddedPop:createAndShow(skuInfo, parentTransform)
    local bLandscape = Unity.Screen.width > Unity.Screen.height
    if(bLandscape ~= self.bLandscape) then
        if self.gameObject then
            Unity.GameObject.Destroy(self.gameObject)
        end
        self.gameObject = Unity.Object.Instantiate(Util.getHotPrefab("Assets/BaseHotAdd/Prefabs/prefab/CoinAddedPop.prefab"))
        
        self.bLandscape = bLandscape
        self.tableName = "CoinAddedPop"
        -- self.gameObject = Unity.Object.Instantiate(Util.getHotPrefab("Assets/BaseHotAdd/CoinAddedPop/CoinAddedPop.prefab"))
        self.transform = self.gameObject.transform
        self.coinImage = self.transform:FindDeepChild("CoinImage")
        self.cardImage = self.transform:FindDeepChild("CardsImage")

        LuaAutoBindMonoBehaviour.Bind(self.gameObject, self)
        self.popController = PopController:new(self.gameObject, PopPriority.highestPriority)
        self.m_btnOk = self.transform:FindDeepChild("ButtonOK"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(self.m_btnOk)
        self.m_btnOk.onClick:AddListener(function()
            self:onOKBtnClicked()
        end)
    end
    local purchaseTitle = self.transform:FindDeepChild ("PurchaseDone")
    local watchADTitle = self.transform:FindDeepChild ("WatchADDone")
    local descriptionText = self.transform:FindDeepChild ("DescriptionText"):GetComponent(typeof(TextMeshProUGUI))
    if(skuInfo and skuInfo.productId ~= "") then
        purchaseTitle.gameObject:SetActive(true)
        watchADTitle.gameObject:SetActive(false)
        local coinCount = skuInfo.finalCoins
        local vipPoint = skuInfo.vipPoint
        descriptionText.text = string.format("You Got: %s Coins \n <size=25>+%d VIP Pts.</size>", MoneyFormatHelper.numWithCommas(coinCount), vipPoint)
        if skuInfo.nType == SkuInfoType.ShopCoins or skuInfo.nType == SkuInfoType.MegaBall then
            local isActiveShow = false
            for i=1,#SlotsCardsHandler.m_albumTable do
                local status = SlotsCardsHandler:checkIsActiveTime(i)
                if not isActiveShow then
                    isActiveShow = status
                end
            end
            local userLevel = PlayerHandler.nLevel
            if isActiveShow and (userLevel >= SlotsCardsManager.m_nUnlockLevel) then
                --显示卡包图片，移动金币位置
                self.cardImage.gameObject:SetActive(true)
                self:setCardsContainer(skuInfo)
                self.coinImage.anchoredPosition = Unity.Vector2(-43,64)
            else
                self.cardImage.gameObject:SetActive(false)
                self.coinImage.anchoredPosition = Unity.Vector2(0,64)
            end
            
        else
            self.cardImage.gameObject:SetActive(false)
            self.coinImage.anchoredPosition = Unity.Vector2(0,64)
        end
    else
        self.coinImage.anchoredPosition = Unity.Vector2(0,64)
        self.cardImage.gameObject:SetActive(false)
        purchaseTitle.gameObject:SetActive(false)
        watchADTitle.gameObject:SetActive(true)
        descriptionText.text = string.format("You Got: %s Coins For Watching AD", MoneyFormatHelper.numWithCommas(BonusUtil.getRewardVideoBonus()))
    end
    parentTransform = parentTransform or LobbyScene.popCanvas
    self.transform:SetParent(parentTransform, false)
    self.popController:show(nil, nil, true)
    self.m_btnOk.interactable = true
    self.popController.adapterContainer.localScale = Unity.Vector3.one
    if not bLandscape and BuyView:isActiveShow() then
        self.popController.containerRectTransform.localRotation = Unity.Quaternion.Euler(0,0,90)
    else
        self.popController.containerRectTransform.localRotation = Unity.Quaternion.Euler(0,0,0)
        if ThemeLoader.themeKey ~= nil then
            self.popController.adapterContainer.localScale = Unity.Vector3.one*0.7
        end
    end
end

function CoinAddedPop:setCardsContainer(skuInfo)
    local stars = self.transform:FindDeepChild("Stars")
    local packCount = self.transform:FindDeepChild("DoublePack")
    local packTypeContainer = self.transform:FindDeepChild("KaPaiJieDian")
    for i=1,#SlotsCardsGiftManager.m_skuToSlotsCardsPack do
        if skuInfo.productId == SlotsCardsGiftManager.m_skuToSlotsCardsPack[i].productId then
            packCount:GetComponentInChildren(typeof(TextMeshProUGUI)).text = SlotsCardsGiftManager.m_skuToSlotsCardsPack[i].info.packCount.." PACKS"
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
end

function CoinAddedPop:onOKBtnClicked()
    self.m_btnOk.interactable = false
    GlobalAudioHandler:PlayBtnSound()
    if(self.productId and self.productId ~= "") then
        ViewScaleAni:Hide(self.transform.gameObject)
        AudioHandler:PlaySound("iap_coin_collect")
        CS.ParticleAttractor.instance:Play(self.coinImage.position, GlobalTempData.goUITopCollectMoneyEndPos.transform.position)
        LeanTween.delayedCall(2.6, function()
            AudioHandler:playCoinCollection(2)
            UITop:updateCoinCountInUi()
        end)
    else
        CoinFly:fly(self.coinImage.position, GlobalTempData.goUITopCollectMoneyEndPos.transform.position, 10)
        LeanTween.delayedCall(1.5 + 0.12 * 10, function()
            ViewScaleAni:Hide(self.transform.gameObject)
        end)
    end
end

