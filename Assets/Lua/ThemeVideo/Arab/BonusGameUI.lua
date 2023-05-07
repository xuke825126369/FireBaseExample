local BonusGameUI = {}

function BonusGameUI:Init()
    local assetPath = "qBonusgame.prefab"
	local goPrefab = AssetBundleHandler:LoadThemeAsset(assetPath, typeof(Unity.GameObject))
    local obj = Unity.Object.Instantiate(goPrefab)

    obj.transform:SetParent(ThemeVideoScene.mPopScreenCanvas, false)
    obj.transform.localScale = Unity.Vector3.one
    obj:SetActive(false)
    self.m_transform = obj.transform
    LuaAutoBindMonoBehaviour.Bind(self.m_transform.gameObject, self)
    self.m_transform.gameObject:SetActive(false)

    self.tableGoGem = {}
    self.tableGoGemBtn = {}
    for i = 1, 16 do
        self.tableGoGem[i] = self.m_transform:FindDeepChild("GemSels/Gem"..(i - 1)).gameObject
        self.tableGoGemBtn[i] = self.m_transform:FindDeepChild("GemSels/Gem"..(i - 1).."/btnGem"..(i - 1)):GetComponent(typeof(UnityUI.Button))
        self.tableGoGemBtn[i].onClick:AddListener(function()
            self:OnClickGemBtn(i)
        end)
    end

    self.goGrandGem1 = self.m_transform:FindDeepChild("GrandResult/show0").gameObject
    self.goGrandGem2 = self.m_transform:FindDeepChild("GrandResult/show1").gameObject
    self.goGrandGem3 = self.m_transform:FindDeepChild("GrandResult/show2").gameObject
    self.textGrandMoneyCount = self.m_transform:FindDeepChild("GrandResult/textMoneyCount"):GetComponent(typeof(TextMeshProUGUI))
    self.goGrandEffectAni = self.m_transform:FindDeepChild("GrandResult/GrandEffectAni").gameObject

    self.goMajorGem1 = self.m_transform:FindDeepChild("MajorResult/show0").gameObject
    self.goMajorGem2 = self.m_transform:FindDeepChild("MajorResult/show1").gameObject
    self.goMajorGem3 = self.m_transform:FindDeepChild("MajorResult/show2").gameObject
    self.textMajorMoneyCount = self.m_transform:FindDeepChild("MajorResult/textMoneyCount"):GetComponent(typeof(TextMeshProUGUI))
    self.goMajorEffectAni = self.m_transform:FindDeepChild("MajorResult/MajorEffectAni").gameObject

    self.goMinorGem1 = self.m_transform:FindDeepChild("MinorResult/show0").gameObject
    self.goMinorGem2 = self.m_transform:FindDeepChild("MinorResult/show1").gameObject
    self.goMinorGem3 = self.m_transform:FindDeepChild("MinorResult/show2").gameObject
    self.textMinorMoneyCount = self.m_transform:FindDeepChild("MinorResult/textMoneyCount"):GetComponent(typeof(TextMeshProUGUI))
    self.goMinorEffectAni = self.m_transform:FindDeepChild("MinorResult/MinorEffectAni").gameObject

end

function BonusGameUI:Update()
    if self.m_SlotsNumberWinCoins ~= nil then
        self.m_SlotsNumberWinCoins:Update()
    end
end

function BonusGameUI:Show()
    self.m_transform.gameObject:SetActive(true)
    self.tableCollectGemType = {}
    self.bGameFinish = false

    AudioHandler:LoadAndPlayThemeMusic("music_bonus")

    self:ShowResultGemCount(1, 0)
    self:ShowResultGemCount(2, 0)
    self:ShowResultGemCount(3, 0)
    self.goGrandEffectAni:SetActive(false)
    self.goMajorEffectAni:SetActive(false)
    self.goMinorEffectAni:SetActive(false)

    self.textMinorMoneyCount.text = MoneyFormatHelper.numWithCommas(ArabFunc.tableNowJackPotMoneyCount[1])
    self.textMajorMoneyCount.text = MoneyFormatHelper.numWithCommas(ArabFunc.tableNowJackPotMoneyCount[2])
    self.textGrandMoneyCount.text = MoneyFormatHelper.numWithCommas(ArabFunc.tableNowJackPotMoneyCount[3])

    for i = 1, 16 do
        local goGem = self.tableGoGem[i]
        local goGrandClickEffect = ArabLevelUI:FindSymbolElement(goGem, "GrandClickEffect")
        local goMajorClickEffect = ArabLevelUI:FindSymbolElement(goGem, "MajorClickEffect")
        local goMinorClickEffect = ArabLevelUI:FindSymbolElement(goGem, "MinorClickEffect")
        goGrandClickEffect:SetActive(false)
        goMajorClickEffect:SetActive(false)
        goMinorClickEffect:SetActive(false)

        self.tableGoGemBtn[i].gameObject:SetActive(true)
    end

    if SlotsGameLua.m_bAutoSpinFlag then

    end

end

function BonusGameUI:Hide()
    self.m_transform.gameObject:SetActive(false)
