EarningPointsUI = {}
EarningPointsUI.m_bInitFlag = false

EarningPointsUI.EarningPointType = 
{
    enumLuckyMegaball = 1, -- 50
    enumStoreBonus = 2, -- 5
    enumQualifiedSpins = 3, -- up to 100 -- bet >= 200k
    enumLuckyWheel = 4, -- 20
    enumLevelUp = 5, -- up to 300 -- when 5 or 0 is last digit of level
    enumGoldenChest = 6, -- 2
    enumSilverChest = 7, -- 1
}

function EarningPointsUI:Show()
    if not LuaHelper.OrGameObjectExist(self.transform) then
        local goPrefab = AssetBundleHandler:LoadGoldenLoungeAsset("LoungeUI/EarningPointsUI.prefab")
        local goPanel = Unity.Object.Instantiate(goPrefab)
        self.transform = goPanel.transform
        self.transform:SetParent(LobbyScene.popCanvas, false)
        self.transform.localScale = Unity.Vector3.one
        self.transform.localPosition = Unity.Vector3.zero
        LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
        self.transform.gameObject:SetActive(false)

        local trPlayItemNodes = self.transform:FindDeepChild("PlayItemNodes")
        local trProgress = trPlayItemNodes:FindDeepChild("SpinProgressNode")
        -- imageSpinProgress -- TextMeshProSpinNum
        self.imageSpinProgress = trProgress:FindDeepChild("imageSpinProgress"):GetComponent(typeof(UnityUI.Image))
        self.TextMeshProSpinNum = trProgress:FindDeepChild("TextMeshProSpinNum"):GetComponent(typeof(TextMeshProUGUI))

        -- PlayItemNodes  -- StoreItemNodes
        self.m_goPlayItemNodes = trPlayItemNodes.gameObject
        self.m_goStoreItemNodes = self.transform:FindDeepChild("StoreItemNodes").gameObject

        -- imgPlayNoSel -- imgPlaySel -- imgStoreNoSel -- imgStoreSel
        self.m_goimgPlayNoSel = self.transform:FindDeepChild("imgPlayNoSel").gameObject
        self.m_goimgPlaySel = self.transform:FindDeepChild("imgPlaySel").gameObject
        self.m_goimgStoreNoSel = self.transform:FindDeepChild("imgStoreNoSel").gameObject
        self.m_goimgStoreSel = self.transform:FindDeepChild("imgStoreSel").gameObject

        local btnClose = self.transform:FindDeepChild("BtnClose"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(btnClose)
        btnClose.onClick:AddListener(function()
            GlobalAudioHandler:PlayBtnSound()
            self:Hide()
        end)
        
        local btnPlay = self.transform:FindDeepChild("BtnPlay"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(btnPlay)
        btnPlay.onClick:AddListener(function()
            GlobalAudioHandler:PlayBtnSound()
            self:ShowPlayPage()
        end)
        
        local btnStore = self.transform:FindDeepChild("BtnStore"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(btnStore)
        btnStore.onClick:AddListener(function()
            GlobalAudioHandler:PlayBtnSound()
            self:ShowStorePage()
        end)
        
    end
    
    ViewAlphaAni:Show(self.transform.gameObject)
    self.transform:SetAsLastSibling()
    self:ShowPlayPage()

end

function EarningPointsUI:ShowPlayPage()
    self.m_goPlayItemNodes:SetActive(true)
    self.m_goStoreItemNodes:SetActive(false)
    
    self.m_goimgPlayNoSel:SetActive(false)
    self.m_goimgPlaySel:SetActive(true)
    self.m_goimgStoreNoSel:SetActive(true)
    self.m_goimgStoreSel:SetActive(false)

    -- 显示界面参数
    local nSpin = LoungeHandler.data.activityData.nQualifiedSpins
    local fcoef = nSpin / 200
    self.imageSpinProgress.fillAmount = fcoef
    local strSpin = nSpin .. "/200"
    self.TextMeshProSpinNum.text = strSpin
end

function EarningPointsUI:ShowStorePage()
    self.m_goPlayItemNodes:SetActive(false)
    self.m_goStoreItemNodes:SetActive(true)
    
    self.m_goimgPlayNoSel:SetActive(true)
    self.m_goimgPlaySel:SetActive(false)
    self.m_goimgStoreNoSel:SetActive(false)
    self.m_goimgStoreSel:SetActive(true)
end

function EarningPointsUI:Hide(normalHide)
    LoungeAudioHandler:StopBackMusic()
    ViewAlphaAni:Hide(self.transform.gameObject)
end
