local UIPayTable = {}

function UIPayTable:Init()
    local strPayTableFullName = "PayTable.prefab"
	local payTableObj = AssetBundleHandler:LoadThemeAsset(strPayTableFullName)
    local goPayTable = Unity.Object.Instantiate(payTableObj)
    goPayTable.transform:SetParent(ThemeVideoScene.mPopScreenCanvas, false)
    goPayTable.name = "PayTable"
    goPayTable:SetActive(false)

    self.m_transform = goPayTable.transform
    LuaAutoBindMonoBehaviour.Bind(goPayTable, self)

    self.m_goPages = {}
    for i = 0, self.m_transform.childCount - 1 do
        local tempTran = self.m_transform:GetChild(i)
        local startIndex, endIdnex = string.find(tempTran.name, "page?")
        if startIndex ~= nil then
            table.insert(self.m_goPages, tempTran.gameObject)
        end 
    end

    table.sort(self.m_goPages, function(xGo,yGo)
        local xGoSortNum = tonumber(string.sub(xGo.name,5))
        local yGoSortNum = tonumber(string.sub(yGo.name,5))
        return xGoSortNum <= yGoSortNum
    end)
    
    self.m_nTotalPages = #self.m_goPages

    self.m_btnBackGame = self.m_transform:FindDeepChild("button/backGameBtn").gameObject
    self.m_btnBackGame:GetComponent("Button").onClick:AddListener(function()
			self:OnButtonBackToGame()
		end)
    self.m_btnPrePage = self.m_transform:FindDeepChild("button/prePage").gameObject
    self.m_btnPrePage:GetComponent("Button").onClick:AddListener(function()
			self:OnButtonPrev()
		end)
    self.m_btnNextPage = self.m_transform:FindDeepChild("button/nextPage").gameObject
    self.m_btnNextPage:GetComponent("Button").onClick:AddListener(function()
			self:OnButtonNext()
		end)

    self.m_nCurPageIndex = 1
    for i = 1, self.m_nTotalPages do
        self.m_goPages[i]:SetActive(false)
    end
    
end

function UIPayTable:OnDestroy()
    self.m_transform = nil
    self.m_btnBackGame = nil
    self.m_btnNextPage = nil
    self.m_btnPrePage = nil
    self.m_goPages = nil
end

function UIPayTable:OnButtonPrev()
    AudioHandler:PlayBtnSound()
    self.m_goPages[self.m_nCurPageIndex]:SetActive(false)
    self.m_nCurPageIndex = self.m_nCurPageIndex - 1
    if self.m_nCurPageIndex < 1 then
        self.m_nCurPageIndex = self.m_nTotalPages
    end
    self.m_goPages[self.m_nCurPageIndex]:SetActive(true)
end

function UIPayTable:OnButtonNext()
    AudioHandler:PlayBtnSound()
    self.m_goPages[self.m_nCurPageIndex]:SetActive(false)
    self.m_nCurPageIndex = self.m_nCurPageIndex + 1
    if self.m_nCurPageIndex > self.m_nTotalPages then
        self.m_nCurPageIndex = 1
    end
    self.m_goPages[self.m_nCurPageIndex]:SetActive(true)
end

function UIPayTable:OnButtonBackToGame()
    AudioHandler:PlayBtnSound()
    self:Hide()
end

function UIPayTable:Hide()
    self.m_transform.gameObject:SetActive(false)
    SceneSlotGame.m_bUIState = false
    self.m_nCurPageIndex = 1

    for i = 1, self.m_nTotalPages do
        self.m_goPages[i]:SetActive(false)
    end

    SlotsGameLua.m_bReelPauseFlag = false
end

function UIPayTable:Show()
    SceneSlotGame.m_bUIState = true
    self.m_transform.localPosition = Unity.Vector3.zero
    self.m_transform.gameObject:SetActive(true)
    self.m_nCurPageIndex = 1
    self.m_goPages[self.m_nCurPageIndex]:SetActive(true)
    SlotsGameLua.m_bReelPauseFlag = true
end

return UIPayTable


