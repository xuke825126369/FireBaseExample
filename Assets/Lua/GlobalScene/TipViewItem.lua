local TipViewItem = {}

function TipViewItem:New(go)
    local temp = {}
    self.__index = self
    setmetatable(temp, self)

    temp:Init(go)
    return temp
end

function TipViewItem:Init(go)
    self.transform = go.transform
    self.imageBg = self.transform:FindDeepChild("bg"):GetComponent(typeof(UnityUI.Image))
    self.textTip = self.transform:FindDeepChild("textTip"):GetComponent(typeof(TextMeshProUGUI))
    self.transform.gameObject:SetActive(false)
end

function TipViewItem:Show(strDes)
    self.transform.gameObject:SetActive(true)
    self.transform:SetAsLastSibling()
    
    self.textTip.text = strDes

    local oriSizeY = self.imageBg.rectTransform.sizeDelta.y
    self.imageBg.rectTransform.sizeDelta = Unity.Vector2(self.textTip.preferredWidth + 100, oriSizeY)
    LeanTween.delayedCall(self.transform.gameObject, 3.0, function()
        self:Hide()
    end)
end 

function TipViewItem:Hide()
    TipPoolView:RecycleItem(self)
end

return TipViewItem
