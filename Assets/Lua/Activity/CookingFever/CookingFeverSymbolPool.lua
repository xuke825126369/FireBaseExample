CookingFeverSymbolPool = {}

function CookingFeverSymbolPool:Init()
    self.tableGoItem = {}
    self.tableGoText = {}
    self.tableTextCount = {}
end

function CookingFeverSymbolPool:get(nId)
    if self.tableGoItem[nId] == nil then
        local strName = CookingFeverConfig:getIngredientNameById(nId)
        local prefabObj = AssetBundleHandler:LoadActivityAsset(string.format("SymbolPrefab/%s", strName))
        if prefabObj == nil then
            Debug.Log(strName.." is null")
        end
        local go = Unity.Object.Instantiate(prefabObj)
        self.tableGoItem[nId] = go
    end
    return self.tableGoItem[nId]
end

function CookingFeverSymbolPool:setNum(go, nCount)
    if not self.tableTextCount[go] then
        local tr = go.transform:FindDeepChild("txtNumber")
        local text = tr.gameObject:GetComponentInChildren(typeof(TextMeshProUGUI))
        self.tableTextCount[go] = text
        self.tableGoText[go] = go.transform:FindDeepChild("Tishi").gameObject
    end
    self.tableTextCount[go].text = tostring("x"..nCount)
    self.tableGoText[go]:SetActive(nCount > 0)
end

function CookingFeverSymbolPool:getIngredientSprite(nId)
    self.tableIngredientSprite = self.tableIngredientSprite or {}
    if self.tableIngredientSprite[nId] == nil then
        local strName = CookingFeverConfig:getIngredientNameById(nId)
        local strPath = string.format("Assets/ActiveNeedLoad/CookingFever/SymbolImage/%s.png", strName)
        local sprite = ActivityBundleHandler:loadAssetFromLoadedBundle(strPath,typeof(Unity.Sprite))   
        self.tableIngredientSprite[nId] = sprite
    end
    return self.tableIngredientSprite[nId]
end

function CookingFeverSymbolPool:getDishSprite(nId)
    self.tableDishSprite = self.tableDishSprite or {}
    if self.tableDishSprite[nId] == nil then
        local strName = CookingFeverConfig:getDishNameById(nId)
        local strPath = string.format("Assets/ActiveNeedLoad/CookingFever/SymbolImage/%s.png", strName)
        local sprite = ActivityBundleHandler:loadAssetFromLoadedBundle(strPath,typeof(Unity.Sprite))   
        self.tableDishSprite[nId] = sprite
    end
    return self.tableDishSprite[nId]
end