LoungePayTable = {}

function LoungePayTable:Show()
    if not LuaHelper.OrGameObjectExist(self.transform) then
        local goPrefab = AssetBundleHandler:LoadGoldenLoungeAsset("LoungeUI/LoungePayTable.prefab")
        local goPanel = Unity.Object.Instantiate(goPrefab)
        self.transform = goPanel.transform
        self.transform:SetParent(LobbyScene.popCanvas, false)
        self.transform.localScale = Unity.Vector3.one
        self.transform.localPosition = Unity.Vector3.zero
        LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
        self.transform.gameObject:SetActive(false)
        
        self.trPageNodes = self.transform:FindDeepChild("pageNodes")
        local btnClose = self.transform:FindDeepChild("BtnClose"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(btnClose)
        btnClose.onClick:AddListener(function()
            GlobalAudioHandler:PlayBtnSound()
            self:Hide()
        end)
        
        local btnLeft = self.transform:FindDeepChild("BtnLeft"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(btnLeft)
        btnLeft.onClick:AddListener(function()
            GlobalAudioHandler:PlayBtnSound()
            self.m_nPageIndex = self.m_nPageIndex - 1
            if self.m_nPageIndex < 0 then
                self.m_nPageIndex = 3
            end
            
            self:ShowPage(self.m_nPageIndex)
        end)
        
        local btnRight = self.transform:FindDeepChild("BtnRight"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(btnRight)
        btnRight.onClick:AddListener(function()
            GlobalAudioHandler:PlayBtnSound()
            self.m_nPageIndex = self.m_nPageIndex + 1
            if self.m_nPageIndex > 3 then
                self.m_nPageIndex = 0
            end
            
            self:ShowPage(self.m_nPageIndex)
        end)
        
    end 

    ViewAlphaAni:Show(self.transform.gameObject)
    self.transform:SetAsLastSibling() -- SetAsFirstSibling -- SetSiblingIndex(0)
    self.m_nPageIndex = 0
    self:ShowPage(0)
end

function LoungePayTable:ShowPage(index)
    for i=0, self.trPageNodes.childCount - 1 do
        local go = self.trPageNodes:GetChild(i).gameObject
        go:SetActive(false)
        if i == index then
            go:SetActive(true)
        end
    end
end

function LoungePayTable:Hide(normalHide)
    LoungeAudioHandler:StopBackMusic()
    ViewAlphaAni:Hide(self.transform.gameObject)
end
