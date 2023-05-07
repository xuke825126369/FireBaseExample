local BonusGameUI = {}

BonusGameUI.m_transform = nil -- GameObject
BonusGameUI.m_nSplashType = nil

function BonusGameUI:Init()
    local assetPath = "bonusgame.prefab"
	local goPrefab = AssetBundleHandler:LoadThemeAsset(assetPath, typeof(Unity.GameObject))

	local obj = Unity.Object.Instantiate(goPrefab)
    obj.transform:SetParent(ThemeVideoScene.mPopScreenCanvas, false)
    obj.transform.localScale = Unity.Vector3.one
    obj:SetActive(false)
    self.m_transform = obj.transform
    LuaAutoBindMonoBehaviour.Bind(self.m_transform.gameObject, self)
    self.m_transform.gameObject:SetActive(false)

    self.tableGoItemBtn = {}
    for i = 1, 15 do
        self.tableGoItemBtn[i] = self.m_transform:FindDeepChild("Bottles/bottle"..(i - 1)):GetComponent(typeof(UnityUI.Button))
        self.tableGoItemBtn[i].onClick:AddListener(function()
            self:onClickBtn(i)
        end)
    end

    self.tableGoInfo = {}
    for i = 1, 15 do
        self.tableGoInfo[i] = {}
        local goItem = self.m_transform:FindDeepChild("Bottles/bottle"..(i - 1)).gameObject
        self.tableGoInfo[i].goMini = goItem.transform:FindDeepChild("mini").gameObject
        self.tableGoInfo[i].goMinor = goItem.transform:FindDeepChild("minor").gameObject
        self.tableGoInfo[i].goMajor = goItem.transform:FindDeepChild("major").gameObject
        self.tableGoInfo[i].goGrand = goItem.transform:FindDeepChild("grand").gameObject
        self.tableGoInfo[i].goOpenEffect = goItem.transform:FindDeepChild("bottleOpenEffect").gameObject
        self.tableGoInfo[i].goClickEffect = goItem.transform:FindDeepChild("bottleClickEffect").gameObject
    end

    self.tableGoSelectedInfo = {}
    self.tableGoSelectedInfo[1] = {}
    self.tableGoSelectedInfo[2] = {}
    self.tableGoSelectedInfo[3] = {}
    self.tableGoSelectedInfo[4] = {}

    for i = 1, 3 do
        self.tableGoSelectedInfo[1][i] = self.m_transform:FindDeepChild("ShowSelectResultArea/MiniResult/Select"..(i - 1).."/show"..(i - 1)).gameObject
        self.tableGoSelectedInfo[2][i] = self.m_transform:FindDeepChild("ShowSelectResultArea/MinorResult/Select"..(i - 1).."/show"..(i - 1)).gameObject
        self.tableGoSelectedInfo[3][i] = self.m_transform:FindDeepChild("ShowSelectResultArea/MajorResult/Select"..(i - 1).."/show"..(i - 1)).gameObject
        self.tableGoSelectedInfo[4][i] = self.m_transform:FindDeepChild("ShowSelectResultArea/GrandResult/Select"..(i - 1).."/show"..(i - 1)).gameObject
    end

    self.tableGoSelectedAward = {}
    self.tableGoSelectedAward[1] = self.m_transform:FindDeepChild("ShowSelectResultArea/MiniResult/KaiJiangTX").gameObject
    self.tableGoSelectedAward[2] = self.m_transform:FindDeepChild("ShowSelectResultArea/MinorResult/KaiJiangTX").gameObject
    self.tableGoSelectedAward[3] = self.m_transform:FindDeepChild("ShowSelectResultArea/MajorResult/KaiJiangTX").gameObject
    self.tableGoSelectedAward[4] = self.m_transform:FindDeepChild("ShowSelectResultArea/GrandResult/KaiJiangTX").gameObject

    self.tableClickedIndex = {}
end

