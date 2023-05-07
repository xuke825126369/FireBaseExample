PickBonusJackpotEndUIPop = {}

function PickBonusJackpotEndUIPop:Show(nIndex, winCoins)
    if not LuaHelper.OrGameObjectExist(self.transform) then
        local bundleName = "Activity_PickBonus"
        local goPrefab = AssetBundleHandler:LoadAsset(bundleName, "JackpotEnd.prefab")
        local goPanel = Unity.Object.Instantiate(goPrefab)
        self.transform = goPanel.transform
        self.transform:SetParent(LobbyScene.popCanvas, false)
        self.transform.localScale = Unity.Vector3.one
        self.transform.localPosition = Unity.Vector3.zero
        LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
        self.transform.gameObject:SetActive(false)

        self.m_ani = self.transform:GetComponentInChildren(typeof(Unity.Animator))

        self.m_jackPotContainer = self.transform:FindDeepChild("Jackpot")
        self.m_textReward = self.transform:FindDeepChild("RewardText"):GetComponent(typeof(UnityUI.Text))
        self.m_btnTakeIt = self.transform:FindDeepChild("ButCollect"):GetComponent(typeof(UnityUI.Button))
        self.m_btnTakeIt.onClick:AddListener(function()
            self:onTakeItClick()
        end)
    end 

    self.transform.gameObject:SetActive(true)
    self.m_btnTakeIt.interactable = true
    
    for i = 0, self.m_jackPotContainer.childCount - 1 do
        self.m_jackPotContainer:GetChild(i).gameObject:SetActive(i == (nIndex - 1))
    end
    self.m_textReward.text = MoneyFormatHelper.numWithCommas(winCoins)
    PickBonusAudioHandler:PlaySound("reward_pop")
end

function PickBonusJackpotEndUIPop:onTakeItClick()
    PickBonusAudioHandler:PlaySound("button")
    self.m_btnTakeIt.interactable = false
    LobbyView:UpCoinsCanvasLayer()
    CoinFly:fly(self.m_btnTakeIt.transform.position, GlobalTempData.goUITopCollectMoneyEndPos.transform.position, 12)
    LeanTween.delayedCall(3.5, function()
        LobbyView:DownCoinsCanvasLayer()
        self:Hide()
    end)
end

function PickBonusJackpotEndUIPop:Hide()
    self.m_ani:SetInteger("nPlayMode", 1)
    LeanTween.delayedCall(0.5, function()
        self.m_ani:SetInteger("nPlayMode", 0)
        self.transform.gameObject:SetActive(false)
        PickBonusMainUIPop:Hide()
    end)
end
