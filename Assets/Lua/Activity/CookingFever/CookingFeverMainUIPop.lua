require("Lua.Activity.CookingFever.CookingFeverSymbolPool")
require("Lua.Activity.CookingFever.CookingFeverStorageBoxUI")
require("Lua.Activity.CookingFever.CookingFeverRewardIngredientUI")
require("Lua.Activity.CookingFever.CookingFeverRecipeUI")
require("Lua.Activity.CookingFever.CookingFeverFinishedDishUI")
require("Lua.Activity.CookingFever.CookingFeverFinalPrizeUI")
require("Lua.Activity.CookingFever.CookingFeverLevelPrizeSplashUI")
require("Lua.Activity.CookingFever.CookingFeverFinalPrizeSplashUI")
require("Lua.Activity.CookingFever.CookingFeverWildBasketUI")
require("Lua.Activity.CookingFever.CookingFeverIAPStoreUI")
require("Lua.Activity.CookingFever.CookingFeverIntroductionUI")
require("Lua.Activity.CookingFever.CookingFeverIAPConfig")

CookingFeverMainUIPop = {}

function CookingFeverMainUIPop:Show()
    if ActivityBundleHandler.m_bundleInfo.downloadStatus ~= DownloadStatus.Downloaded then
        return
    end
    if GameConfig.PLATFORM_EDITOR then
        ActivityBundleHandler:asynLoadAssetBundle()
        self:Show()
    else
        if self.asynLoadCo == nil then
            self.asynLoadCo = StartCoroutine(function()
                Scene.loadingAssetBundle:SetActive(true)
                Debug.Log("-------CookingFever begin Loaded---------")
                ActivityBundleHandler:asynLoadAssetBundle()
                local isReady = CookingFeverUnloadedUI.m_bAssetReady
                while (not isReady) do
                    yield_return(0)
                end
                Scene.loadingAssetBundle:SetActive(false)
                self:Show()
                self.asynLoadCo = nil
            end)
        end
    end
end

function CookingFeverMainUIPop:Show()
    if not self.m_bInitFlag then
        self:Init()
    end

    self.popController:show(function()
        GlobalAudioHandler:PlayActiveBackgroundMusic("cook_music_loop")
    end)
    self:SetItem(CookingFeverDataHandler.data.nLevel)
    self:UpdateFeatureTimeUI()

    if CookingFeverDataHandler.data.bFirstTime or CookingFeverDataHandler.data.nLevel > CookingFeverConfig.N_MAX_LEVEL then
        CookingFeverDataHandler.data.bFirstTime = false
        CookingFeverDataHandler:writeFile()
        self.transform.gameObject:SetActive(false)
        CookingFeverFinalPrizeUI:show(CookingFeverDataHandler.data.nLevel)
    end
    EventHandler:Brocast("onActiveShow")
end

