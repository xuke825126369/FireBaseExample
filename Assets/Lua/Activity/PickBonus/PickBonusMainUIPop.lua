require("Lua.Activity.PickBonus.PickBonusJackpotBonusAwardUIPop")
require("Lua.Activity.PickBonus.PickBonusJackpotEndUIPop")

PickBonusMainUIPop = {}
PickBonusMainUIPop.m_LeanTweenIDs = {}
PickBonusMainUIPop.m_mapItems = {}

PickBonusMainUIPop.m_nCurrentJackPot = nil -- JackPot索引值
PickBonusMainUIPop.jackpotType = {
    Mini = 1,
    Minor = 2,
    Major = 3,
    Maxi = 4,
    Grand = 5
}

PickBonusMainUIPop.m_mapRatio = {2, 10, 20, 50, 100} --分别对应mini等 1美金的倍数

function PickBonusMainUIPop:Show()
    StartCoroutine(function()
        WindowLoadingView:Show()
        PickBonusBundleHandler:InitBundleInfo()
        PickBonusBundleHandler:StartDownloadAndLoadBundle()
        while not PickBonusBundleHandler:orExistBundle() do
            yield_return(0)
        end
        WindowLoadingView:Hide()
        self:Show1()
    end)
end

function PickBonusMainUIPop:Show1()
    if not LuaHelper.OrGameObjectExist(self.transform) then
        local bundleName = "Activity_PickBonus"
        local goPrefab = AssetBundleHandler:LoadAsset(bundleName, "PickBonusMainUIPop.prefab")
        local goPanel = Unity.Object.Instantiate(goPrefab)
        self.transform = goPanel.transform
        self.transform:SetParent(LobbyScene.popCanvas, false)
        self.transform.localScale = Unity.Vector3.one
        self.transform.localPosition = Unity.Vector3.zero
        LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
        self.transform.gameObject:SetActive(false)

        self.m_trItemContainer = self.transform:FindDeepChild("ItemContainer")
        self.m_goSuperLogo = self.transform:FindDeepChild("SuperLogo").gameObject
        self.m_goLogo = self.transform:FindDeepChild("Logo").gameObject

        self.m_textPickCount = self.transform:FindDeepChild("PickCountText"):GetComponent(typeof(UnityUI.Text))
        self.m_mapTextJackPotCoins = {}
        for i = 1, 5 do
            self.m_mapTextJackPotCoins[i] = self.transform:FindDeepChild("JackpotNode/"..i.."/TextJinBi"):GetComponent(typeof(UnityUI.Text))
        end

        self.m_mapAni = {}
        for i = 1, 5 do
            self.m_mapAni[i] = self.transform:FindDeepChild("JackpotNode/"..i):GetComponent(typeof(Unity.Animator))
        end
        self:InitItem()
    end

    self.m_currentRandomRate = {500, 200, 50, 10, 2}
    self.m_goSuperLogo:SetActive(FlashChallengeRewardDataHandler.data.nPickBonusReduceCount > 0)
    self.m_goLogo:SetActive(FlashChallengeRewardDataHandler.data.nPickBonusReduceCount <= 0)
    if FlashChallengeRewardDataHandler.data.nPickBonusReduceCount > 0 then
        for i = 1, FlashChallengeRewardDataHandler.data.nPickBonusReduceCount do
            self.m_currentRandomRate[i] = 0
        end
    end
    self.m_nCurrentJackPot = 0

    self.transform.gameObject:SetActive(true)
    self:UpdatePickCount()

    for i = 1,LuaHelper.tableSize(self.m_mapTextJackPotCoins) do
        self.m_mapTextJackPotCoins[i].text = MoneyFormatHelper.numWithCommas(self:getBasePrize() * self.m_mapRatio[i])
    end

    for i = 1, LuaHelper.tableSize(self.m_mapAni) do
        self.m_mapAni[i]:SetInteger("nPlayMode", self.m_currentRandomRate[i] == 0 and 1 or 0)
    end

    PickBonusAudioHandler:PlayBackMusic("music")
end

