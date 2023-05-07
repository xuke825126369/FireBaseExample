MegaballPremiumEnd = {}
MegaballPremiumEnd.m_btnCollect = nil
MegaballPremiumEnd.m_TextMeshProBaseCoins = nil
MegaballPremiumEnd.m_TextMeshProMultiplyCoef = nil
MegaballPremiumEnd.m_TextFinalBonus = nil

function MegaballPremiumEnd:Init()
    if LuaHelper.OrGameObjectExist(self.transform) then
        return
    end

    local bundleName = "Lobby"
    local goPrefab = AssetBundleHandler:LoadAsset(bundleName, "Assets/Lobby/MegaBall/MegaballPremiumEnd.prefab")
    local goPanel = Unity.Object.Instantiate(goPrefab)
    self.transform = goPanel.transform
    self.transform:SetParent(GlobalScene.popCanvasActivity, false)
    self.transform.localScale = Unity.Vector3.one
    self.transform.localPosition = Unity.Vector3.zero
    LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
    self.transform.gameObject:SetActive(false)

    local trCollect = self.transform:FindDeepChild("ButtonCollect")
    local btnCollect = trCollect:GetComponent(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(btnCollect)
    btnCollect.onClick:AddListener(function()
        self:onCollectBtnClicked()
    end)
    self.m_btnCollect = btnCollect

    local tr = self.transform:FindDeepChild("TextMeshProBaseCoins")
    self.m_TextMeshProBaseCoins = tr:GetComponent(typeof(TextMeshProUGUI))

    tr = self.transform:FindDeepChild("TextMeshProMultiplyCoef")
    self.m_TextMeshProMultiplyCoef = tr:GetComponent(typeof(TextMeshProUGUI))

    tr = self.transform:FindDeepChild("TextFinalBonus")
    self.m_TextFinalBonus = tr:GetComponent(typeof(UnityUI.Text))

end


function MegaballPremiumEnd:Show()
    self:Init()
    self.transform.gameObject:SetActive(true)
    self.m_btnCollect.interactable = true

    local data = MegaballPremiumUI.m_BonusData
    local nBaseCoins = data.nBaseCoins
    local nMultiplyCoef = data.nMultiplyCoef
    local strBaseCoins = MoneyFormatHelper.numWithCommas(nBaseCoins)
    self.m_TextMeshProBaseCoins.text = strBaseCoins

    self.m_TextMeshProMultiplyCoef.text = tostring(nMultiplyCoef)

    local strFinalBonus = MoneyFormatHelper.numWithCommas(nBaseCoins * nMultiplyCoef)
    self.m_TextFinalBonus.text = strFinalBonus
end

function MegaballPremiumEnd:Hide()
    Unity.Object.Destroy(self.transform.gameObject)
    MegaballPremiumUI:Hide()
end

function MegaballPremiumEnd:onCollectBtnClicked()
    self.m_btnCollect.interactable = false
    local ftime = 2.5

    local coinPos = self.m_TextFinalBonus.transform.position
    CoinFly:fly(coinPos, GlobalTempData.goUITopCollectMoneyEndPos.transform.position, 12)
    
    GlobalAudioHandler:PlaySound("megaball_coins")
    LeanTween.delayedCall(ftime, function()
        self:Hide()
    end)
    
end