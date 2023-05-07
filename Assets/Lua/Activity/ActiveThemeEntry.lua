require("Lua.Activity.ActiveLobbyEntry")
require("Lua.Activity.ActiveTimesUpPop")
require("Lua.Activity.CardPackUI")
require("Lua.Activity.SlotsCards2020.SlotsCardsGameEntry")
require("Lua.Activity.ActiveBetSizeChangeBar")

ActiveThemeEntry = {}
function ActiveThemeEntry:isActiveShow()
    if not LuaHelper.OrGameObjectExist(self.transform) then
        return false
    end 

    if not self.transform.gameObject.activeInHierarchy then
        return false
    end

    return true
end

function ActiveThemeEntry:Show()
    if not LuaHelper.OrGameObjectExist(self.transform) then
        local bundleName = "ActivityCommon"
        local assetPath = "Assets/ResourceABs/ActivityCommon/ActiveThemeEntry.prefab"
        local goPrefab = AssetBundleHandler:LoadAsset(bundleName, assetPath)
        local goPanel = Unity.Object.Instantiate(goPrefab)

        local parent = UITop.m_transform
        self.transform = goPanel.transform:GetComponent(typeof(Unity.RectTransform))
        self.transform:SetParent(parent, false)
        self.transform.localScale = Unity.Vector3.one
        self.transform.localPosition = Unity.Vector3.zero
        LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
        self.transform.gameObject:SetActive(false)

        CS.LuaBindMouseBehaviour.Bind(self.transform.gameObject, self)
        self.transform.anchorMin = Unity.Vector2(0.5, 0.5)
        self.transform.anchorMax = Unity.Vector2(0.5, 0.5)
        Unity.Object.Destroy(self.transform:GetComponent(typeof(Unity.Animator)))
        self.m_boxCollider = self.transform.gameObject:AddComponent(typeof(Unity.BoxCollider2D))

        EventHandler:AddListener("OnSplashMsgHandler", self)
        EventHandler:AddListener("OnTotalBetChange", self)
    end     

    self.transform.gameObject:SetActive(true)
    self.m_bIsShow = true

    if SlotsCardsManager:orActivityOpen() then
        SlotsCardsGameEntry:Show(self.transform)
    end

    if ActiveManager:orActivityOpen() then
        ActiveManager.unloadedUI:Show(self.transform)
    end
    
    self:setTransform()
    ActivityHelper:DestroyPrefabPoolAllObj()
    self.bActive = true
end

function ActiveThemeEntry:OnDestroy()
    ActivityHelper:DestroyPrefabPoolAllObj()
    EventHandler:RemoveListener("OnSplashMsgHandler", self)
    EventHandler:RemoveListener("OnTotalBetChange", self)
end

function ActiveThemeEntry:setTransform()
    local nChildCount = 0
    for i = 0, self.transform.childCount - 1 do
        if self.transform:GetChild(i).gameObject.activeSelf then
            nChildCount = nChildCount + 1
        end
    end

    local size = Unity.Vector2(150, nChildCount * 150)
    self.transform.sizeDelta = size
    
    self.canvasContainer = UITop.m_transform:GetComponent(typeof(Unity.RectTransform))
    local x = self.canvasContainer.sizeDelta.x / 2
    self.minPosX = -x + 100
    self.maxPosX = x - 100
    local y = self.canvasContainer.sizeDelta.y / 2
    local minYOffset = 160
    local maxYOffset = 100
    if GameLevelUtil:isPortraitLevel() then
        minYOffset = 350
        maxYOffset = 200
    end

    self.minPosY = -y + self.transform.sizeDelta.y / 2 + minYOffset
    self.maxPosY = y - self.transform.sizeDelta.y / 2 - maxYOffset
    local pos = Unity.Vector3(self.minPosX, 0, 0)
    self.transform.anchoredPosition3D = pos
    self.m_boxCollider.size = size

end

function ActiveThemeEntry:showEntry()
    self.bActive = true
    local targetPos = self.transform.localPosition
    if targetPos.x <= self.minPosX then
        targetPos = Unity.Vector3(self.minPosX, self.transform.localPosition.y, 0)
    else
        targetPos = Unity.Vector3(self.maxPosX, self.transform.localPosition.y, 0)
    end
    LeanTween.moveLocal(self.transform.gameObject, targetPos, 0.4)
end