function PickBonusMainUIPop:InitItem()
    self.m_mapItems = nil
    self.m_mapItems = {}
    local prefabObj = AssetBundleHandler:LoadAsset("Activity_PickBonus", "JackPotItem.prefab")
    local posX = -263
    local posY = 249

    local nRow = 1
    local nRowCount = 6
    for i = 1, 33 do
        local item = Unity.Object.Instantiate(prefabObj).transform
        item:SetParent(self.m_trItemContainer, false)
        item.anchoredPosition3D = Unity.Vector3(posX, posY, 0)
        self.m_mapItems[i] = {}
        self.m_mapItems[i].item = item
        self.m_mapItems[i].bGet = false
        local btn = item:GetComponent(typeof(UnityUI.Button))
        btn.onClick:AddListener(function()
            self:onItemClick(i, btn)
        end)
        if i >= nRowCount then
            nRow = nRow + 1
            local nAdd = nRow % 2 == 0 and 5 or 6
            nRowCount = nRowCount + nAdd
            posX = nRow % 2 == 0 and -181 or -263
            posY = posY - 129 
        else
            posX = posX + 165
        end
    end

    local nCount = 0
    if FlashChallengeRewardDataHandler.data.nPickBonusReduceCount > 0 and FlashChallengeRewardDataHandler.data.nPickBonusReduceCount < 2 then
        nCount = 5
    elseif FlashChallengeRewardDataHandler.data.nPickBonusReduceCount > 0 and FlashChallengeRewardDataHandler.data.nPickBonusReduceCount < 4 then
        nCount = 15
    end

    if nCount > 0 then
        local mapNeedGet = {}
        for i = 1, 33 do
            table.insert( mapNeedGet, i )
        end
        for i = 1, nCount do
            local nLength = LuaHelper.tableSize(mapNeedGet)
            local index = math.random(1, nLength)
            local result = mapNeedGet[index]
            table.remove( mapNeedGet, index )
            self.m_mapItems[result].bGet = true
            self.m_mapItems[result].item:GetComponent(typeof(UnityUI.Button)).interactable = false
            local ani = self.m_mapItems[result].item:GetComponent(typeof(Unity.Animator))
            ani:SetInteger("nPlayMode", 2)
        end
    end
end

function PickBonusMainUIPop:onItemClick(nIndex, lastBtn)
    lastBtn.interactable = false
    local item = self.m_mapItems[nIndex].item

    PickBonusAudioHandler:PlaySound("pick")

    local ani = item:GetComponent(typeof(Unity.Animator))
    ani:SetInteger("nPlayMode", 1)

    self.m_mapItems[nIndex].bGet = true
    -- TODO 刷新UI
    local nJackPotIndex = LuaHelper.GetIndexByRate(self.m_currentRandomRate)
    local jackpotContainer = item:FindDeepChild("JackPotContainer")
    jackpotContainer.gameObject:SetActive(true)
    local jinBin = item:FindDeepChild("JinBi").gameObject
    jinBin:SetActive(true)
    for i = 0, jackpotContainer.childCount - 1 do
        jackpotContainer:GetChild(i).gameObject:SetActive((nJackPotIndex - 1) == i)
    end
    
    self.m_nCurrentJackPot = nJackPotIndex
    local count = FlashChallengeRewardDataHandler.data.nPickBonusCount - 1
    FlashChallengeRewardDataHandler:setPickBonusCount(count, FlashChallengeRewardDataHandler.data.nPickBonusReduceCount)

    if FlashChallengeRewardDataHandler.data.nPickBonusCount <= 0 then
        for i = 1, LuaHelper.tableSize(self.m_mapItems) do
            local btn = self.m_mapItems[i].item:GetComponent(typeof(UnityUI.Button))
            btn.interactable = false
        end
        local winCoins = self:getBasePrize() * self.m_mapRatio[self.m_nCurrentJackPot]
        PlayerHandler:AddCoin(winCoins)
        LeanTween.delayedCall(2, function()
            PickBonusJackpotEndUIPop:Show(self.m_nCurrentJackPot, winCoins)
        end)
    else
        for i = 1, LuaHelper.tableSize(self.m_mapItems) do
            local btn = self.m_mapItems[i].item:GetComponent(typeof(UnityUI.Button))
            btn.interactable = false
        end
        LeanTween.delayedCall(2, function()
            PickBonusJackpotBonusAwardUIPop:Show()
            for i = 1, LuaHelper.tableSize(self.m_mapItems) do
                local btn = self.m_mapItems[i].item:GetComponent(typeof(UnityUI.Button))
                btn.interactable = not self.m_mapItems[i].bGet
            end 
        end)
    end
    self:UpdatePickCount()
end

function PickBonusMainUIPop:UpdatePickCount()
    local count = FlashChallengeRewardDataHandler.data.nPickBonusCount
    self.m_textPickCount.text = count
end

function PickBonusMainUIPop:CancelLeanTween()
	local count = #self.m_LeanTweenIDs
	for i=1, count do
		local id = self.m_LeanTweenIDs[i]
		if LeanTween.isTweening(id) then
			LeanTween.cancel(id)
		end
	end
	self.m_LeanTweenIDs = {}
end

function PickBonusMainUIPop:Hide()
    PickBonusAudioHandler:StopBackMusic()
    self:CancelLeanTween()
    if self.transform ~= nil then
        Unity.Object.Destroy(self.transform.gameObject)
    end
    if PickBonusJackpotBonusAwardUIPop.transform ~= nil then
        Unity.Object.Destroy(PickBonusJackpotBonusAwardUIPop.transform.gameObject)
    end
    if PickBonusJackpotEndUIPop.transform ~= nil then
        Unity.Object.Destroy(PickBonusJackpotEndUIPop.transform.gameObject)
    end
    PickBonusBundleHandler:UnBundle()
end

--以1美金为奖励
function PickBonusMainUIPop:getBasePrize()
    -- 取商店1美元的coins为参考依据
    local strSKuKey = AllBuyCFG[1].productId
    local skuInfo = GameHelper:GetSimpleSkuInfoById(strSKuKey)
    local nCoins = skuInfo.baseCoins -- 不乘打折系数的。。

    return nCoins
end