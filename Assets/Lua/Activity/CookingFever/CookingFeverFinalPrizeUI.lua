CookingFeverFinalPrizeUI = {}

function CookingFeverFinalPrizeUI:Init()
    local prefabObj = AssetBundleHandler:LoadActivityAsset("FinalPrize")
    Debug.Assert(prefabObj)
    self.transform.gameObject = Unity.Object.Instantiate(prefabObj)
    self.transform.gameObject:SetActive(false)
    self.transform = self.transform.gameObject.transform
    self.transform:SetParent(LobbyScene.popCanvas, false)
    self.popController = PopController:new(self.transform.gameObject, nil, PopTweenType.alpha)

    local btnClose = self.transform:FindDeepChild("btnClose"):GetComponent(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(btnClose)
    btnClose.onClick:AddListener(function()
        if not self.bCanHide then return end
        ActivityAudioHandler:PlaySound("cook_button")
        self:hide()
        CookingFeverMainUIPop:hide()
    end)

    self.tableGoUnlocked = {}
    self.tableGoLocked = {}
    self.tableGoReward = {}

    self.tableGoBtnPlay = {}
    self.tableTextCookCoin = {}
    self.tableGoCompleted = {}
    self.tableTextCoin = {}
    for i = 1, CookingFeverConfig.N_MAX_LEVEL do
        local trLevel = self.transform:FindDeepChild("Level"..i)
        self.tableGoUnlocked[i] = trLevel:FindDeepChild("Unlocked").gameObject
        self.tableGoLocked[i] = trLevel:FindDeepChild("Locked").gameObject
        self.tableGoReward[i] = trLevel:FindDeepChild("Reward").gameObject

        local btnPlay = self.tableGoUnlocked[i].transform:FindDeepChild("btnPlay"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(btnPlay)
        btnPlay.onClick:AddListener(function()
            if not self.bCanHide then return end
            ActivityAudioHandler:PlaySound("cook_button")
            self:hide()
            CookingFeverMainUIPop:Show()
            CookingFeverMainUIPop:SetItem(CookingFeverDataHandler.data.nLevel)
        end)
        self.tableGoBtnPlay[i] = btnPlay.gameObject

        self.tableGoCompleted[i] = self.tableGoUnlocked[i].transform:FindDeepChild("Completed").gameObject
        self.tableTextCoin[i] = trLevel:FindDeepChild("textCoin"):GetComponent(typeof(UnityUI.Text))

        self.tableTextCookCoin[i] = self.tableGoBtnPlay[i].transform:FindDeepChild("CoinNumber"):GetComponent(typeof(UnityUI.Text))
    end

    self.tableTextBooster = {}
    self.tableTextBooster[1] = self.transform:FindDeepChild("textCoinBooster"):GetComponent(typeof(TextMeshProUGUI))
    self.tableTextBooster[2]  = self.transform:FindDeepChild("textBasketBooster"):GetComponent(typeof(TextMeshProUGUI))
    self.textWildBasketCount = self.transform:FindDeepChild("textWildBasketCount"):GetComponent(typeof(TextMeshProUGUI))

    ActivityHelper:addDataObserver("nWildBasketCount", self, 
    function(self, nWildBasketCount)
        self.textWildBasketCount.text = tostring(nWildBasketCount)
    end)

    ActivityHelper:addDataObserver("nAction", self, 
    function(self, nAction)
        for i = 1, CookingFeverConfig.N_MAX_LEVEL do
            self.tableTextCookCoin[i].text = tostring(nAction)
        end
    end)

    local btnWildBasket = self.transform:FindDeepChild("btnWildBasket"):GetComponent(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(btnWildBasket)
    btnWildBasket.onClick:AddListener(function()
        ActivityAudioHandler:PlaySound("cook_button")
        CookingFeverWildBasketUI:Show()
    end)

    local btnAddWildBasket = self.transform:FindDeepChild("btnAddWildBasket"):GetComponent(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(btnAddWildBasket)
    btnAddWildBasket.onClick:AddListener(function()
        ActivityAudioHandler:PlaySound("cook_button")
        CookingFeverIAPStoreUI:Show()
    end)
    local btnAddWildBasket2 = self.transform:FindDeepChild("btnAddWildBasket2"):GetComponent(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(btnAddWildBasket2)
    btnAddWildBasket2.onClick:AddListener(function()
        ActivityAudioHandler:PlaySound("cook_button")
        CookingFeverIAPStoreUI:Show()
    end)

    local btnAddCoinBooster = self.transform:FindDeepChild("btnAddCoinBooster"):GetComponent(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(btnAddCoinBooster)
    btnAddCoinBooster.onClick:AddListener(function()
        ActivityAudioHandler:PlaySound("cook_button")
        CookingFeverIAPStoreUI:Show()
    end)
    local btnAddCoinBooster2 = self.transform:FindDeepChild("btnAddCoinBooster2"):GetComponent(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(btnAddCoinBooster2)
    btnAddCoinBooster2.onClick:AddListener(function()
        ActivityAudioHandler:PlaySound("cook_button")
        CookingFeverIAPStoreUI:Show()
    end)

    local btnAddBasketBooster = self.transform:FindDeepChild("btnAddBasketBooster"):GetComponent(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(btnAddBasketBooster)
    btnAddBasketBooster.onClick:AddListener(function()
        ActivityAudioHandler:PlaySound("cook_button")
        CookingFeverIAPStoreUI:Show()
    end)
    local btnAddBasketBooster2 = self.transform:FindDeepChild("btnAddBasketBooster2"):GetComponent(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(btnAddBasketBooster2)
    btnAddBasketBooster2.onClick:AddListener(function()
        ActivityAudioHandler:PlaySound("cook_button")
        CookingFeverIAPStoreUI:Show()
    end)

    self.textDate = self.transform:FindDeepChild("textDate"):GetComponent(typeof(TextMeshProUGUI))

    self.textFinalPrizeWinCoin = self.transform:FindDeepChild("textFinalPrizeWinCoin"):GetComponent(typeof(UnityUI.Text))
    self.goSlotsCards = self.transform:FindDeepChild("SlotsCards").gameObject
    self.tableGoCardPack = LuaHelper.GetTableFindChild(self.goSlotsCards.transform, 5, "CardPack")
    self.tableGoStar = LuaHelper.GetTableFindChild(self.goSlotsCards.transform, 5, "Star")
    self.textCardPackCount = self.goSlotsCards.transform:FindDeepChild("textCardPackCount"):GetComponent(typeof(TextMeshProUGUI))

    local btnIntroduction = self.transform:FindDeepChild("btnIntroduction"):GetComponent(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(btnIntroduction)
    btnIntroduction.onClick:AddListener(function() 
        ActivityAudioHandler:PlaySound("cook_button")    
        CookingFeverIntroductionUI:Show()
    end)
end

function CookingFeverFinalPrizeUI:show(nLevel)
    if self.transform.gameObject == nil then
        self.m_bInitFlag = false
    else
        if self.transform.gameObject:Equals(nil) then
            self.m_bInitFlag = false
        end
    end
    if not self.m_bInitFlag then
        self.m_bInitFlag = true
        self:Init()
    end
    
    self.bCanHide = true
    for i = 1, CookingFeverConfig.N_MAX_LEVEL do
        self.tableGoUnlocked[i]:SetActive(i <= nLevel)
        self.tableGoLocked[i]:SetActive(i > nLevel)

        self.tableGoBtnPlay[i]:SetActive(i >= nLevel)
        self.tableGoCompleted[i]:SetActive(i < nLevel)
        self.tableGoReward[i]:SetActive(i >= nLevel)
    end
    
    for i = 1, CookingFeverConfig.N_MAX_LEVEL do
        self.tableTextCoin[i].text = MoneyFormatHelper.numWithCommas(CookingFeverDataHandler.m_mapPrize[i])
    end

    self.textFinalPrizeWinCoin.text = MoneyFormatHelper.numWithCommas(CookingFeverDataHandler.nFinalPrize)
    --检测卡牌是否开启
    local bIsSlotsCardsOpen = SlotsCardsManager:orActivityOpen()
    self.goSlotsCards:SetActive(bIsSlotsCardsOpen)
    if bIsSlotsCardsOpen then
        for i = 1, 5 do
            local nCardPackLevel = CookingFeverConfig.FinalPrizeRewardCardPack.nPackType + 1
            self.tableGoCardPack[i]:SetActive(i == nCardPackLevel)
            self.tableGoStar[i]:SetActive(i <= nCardPackLevel)
        end
        self.textCardPackCount.text = math.floor(CookingFeverConfig.FinalPrizeRewardCardPack.nCount)
    end

    self.popController:show(nil, nil, true)

    EventHandler:AddListener(self, "onActiveTimeChanged")

    StaticDataHandler:add(ActiveManager.activeType, "nFinalPrizeTime")
end

function CookingFeverFinalPrizeUI:hide()
    if not self.bCanHide then return end
    self.bCanHide = false
    ViewScaleAni:Hide(self.transform.gameObject)
    ActivityHelper:SetTrigger(self.transform.gameObject, "Hide")
    NotificationHandler:removeObserver(self)
end

function CookingFeverFinalPrizeUI:onActiveTimeChanged(time)
    if time <= 0 then
    else
        self.textDate.text = ActivityHelper:FormatTime(time)
    end
end