function ActiveThemeEntry:hideEntry()
    self.bActive = false
    local targetPos = self.transform.localPosition
    if targetPos.x >= self.maxPosX then
        targetPos = Unity.Vector3(self.maxPosX + 200, self.transform.localPosition.y, 0)
    else
        targetPos = Unity.Vector3(self.minPosX - 200, self.transform.localPosition.y, 0)
    end
    LeanTween.moveLocal(self.transform.gameObject, targetPos, 0.4)
end

function ActiveThemeEntry:OnSplashMsgHandler(data)
    if not data.flag then
        self.m_bIsShow = false
        if SlotsCardsGameEntry.transform ~= nil then
            SlotsCardsGameEntry.m_entryBtn.interactable = false
        end
        self:hideEntry()
    else
        self.m_bIsShow = true
        if SlotsCardsGameEntry.transform ~= nil then
            SlotsCardsGameEntry.m_entryBtn.interactable = true
        end
        self:showEntry()
    end
end

function ActiveThemeEntry:onMouseDown()
    self.originPos = self.transform.anchoredPosition
    local worldPos = Unity.Camera.main:ScreenToWorldPoint(Unity.Input.mousePosition)
    self.offset = self.transform:InverseTransformPoint(worldPos)

    if self.m_moveLeanTweenId then
        if LeanTween.isTweening(self.m_moveLeanTweenId) then
            LeanTween.cancel(self.m_moveLeanTweenId)
        end
    end
end

function ActiveThemeEntry:onMouseDrag()
    if not self.m_bIsShow then
        return
    end

    local uiPos = Unity.Vector2.zero
    local mousePos = Unity.Input.mousePosition
    if GameLevelUtil:is3DModelCurvedLevel() or GameLevelUtil:is3DLevel() then
        local uisize = self.canvasContainer.sizeDelta    
        uiPos = Unity.Vector2((mousePos.x - (Unity.Screen.width / 2))*  (uisize.x / Unity.Screen.width), (mousePos.y - (Unity.Screen.height / 2)) * ( uisize.y / Unity.Screen.height) )
    else
        local worldPos = Unity.Camera.main:ScreenToWorldPoint(mousePos)
        uiPos = self.canvasContainer:InverseTransformPoint(worldPos)
    end

    local target = Unity.Vector2(uiPos.x - self.offset.x , uiPos.y - self.offset.y)
    local distance = Unity.Vector2.Distance(self.originPos, target)
    if distance >= 20 then
        self.m_bBeginDrag = true
    end

    if self.m_bBeginDrag then
        self.transform.anchoredPosition = target
    end

    if ActiveBetSizeChangeBar.bActive then
        ActiveBetSizeChangeBar.transform.gameObject:SetActive(false)
        ActiveBetSizeChangeBar.bActive = false
    end
end

function ActiveThemeEntry:onMouseUp()
    if not self.m_bIsShow then
        return
    end

    local targetX = 0
    local targetY = 0
    if self.transform.position.x > 0 then
        targetX = self.maxPosX
    else
        targetX = self.minPosX
    end

    if self.transform.anchoredPosition.y > self.minPosY and self.transform.anchoredPosition.y < self.maxPosY then
        targetY = self.transform.anchoredPosition.y
    elseif self.transform.anchoredPosition.y <= self.minPosY then
        targetY = self.minPosY
    elseif self.transform.anchoredPosition.y >= self.maxPosY then
        targetY = self.maxPosY
    end

    local targetPos = Unity.Vector3(targetX, targetY, 0)
    if targetPos ~= self.transform.localPosition then
        self:BeginMoveToPos(targetPos)
    else
        self.m_bBeginDrag = false
    end

end

function ActiveThemeEntry:BeginMoveToPos(targetPos)
    self.m_moveLeanTweenId = LeanTween.moveLocal(self.transform.gameObject, targetPos, 0.5):setOnComplete(function()
        self.m_bBeginDrag = false
    end).id
end

function ActiveThemeEntry:OnTotalBetChange()
    if self.bActive then
        if ActiveManager.activeType then
            ActiveBetSizeChangeBar:Show(ActiveManager.unloadedUI.transform)
        end
    else
        self:showEntry()
        if ActiveManager.activeType then
            LeanTween.delayedCall(0.5, function()
                ActiveBetSizeChangeBar:Show(ActiveManager.unloadedUI.transform)
            end)
        end
    end
end

function ActiveThemeEntry:orInMove()
    return self.m_bBeginDrag
end

