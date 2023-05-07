local ThemeEntryItemLockTip = {}

function ThemeEntryItemLockTip:Init()
    if self.bInit then
        return 
    end
    self.bInit = true
    
    local bundleName = "ThemeVideoEntry"
    local assetPath = "ThemeEntryTipGo.prefab"
    local goPrefab = AssetBundleHandler:LoadAsset(bundleName, assetPath)
    local goPanel = Unity.Object.Instantiate(goPrefab)

    self.transform = goPanel.transform
    self.transform:SetParent(LobbyScene.popCanvas, false)
    self.transform.localScale = Unity.Vector3.one
    self.transform.localPosition = Unity.Vector3.zero
    LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
    self.transform.gameObject:SetActive(false)

    self.textLockTip = self.transform:FindDeepChild("LevelText"):GetComponent(typeof(TextMeshProUGUI))
    self.lockgrayBtn = self.transform:FindDeepChild("grayBtn"):GetComponent(typeof(UnityUI.Button))

    self.lockgrayBtn.onClick:AddListener(function()
        GlobalAudioHandler:PlayBtnSound()
        self:Hide()
    end)
end

function ThemeEntryItemLockTip:Show(targetGo, nUnLockLevel)
    self:Init()
    self.transform.gameObject:SetActive(true)
    self.transform.position = targetGo.transform.position
    self.textLockTip.text = string.format("UnLock Level: %d\n<color=yellow>Current Level: %d",  nUnLockLevel, PlayerHandler.nLevel)
end

function ThemeEntryItemLockTip:Hide()
    self.transform.gameObject:SetActive(false)
end

return ThemeEntryItemLockTip