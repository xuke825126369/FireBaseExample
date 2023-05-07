CookingFeverStorageBoxUI = {}

function CookingFeverStorageBoxUI:Init()
    local prefabObj = AssetBundleHandler:LoadActivityAsset("StorageBox")
    Debug.Assert(prefabObj)
    self.transform.gameObject = Unity.Object.Instantiate(prefabObj)
    self.transform = self.transform.gameObject.transform
    self.transform:SetParent(LobbyScene.popCanvas, false)

    self.N_MAX = 10 -- 每页最多有10个
    self.transform.gameObject:SetActive(false)
    self.popController = PopController:new(self.transform.gameObject, nil, PopTweenType.alpha)

    self.trItems = self.transform:FindDeepChild("Items")

    local btnBack = self.transform:FindDeepChild("btnBack"):GetComponent(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(btnBack)
    btnBack.onClick:AddListener(function()
        ActivityAudioHandler:PlaySound("cook_button")
        self:hide()
    end)

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
end

function CookingFeverStorageBoxUI:Show()
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
    self:refresh()
    self:setPage(1)
    ViewScaleAni:Show(self.transform.gameObject)
end

function CookingFeverStorageBoxUI:hide()
    ViewScaleAni:Hide(self.transform.gameObject)
end

function CookingFeverStorageBoxUI:refresh()
    local tableNeedIngredients = CookingFeverDataHandler:getNeedIngredient(CookingFeverDataHandler.data.nLevel)
    --分页
    self.tableNIngredients = {}
    local nPageIndex = 1
    for i = 1, CookingFeverConfig.N_INGREDIENT do
        if tableNeedIngredients[i] > 0 then
            if self.tableNIngredients[nPageIndex] == nil then
                self.tableNIngredients[nPageIndex] = {}
            end
            table.insert(self.tableNIngredients[nPageIndex], i)
            if #self.tableNIngredients[nPageIndex] >= self.N_MAX then
                nPageIndex = nPageIndex + 1
            end
        end
    end
    self.nMaxPageIndex = nPageIndex
end

function CookingFeverStorageBoxUI:setPage(nPageIndex)
    self.nPageIndex = nPageIndex
    self.btnLeft.gameObject:SetActive(nPageIndex ~= 1)
    self.btnRight.gameObject:SetActive(nPageIndex ~= self.nMaxPageIndex)

    for i = 0, self.trItems.childCount - 1 do
        self.trItems:GetChild(i).gameObject:SetActive(false)
    end

    local table = self.tableNIngredients[nPageIndex]
    for i = 1, #table do
        local nIngredientId = table[i]
        local go = CookingFeverSymbolPool:get(nIngredientId)
        go:SetActive(true)
        go.transform:SetParent(self.trItems)
        go.transform:SetSiblingIndex(i - 1)
        go.transform.localScale = Unity.Vector3.one
        CookingFeverSymbolPool:setNum(go, CookingFeverDataHandler.data.tableNIngredientCount[nIngredientId])
    end
end