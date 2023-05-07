SlotsCardThemeEntry = {}

function SlotsCardThemeEntry:new(gameObject, themeKey, index)
	local temp = {}
	setmetatable(temp, self)
	self.__index = self
    temp:Init(gameObject, themeKey, index)
    return temp
end

function SlotsCardThemeEntry:Init(gameObject, themeKey, index)
    self.transform = gameObject.transform
    LuaAutoBindMonoBehaviour.Bind(gameObject, self)
    self.albumKey = SlotsCardsManager.album
    self.themeKey = themeKey --该卡对应的主题ID
    self.index = index
    
    self.button = self.transform:GetComponent(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(self.button)
    self.button.onClick:AddListener(function()
        SlotsCardsHandler:SetThemeHasNew(self.themeKey, false)
        self:refreshUI()
        SlotsCardsAudioHandler:PlaySound("click")
		SlotsCardsBookPop:Show(index)
    end)

    self.ani = self.transform:GetComponent(typeof(Unity.Animator))
    self.textCollect = self.transform:FindDeepChild("CollectText"):GetComponent(typeof(TextMeshProUGUI))
    self.progressImg = self.transform:FindDeepChild("ProgressBar")
    self.completeGo = self.transform:FindDeepChild("CompletedUI").gameObject
    self.effectGo = self.transform:FindDeepChild("lizi").gameObject
    self.new = self.transform:FindDeepChild("new").gameObject
    self.golden = self.transform:FindDeepChild("golden").gameObject
    self:refreshUI()
	return self
end

function SlotsCardThemeEntry:refreshUI()
    local goldenCount = SlotsCardsHandler.data.activityData[self.themeKey].nGoldSpinGameCount
    if goldenCount > 0 then
        self.golden:SetActive(true)
        self.new:SetActive(false)
    else
        self.golden:SetActive(false)
        local bHasNew = SlotsCardsHandler:CheckThemeHasNew(self.themeKey)
        if bHasNew then
            if not self.new.activeSelf then
                self.new:SetActive(true)
            end
        else
            if self.new.activeSelf then
                self.new:SetActive(false)
            end
        end
    end
    
	local progress = SlotsCardsHandler.data.activityData[self.albumKey].dicThemeProgress[self.themeKey]
    local nSumCollectCount = #SlotsCardsConfig[self.albumKey][1].ThemeCards

	self.textCollect.text = progress .."/".. nSumCollectCount
	self.progressImg.sizeDelta = Unity.Vector2(progress / nSumCollectCount * 160, 30)
    if progress >= nSumCollectCount then
        if not self.completeGo.activeSelf then
            self.completeGo:SetActive(true)
        end
    end

end

function SlotsCardThemeEntry:AddBonusStampCardListenerInEntry()
	self.button.onClick:RemoveAllListeners()
	local progress = SlotsCardsHandler.data.activityData[self.albumKey].dicThemeProgress[self.themeKey]
    local nSumCollectCount = #SlotsCardsConfig[self.albumKey][1].ThemeCards

	if progress < nSumCollectCount then
        DelegateCache:addOnClickButton(self.button)
		self.button.onClick:AddListener(function()
			SlotsCardsMainUIPop:randomGetNotOwnCard(self.themeKey)
		end)
		self.button.interactable = true
	else
		self.button.interactable = false
	end

end

function SlotsCardThemeEntry:AddThemeEntryListener()
    self.button.onClick:RemoveAllListeners()
    DelegateCache:addOnClickButton(self.button)
    self.button.onClick:AddListener(function()
        SlotsCardsHandler:SetThemeHasNew(self.themeKey, false)
        self:refreshUI()
		SlotsCardsAudioHandler:PlaySound("click")
		SlotsCardsBookPop:Show(self.index)
	end)

end