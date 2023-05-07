TipPoolView = {}

function TipPoolView:Init()
	local bundleName = "Global"
	local assetPath = "Assets/ResourceABs/Global/View/TipPoolView.prefab"
	local goPrefab = AssetBundleHandler:LoadAsset(bundleName, assetPath)
	local goPanel = Unity.Object.Instantiate(goPrefab)

    local goParent =  GlobalScene.popCanvas
    self.transform = goPanel.transform
    self.transform:SetParent(goParent, false)
    self.transform.localScale = Unity.Vector3.one
	self.transform.localPosition = Unity.Vector3.zero
        
    LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
    self.transform.gameObject:SetActive(false)

    self.tableDes = {}
    self.tableUsedItem = {}
    self.tableItemPool = {}
    for i = 1, 3 do
        self.tableItemPool[i] = self:GetItem()
    end

end

function TipPoolView:GetItem()
    local tranRoomParent = self.transform

    local bundleName = "Global"
	local assetPath = "Assets/ResourceABs/Global/View/TipViewItem.prefab"
	local goPrefab = AssetBundleHandler:LoadAsset(bundleName, assetPath)
    
    local go = Unity.Object.Instantiate(goPrefab)
    go.transform:SetParent(tranRoomParent, false)
    go.transform.localScale = Unity.Vector3.one
    go.transform.localPosition = Unity.Vector3.zero

    local rectTransform = go.transform:GetComponent(typeof(Unity.RectTransform))
    rectTransform.anchorMin = Unity.Vector2(0.5, 0.5)
    rectTransform.anchorMax = Unity.Vector2(0.5, 0.5)
    rectTransform.anchoredPosition = Unity.Vector2 (0, 0)
        
    local goItem = go
    local deskItemGenerator = require "Lua/GlobalScene/TipViewItem"
    return deskItemGenerator:New(goItem)
end

function TipPoolView:Show(strDes)
    self.transform.gameObject:SetActive(true)
    self.transform:SetAsLastSibling()
    table.insert(self.tableDes, strDes)
    
    if not self:orInAni() then
        self.bAni = true
        self.fTipCdTime = 0
        self.fTipInternalTime = 0.3

        local strDes = table.remove(self.tableDes, 1)
        local viewTipItem = table.remove(self.tableItemPool)
        viewTipItem:Show(strDes)
        table.insert(self.tableUsedItem, viewTipItem)
    end
    
end

function TipPoolView:Hide()
    self.transform.gameObject:SetActive(false)
    for k, v in pairs(self.tableUsedItem) do
       self:RecycleItem(v)
    end
    self.tableUsedItem = {}
    self.tableDes = {}
end

function TipPoolView:Update(fElapsedTime)
    if #self.tableDes > 0 then
        self.fTipCdTime = self.fTipCdTime + Unity.Time.deltaTime
        if self.fTipCdTime > self.fTipInternalTime then
            local strDes = table.remove(self.tableDes, 1)
            local viewTipItem = nil
            if #self.tableItemPool > 0 then
                viewTipItem = table.remove(self.tableItemPool)
            else
                viewTipItem = self:GetItem()
            end
            table.insert(self.tableUsedItem, viewTipItem)
            viewTipItem:Show(strDes)
            self.fTipCdTime = 0
        end
    end
end

function TipPoolView:orInAni()
   return #self.tableUsedItem > 0
end

function TipPoolView:RecycleItem(v)
    Debug.Assert(v, "v == nil")
    if LuaHelper.tableContainsElement(self.tableUsedItem, v) then
        v.transform.gameObject:SetActive(false)
        table.insert(self.tableItemPool, v)
        local nIndex = LuaHelper.indexOfTable(self.tableUsedItem, v)
        if nIndex and nIndex >= 1 then
            table.remove(self.tableUsedItem, nIndex)
        else
            Debug.LogError("TipPoolView:RecycleItem: "..v.transform.gameObject.name.." | "..nIndex)
        end
    end
end
