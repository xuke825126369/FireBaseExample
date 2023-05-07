WelcomeBonusView = PopStackViewBase:New()

function WelcomeBonusView:Init()
    if LuaHelper.OrGameObjectExist(self.transform) then
        return
    end

    local bundleName = "Lobby"
	local assetPath = "View/WelcomeBonusView.prefab"
	local goPrefab = AssetBundleHandler:LoadAsset(bundleName, assetPath)
	local goPanel = Unity.Object.Instantiate(goPrefab)

    local goParent = LobbyScene.popCanvas
    self.transform = goPanel.transform
    self.transform:SetParent(goParent, false)
    self.transform.localScale = Unity.Vector3.one
	self.transform.localPosition = Unity.Vector3.zero
	LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
	self.transform.gameObject:SetActive(false)

    self.textMoneyText = self.transform:FindDeepChild("nMoneyCount"):GetComponent(typeof(UnityUI.Text))
    self.mCollectBtn = self.transform:FindDeepChild("CollectBtn"):GetComponent(typeof(UnityUI.Button))
    self.mCollectBtn.onClick:AddListener(function()
        self:onCollectBtnClicked()
    end)

end     

function WelcomeBonusView:Show()
    self:Init()
    ViewScaleAni:Show(self.transform.gameObject)
    self.mCollectBtn.interactable = true
    self.textMoneyText.text = MoneyFormatHelper.numWithCommas(GameConst.nWelcomeBonusMoneyCount)
end

function WelcomeBonusView:Hide()
    ViewScaleAni:Hide(self.transform.gameObject)
end

function WelcomeBonusView:onCollectBtnClicked()
    self.mCollectBtn.interactable = false
    GlobalAudioHandler:PlayBtnSound()
    self:Hide()
    PlayerHandler:AddCoin(GameConst.nWelcomeBonusMoneyCount)
    CoinFly:fly(self.mCollectBtn.transform.position, GlobalTempData.goUITopCollectMoneyEndPos.transform.position, 10)
end

