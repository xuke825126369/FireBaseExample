FruitItem = {}

function FruitItem:new(gameObject, nIndex)
	local o = {}
	setmetatable(o, self)
	self.__index = self

	o.gameObject = gameObject
	o.nIndex = nIndex

	local icon = gameObject.transform:FindDeepChild("icon"):GetComponent(typeof(UnityUI.Image))
	icon.color = Unity.Color.white
	icon.transform.localScale = Unity.Vector3.one
	o.icon = icon.gameObject

	o.bStates = FindRichieDataHandler.data.mapLevelInfo[nIndex]
	o.button = gameObject:GetComponent(typeof(UnityUI.Button))
	o.button.interactable = true
	o.button.onClick:AddListener(function()
		o:RandomGetGift()
	end)
	o:SetStatus()
	return o
end

function FruitItem:SetStatus()
	self.gameObject:SetActive(not self.bStates)
end

function FruitItem:ShowClickAni(index)
	LeanTween.scale(self.icon, Unity.Vector3.one*0.9, 0.1):setOnComplete(function()
		LeanTween.scale(self.icon, Unity.Vector3.one, 0.1):setOnComplete(function()
			LeanTween.scale(self.icon, Unity.Vector3.one*1.3, 0.5)
			LeanTween.alpha(self.icon.transform, 0, 0.5):setOnComplete(function()
				self:SetStatus()
			end)
		end)
	end)
end

function FruitItem:RandomGetGift()
	self.button.interactable = false
	FindRichieDataHandler:addPickCount(-1)
    local probs = FindRichieMainUIPop.m_randomConfig.probs

    local nRandomIndex = LuaHelper.GetIndexByRate(probs)
	local index = FindRichieMainUIPop.m_randomConfig.steps[nRandomIndex]

	local count = FindRichieMainUIPop:GetPickCount()
	if index == 5 and count < (FindRichieDataHandler.m_mapLevelConfig["Level"..FindRichieDataHandler.data.nLevel]/2) then
		index = math.random(1, 3)
	end

	--这里处理最后一个水果必然结束
	if count == (FindRichieDataHandler.m_mapLevelConfig["Level"..FindRichieDataHandler.data.nLevel] - 1) then
		index = 5
	end
	-- self.nIndex
	self.bStates = true
	FindRichieDataHandler:SetLevelInfo(FindRichieDataHandler.data.nLevel, self.nIndex)
	
	self:ShowClickAni(index)

	if index == 5 then
		--TODO 结束，开启下一关，弹页面
		FindRichieDataHandler:toNextLevel()
		FindRichieMainUIPop:ShowLevelEnd()
	elseif index == 4 then
		--TODO 加一个卡包，做动画
		FindRichieMainUIPop:ShowGetSlotsCards(self.gameObject.transform.position)
	elseif index == 3 then
		--TODO 加一次PickCount，做动画
		FindRichieDataHandler:addPickCount(1)
		FindRichieMainUIPop:ShowGetExtraPick(self.gameObject.transform.position)
	elseif index == 2 then
		--TODO 获得一个钱袋，做动画
		local coinsCount = FindRichieDataHandler:getBasePrize()/10
		PlayerHandler:AddCoin(coinsCount)
		FindRichieMainUIPop:ShowGetCoins(self.gameObject.transform.position)
	elseif index == 1 then
		--TODO 啥也没获得
		if FindRichieDataHandler.data.nPickCount <= 0 then
			FindRichieMainUIPop:ShowGetNothing()
		end
	end
	FindRichieMainUIPop:UpdatePickCount()
	FindRichieUnloadedUI:refreshMoveCount()
end
