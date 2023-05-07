require "Lua/Booster/BoostWin/BoostWinEntry"
require "Lua/Booster/BoostWin/BoostWinLock"
require "Lua/Booster/BoostWin/BoostWinUnlock"

require "Lua/Booster/CashBack/CashBackBoosterEntry"
require "Lua/Booster/LevelBurstBooster/LevelBoosterUI"

require "Lua/Booster/RepeatWin/RepeatWinEntry"
require "Lua/Booster/RepeatWin/RepeatWinLock"
require "Lua/Booster/RepeatWin/RepeatWinUnlock"

BoosterEntry = {}
BoosterEntry.m_bBeginDrag = false
BoosterEntry.m_moveLeanTweenId = nil

BoosterEntry.minPosX = nil
BoosterEntry.maxPosX = nil
BoosterEntry.minPosY = nil
BoosterEntry.maxPosY = nil

function BoosterEntry:Show()
    if not LuaHelper.OrGameObjectExist(self.transform) then
        local goPrefab = AssetBundleHandler:LoadAsset("lobby", "BoosterUI/BoosterContainer.prefab")
        local goPanel = Unity.Object.Instantiate(goPrefab)
        self.transform = goPanel.transform:GetComponent(typeof(Unity.RectTransform))
        self.transform:SetParent(UITop.m_transform, false)
        self.transform.localScale = Unity.Vector3.one
        self.transform.localPosition = Unity.Vector3.zero
        LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
        CS.LuaBindMouseBehaviour.Bind(self.transform.gameObject, self)
        self.transform.gameObject:SetActive(false)

        self.m_aniEntryUI = self.transform:GetComponent(typeof(Unity.Animator))
        self.canvasContainer = UITop.m_transform.gameObject:GetComponent(typeof(Unity.Canvas))
        self.transform.anchorMin = Unity.Vector2(0.5, 0.5)
        self.transform.anchorMax = Unity.Vector2(0.5, 0.5)
        Unity.Object.Destroy(self.transform:GetComponent(typeof(Unity.Animator)))
        self.m_boxCollider = self.transform.gameObject:AddComponent(typeof(Unity.BoxCollider2D))
        CashBackBoosterEntry:Init()
    end

    --设置位置
    local portraitFlag = not ScreenHelper:isLandScape()
    local goSceneContainer = self.canvasContainer
    local fy = 210
    local pos = Unity.Vector3(goSceneContainer.transform.sizeDelta.x/2 - 80, -goSceneContainer.transform.sizeDelta.y/2 + fy, 0)
    if portraitFlag then
        pos = Unity.Vector3(goSceneContainer.transform.sizeDelta.x/2 - 80, goSceneContainer.transform.sizeDelta.y/2 - 700, 0)
    end
    
    self.transform.anchoredPosition3D = pos
    self.transform.gameObject:SetActive(true)
    
    local nChildCount = 0
    for i = 0, self.transform.childCount - 1 do
        if self.transform:GetChild(i).gameObject.activeSelf then
            nChildCount = nChildCount + 1
        end
    end
    local size = Unity.Vector2(150, nChildCount * 150)
    self.transform.sizeDelta = size
    
    local x = goSceneContainer.transform.sizeDelta.x / 2
    self.minPosX = x - 200
    self.maxPosX = x - 100
    local y = goSceneContainer.transform.sizeDelta.y / 2
    local portraitFlag = GameLevelUtil:isPortraitLevel()
    local minOffset = 160
    local maxOffset = 100
    self.minPosY = -y + self.transform.sizeDelta.y/2 + minOffset
    self.maxPosY = y - self.transform.sizeDelta.y/2 - maxOffset
    self.m_boxCollider.size = size
end

function BoosterEntry:showEntry()
    local targetPos = self.transform.localPosition
    if targetPos.x <= self.minPosX then
        targetPos = Unity.Vector3(self.minPosX, self.transform.localPosition.y, 0)
    else
        targetPos = Unity.Vector3(self.maxPosX, self.transform.localPosition.y, 0)
    end
    LeanTween.moveLocal(self.transform.gameObject, targetPos, 0.4)
end

function BoosterEntry:hideEntry()
    local targetPos = self.transform.localPosition
    if targetPos.x >= self.maxPosX then
        targetPos = Unity.Vector3(self.maxPosX + 200, self.transform.localPosition.y, 0)
    else
        targetPos = Unity.Vector3(self.minPosX - 200, self.transform.localPosition.y, 0)
    end
    LeanTween.moveLocal(self.transform.gameObject, targetPos, 0.4)
end

function BoosterEntry:onDestroy()
    NotificationHandler:removeObserver(self)
end

function BoosterEntry:onMouseDown()
    self.originPos = self.transform.anchoredPosition
    if GameLevelUtil:is3DModelCurvedLevel() or GameLevelUtil:is3DLevel() then
        local mousePos = Unity.Input.mousePosition
        local uisize = self.canvasContainer.sizeDelta    
        local uiPos = Unity.Vector2((mousePos.x - (Unity.Screen.width / 2))*  (uisize.x / Unity.Screen.width), (mousePos.y - (Unity.Screen.height / 2)) * ( uisize.y / Unity.Screen.height) )
        self.offset = Unity.Vector2(uiPos.x - self.originPos.x, uiPos.y - self.originPos.y)
    else
        local worldPos = Unity.Camera.main:ScreenToWorldPoint(Unity.Input.mousePosition)
        self.offset = self.transform:InverseTransformPoint(worldPos)
    end

    if self.m_moveLeanTweenId then
        if LeanTween.isTweening(self.m_moveLeanTweenId) then
            LeanTween.cancel(self.m_moveLeanTweenId)
        end
    end
end

function BoosterEntry:onMouseDrag()
    -- Unity.RectTransformUtility.ScreenPointToLocalPointInRectangle
    local uiPos = Unity.Vector2.zero
    local mousePos = Unity.Input.mousePosition
    if GameLevelUtil:is3DModelCurvedLevel() or GameLevelUtil:is3DLevel() then
        local uisize = self.canvasContainer.sizeDelta    
        uiPos = Unity.Vector2((mousePos.x - (Unity.Screen.width / 2))*  (uisize.x / Unity.Screen.width), (mousePos.y - (Unity.Screen.height / 2)) * ( uisize.y / Unity.Screen.height) )
    else
        local worldPos = Unity.Camera.main:ScreenToWorldPoint(mousePos)
        uiPos = UITop.m_transform:InverseTransformPoint(worldPos)
    end

    local target = Unity.Vector2(uiPos.x - self.offset.x , uiPos.y - self.offset.y)
    
    local distance = Unity.Vector2.Distance(self.originPos, target)
    if distance >= 20 then
        self.m_bBeginDrag = true
    end
    if self.m_bBeginDrag then
        self.transform.anchoredPosition = target
    end
end

function BoosterEntry:onMouseUp()
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

function BoosterEntry:BeginMoveToPos(targetPos)
    self.m_moveLeanTweenId = LeanTween.moveLocal(self.transform.gameObject, targetPos, 0.5):setOnComplete(function()
        self.m_bBeginDrag = false
    end).id
end
