local NetErrorView = {}
NetErrorView.m_transform = nil
NetErrorView.m_progressBar = nil
NetErrorView.m_progressText = nil

NetErrorView.fProgressValue = nil
NetErrorView.fLastProgressValue = nil
NetErrorView.m_waitingSynData = nil
NetErrorView.finishCf = nil

function NetErrorView:Init()
    local bundleName = "InitScene"
	local assetPath = "Assets/ResourceABs/InitScene/View/NetErrorView.prefab"
    local goPrefab = AssetBundleManager.Instance:LoadAsset(bundleName, assetPath)
    local go = Unity.Object.Instantiate(goPrefab)

    local goParent = InitScene.popCanvas
    self.transform = go.transform
    self.transform:SetParent(goParent, false)
    self.transform.localScale = Unity.Vector3.one
    self.transform.localPosition = Unity.Vector3.zero
    self.transform.gameObject:SetActive(false)
    
    self.textDes = self.transform:FindDeepChild("textNetErrorDes"):GetComponent(typeof(TextMeshProUGUI))
    self.mReTryBtn = self.transform:FindDeepChild("ReTryBtn"):GetComponent(typeof(UnityUI.Button))
    self.mReTryBtn.onClick:AddListener(function()
        self:OnClickReTryBtn()
    end)
    DelegateCache:addOnClickButton(self.mReTryBtn)

end

function NetErrorView:OnClickReTryBtn()
    self:Hide()
    InitScene:ReStartUpdate()
end

function NetErrorView:Show(strDes)
    self.transform.gameObject:SetActive(true)
    if not strDes then
        strDes = "Oops, something went wrong here, please refresh!"
    end
    self.textDes.text = strDes
end

function NetErrorView:Hide()
    self.transform.gameObject:SetActive(false)
end

return NetErrorView

