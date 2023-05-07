AllMedalLevelTo5StarsUI = {}
AllMedalLevelTo5StarsUI.m_bInitFlag = false

function AllMedalLevelTo5StarsUI:Show()
    if not LuaHelper.OrGameObjectExist(self.transform) then
        local goPrefab = AssetBundleHandler:LoadGoldenLoungeAsset("AllMedalLevelTo5StarsUI.prefab")
        local goPanel = Unity.Object.Instantiate(goPrefab)
        self.transform = goPanel.transform
        self.transform:SetParent(LobbyScene.popCanvas, false)
        self.transform.localScale = Unity.Vector3.one
        self.transform.localPosition = Unity.Vector3.zero
        LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
        self.transform.gameObject:SetActive(false)

        local btnClaim = self.transform:FindDeepChild("BtnClaim"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(btnClaim)
        btnClaim.onClick:AddListener(function()
            GlobalAudioHandler:PlayBtnSound()
            self:OnBtnClaimClicked(btnClaim)
        end)

        self.m_TextGrandPrizeCoins = self.transform:FindDeepChild("TextGrandPrizeCoins"):GetComponent(typeof(UnityUI.Text))
    end
    
    ViewAlphaAni:Show(self.transform.gameObject)
    
    -- 都五星之后的总奖励
    local nBaseCoins = LoungeConfig:getOneDollarCoins()
    local nGrandPrize = math.floor(LoungeConfig.fTotalPrize * nBaseCoins)
    self.m_nGrandPrize = nGrandPrize
    local strCoin = MoneyFormatHelper.numWithCommas(nGrandPrize)
    self.m_TextGrandPrizeCoins.text = strCoin

    self.transform:SetAsLastSibling() -- SetAsFirstSibling -- SetSiblingIndex(0)
    LoungeAudioHandler:PlaySound("all_medal_full_level")
end

function AllMedalLevelTo5StarsUI:Hide(normalHide)
    ViewAlphaAni:Hide(self.transform.gameObject)
end

function AllMedalLevelTo5StarsUI:OnBtnClaimClicked(btnClaim)
    btnClaim.interactable = false
    LeanTween.delayedCall(3.9, function()
        btnClaim.interactable = true
    end)

    -- 加钱 飞金币
    local playerData = LoungeHandler.data.activityData.listMedalMasterData
    playerData.bGrandPrizeClaimed = true
    LoungeHandler:SaveDb()

    local posStart = self.m_TextGrandPrizeCoins.transform.position
    PlayerHandler:AddCoin(self.m_nGrandPrize)
    CoinFly:fly(posStart, GlobalTempData.goUITopCollectMoneyEndPos.transform.position, 12, true)

    LeanTween.delayedCall(3.2, function()
        self:Hide()
    end)

    if MedalMasterMainUI:isActiveShow() then
        MedalMasterMainUI.TextTotalPrize.transform.gameObject:SetActive(false)
        MedalMasterMainUI.goSeasonRewardCollectedNode:SetActive(true)
    end
end