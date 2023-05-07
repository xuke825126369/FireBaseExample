DeleteAccountView = {}

function DeleteAccountView:Init()
    if LuaHelper.OrGameObjectExist(self.transform) then
        return
    end

    local bundleName = "Lobby"
	local assetPath = "Assets/ResourceABs/Lobby/View/DeleteAccountView.prefab"
	local goPrefab = AssetBundleHandler:LoadAsset(bundleName, assetPath)
	local goPanel = Unity.Object.Instantiate(goPrefab)

    local goParent = LobbyScene.popCanvas
    self.transform = goPanel.transform
    self.transform:SetParent(goParent, false)
    self.transform.localScale = Unity.Vector3.one
	self.transform.localPosition = Unity.Vector3.zero
	LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
	self.transform.gameObject:SetActive(false)
        
    self.mClosedBtn = self.transform:FindDeepChild("closedBtn"):GetComponent(typeof(UnityUI.Button))
    self.mClosedBtn.onClick:AddListener(function()
        GlobalAudioHandler:PlayBtnSound()
        self:Hide()
    end)

    self.mSureBtn = self.transform:FindDeepChild("sureBtn"):GetComponent(typeof(UnityUI.Button))
    self.mSureBtn.onClick:AddListener(function()
        GlobalAudioHandler:PlayBtnSound()
        self:OnClickDeleteAccountBtn()
    end)
    
    self.textCdTime = self.transform:FindDeepChild("textCd"):GetComponent(typeof(TextMeshProUGUI))
end

function DeleteAccountView:Show()
    self:Init()
    self.transform:SetAsLastSibling()
    ViewScaleAni:Show(self.transform.gameObject)

    self.mSureBtn.gameObject:SetActive(false)
    self.fCdTime = 0
    self.fMaxCdTime = 15
    self.textCdTime.gameObject:SetActive(true)
    self:UpdateCdText(self.fMaxCdTime)
end

function DeleteAccountView:Hide()
    ViewScaleAni:Hide(self.transform.gameObject)
end

function DeleteAccountView:UpdateCdText(nTime)
    self.textCdTime.text = string.format("Think about it for a second: <color=#00FF00>%ds</color>", nTime)
end

function DeleteAccountView:Update()
    self.fCdTime = self.fCdTime + Unity.Time.deltaTime
    local nTime = math.floor(self.fMaxCdTime - self.fCdTime)
    self:UpdateCdText(nTime)
    
    if self.fCdTime >= self.fMaxCdTime then
        self.textCdTime.gameObject:SetActive(false)
        self.mSureBtn.gameObject:SetActive(true)
    end
end

function DeleteAccountView:OnClickDeleteAccountBtn()
    self:Hide()
    CommonLoadingView:Show("Deleting account")
    CS.FirBaseInterface.DeleteAccount(PlayerHandler.nUserId, function(bSuccess)
        if bSuccess then
            Unity.PlayerPrefs.DeleteAll()
            Unity.Caching.ClearCache()

            local rootdir = Unity.Application.persistentDataPath;
            local allfiles = CS.System.IO.Directory.GetFiles(rootdir)
            for i = 0, allfiles.Length - 1 do
                local filePath = allfiles[i]
                CS.System.IO.File.Delete(filePath)
                Debug.Log("remove persist file :"..filePath)
            end
            
            CommonLoadingView:Show("<color=#00FF00>Deleting account Successed!</color>")
            LeanTween.delayedCall(2.0, function()
                Unity.Application.Quit()
            end)
        else
            CommonLoadingView:Show("<color=#FF0000>Deleting account Failed!</color>")
            LeanTween.delayedCall(2.0, function()
                CommonLoadingView:Hide()
            end)
        end
    end)
end

return DeleteAccountView