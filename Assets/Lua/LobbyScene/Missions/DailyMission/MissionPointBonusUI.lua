MissionPointBonusUI = {}

function MissionPointBonusUI:isActiveShow()
    if not LuaHelper.OrGameObjectExist(self.transform) then
        return false
    end

    if not self.transform.gameObject.activeInHierarchy then
        return false
    end

    return true
end

-- nMissionPointType 1： 500点的奖励 2：1000点的奖励 
function MissionPointBonusUI:Show(parent, nMissionPointType)
    if not LuaHelper.OrGameObjectExist(self.transform) then
        local strPath = "Missions/DailyTask/MissionPointBonusUI.prefab"
        local prefabObj = AssetBundleHandler:LoadMissionAsset(strPath)
        local go = Unity.Object.Instantiate(prefabObj)
        self.transform = go.transform
        LuaAutoBindMonoBehaviour.Bind(go, self)
        self.transform:SetParent(parent, false)
        self.transform.localPosition = Unity.Vector3.zero

        local tr = self.transform:FindDeepChild("MissionPointBonusUIAni")
        self.m_animator = tr:GetComponent(typeof(Unity.Animator))

        local tr = self.transform:FindDeepChild("BtnCollect")
        self.m_goCollectNode = tr.gameObject
        local btnCollect = tr:GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(btnCollect)
        btnCollect.onClick:AddListener(function()
            GlobalAudioHandler:PlayBtnSound()
            self:OnCollect()
        end)

        self.m_btnCollect = btnCollect
        self:initBonusNode()
    end

    self.m_nMissionPointType = nMissionPointType
    self.transform.gameObject:SetActive(true)
    GlobalAudioHandler:PlaySound("popup")

    for i = 1, 3 do
        local nodeData = self.m_BonusNodes[i]
        nodeData.BtnBonus.interactable = true
    end

end

function MissionPointBonusUI:initBonusNode()
    local bonusNodePrefab = AssetBundleHandler:LoadMissionAsset("Missions/DailyTask/MissionPointBonusUIGiftNode.prefab")
    self.m_BonusNodes = {}
    for i = 1, 3 do
        local strNodeName = "BonusNode" .. i
        local trParent = self.transform:FindDeepChild(strNodeName)
        local posBonusNode = trParent.localPosition

        local bonusNode = Unity.Object.Instantiate(bonusNodePrefab)
        local tr = bonusNode:GetComponent(typeof(Unity.RectTransform))
        tr:SetParent(trParent, false)
        tr.anchoredPosition = Unity.Vector2.zero

        local BtnBonus = tr:FindDeepChild("BtnBonus"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(BtnBonus)
        BtnBonus.onClick:AddListener(function()
            GlobalAudioHandler:PlaySound("taskPointBonus_reward")
            self:OnCollectBonus(i)
        end)

        local TextCoins = tr:FindDeepChild("TextCoins"):GetComponent(typeof(UnityUI.Text))
        local TextDollarWorthofCoins = tr:FindDeepChild("TextDollarWorthofCoins"):GetComponent(typeof(UnityUI.Text))
        -- $9.99 Worth of coins

        local ani = tr:GetComponentInChildren(typeof(Unity.Animator))
        local data = {bonusNode = bonusNode, BtnBonus = BtnBonus,
                     TextCoins = TextCoins, TextDollarWorthofCoins = TextDollarWorthofCoins,
                     animator = ani}

        table.insert( self.m_BonusNodes, data )
    end

end

function MissionPointBonusUI:initBonusParam()
    local coinSkus = {AllBuyCFG[1].productId, AllBuyCFG[2].productId, AllBuyCFG[3].productId}
    if self.m_nMissionPointType == 2 then
        coinSkus = {AllBuyCFG[4].productId, AllBuyCFG[5].productId, AllBuyCFG[6].productId}
    end

    local index = math.random(1, #coinSkus)
    local strSku = coinSkus[index]
    self.m_selSku = strSku -- 玩家点到的

    table.remove(coinSkus, index)
    self.m_randomCoinSkus = LuaHelper.GetRandomTable(coinSkus) -- 剩下两个
end

function MissionPointBonusUI:OnCollectBonus(index) -- index 点击的是第几个礼盒
    self:initBonusParam()

    local nRandomIndex = 1 -- 金币的
    local nRandomBonusTypeIndex = 1 -- bonustype 的
    for i = 1, 3 do
        local nodeData = self.m_BonusNodes[i]
        nodeData.BtnBonus.interactable = false

        local skuInfo = nil
        if i == index then
            nodeData.animator:Play("MissionPointBonusUIGiftNodeAni", -1, 0)
            skuInfo = GameHelper:GetSimpleSkuInfoById(self.m_selSku)
        else
            skuInfo = GameHelper:GetSimpleSkuInfoById(self.m_randomCoinSkus[nRandomIndex])
            nRandomIndex = nRandomIndex + 1
            LeanTween.delayedCall(0.75, function()
                nodeData.animator:Play("MissionPointBonusUIGiftNodeAni", -1, 0)
            end)
        end

        local imageTable = LuaHelper.GetComponentsInChildren(nodeData.bonusNode, typeof(UnityUI.Image))
        for k, v in pairs(imageTable) do
            if i == index then
                v.color = Unity.Color.white
            else
                v.color = Unity.Color.gray
            end
        end

        local textTable = LuaHelper.GetComponentsInChildren(nodeData.bonusNode, typeof(UnityUI.Text))
        for k, v in pairs(textTable) do
            if i == index then
                v.color = Unity.Color.white
            else
                v.color = Unity.Color.gray
            end
        end

        local coins = skuInfo.baseCoins
        nodeData.TextCoins.text = MoneyFormatHelper.coinCountOmit(coins)

        local nDollar = skuInfo.nDollar
        local strPrice = "$" .. nDollar
        strPrice = strPrice .. " worth of coins"
        nodeData.TextDollarWorthofCoins.text = strPrice

        if i == index then
            self.m_nBonusCoins = coins
            PlayerHandler:AddCoin(self.m_nBonusCoins)

            LeanTween.delayedCall(1.5, function()
                local coinPos = nodeData.TextCoins.transform.position
                CoinFly:fly(coinPos, GlobalTempData.goUITopCollectMoneyEndPos.transform.position, 6, true)
            end)

            -- 到这里就给玩家发完奖励了 
            DailyMissionHandler.data.m_missionPointBonusFlag[self.m_nMissionPointType] = true
            DailyMissionHandler:SaveDb()
        else
            nRandomBonusTypeIndex = nRandomBonusTypeIndex + 1
        end
    end

    local data = DailyMissionHandler.data
    DailyMissionUI:initMissionPointBtnStatus()
    self.m_btnCollect.interactable = true
    LeanTween.delayedCall(1.25, function()
        self.m_animator:Play("MissionPointBonusUIAniguocheng", -1, 0)
    end)

end

function MissionPointBonusUI:OnCollect()
    self.m_btnCollect.interactable = false
    self:Hide()
end

function MissionPointBonusUI:Hide()
    self.m_animator:Play("MissionPointBonusUIAnituichu", -1, 0)
    LeanTween.delayedCall(1.0, function()
        Unity.GameObject.Destroy(self.transform.gameObject)
    end)
end