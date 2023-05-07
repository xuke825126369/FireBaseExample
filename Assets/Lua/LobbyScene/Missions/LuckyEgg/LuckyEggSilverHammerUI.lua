local LuckyEggSilverHammerUI = {}

function LuckyEggSilverHammerUI:Show()
    if not LuaHelper.OrGameObjectExist(self.transform) then
        local goPrefab = AssetBundleHandler:LoadMissionAsset("Missions/LuckyEgg/SilverHammer.prefab")
        local goPanel = Unity.Object.Instantiate(goPrefab)
        self.transform = goPanel.transform
        self.transform:SetParent(MissionMainUIPop.m_trPopNode, false)
        self.transform.localScale = Unity.Vector3.one
        self.transform.localPosition = Unity.Vector3.zero
        LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
        self.transform.gameObject:SetActive(false)

        self.m_ani = self.transform:GetComponentInChildren(typeof(Unity.Animator))
        self.m_trContent = self.transform:FindDeepChild("Content")

        self.m_remainHammerCount = self.transform:FindDeepChild("RemainHammerReward"):GetComponent(typeof(TextMeshProUGUI))
        self.m_btnCollect = self.transform:FindDeepChild("BtnGotIt"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(self.m_btnCollect)
        self.m_btnCollect.onClick:AddListener(function()
            self:onCollectClicked()
        end)

        self.goSlotsCardsReward = self.transform:FindDeepChild("SlotsCardsReward").gameObject
        self.goRoyalStars = self.transform:FindDeepChild("RoyalStars").gameObject
        self:UpdateSlotsCardsUI()
    end

    self.goSlotsCardsReward:SetActive(SlotsCardsManager:orUnLock())
    self.goRoyalStars:SetActive(RoyalPassHandler:orUnLock())

    local textRoyalstarFree = self.transform:FindDeepChild("TextRoyalstarFree"):GetComponent(typeof(TextMeshProUGUI))
    textRoyalstarFree.text = string.format("+%d", LuckyEggMainUI.silverRoyalPassStar:getFinalRoyalStars())
    local bPortraitFlag = not ScreenHelper:isLandScape()
    if bPortraitFlag then
        self.m_trContent.localScale = Unity.Vector3.one * 0.65
    else
        self.m_trContent.localScale = Unity.Vector3.one
    end

    ViewScaleAni:Show(self.transform.gameObject, nil, function()
        self.m_btnCollect.interactable = true
    end)
    self.m_remainHammerCount.text = "x"..LuckyEggHandler.data.nSilverCount
end

function LuckyEggSilverHammerUI:UpdateSlotsCardsUI()
    local slotsCardsContent = self.transform:FindDeepChild("SlotsCardsContent")
    local packCountText = slotsCardsContent:FindDeepChild("PackCountText"):GetComponent(typeof(TextMeshProUGUI))
    packCountText.text = "+1"
    local stars = slotsCardsContent:FindDeepChild("Stars")
    local packTypeContainer = slotsCardsContent:FindDeepChild("IconContainer")
    local packType = LuckyEggHandler.N_SILVER_END_SEND_SLOTSCARDS
    stars.sizeDelta = Unity.Vector2(20* (packType), 20)
    for j = 0, stars.childCount - 1 do
        if j <= packType then
            stars:GetChild(j).gameObject:SetActive(true)
        else
            stars:GetChild(j).gameObject:SetActive(false)
        end
        packTypeContainer:GetChild(j).gameObject:SetActive(j==packType)
    end
end

function LuckyEggSilverHammerUI:Hide()
    self.m_ani:SetInteger("nPlayMode", 1)
    ViewScaleAni:Hide(self.transform.gameObject, function()
        self.m_ani:SetInteger("nPlayMode", 0)
    end)
end

function LuckyEggSilverHammerUI:onCollectClicked()
    self.m_btnCollect.interactable = false
    GlobalAudioHandler:PlayBtnSound()
    self:Hide()
end

return LuckyEggSilverHammerUI