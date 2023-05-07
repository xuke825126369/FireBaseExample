--点击篮子奖励原料
CookingFeverRewardIngredientUI = {}

function CookingFeverRewardIngredientUI:Init()
    local prefabObj = AssetBundleHandler:LoadActivityAsset("Rewardingredients")
    Debug.Assert(prefabObj)
    self.transform.gameObject = Unity.Object.Instantiate(prefabObj)
    self.transform.gameObject:SetActive(false)
    self.transform = self.transform.gameObject.transform
    self.transform:SetParent(LobbyScene.popCanvas, false)
    self.transform.localScale = Unity.Vector3.one
    self.popController = PopController:new(self.transform.gameObject, nil, PopTweenType.alpha)

    self.btnCollect = self.transform:FindDeepChild("btnCollect"):GetComponent(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(self.btnCollect)
    self.btnCollect.onClick:AddListener(function()
        ActivityAudioHandler:PlaySound("cook_button")
        self:hide()
    end)

    self.tableGoItems = LuaHelper.GetTableFindChild(self.transform, 3, "Items")
    self.tableTrItemContainer = {}
    for i = 1, 3 do
        self.tableTrItemContainer[i] = self.tableGoItems[i].transform:FindDeepChild("Items")
    end
end

function CookingFeverRewardIngredientUI:show(nBasketIndex, tableNIngredient)
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
    self.btnCollect.interactable = true
    ActivityAudioHandler:PlaySound("cook_buy_source_cheer")
    GlobalAudioHandler:LowerActiveBackgroundMusicVolume()
    ViewScaleAni:Show(self.transform.gameObject)
    ActivityHelper:PlayAni(self.transform.gameObject, "Show")

    for i = 1, 3 do
        self.tableGoItems[i]:SetActive(i == nBasketIndex)
    end

    local trItems = self.tableTrItemContainer[nBasketIndex].transform

    for i = 0, trItems.childCount - 1 do
        trItems:GetChild(i).gameObject:SetActive(false)
    end

    for i = 1, CookingFeverConfig.N_INGREDIENT do
        if tableNIngredient[i] > 0 then
            local go = CookingFeverSymbolPool:get(i)
            if go == nil then
                Debug.Log(i)
            end
            CookingFeverSymbolPool:setNum(go, tableNIngredient[i])
            go:SetActive(true)
            go.transform:SetParent(trItems)
            go.transform.localScale = Unity.Vector3.one
            go.transform.localPosition = Unity.Vector3.zero
        end
    end
end

function CookingFeverRewardIngredientUI:hide()
    self.btnCollect.interactable = false
    ViewScaleAni:Hide(self.transform.gameObject)
    ActivityHelper:PlayAni(self.transform.gameObject, "Hide")
end