end

function BonusGameUI:OnClickGemBtn(nIndex)
    AudioHandler:PlayThemeSound("bonusGame_pickItem")
    self.tableGoGemBtn[nIndex].gameObject:SetActive(false)
    
    local goGem = self.tableGoGem[nIndex]
    local goGrandClickEffect = ArabLevelUI:FindSymbolElement(goGem, "GrandClickEffect")
    local goMajorClickEffect = ArabLevelUI:FindSymbolElement(goGem, "MajorClickEffect")
    local goMinorClickEffect = ArabLevelUI:FindSymbolElement(goGem, "MinorClickEffect")
    goGrandClickEffect:SetActive(false)
    goMajorClickEffect:SetActive(false)
    goMinorClickEffect:SetActive(false)

    local nGemType = ArabConfig:GetBonusGameTriggerGemType()
    if nGemType == 1 then
        goMinorClickEffect:SetActive(true)
    elseif nGemType == 2 then
        goMajorClickEffect:SetActive(true)
    elseif nGemType == 3 then
        goGrandClickEffect:SetActive(true)
    else
        Debug.Assert(false)
    end 

    if not self.bGameFinish then
        if not self.tableCollectGemType[nGemType] then
            self.tableCollectGemType[nGemType] = 0
        end
        self.tableCollectGemType[nGemType] = self.tableCollectGemType[nGemType] + 1
        self:ShowResultGemCount(nGemType, self.tableCollectGemType[nGemType])

        if self.tableCollectGemType[nGemType] >= 3 then
            AudioHandler:PlayThemeSound("bonusGame_end")

            local fAddMoneyCount = ArabFunc.tableNowJackPotMoneyCount[nGemType]
            ArabLevelUI:CollectMoneyToDB(fAddMoneyCount)
            ArabLevelUI.mJackPotUI:ResetCurrentJackPot(nGemType)
            ArabFunc.tableNowbGetJackPot[nGemType] = true
            ArabFunc.nCollectGemCount = 0
            ArabLevelUI:setDBCollectGemCount()
            ArabLevelUI:ResetGemProgressAni()
            
            self:ShowFinalResultAni(nGemType)
            self.bGameFinish = true
            LeanTween.delayedCall(2.0, function()
                for i = 1, 16 do
                    local goGemBtn = self.tableGoGemBtn[i].gameObject
                    if goGemBtn.activeInHierarchy then
                        LeanTween.delayedCall(math.random(), function()
                            self:OnClickGemBtn(i)
                        end)
                    end
                end
            end)
        end 
    end

end

function BonusGameUI:ShowResultGemCount(nGemType, nCount)
    if nGemType == 1 then
        self.goMinorGem1:SetActive(false)
        self.goMinorGem2:SetActive(false)
        self.goMinorGem3:SetActive(false)
        
        if nCount == 1 then
            self.goMinorGem1:SetActive(true)
        elseif nCount == 2 then
            self.goMinorGem1:SetActive(true)
            self.goMinorGem2:SetActive(true)
        elseif nCount == 3 then
            self.goMinorGem1:SetActive(true)
            self.goMinorGem2:SetActive(true)
            self.goMinorGem3:SetActive(true)
        end

    elseif nGemType == 2 then
        self.goMajorGem1:SetActive(false)
        self.goMajorGem2:SetActive(false)
        self.goMajorGem3:SetActive(false)

        if nCount == 1 then
            self.goMajorGem1:SetActive(true)
        elseif nCount == 2 then
            self.goMajorGem1:SetActive(true)
            self.goMajorGem2:SetActive(true)
        elseif nCount == 3 then
            self.goMajorGem1:SetActive(true)
            self.goMajorGem2:SetActive(true)
            self.goMajorGem3:SetActive(true)
        end

    elseif nGemType == 3 then
        self.goGrandGem1:SetActive(false)
        self.goGrandGem2:SetActive(false)
        self.goGrandGem3:SetActive(false)

        if nCount == 1 then
            self.goGrandGem1:SetActive(true)
        elseif nCount == 2 then
            self.goGrandGem1:SetActive(true)
            self.goGrandGem2:SetActive(true)
        elseif nCount == 3 then
            self.goGrandGem1:SetActive(true)
            self.goGrandGem2:SetActive(true)
            self.goGrandGem3:SetActive(true)
        end
    end

end

function BonusGameUI:ShowFinalResultAni(nGemType)
    self.goGrandEffectAni:SetActive(false)
    self.goMajorEffectAni:SetActive(false)
    self.goMinorEffectAni:SetActive(false)

    if nGemType == 1 then
        self.goMinorEffectAni:SetActive(true)
    elseif nGemType == 2 then
        self.goMajorEffectAni:SetActive(true)
    elseif nGemType == 3 then
        self.goGrandEffectAni:SetActive(true)
    end 

    LeanTween.delayedCall(5.0, function()
        self:Hide()
        ArabLevelUI.mBonusGameFinishSplashUI:Show(nGemType)
    end)

end 


return BonusGameUI
