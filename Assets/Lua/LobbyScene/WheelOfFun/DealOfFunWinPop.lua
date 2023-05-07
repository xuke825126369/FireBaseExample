DealOfFunWinPop = {}

function DealOfFunWinPop:Init()
    if LuaHelper.OrGameObjectExist(self.transform) then
        return
    end

    local bundleName = "Lobby"
	local assetPath = "NowDealOfFun/DealOfFunWinPop.prefab"
	local goPrefab = AssetBundleHandler:LoadAsset(bundleName, assetPath)
	local goPanel = Unity.Object.Instantiate(goPrefab)
    
    local goParent = LobbyScene .popCanvas
    self.transform = goPanel.transform
    self.transform:SetParent(goParent, false)
    self.transform.localScale = Unity.Vector3.one
	self.transform.localPosition = Unity.Vector3.zero
	LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
	self.transform.gameObject:SetActive(false)

    self.finalWinCountText =  self.transform:FindDeepChild("FinalWinCount"):GetComponent(typeof(TextMeshProUGUI))
    self.buttonCollectionTransform  = self.transform:FindDeepChild("ButtonCollection")
    local btn = self.buttonCollectionTransform:GetComponent(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(btn)
    btn.onClick:AddListener(function()
        self:onCollectBtnClicked()
    end)
end

function DealOfFunWinPop:Show(winIndex, bonusCount)
    self:Init()
    self.finalWinCountText.text = MoneyFormatHelper.numWithCommas(bonusCount)
    self.transform:SetParent(LobbyScene.popCanvas, false)
    ViewScaleAni:Show(self.transform.gameObject)
end

function DealOfFunWinPop:onCollectBtnClicked()
    ViewScaleAni:Hide(self.transform.gameObject)
    
    GlobalAudioHandler:PlaySound("iap_coin_collect")
    CS.ParticleAttractor.instance:Play(self.buttonCollectionTransform.position, GlobalTempData.goUITopCollectMoneyEndPos.transform.position)
    LeanTween.delayedCall(2.6, function()
        GlobalAudioHandler:playCoinCollection(2)
        GlobalAudioHandler:PlaySound("")
		EventHandler:Brocast("UpdateMyInfo")
    end)

    if DealOfFunPop.m_bDailyTaskBonusFlag then
        LeanTween.delayedCall(2.0, function()
            if MissionPoint1000WheelofFortuneUI.m_bInitFlag then
                MissionPoint1000WheelofFortuneUI:Hide()
            end
        end)
    end

end