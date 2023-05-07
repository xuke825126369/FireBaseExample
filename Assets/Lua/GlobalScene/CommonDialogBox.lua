
CommonDialogBox = {}

function CommonDialogBox:Init()
    local bundleName = "Global"
	local assetPath = "Assets/ResourceABs/Global/View/CommonDialogBox.prefab"
	local goPrefab = AssetBundleHandler:LoadAsset(bundleName, assetPath)
	local goPanel = Unity.Object.Instantiate(goPrefab)

    local goParent = GlobalScene.popCanvas
    self.transform = goPanel.transform
    self.transform:SetParent(goParent, false)
    self.transform.localScale = Unity.Vector3.one
	self.transform.localPosition = Unity.Vector3.zero

    LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
    self.transform.gameObject:SetActive(false)
    
    self.textTitle = self.transform:FindDeepChild("Title"):GetComponent(typeof(TextMeshProUGUI))
    self.textMessage = self.transform:FindDeepChild("textDes"):GetComponent(typeof(TextMeshProUGUI)) 
    self.mYesBtn = self.transform:FindDeepChild("yesBtn"):GetComponent(typeof(UnityUI.Button))
    self.mCancelBtn = self.transform:FindDeepChild("cancelBtn"):GetComponent(typeof(UnityUI.Button))
    self.mSureBtn = self.transform:FindDeepChild("sureBtn"):GetComponent(typeof(UnityUI.Button))

    self.mOnYesEvent = nil
    self.mOnNoEvent = nil
    self.mOnSureEvent = nil
    
    self.mYesBtn.onClick:AddListener(function()
        ViewScaleAni:Hide(self.transform.gameObject)
        if self.mOnYesEvent then
            self.mOnYesEvent()
            self.mOnYesEvent = nil
        end
    end)

    self.mCancelBtn.onClick:AddListener(function()
        ViewScaleAni:Hide(self.transform.gameObject)
        if self.mOnNoEvent then
            self.mOnNoEvent()
            self.mOnNoEvent = nil
        end
    end)

    self.mSureBtn.onClick:AddListener(function()
        ViewScaleAni:Hide(self.transform.gameObject)
        if self.mOnSureEvent then
            self.mOnSureEvent()
            self.mOnSureEvent = nil
        end
    end)

end

function CommonDialogBox:OnDestroy()
    self.mOnYesEvent = nil
    self.mOnNoEvent = nil
    self.mOnSureEvent = nil

    self.mYesBtn.onClick:RemoveAllListeners()
    self.mCancelBtn.onClick:RemoveAllListeners()
    self.mSureBtn.onClick:RemoveAllListeners()
end

function CommonDialogBox:ShowYesNoUI(message, title, mYesEvent, mNoEvent)
    self.mYesBtn.gameObject:SetActive(true)
    self.mCancelBtn.gameObject:SetActive(true)
    self.mSureBtn.gameObject:SetActive(false)

    self.mOnYesEvent = mYesEvent
    self.mOnNoEvent = mNoEvent
    if not title then
        title = "Warning"
    end

	ViewScaleAni:Show(self.transform.gameObject)
    self.textMessage.text = message
    self.textTitle.text = title

    self.transform:SetAsLastSibling()
end

function CommonDialogBox:ShowSureUI(message, title, mSureEvent)
    self.mYesBtn.gameObject:SetActive(false)
    self.mCancelBtn.gameObject:SetActive(false)
    self.mSureBtn.gameObject:SetActive(true)
    self.mOnSureEvent = mSureEvent
    if not title  then
        title = "Warning"
    end

	ViewScaleAni:Show(self.transform.gameObject)
    self.textMessage.text = message
    self.textTitle.text = title
    
    self.transform:SetAsLastSibling()
end
    
