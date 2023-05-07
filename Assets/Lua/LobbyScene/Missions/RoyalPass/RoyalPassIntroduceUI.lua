RoyalPassIntroduceUI = {}
RoyalPassIntroduceUI.m_btnClose = nil
RoyalPassIntroduceUI.m_btnLeft = nil
RoyalPassIntroduceUI.m_btnRight = nil

function RoyalPassIntroduceUI:Show()
    if not LuaHelper.OrGameObjectExist(self.transform) then
        local goPrefab = AssetBundleHandler:LoadMissionAsset("Missions/RoyalPass/PopPrefab/RoyalPassIntroduceUI.prefab")
        local goPanel = Unity.Object.Instantiate(goPrefab)
        self.transform = goPanel.transform
        self.transform:SetParent(MissionMainUIPop.m_trPopNode, false)
        self.transform.localScale = Unity.Vector3.one
        self.transform.localPosition = Unity.Vector3.zero
        LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
        self.transform.gameObject:SetActive(false)

        self.m_trContent = self.transform:FindDeepChild("Content")
        self.m_btnClose = self.transform:FindDeepChild("BtnClose"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(self.m_btnClose)
        self.m_btnClose.onClick:AddListener(function()
            self:Hide()
        end)

        self.m_btnLeft = self.transform:FindDeepChild("LeftBtn"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(self.m_btnLeft)
        self.m_btnLeft.onClick:AddListener(function()
            self:changeIndex(2)
        end)

        self.m_btnRight = self.transform:FindDeepChild("RightBtn"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(self.m_btnRight)
        self.m_btnRight.onClick:AddListener(function()
            self:changeIndex(1)
        end)

        self.m_goNode1 = self.transform:FindDeepChild("RoyalPassNode").gameObject
        self.m_goNode2 = self.transform:FindDeepChild("RoyalChestNode").gameObject
    end
    
    self:changeIndex(1)
    self:refreshBtnStatus(1)
    ViewScaleAni:Show(self.transform.gameObject)
end

function RoyalPassIntroduceUI:Hide()
    GlobalAudioHandler:PlayBtnSound()
    ViewScaleAni:Hide(self.transform.gameObject)
end

function RoyalPassIntroduceUI:changeIndex(nIndex)
    GlobalAudioHandler:PlayBtnSound()
    self.m_goNode1:SetActive(nIndex == 1)
    self.m_goNode2:SetActive(nIndex ~= 1)
    self:refreshBtnStatus(nIndex)
end

function RoyalPassIntroduceUI:refreshBtnStatus(nIndex)
    self.m_btnLeft.gameObject:SetActive(nIndex == 1)
    self.m_btnRight.gameObject:SetActive(nIndex ~= 1)
end