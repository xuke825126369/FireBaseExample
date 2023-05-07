--点击菜，出现菜谱
CookingFeverRecipeUI = {}

function CookingFeverRecipeUI:Init()
    local prefabObj = AssetBundleHandler:LoadActivityAsset("Recipe")
    Debug.Assert(prefabObj)
    self.transform.gameObject = Unity.Object.Instantiate(prefabObj)
    self.transform.gameObject:SetActive(false)
    self.transform = self.transform.gameObject.transform
    self.transform:SetParent(LobbyScene.popCanvas, false)
    self.popController = PopController:new(self.transform.gameObject, nil, PopTweenType.alpha)

    self.textWinCoin = self.transform:FindDeepChild("textWinCoin"):GetComponent(typeof(UnityUI.Text))

    self.tableGoLevel = LuaHelper.GetTableFindChild(self.transform, CookingFeverConfig.N_MAX_LEVEL, "Level")
    self.tableGoDishes = {}
    for i = 1, CookingFeverConfig.N_MAX_LEVEL do
        self.tableGoDishes[i] = {}
        for j = 1, #CookingFeverConfig.LevelInfo[i] do
            self.tableGoDishes[i][j] = self.tableGoLevel[i].transform:FindDeepChild("Dish"..j).gameObject
        end
    end

    local btnClose = self.transform:FindDeepChild("btnClose"):GetComponent(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(btnClose)
    btnClose.onClick:AddListener(function()
        ActivityAudioHandler:PlaySound("cook_button")
        self:hide()
    end)

    self.tableGoBackground = {}
    self.tableTextName = {}
    self.tableTextCount = {}
    self.tabelGoFrame = {}
    self.N_CELL = 10
    for i = 1, self.N_CELL do
        local trCell = self.transform:FindDeepChild("Cell"..i)
        self.tableGoBackground[i] = trCell:FindDeepChild("Background").gameObject
        self.tableTextName[i] = trCell:FindDeepChild("textName"):GetComponent(typeof(TextMeshProUGUI))
        self.tableTextCount[i] = trCell:FindDeepChild("textCount"):GetComponent(typeof(TextMeshProUGUI))
        self.tabelGoFrame[i] = trCell:FindDeepChild("TuPianKuang").gameObject
    end

    self.goNoEnoughIngredients = self.transform:FindDeepChild("textNoEnoughIngredients").gameObject
    self.goBtnCook = self.transform:FindDeepChild("btnCook").gameObject
    local btnCook = self.goBtnCook:GetComponent(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(btnCook)
    btnCook.onClick:AddListener(function()
        ActivityAudioHandler:PlaySound("cook_button")
        self:cook()
    end)
    self.goBtnCookMore = self.transform:FindDeepChild("btnCookMore").gameObject
    local btnCookMore = self.goBtnCookMore:GetComponent(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(btnCookMore)
    btnCookMore.onClick:AddListener(function()
        ActivityAudioHandler:PlaySound("cook_button")
        self:cook()
    end)

    local btnLeft = self.transform:FindDeepChild("btnLeft"):GetComponent(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(btnLeft)
    btnLeft.onClick:AddListener(function()
        ActivityAudioHandler:PlaySound("cook_button")
        local nMaxDish = #CookingFeverConfig.LevelInfo[self.nLevel]
        self.nIndex = LuaHelper.Loop(self.nIndex - 1, 1, nMaxDish)
        self:set(self.nLevel, self.nIndex)
    end)
    local btnRight = self.transform:FindDeepChild("btnRight"):GetComponent(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(btnRight)
    btnRight.onClick:AddListener(function()
        ActivityAudioHandler:PlaySound("cook_button")
        local nMaxDish = #CookingFeverConfig.LevelInfo[self.nLevel]
        self.nIndex = LuaHelper.Loop(self.nIndex + 1, 1, nMaxDish)
        self:set(self.nLevel, self.nIndex)
    end)
end

function CookingFeverRecipeUI:show(nLevel, nIndex)
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
    ActivityAudioHandler:PlaySound("cook_normal_pop_up")
    GlobalAudioHandler:LowerActiveBackgroundMusicVolume()
    ViewScaleAni:Show(self.transform.gameObject)
    self:set(nLevel, nIndex)
    self.bCanHide = true
    self.textWinCoin.text = MoneyFormatHelper.numWithCommas(CookingFeverDataHandler.m_mapDishPrize[nLevel])
end

function CookingFeverRecipeUI:hide()
    if not self.bCanHide then return end
    self.bCanHide = false
    ViewScaleAni:Hide(self.transform.gameObject)
end

function CookingFeverRecipeUI:set(nLevel, nIndex)
    self.nLevel = nLevel
    self.nIndex = nIndex

    for i = 1, CookingFeverConfig.N_MAX_LEVEL do
        self.tableGoLevel[i]:SetActive(i == nLevel)
        if i == nLevel then
            for j = 1, #CookingFeverConfig.LevelInfo[i] do
                self.tableGoDishes[i][j]:SetActive(j == nIndex)
            end
        end
    end

    local nDish = CookingFeverConfig.LevelInfo[nLevel][nIndex]
    self.nDish = nDish
    local tableNIngredient = CookingFeverConfig.Recipe[nDish].Ingredient
    local nIngredientCount = #tableNIngredient
    for i = 1, self.N_CELL do
        --设置背景
        self.tableGoBackground[i]:SetActive(i <= nIngredientCount)
        self.tabelGoFrame[i]:SetActive(i <= nIngredientCount)
        --设置名字
        if i <= nIngredientCount then
            local nId = tableNIngredient[i]
            self.tableTextName[i].text = CookingFeverConfig:getInredientUIName(nId)
        else
            self.tableTextName[i].text = ""
        end
        --设置数量
        local tableNCount = CookingFeverConfig.Recipe[nDish].Count
        if i <= nIngredientCount then
            local nId = tableNIngredient[i]
            local nNeedCount = tableNCount[i]
            local nCurCount = CookingFeverDataHandler.data.tableNIngredientCount[nId]
            local color
            if nCurCount >= nNeedCount then
                color = "3AFF4CFF"
            else
                color = "FD4949FF"
            end
            self.tableTextCount[i].text = string.format("<color=#%s>%s / %s</color>", color, nCurCount, nNeedCount)
        else
            self.tableTextCount[i].text = ""
        end
    end

    local bCanCook = CookingFeverDataHandler:checkCanCook(nDish)
    local bCookded = CookingFeverDataHandler.data.tableBCooked[nDish]

    self.goNoEnoughIngredients:SetActive(not bCanCook)
    self.goBtnCook:SetActive(bCanCook and not bCookded)
    self.goBtnCookMore:SetActive(bCanCook and bCookded)
end

function CookingFeverRecipeUI:cook()
    if not self.bCanHide then return end
    self.bCanHide = false
    ViewScaleAni:Hide(self.transform.gameObject)
    CookingFeverDataHandler:cook(self.nDish)
end