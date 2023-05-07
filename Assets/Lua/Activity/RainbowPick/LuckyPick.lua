--LuckyPick界面
local LuckyPick = {}

function LuckyPick:Init()
    local prefabObj = AssetBundleHandler:LoadActivityAsset("LuckyPick")
    self.transform.gameObject = Unity.Object.Instantiate(prefabObj)
    self.transform.gameObject:SetActive(false)
    self.transform = self.transform.gameObject.transform
    self.transform:SetParent(LobbyScene.popCanvas, false)
    self.popController = PopController:new(self.transform.gameObject, nil, PopTweenType.alpha)

    self.tableGoBag = LuaHelper.GetTableFindChild(self.transform, 3, "Bag")
    self.tableTextMultiplier = {}
    for i = 1, 3 do
        self.tableTextMultiplier[i] = self.tableGoBag[i].transform:FindDeepChild("btn/textMultiplier"):GetComponent(typeof(UnityUI.Text))
        local btn = self.tableGoBag[i].transform:GetComponentInChildren(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(btn)
        btn.onClick:AddListener(function()
            if self.bCanHide then
                self.bCanHide = false
                self:onClickItem(i)
            end
        end)
    end
    self.textMaxMultiplier = self.transform:FindDeepChild("textMaxMultiplier"):GetComponent(typeof(UnityUI.Text))
    self.textBasePrize = self.transform:FindDeepChild("textBasePrize"):GetComponent(typeof(UnityUI.Text))
end

function LuckyPick:show(nChestType)
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
    self.popController:show(nil, function()
        ActivityAudioHandler:PlaySound("rainbow_reward_pop")
        GlobalAudioHandler:LowerActiveBackgroundMusicVolume()
    end, true)
    local nMaxMultiplier = RainbowPickConfig.tableLuckyPickMultiplier[nChestType][3]
    self.textMaxMultiplier.text = tostring(nMaxMultiplier)
    self.textBasePrize.text = MoneyFormatHelper.numWithCommas(self:getBasePrize())

    self.nChestType = nChestType
end

function LuckyPick:hide()
    ActivityAudioHandler:PlaySound("rainbow_closeWindow")
    self.popController:hide(false, function()
        RainbowPickMainUIPop.bCanClick = true
    end)
end

function LuckyPick:onClickItem(nIndex)
    ActivityAudioHandler:PlaySound("rainbow_pack_pick")
    local nMultiplierIndex = LuaHelper.GetIndexByRate(RainbowPickConfig.tableLuckyPickMultiplierRate[self.nChestType])
    local tableMultiplier = LuaHelper.DeepCloneTable(RainbowPickConfig.tableLuckyPickMultiplier[self.nChestType])
    local nMultiplier = tableMultiplier[nMultiplierIndex]
    table.remove(tableMultiplier, nMultiplierIndex)
    tableMultiplier = LuaHelper.GetRandomTable(tableMultiplier)
    table.insert(tableMultiplier, nIndex, nMultiplier)
    
    local nBasePrize = self:getBasePrize()
    local nCoinWin = nBasePrize * nMultiplier
    PlayerHandler:AddCoin(nCoinWin)
    local nPlayerCoin = PlayerHandler.nGoldCount

    for i = 1, 3 do
        self.tableTextMultiplier[i].text = tostring("x"..tableMultiplier[i])
    end

    ActivityHelper:PlayAni(self.tableGoBag[nIndex], "Open")

    LeanTween.delayedCall(2, function()
        for i = 1, 3 do
            if i ~= nIndex then
                ActivityHelper:PlayAni(self.tableGoBag[i], "Gray")
            end
        end 
    end)

    RainbowPickMainUIPop.LuckyPickEndSplashUI:show(nCoinWin, nBasePrize, nMultiplier, nPlayerCoin)

    LeanTween.delayedCall(4, function()
        self:hide()
    end)
end

function LuckyPick:getBasePrize()
    local ratio = 1
    if RainbowPickDataHandler:checkInBoosterTime(RainbowPickBooster.Coin) then
        ratio = 2
    end

    return ActivityHelper:getBasePrize() * RainbowPickConfig.fLuckyPickBasePrizeRatio * ratio
end

return LuckyPick