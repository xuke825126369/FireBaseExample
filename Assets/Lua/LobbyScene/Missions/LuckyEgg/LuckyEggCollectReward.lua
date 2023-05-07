local LuckyEggCollectReward = {}

function LuckyEggCollectReward:Show(rewardCount, bIsGold)
    if not LuaHelper.OrGameObjectExist(self.transform) then
        local goPrefab = AssetBundleHandler:LoadMissionAsset("Missions/LuckyEgg/LuckyEggAlmostThereEnd.prefab")
        local goPanel = Unity.Object.Instantiate(goPrefab)
        self.transform = goPanel.transform
        self.transform:SetParent(MissionMainUIPop.m_trPopNode, false)
        self.transform.localScale = Unity.Vector3.one
        self.transform.localPosition = Unity.Vector3.zero
        LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
        self.transform.gameObject:SetActive(false)

        self.m_ani = self.transform:GetComponentInChildren(typeof(Unity.Animator))
        self.m_trContent = self.transform:FindDeepChild("Content")

        self.m_goGold = self.transform:FindDeepChild("Gold").gameObject
        self.m_goSilver = self.transform:FindDeepChild("Silver").gameObject

        self.m_rewardCoinsText = self.transform:FindDeepChild("RewardCoins"):GetComponent(typeof(UnityUI.Text))
        self.m_btnCollect = self.transform:FindDeepChild("BtnCollect"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(self.m_btnCollect)
        self.m_btnCollect.onClick:AddListener(function()
            self:onCollectClicked()
        end)
    end

    self.m_goGold:SetActive(bIsGold)
    self.m_goSilver:SetActive(not bIsGold)
    self.m_btnCollect.interactable = true

    local bPortraitFlag = not ScreenHelper:isLandScape()
    if bPortraitFlag then
        self.m_trContent.localScale = Unity.Vector3.one * 0.65
    else
        self.m_trContent.localScale = Unity.Vector3.one
    end
    
    ViewScaleAni:Show(self.transform.gameObject, nil, function()
        GlobalAudioHandler:PlaySound("popup")
    end)
    self.m_rewardCoinsText.text = MoneyFormatHelper.numWithCommas(rewardCount)
end

function LuckyEggCollectReward:Hide()
    self.m_ani:SetInteger("nPlayMode", 1)
    ViewScaleAni:Hide(self.transform.gameObject)
end

function LuckyEggCollectReward:onCollectClicked()
    self.m_btnCollect.interactable = false
    GlobalAudioHandler:PlayBtnSound()
    self:Hide()
end

return LuckyEggCollectReward