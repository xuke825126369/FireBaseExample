MedalPayTable = {}
MedalPayTable.m_nPageIndex = 0

function MedalPayTable:Show()
    if not LuaHelper.OrGameObjectExist(self.transform) then
        local strPath = "MedalPayTable.prefab"
        local prefabObj = AssetBundleHandler:LoadGoldenLoungeAsset(strPath)
        local go = Unity.Object.Instantiate(prefabObj)
        self.transform = go.transform
        self.transform:SetParent(LobbyScene.popCanvas, false)

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
                self.m_nPageIndex = 2
            end
            
            self:ShowPage(self.m_nPageIndex)
        end)
        
        local btnRight = self.transform:FindDeepChild("BtnRight"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(btnRight)
        btnRight.onClick:AddListener(function()
            GlobalAudioHandler:PlayBtnSound()
            self.m_nPageIndex = self.m_nPageIndex + 1
            if self.m_nPageIndex > 2 then
                self.m_nPageIndex = 0
            end
            
            self:ShowPage(self.m_nPageIndex)
        end)
        
    end

    ViewAlphaAni:Show(self.transform.gameObject)
    self.transform:SetAsLastSibling()
    self.m_nPageIndex = 0
    self:ShowPage(0)

end

function MedalPayTable:ShowPage(index)
    for i = 0, self.trPageNodes.childCount - 1 do
        local go = self.trPageNodes:GetChild(i).gameObject
        go:SetActive(false)
        if i == index then
            go:SetActive(true)
        end
    end
end

function MedalPayTable:Hide()
    LoungeAudioHandler:StopBackMusic()
    ViewAlphaAni:Hide(self.transform.gameObject)
end
