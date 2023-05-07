MegaballPremiumBegin = {}
MegaballPremiumBegin.m_bInitFlag = false

MegaballPremiumBegin.m_btnPlay = nil
MegaballPremiumBegin.m_TextMeshProBaseCoins = nil
MegaballPremiumBegin.m_TextMultiplyCoef = nil -- 免费的最多X500 购买的最多X5000

MegaballPremiumBegin.m_goButtonClose = nil -- 关闭界面的按钮节点 免费下是隐藏的

function MegaballPremiumBegin:Init(goBeginUI)
    if LuaHelper.OrGameObjectExist(self.transform) then
        return
    end

    self.transform = goBeginUI.transform
    local tr = self.transform:FindDeepChild("ButtonClose")
    self.m_goButtonClose = tr.gameObject

    local trPlay = self.transform:FindDeepChild("ButtonPlay")
    local btnPlay = trPlay:GetComponent(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(btnPlay)
    btnPlay.onClick:AddListener(function()
        self:onPlayBtnClicked()
    end)
    self.m_btnPlay = btnPlay
    
    local tr = self.transform:FindDeepChild("TextMeshProBaseCoins")
    self.m_TextMeshProBaseCoins = tr:GetComponent(typeof(TextMeshProUGUI))
    local nBaseCoins = MegaballPremiumUI.m_BonusData.nBaseCoins
    local strCoins = MoneyFormatHelper.numWithCommas(nBaseCoins)
    strCoins = strCoins .. " Coins"
    self.m_TextMeshProBaseCoins.text = strCoins

    local tr = self.transform:FindDeepChild("TextMultiplyCoef")
    self.m_TextMultiplyCoef = tr:GetComponent(typeof(UnityUI.Text))
    self.m_TextMultiplyCoef.text = "X500"
end

function MegaballPremiumBegin:Show()
    self:Init()
    LeanTween.delayedCall(0.3, function()
        GlobalAudioHandler:PlaySound("popup1")
    end)
    self.m_goButtonClose:SetActive(false)
    self.transform.gameObject:SetActive(true)
    self.m_btnPlay.interactable = true
end

function MegaballPremiumBegin:Hide()
    Unity.Object.Destroy(self.transform.gameObject)
    self.m_bInitFlag = false
end

function MegaballPremiumBegin:onPlayBtnClicked()
    self.m_btnPlay.interactable = false
    GlobalAudioHandler:PlayBtnSound()
    self.transform.gameObject:SetActive(false)
    MegaballPremiumUI:playAni(true)
end