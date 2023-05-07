CookingFeverWildBasketUI = {}

function CookingFeverWildBasketUI:Init()
    local prefabObj = AssetBundleHandler:LoadActivityAsset("WildBasket")
    Debug.Assert(prefabObj)
    self.transform.gameObject = Unity.Object.Instantiate(prefabObj)
    self.transform.gameObject:SetActive(false)
    self.transform = self.transform.gameObject.transform
    self.transform:SetParent(LobbyScene.popCanvas, false)
    self.transform.localScale = Unity.Vector3.one
    self.popController = PopController:new(self.transform.gameObject, nil, PopTweenType.alpha)
    LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
    self.N_COLUMN = 3 --有3列 
    self.N_CELL = 10

    self.textWildBasketCount = self.transform:FindDeepChild("textWildBasketCount"):GetComponent(typeof(UnityUI.Text))

    self.btnClose = self.transform:FindDeepChild("btnClose"):GetComponentInChildren(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(self.btnClose)
    self.btnClose.onClick:AddListener(function()
        ActivityAudioHandler:PlaySound("cook_button")
        self:hide()
    end)

    self.goBtnFinish = self.transform:FindDeepChild("btnFinish").gameObject
    self.btnFinish = self.goBtnFinish:GetComponentInChildren(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(self.btnFinish)
    self.btnFinish.onClick:AddListener(function()
        ActivityAudioHandler:PlaySound("cook_button")
        self:finish()
    end)

    self.goBtnFinish2 = self.transform:FindDeepChild("btnFinish2").gameObject

    self.v3ContentOriginalPos = nil
    self.tableTrContent = {}
    self.tableGoDish = {}
    self.tableGoCompleted = {}
    self.tableImageDish = {}

    self.tableGoCell = {}
    self.tableTextIngredientCount = {}
    self.tableTextIngredientName = {}
    self.tableImageIngredient = {}

    self.tabelBtnAdd = {}
    self.tabelBtnMinus = {}

    local trHorizontalGrid = self.transform:FindDeepChild("HorizontalGrid")
    for i = 1, self.N_COLUMN do
        local trDish = trHorizontalGrid:FindDeepChild("Dish"..i)
        self.tableTrContent[i] = trDish:FindDeepChild("Content")
        self.v3ContentOriginalPos = self.tableTrContent[i].localPosition
        self.tableGoDish[i] = trDish.gameObject
        self.tableGoCompleted[i] = trDish:FindDeepChild("Completed").gameObject
        self.tableImageDish[i] = trDish:FindDeepChild("imageDish"):GetComponentInChildren(typeof(UnityUI.Image))

        local trGrid = trDish:FindDeepChild("Grid")
        self.tableGoCell[i] = {}
        self.tableTextIngredientCount[i] = {}
        self.tableTextIngredientName[i] = {}
        self.tableImageIngredient[i] = {}
        self.tabelBtnAdd[i] = {}
        self.tabelBtnMinus[i] = {}
         
        for j = 1, 10 do
            local trCell = trGrid:GetChild(j - 1)
            self.tableGoCell[i][j] = trCell.gameObject
            local btnAdd = trCell:FindDeepChild("btnAdd"):GetComponentInChildren(typeof(UnityUI.Button))
            DelegateCache:addOnClickButton(btnAdd)
            btnAdd.onClick:AddListener(function()
                ActivityAudioHandler:PlaySound("cook_button")
                self:add(i,j)
            end)
            self.tabelBtnAdd[i][j] = btnAdd

            local btnMinus = trCell:FindDeepChild("btnMinus"):GetComponentInChildren(typeof(UnityUI.Button))
            DelegateCache:addOnClickButton(btnMinus)
            btnMinus.onClick:AddListener(function()
                ActivityAudioHandler:PlaySound("cook_button")
                self:minus(i,j)
            end)
            self.tabelBtnMinus[i][j] = btnMinus

            self.tableTextIngredientCount[i][j] = trCell:FindDeepChild("textNumber"):GetComponentInChildren(typeof(TextMeshProUGUI))
            self.tableTextIngredientName[i][j] = trCell:FindDeepChild("textName"):GetComponentInChildren(typeof(TextMeshProUGUI))
            self.tableImageIngredient[i][j] = trCell:FindDeepChild("ImageIngredient"):GetComponentInChildren(typeof(UnityUI.Image))
        end
    end

    self.btnLeft = self.transform:FindDeepChild("btnLeft"):GetComponent(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(self.btnLeft)
    self.btnLeft.onClick:AddListener(function()
        ActivityAudioHandler:PlaySound("cook_button")
        self.nPageIndex = LuaHelper.Loop(self.nPageIndex - 1, 1, self.nMaxPageIndex)
        self:setPage(self.nPageIndex)
    end)
    self.btnRight = self.transform:FindDeepChild("btnRight"):GetComponent(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(self.btnRight)
    self.btnRight.onClick:AddListener(function()
        ActivityAudioHandler:PlaySound("cook_button")
        self.nPageIndex = LuaHelper.Loop(self.nPageIndex + 1, 1, self.nMaxPageIndex)
        self:setPage(self.nPageIndex)
    end)

    local btnQuickExchange = self.transform:FindDeepChild("btnQuickExchange"):GetComponent(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(btnQuickExchange)
    btnQuickExchange.onClick:AddListener(function()
        ActivityAudioHandler:PlaySound("cook_button")
        CookingFeverIAPStoreUI:Show()
    end)

    ActivityHelper:addDataObserver("nWildBasketCount", self, 
    function(self, nWildBasketCount)
        if self.transform.gameObject.activeSelf then
            self.textWildBasketCount.text = tostring(nWildBasketCount)
            for i = 1, 3 do
                for j = 1, 10 do
                    self.tabelBtnAdd[i][j].interactable = nWildBasketCount > 0
                end
            end
        end
    end)
end

function CookingFeverWildBasketUI:Show()
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

    ActivityAudioHandler:PlaySound("cook_normal_pop_up")
    GlobalAudioHandler:LowerActiveBackgroundMusicVolume()
    ViewScaleAni:Show(self.transform.gameObject)
    local nDishesCount = #CookingFeverConfig.LevelInfo[CookingFeverDataHandler.data.nLevel]
    self.nMaxPageIndex = math.floor((nDishesCount - 1) / self.N_COLUMN) + 1
    self.textWildBasketCount.text = tostring(CookingFeverDataHandler.data.nWildBasketCount)
    self.tableNBuyCount =  LuaHelper.GetTable(0, CookingFeverConfig.N_INGREDIENT)
    self.goBtnFinish:SetActive(false)
    self.goBtnFinish2:SetActive(true)
    self:setPage(1)
    CookingFeverDataHandler:writeFile()
end

function CookingFeverWildBasketUI:hide()
    if not self.bCanHide then
        return 
    end
    self.bCanHide = false
    ViewScaleAni:Hide(self.transform.gameObject)
    CookingFeverDataHandler:readFile()
    ActivityHelper:AddMsgCountData("nWildBasketCount", 0)
end

function CookingFeverWildBasketUI:setPage(nPageIndex)
    self.nPageIndex = nPageIndex

    self.btnLeft.gameObject:SetActive(nPageIndex ~= 1)
    self.btnRight.gameObject:SetActive(nPageIndex ~= self.nMaxPageIndex)

    self.tableNDishes = {}

    local nIndex = (nPageIndex - 1) * self.N_COLUMN
    for i = nIndex + 1, nIndex + self.N_COLUMN do
        local nDish = CookingFeverConfig.LevelInfo[CookingFeverDataHandler.data.nLevel][i]
        if nDish then
            table.insert(self.tableNDishes, nDish)
        end
    end

    local nDishCount = #self.tableNDishes

    for i = 1, self.N_COLUMN do
        self.tableGoDish[i]:SetActive(i <= nDishCount)
        self.tableTrContent[i].localPosition = self.v3ContentOriginalPos
    end

    self:setItem()
    self:setNum()
end

function CookingFeverWildBasketUI:setItem()
    for i = 1, #self.tableNDishes do
        local nDishId = self.tableNDishes[i]
        self.tableImageDish[i].sprite = CookingFeverSymbolPool:getDishSprite(nDishId)
        self.tableGoCompleted[i]:SetActive(CookingFeverDataHandler.data.tableBCooked[nDishId])
        local tableNIngredientId = CookingFeverConfig.Recipe[nDishId].Ingredient
        local nIngredientKind = #tableNIngredientId
        for j = 1, self.N_CELL do
            self.tableGoCell[i][j]:SetActive(j <= nIngredientKind)
        end

        for j = 1, nIngredientKind do
            local nIngredientId = tableNIngredientId[j]
            self.tableTextIngredientName[i][j].text = CookingFeverConfig:getInredientUIName(nIngredientId)
            self.tableImageIngredient[i][j].sprite = CookingFeverSymbolPool:getIngredientSprite(nIngredientId)
        end
    end
end

function CookingFeverWildBasketUI:setNum()
    for i = 1, #self.tableNDishes do
        local nDishId = self.tableNDishes[i]
        local tableNIngredientId = CookingFeverConfig.Recipe[nDishId].Ingredient
        local nIngredientKind = #tableNIngredientId
        for j = 1, nIngredientKind do
            local nIngredientId = tableNIngredientId[j]       
            local nNeedCount = CookingFeverConfig.Recipe[nDishId].Count[j]
            local nCurCount = CookingFeverDataHandler.data.tableNIngredientCount[nIngredientId]
            local color
            if nCurCount >= nNeedCount then
                color = "18AC00FF"
            else
                color = "FC0000FF"
            end
            self.tableTextIngredientCount[i][j].text = string.format("<color=#%s>%s / %s</color>", color, nCurCount, nNeedCount)
   
            self.tabelBtnAdd[i][j].interactable = CookingFeverDataHandler.data.nWildBasketCount > 0
            self.tabelBtnMinus[i][j].interactable = self.tableNBuyCount[nIngredientId] > 0
        end
    end
end

function CookingFeverWildBasketUI:add(nDishIndex, nIngredientIndex)
    if CookingFeverDataHandler.data.nWildBasketCount > 0 then
        ActivityHelper:AddMsgCountData("nWildBasketCount", -1)
        nDishIndex = (self.nPageIndex - 1) * 3 + nDishIndex
        local nDishId = CookingFeverConfig.LevelInfo[CookingFeverDataHandler.data.nLevel][nDishIndex]
        local nIngredientId = CookingFeverConfig.Recipe[nDishId].Ingredient[nIngredientIndex]
        CookingFeverDataHandler.data.tableNIngredientCount[nIngredientId] = CookingFeverDataHandler.data.tableNIngredientCount[nIngredientId] + 1
        self.tableNBuyCount[nIngredientId] = self.tableNBuyCount[nIngredientId] + 1
        self:setNum()
        self.goBtnFinish:SetActive(true)
        self.goBtnFinish2:SetActive(false)
    else
        CookingFeverIAPStoreUI:Show()
    end
end

function CookingFeverWildBasketUI:minus(nDishIndex, nIngredientIndex)
    nDishIndex = (self.nPageIndex - 1) * 3 + nDishIndex
    local nDishId = CookingFeverConfig.LevelInfo[CookingFeverDataHandler.data.nLevel][nDishIndex]
    local nIngredientId = CookingFeverConfig.Recipe[nDishId].Ingredient[nIngredientIndex]

    if self.tableNBuyCount[nIngredientId] > 0 then
        ActivityHelper:AddMsgCountData("nWildBasketCount", 1)
        CookingFeverDataHandler.data.tableNIngredientCount[nIngredientId] = CookingFeverDataHandler.data.tableNIngredientCount[nIngredientId] - 1
    
        self.tableNBuyCount[nIngredientId] = self.tableNBuyCount[nIngredientId] - 1
        self:setNum()
        --是否可以点Finish
        local bFlag = true
        for i = 1, #self.tableNBuyCount do
            if self.tableNBuyCount[i] > 0 then
                bFlag = false
            end
        end
        self.goBtnFinish:SetActive(not bFlag)
        self.goBtnFinish2:SetActive(bFlag)
    end
end

function CookingFeverWildBasketUI:finish()
    if not self.bCanHide then
        return 
    end
    self.bCanHide = false
    CookingFeverDataHandler:writeFile()
    CookingFeverMainUIPop:SetItem(CookingFeverDataHandler.data.nLevel)
    ViewScaleAni:Hide(self.transform.gameObject)
end