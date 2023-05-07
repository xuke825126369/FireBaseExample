CollectFreeBonusUI = PopStackViewBase:New()
CollectFreeBonusUI.m_bInitFlag = false
CollectFreeBonusUI.m_nCurMedalIndex = 0

function CollectFreeBonusUI:Show(index) -- index 第几个徽章
    self.m_nCurMedalIndex = index
    if not LuaHelper.OrGameObjectExist(self.transform) then
        local goPrefab = AssetBundleHandler:LoadGoldenLoungeAsset("CollectFreeBonusUI.prefab")
        local goPanel = Unity.Object.Instantiate(goPrefab)
        self.transform = goPanel.transform
        self.transform:SetParent(LobbyScene.popCanvas, false)
        self.transform.localScale = Unity.Vector3.one
        self.transform.localPosition = Unity.Vector3.zero
        LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
        self.transform.gameObject:SetActive(false)

        local btnCollect = self.transform:FindDeepChild("BtnCollect"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(btnCollect)
        btnCollect.onClick:AddListener(function()
            GlobalAudioHandler:PlayBtnSound()
            self:OnBtnCollectClicked(btnCollect)
        end)

        local tr = self.transform:FindDeepChild("BonusLoungePointNode")
        self.m_goBonusLoungePointNode = tr.gameObject

        local tr = self.transform:FindDeepChild("TextMeshProCoin")
        self.m_TextMeshProCoin = tr:GetComponent(typeof(TextMeshProUGUI))

        local tr = self.transform:FindDeepChild("TextMeshProLoungePoint")
        self.m_TextMeshProLoungePoint = tr:GetComponent(typeof(TextMeshProUGUI))

        local tr = self.transform:FindDeepChild("TextMeshProCardPackCount")
        self.m_TextMeshProCardPackCount = tr:GetComponent(typeof(TextMeshProUGUI))
        self.m_trCardsNode = self.transform:FindDeepChild("Cards")
        self.m_trStarsNode = self.transform:FindDeepChild("Stars")
    end

    ViewAlphaAni:Show(self.transform.gameObject)
    self:refreshUI(index)
    self.transform:SetAsLastSibling()
end

function CollectFreeBonusUI:refreshUI(index)
    local nLoungePoint, nCoinReward, param = LoungeConfig:getFreeBonusParam(index)

    self.m_nLoungePoint = nLoungePoint
    self.m_nBonusCoins = nCoinReward
    self.m_ParamCardPack = param
    
    if nLoungePoint == 0 then
        self.m_goBonusLoungePointNode:SetActive(false)
    else
        self.m_goBonusLoungePointNode:SetActive(true)
        self.m_TextMeshProLoungePoint.text = tostring(nLoungePoint)
    end

    local strCoin = MoneyFormatHelper.numWithCommas(nCoinReward)
    self.m_TextMeshProCoin.text = strCoin
    self.m_TextMeshProCardPackCount.text = "+" .. tostring(param.cardPackCount)

    for i = 0, self.m_trStarsNode.childCount - 1 do
        if i <= param.packType then
            self.m_trStarsNode:GetChild(i).gameObject:SetActive(true)
        else
            self.m_trStarsNode:GetChild(i).gameObject:SetActive(false)
        end
        self.m_trCardsNode:GetChild(i).gameObject:SetActive(i == param.packType)
    end

end

function CollectFreeBonusUI:Hide()
    ViewAlphaAni:Hide(self.transform.gameObject)
end

function CollectFreeBonusUI:OnBtnCollectClicked(btnCollect)
    btnCollect.interactable = false
    LeanTween.delayedCall(3.9, function()
        btnCollect.interactable = true
    end)

    LoungeHandler:addLoungePoints(self.m_nLoungePoint)
    local data = LoungeHandler.data.activityData.listMedalMasterData
    data.listFreeBonusLastLocalTime[self.m_nCurMedalIndex] = TimeHandler:GetServerTimeStamp()
    LoungeHandler:SaveDb()

    local posStart = self.m_TextMeshProCoin.transform.position
    PlayerHandler:AddCoin(self.m_nBonusCoins)
    CoinFly:fly(posStart, GlobalTempData.goUITopCollectMoneyEndPos.transform.position, 12, true)

    LeanTween.delayedCall(3.2, function()
        self:Hide()
        local cardPackCount = self.m_ParamCardPack.cardPackCount
        local packType = self.m_ParamCardPack.packType
        SlotsCardsHandler:addPackCount(packType, cardPackCount)
        SlotsCardsGetPackPop:Show(packType, true, cardPackCount)
    end)

end