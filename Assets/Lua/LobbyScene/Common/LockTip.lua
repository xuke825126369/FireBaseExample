LockTip = {}

function LockTip:Init()
    if LuaHelper.OrGameObjectExist(self.transform) then
        return
    end

    local bundleName = "Lobby"
    local goPrefab = AssetBundleHandler:LoadAsset(bundleName, "View/LockTip.prefab")
    local goPanel = Unity.Object.Instantiate(goPrefab)

    self.transform = goPanel.transform
    self.transform:SetParent(LobbyScene.popCanvas, false)
    self.transform.localScale = Unity.Vector3.one
    self.transform.localPosition = Unity.Vector3.zero
    LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
    self.transform.gameObject:SetActive(false)

    self.textLockTip = self.transform:FindDeepChild("TipText"):GetComponent(typeof(TextMeshProUGUI))
end

function LockTip:ShowWithDes(targetGo, strDes)
    self:Init()
    self.transform:SetAsLastSibling()
    self.transform.position = targetGo.transform.position
    self.textLockTip.text = strDes
    self:DoShow()
end

function LockTip:ShowWithLevel(targetGo, nUnLockLevel)
    self:Init()

    self.transform:SetAsLastSibling()
    self.transform.position = targetGo.transform.position
    self.textLockTip.text = string.format("UnLock Level: <color=yellow>%d</color>",  nUnLockLevel)
    self:DoShow()
end 

function LockTip:DoShow()
    if self.hitLtd then
        if LeanTween.isTweening(self.hitLtd) then
            LeanTween.cancel(self.hitLtd)
        end
        self.hitLtd = nil
    end
    
    self.transform.gameObject:SetActive(false)
    self.transform.gameObject:SetActive(true)
    self.hitLtd = LeanTween.delayedCall(2.2, function()
        self.transform.gameObject:SetActive(false)
    end).id
end