function CookingFeverMainUIPop:Init()
    self.m_bInitFlag = true
    local prefabObj = AssetBundleHandler:LoadActivityAsset("CookingFeverMainUIPop")
    self.transform.gameObject = Unity.Object.Instantiate(prefabObj)

    self.transform = self.transform.gameObject.transform
    self.transform:SetParent(LobbyScene.popCanvas, false)
    self.popController = PopController:new(self.transform.gameObject, nil, PopTweenType.alpha)

    if GameConfig.IS_GREATER_169 then
        self.popController.adapterContainer.localScale = Unity.Vector3.one * 0.9
    end

    self.tableUI = {
        CookingFeverFinalPrizeSplashUI,
        CookingFeverFinalPrizeUI,
        CookingFeverFinishedDishUI,
        CookingFeverIAPStoreUI,
        CookingFeverIntroductionUI,
        CookingFeverLevelPrizeSplashUI,
        CookingFeverRecipeUI,
        CookingFeverRewardIngredientUI,
        CookingFeverStorageBoxUI,
        CookingFeverWildBasketUI,
        self,
    }

    local btnClose = self.transform:FindDeepChild("btnClose"):GetComponent(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(btnClose)
    btnClose.onClick:AddListener(function()
        ActivityAudioHandler:PlaySound("cook_button")
        self:hide()
    end)

    local btnBack = self.transform:FindDeepChild("btnBack"):GetComponent(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(btnBack)
    btnBack.onClick:AddListener(function()
        ActivityAudioHandler:PlaySound("cook_button")
        CookingFeverFinalPrizeUI:show(CookingFeverDataHandler.data.nLevel)
    end)
    --------------------菜--------------------
    local trItems = self.transform:FindDeepChild("Items")
    self.tableGoLevelItems = LuaHelper.GetTableFindChild(trItems, CookingFeverConfig.N_MAX_LEVEL, "Level")
    --------------------做菜--------------------
    self.tableGoCook = {}
    self.tableGoCookGray = {}
    self.tableGoCookMore = {}
    self.tableGoCookMoreGray = {}
    self.tableGoCooked = {} --一道菜是否做过了
    for i = 1, CookingFeverConfig.N_MAX_LEVEL do
        self.tableGoCook[i] = {}
        self.tableGoCookGray[i] = {}
        self.tableGoCookMore[i] = {}
        self.tableGoCookMoreGray[i] = {}
        self.tableGoCooked[i] = {}
        for j = 1, #CookingFeverConfig.LevelInfo[i] do
            local trDish = self.tableGoLevelItems[i].transform:FindDeepChild("Dish"..j)

            local go = trDish:FindDeepChild("Cook").gameObject
            self.tableGoCook[i][j] = go
            local go = trDish:FindDeepChild("CookGray").gameObject
            self.tableGoCookGray[i][j] = go
            local go = trDish:FindDeepChild("CookMore").gameObject
            self.tableGoCookMore[i][j] = go
            local go = trDish:FindDeepChild("CookMoreGray").gameObject
            self.tableGoCookMoreGray[i][j] = go

            local btn = self.tableGoCook[i][j].transform:GetComponentInChildren(typeof(UnityUI.Button))
            DelegateCache:addOnClickButton(btn)
            btn.onClick:AddListener(function()
                ActivityAudioHandler:PlaySound("cook_button")
                CookingFeverRecipeUI:show(i, j)
            end)

            local btn = self.tableGoCookGray[i][j].transform:GetComponentInChildren(typeof(UnityUI.Button))
            DelegateCache:addOnClickButton(btn)
            if btn == nil then Debug.Log(string.format("i %s j %s", i, j)) end
            btn.onClick:AddListener(function()
                ActivityAudioHandler:PlaySound("cook_button")
                CookingFeverRecipeUI:show(i, j)
            end)

            local btn = self.tableGoCookMore[i][j].transform:GetComponentInChildren(typeof(UnityUI.Button))
            DelegateCache:addOnClickButton(btn)
            btn.onClick:AddListener(function()
                ActivityAudioHandler:PlaySound("cook_button")
                CookingFeverRecipeUI:show(i, j)
            end)

            local btn = self.tableGoCookMoreGray[i][j].transform:GetComponentInChildren(typeof(UnityUI.Button))
            DelegateCache:addOnClickButton(btn)
            btn.onClick:AddListener(function()
                ActivityAudioHandler:PlaySound("cook_button")
                CookingFeverRecipeUI:show(i, j)
            end)

            self.tableGoCooked[i][j] = trDish:FindDeepChild("Finished").gameObject
        end
    end
    --------------------Cook币--------------------
    self.textCoin = self.transform:FindDeepChild("textCoin"):GetComponent(typeof(UnityUI.Text))
    self.textCoin.text = tostring(CookingFeverDataHandler.data.nAction)

    ActivityHelper:addDataObserver("nAction", self, 
    function(self, nCount)
        self.textCoin.text = tostring(nCount)
    end)
    --------------------储物箱--------------------
    CookingFeverSymbolPool:Init()
    local btnStorageBox = self.transform:FindDeepChild("btnStorageBox"):GetComponent(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(btnStorageBox)
    btnStorageBox.onClick:AddListener(function()
        ActivityAudioHandler:PlaySound("cook_button")
        CookingFeverStorageBoxUI:Show()
    end)
    --------------------菜篮子--------------------
    --CookingFeverRewardIngredientUI:Init()
    self.tableBtnBasket = {}
    for i = 1, 3 do
        local btnBasket = self.transform:FindDeepChild("btnBasket_"..i):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(btnBasket)
        btnBasket.onClick:AddListener(function()
            ActivityAudioHandler:PlaySound("cook_button")
            if CookingFeverDataHandler.data.nAction >= CookingFeverConfig.tableBasketPrice[i] then
                --退出Maxium状态
                if CookingFeverDataHandler.data.nAction >= CookingFeverConfig.N_MAX_ACTION 
                and CookingFeverDataHandler.data.nAction - CookingFeverConfig.tableBasketPrice[i] < CookingFeverConfig.N_MAX_ACTION then
                    CookingFeverDataHandler.data.fProgress = 0
                end
                ActivityHelper:AddMsgCountData("nAction", - CookingFeverConfig.tableBasketPrice[i])

                local tableNIngredient = CookingFeverDataHandler:getRewardIngredients(i, CookingFeverDataHandler.data.nLevel)
                --BasketBooster
                if CookingFeverDataHandler:checkInBoosterTime(2) then
                    for i = 1, CookingFeverConfig.N_INGREDIENT do
                        tableNIngredient[i] = tableNIngredient[i] * 2
                    end
                end
                for i = 1, CookingFeverConfig.N_INGREDIENT do
                    CookingFeverDataHandler.data.tableNIngredientCount[i] = CookingFeverDataHandler.data.tableNIngredientCount[i] + tableNIngredient[i]
                end 
                CookingFeverDataHandler:writeFile()
                CookingFeverRewardIngredientUI:show(i, tableNIngredient)
                self:SetItem(CookingFeverDataHandler.data.nLevel)
            else
                CookingFeverIAPStoreUI:Show()
            end
        end)
    end
    --------------------WildBasket--------------------
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

    --------------------Booster和WildBasket--------------------
    self.tableBoosterTimeCo = {}
    self.tableTextBooster = {}
    self.tableTextBooster[1] = self.transform:FindDeepChild("textCoinBooster"):GetComponent(typeof(TextMeshProUGUI))
    self.tableTextBooster[2]  = self.transform:FindDeepChild("textBasketBooster"):GetComponent(typeof(TextMeshProUGUI))
    self.textWildBasketCount = self.transform:FindDeepChild("textWildBasketCount"):GetComponent(typeof(TextMeshProUGUI))

    ActivityHelper:addDataObserver("nWildBasketCount", self, 
    function(self, nWildBasketCount)
        self.textWildBasketCount.text = tostring(nWildBasketCount)
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

    self.textWinCoin = self.transform:FindDeepChild("textWinCoin"):GetComponent(typeof(UnityUI.Text))

    self.goSlotsCards = self.transform:FindDeepChild("SlotsCards").gameObject
    self.tableGoCardPack = LuaHelper.GetTableFindChild(self.goSlotsCards.transform, 5, "CardPack")
    self.tableGoStar = LuaHelper.GetTableFindChild(self.goSlotsCards.transform, 5, "Star")
    self.textCardPackCount = self.goSlotsCards.transform:FindDeepChild("textCardPackCount"):GetComponent(typeof(TextMeshProUGUI))

    EventHandler:AddListener(self, "onPurchaseDoneNotifycation")
    EventHandler:AddListener(self, "onActiveTimesUp")
end

function CookingFeverMainUIPop:hide()
    EventHandler:Brocast("onActiveHide")
    ViewScaleAni:Hide(self.transform.gameObject)
end

function CookingFeverMainUIPop:OnDestroy()
    
end
---------------------------逻辑---------------------------
function CookingFeverMainUIPop:SetItem(nLevel)
    if nLevel > CookingFeverConfig.N_MAX_LEVEL then return end
    for i = 1, CookingFeverConfig.N_MAX_LEVEL do
        self.tableGoLevelItems[i]:SetActive(i == nLevel)
    end

    for j = 1, #CookingFeverConfig.LevelInfo[nLevel] do
        local nDishId = CookingFeverConfig.LevelInfo[nLevel][j]
        self.tableGoCooked[nLevel][j]:SetActive(CookingFeverDataHandler.data.tableBCooked[nDishId])
        local bCookedFlag = CookingFeverDataHandler.data.tableBCooked[nDishId]
        local bCanCookedFlag = CookingFeverDataHandler:checkCanCook(nDishId)

        self.tableGoCook[nLevel][j]:SetActive(not bCookedFlag and bCanCookedFlag)
        self.tableGoCookGray[nLevel][j]:SetActive(not bCookedFlag and not bCanCookedFlag)
        self.tableGoCookMore[nLevel][j]:SetActive(bCookedFlag and bCanCookedFlag)
        self.tableGoCookMoreGray[nLevel][j]:SetActive(bCookedFlag and not bCanCookedFlag)
    end
    self.textWinCoin.text = MoneyFormatHelper.numWithCommas(CookingFeverDataHandler.m_mapPrize[CookingFeverDataHandler.data.nLevel])

    --检测卡牌是否开启
    local bIsSlotsCardsOpen = SlotsCardsManager:orActivityOpen()
    self.goSlotsCards:SetActive(bIsSlotsCardsOpen)
    for i = 1, 5 do
        local n = CookingFeverConfig.LevelRewardCardPack[nLevel].nPackType + 1
        self.tableGoCardPack[i]:SetActive(i == n)
        self.tableGoStar[i]:SetActive(i <= n)
    end
    self.textCardPackCount.text = math.floor(CookingFeverConfig.LevelRewardCardPack[nLevel].nCount)
end

function CookingFeverMainUIPop:UpdateFeatureTimeUI()   
    for i = 1, 2 do
        if self.tableBoosterTimeCo[i] == nil and CookingFeverDataHandler:checkInBoosterTime(i) then
            self.tableBoosterTimeCo[i] = StartCoroutine(function() 
                while (CookingFeverDataHandler.data.tableNBoosterEndTime[i] > 0) and (self.transform ~= nil) do
                    local nowSecond = TimeHandler:GetServerTimeStamp()
                    local time = CookingFeverDataHandler.data.tableNBoosterEndTime[i] - nowSecond
                    local days = time // (3600*24)
                    local hours = time // 3600 - 24 * days
                    local minutes = time // 60 - 24 * days * 60 - 60 * hours
                    local seconds = time % 60
                    local str = string.format("%02d:%02d:%02d", hours, minutes, seconds)
                    self.tableTextBooster[i].text = str
                    if CookingFeverFinalPrizeUI.tableTextBooster then --可能CookingFeverFinalPrizeUI没有打开过，还没有init
                        CookingFeverFinalPrizeUI.tableTextBooster[i].text = str
                    end
                    if time <= 0 then
                        CookingFeverDataHandler.data.tableNBoosterEndTime[i] = 0
                    end
                    yield_return(YieldCache:Wait(1))
                end
                self.tableBoosterTimeCo[i] = nil
            end)
        else
            local str = string.format("%02d:%02d:%02d", 0, 0, 0)
            self.tableTextBooster[i].text = str
            if CookingFeverFinalPrizeUI.tableTextBooster then --可能CookingFeverFinalPrizeUI没有打开过，还没有init
                CookingFeverFinalPrizeUI.tableTextBooster[i].text = str
            end
        end
    end
end

function CookingFeverMainUIPop:onPurchaseDoneNotifycation()
    self:UpdateFeatureTimeUI()
end

function CookingFeverMainUIPop:onActiveTimesUp()
    self.m_bInitFlag = false
    if self.tableUI then
        for k, v in pairs(self.tableUI) do
            if v.transform.gameObject then
                v.transform.gameObject:SetActive(false)
            end
        end
    end
end