function BonusGameUI:Show(bRecover)
    self.m_transform.gameObject:SetActive(true)

    for i = 1, 15 do
        self.tableGoItemBtn[i].interactable = true
        for k1, v1 in pairs(self.tableGoInfo[i]) do
            v1:SetActive(false)
        end
    end

    for i = 1, #self.tableClickedIndex do
        local nIndex = self.tableClickedIndex[i]
        self.tableGoItemBtn[nIndex].interactable = false
        self.tableGoInfo[nIndex].goClickEffect:SetActive(true)

        local nJackPotIndex = OceanFunc.tableBonusSelectIndex[i]
        if nJackPotIndex == 1 then
            self.tableGoInfo[nIndex].goMini:SetActive(true)
        elseif nJackPotIndex == 2 then
            self.tableGoInfo[nIndex].goMinor:SetActive(true)
        elseif nJackPotIndex == 3 then
            self.tableGoInfo[nIndex].goMajor:SetActive(true)
        elseif nJackPotIndex == 4 then
            self.tableGoInfo[nIndex].goGrand:SetActive(true)
        end
    end

    for i = 1, 4 do
        self.tableGoSelectedAward[i]:SetActive(false)

        local nJackPotCount = self:GetJackPotClickCount(i)
        for j = 1, 3 do
            self.tableGoSelectedInfo[i][j]:SetActive(j <= nJackPotCount)
        end
    end

    AudioHandler:LoadAndPlayThemeMusic("music_bonus")
    
    if GameConfig.PLATFORM_EDITOR then
        if SceneSlotGame:orAutoHideSplashUI() then
            local tableClickIndex = {}
            for i = 1, 15 do
                table.insert(tableClickIndex, i)
            end

            while #self.tableClickedIndex < #OceanFunc.tableBonusSelectIndex do
                local nIndex = table.remove(tableClickIndex, math.random(1, #tableClickIndex))
                self:onClickBtn(nIndex)
            end
        end
    end

end

function BonusGameUI:GetJackPotClickCount(nJackPotIndex)
    local nCount = 0

    for i = 1, #self.tableClickedIndex do
        local nIndex = OceanFunc.tableBonusSelectIndex[i]
        if nIndex == nJackPotIndex then
            nCount = nCount + 1
        end
    end

    return nCount
end

function BonusGameUI:onClickBtn(nIndex)
    self.tableGoItemBtn[nIndex].interactable = false
    self.tableGoInfo[nIndex].goClickEffect:SetActive(true)
    table.insert(self.tableClickedIndex, nIndex)

    AudioHandler:PlayThemeSound("bonusGame_pickItem")

    local nJackPotIndex = OceanFunc.tableBonusSelectIndex[#self.tableClickedIndex]
    if nJackPotIndex == 1 then
        self.tableGoInfo[nIndex].goMini:SetActive(true)
    elseif nJackPotIndex == 2 then
        self.tableGoInfo[nIndex].goMinor:SetActive(true)
    elseif nJackPotIndex == 3 then
        self.tableGoInfo[nIndex].goMajor:SetActive(true)
    elseif nJackPotIndex == 4 then
        self.tableGoInfo[nIndex].goGrand:SetActive(true)
    else
        Debug.Assert(false, nJackPotIndex)
    end

    local nJackPotCount = self:GetJackPotClickCount(nJackPotIndex)
    for j = 1, 3 do
        self.tableGoSelectedInfo[nJackPotIndex][j]:SetActive(j <= nJackPotCount)
    end

    if #self.tableClickedIndex == #OceanFunc.tableBonusSelectIndex then
        self.tableGoSelectedAward[nJackPotIndex]:SetActive(true)

        local fAddMoneyCount = OceanFunc.tableNowJackPotMoneyCount[nJackPotIndex]
        OceanLevelUI:CollectMoneyToDB(fAddMoneyCount)
        OceanFunc.tableNowbGetJackPot[nJackPotIndex] = true
        OceanLevelUI.mJackPotUI:ResetCurrentJackPot(nJackPotIndex)
        OceanFunc.bInBonusGame = false

        for i = 1, 15 do
            self.tableGoItemBtn[i].interactable = false
        end

        LeanTween.delayedCall(3.0, function()
            self:Hide()
            OceanLevelUI.mBonusGameFinishUI:Show(nJackPotIndex)
        end)
    end

    OceanLevelUI:setDBBonsuGame()
end

function BonusGameUI:Hide()
    self.m_transform.gameObject:SetActive(false)
end

return BonusGameUI