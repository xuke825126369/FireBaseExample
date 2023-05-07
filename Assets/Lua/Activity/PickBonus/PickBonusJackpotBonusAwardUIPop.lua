PickBonusJackpotBonusAwardUIPop = {}

function PickBonusJackpotBonusAwardUIPop:Show()
    if not LuaHelper.OrGameObjectExist(self.transform) then
        local bundleName = "Activity_PickBonus"
        local goPrefab = AssetBundleHandler:LoadAsset(bundleName, "JackpotBonusAwarded.prefab")
        local goPanel = Unity.Object.Instantiate(goPrefab)
        self.transform = goPanel.transform
        self.transform:SetParent(LobbyScene.popCanvas, false)
        self.transform.localScale = Unity.Vector3.one
        self.transform.localPosition = Unity.Vector3.zero
        LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
        self.transform.gameObject:SetActive(false)

        self.m_ani = self.transform:GetComponentInChildren(typeof(Unity.Animator))
        self.m_textPickCount = self.transform:FindDeepChild("PickCountText"):GetComponent(typeof(TextMeshProUGUI))

        self.m_btnTakeIt = self.transform:FindDeepChild("ButTakeIt"):GetComponent(typeof(UnityUI.Button))
        self.m_btnTakeIt.onClick:AddListener(function()
            self:onTakeItClick()
        end)

        self.m_btnLeaveIt = self.transform:FindDeepChild("ButLeaveIt"):GetComponent(typeof(UnityUI.Button))
        self.m_btnLeaveIt.onClick:AddListener(function()
            self:onLeaveItClick()
        end)

        self.m_mapJackPot = {}
        local goMini = self.transform:FindDeepChild("Mini").gameObject
        self.m_mapJackPot[1] = goMini
        local goMinor = self.transform:FindDeepChild("Minor").gameObject
        self.m_mapJackPot[2] = goMinor
        local goMajor = self.transform:FindDeepChild("Major").gameObject
        self.m_mapJackPot[3] = goMajor
        local goMaxi = self.transform:FindDeepChild("Maxi").gameObject
        self.m_mapJackPot[4] = goMaxi
        local goGrand = self.transform:FindDeepChild("Grand").gameObject
        self.m_mapJackPot[5] = goGrand
    end

    for i = 1, 5 do
        self.m_mapJackPot[i]:SetActive(PickBonusMainUIPop.m_nCurrentJackPot == i)
    end
        
    self.transform.gameObject:SetActive(true)
    self:UpdatePickCount()
    PickBonusAudioHandler:PlaySound("pop")
end

function PickBonusJackpotBonusAwardUIPop:onTakeItClick()
    PickBonusAudioHandler:PlaySound("button")
    FlashChallengeRewardDataHandler:setPickBonusCount(0, 0)
    local winCoins = PickBonusMainUIPop:getBasePrize() * PickBonusMainUIPop.m_mapRatio[PickBonusMainUIPop.m_nCurrentJackPot]
    PlayerHandler:AddCoin(winCoins)
    PickBonusJackpotEndUIPop:Show(PickBonusMainUIPop.m_nCurrentJackPot, winCoins)
    self:Hide()
end

function PickBonusJackpotBonusAwardUIPop:onLeaveItClick()
    PickBonusAudioHandler:PlaySound("button")
    self:Hide()
end

function PickBonusJackpotBonusAwardUIPop:UpdatePickCount()
    local count = FlashChallengeRewardDataHandler.data.nPickBonusCount
    self.m_textPickCount.text = count
end

function PickBonusJackpotBonusAwardUIPop:Hide()
    self.m_ani:SetInteger("nPlayMode", 1)
    LeanTween.delayedCall(0.85, function()
        self.m_ani:SetInteger("nPlayMode", 0)
        self.transform.gameObject:SetActive(false)
    end)
end
