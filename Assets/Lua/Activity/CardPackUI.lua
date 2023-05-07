CardPackUI = {}

function CardPackUI:new(go)
    local o = {}
	setmetatable(o, self)
	self.__index = self
    o:init(go)
    return o
end

function CardPackUI:init(go)
    self.transform.gameObject = go
    self.transform = go.transform
    self.tableGoCardPack = LuaHelper.GetTableFindChild(self.transform, 5, "CardPack")
    self.tableGoStar = LuaHelper.GetTableFindChild(self.transform, 5, "Star")
    local tr = self.transform:FindDeepChild("textCardPackCount")
    if tr then
        self.textCardPackCount = tr:GetComponent(typeof(TextMeshProUGUI))
    end
end

function CardPackUI:set(nCardPackType, nCount)
    if nCardPackType then
        self.transform.gameObject:SetActive(true)
        for i = 1, 5 do           
            self.tableGoCardPack[i]:SetActive(i == nCardPackType)
            self.tableGoStar[i]:SetActive(i <= nCardPackType)
        end
        if nCount then
            self.textCardPackCount.text = tostring(nCount)
        end
    else    
        self.transform.gameObject:SetActive(false)
    end
end
