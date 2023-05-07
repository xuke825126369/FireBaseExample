SlotsCardsGetCardsPop = {}
SlotsCardsGetCardsPop.m_btnCollect = nil
SlotsCardsGetCardsPop.m_btnCheck = nil
SlotsCardsGetCardsPop.m_trCardsContainer = nil
SlotsCardsGetCardsPop.m_trGetTextAni = nil
SlotsCardsGetCardsPop.cardItems = {}
SlotsCardsGetCardsPop.m_ImgPackTop = nil
SlotsCardsGetCardsPop.m_goPackBottom = nil
SlotsCardsGetCardsPop.m_bIsShow = true

function SlotsCardsGetCardsPop:Show(data, params)
    if self.transform.gameObject == nil then
        self.m_bInitFlag = false
    else
        if self.transform.gameObject:Equals(nil) then
            self.m_bInitFlag = false
        end
    end

    if not self.m_bInitFlag then
        if self.transform ~= nil then
            Unity.GameObject.Destroy(self.transform.gameObject)
        end

        self.m_bInitFlag = true

        local strPath ="SlotsCardsGetCardsPop.prefab"
        local prefabObj = AssetBundleHandler:LoadSlotsCardsAsset(strPath)
        self.transform.gameObject = Unity.Object.Instantiate(prefabObj)
        self.transform = self.transform.gameObject.transform
        self.transform:SetParent(LobbyScene.popCanvas, false)
        self.popController = PopController:new(self.transform.gameObject, PopPriority.middlePriority)
        LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
    
    
        self.m_trCardsContainer = self.transform:FindDeepChild("CardContainer")
        self.m_trGetTextAni = self.transform:FindDeepChild("GetTextAni")
        self.m_trContent = self.transform:FindDeepChild("Content")
    
        self.m_goPackBottom = self.transform:FindDeepChild("Packcontent")
        self.m_ImgPackTop = self.transform:FindDeepChild("PackTop"):GetComponent(typeof(UnityUI.Image))
    
        self.m_btnCollect = self.transform:FindDeepChild("BtnCollect"):GetComponent(typeof(UnityUI.Button))
        self.m_btnCheck = self.transform:FindDeepChild("BtnCheck"):GetComponent(typeof(UnityUI.Button))
        self.btnCheckOriPos = self.m_btnCheck.transform.anchoredPosition
    
        DelegateCache:addOnClickButton(self.m_btnCheck)
        self.m_btnCheck.onClick:AddListener(function()
            SlotsCardsAudioHandler:PlaySound("click")
            self:onCheckBtnClicked()
        end)
        DelegateCache:addOnClickButton(self.m_btnClose)
        self.m_btnClose = self.transform:FindDeepChild("BtnClose"):GetComponent(typeof(UnityUI.Button))
        self.m_btnClose.onClick:AddListener(function()
            SlotsCardsAudioHandler:PlaySound("click")
            self:Hide()
        end)
    end
    
    self.popController:show(nil, function()
        SlotsCardsAudioHandler:PlaySound("stamp_pack_pop")
        self:initContent(data)
    end, true)
end

local delay = 1
local showBtnActionId = 0
local hideActionId = 0

function SlotsCardsGetCardsPop:initContent(data, strGift, strAccess)
    local path = "zu.png"
    local sprite = AssetBundleHandler:LoadSlotsCardsAsset(path,typeof(Unity.Sprite))
    self.m_ImgPackTop.sprite = sprite
    self.m_ImgPackTop:SetNativeSize()

    self.m_btnClose.interactable = true
    self.m_btnCheck.gameObject:SetActive(false)
    self.m_btnClose.gameObject:SetActive(false)
    
    --如果不是第一次出现，删除上一次的cards
    if #self.cardItems ~= 0 then
        for k,v in pairs(self.cardItems) do
            Unity.Object.Destroy(v.gameObject)
        end
        self.cardItems = {}
    end
    self.m_trGetTextAni.gameObject:SetActive(false)
    self.m_btnCollect.gameObject:SetActive(false)
    delay = 0
    self:collectBtnClicked(data, strGift)
end

function SlotsCardsGetCardsPop:OnDestroy()
    
end

function SlotsCardsGetCardsPop:onCheckBtnClicked()
    self.m_btnCheck.interactable = false
    self.m_btnClose.interactable = false
    self:Hide()
end

function SlotsCardsGetCardsPop:Hide()
    if LeanTween.isTweening(showBtnActionId) then
        LeanTween.cancel(showBtnActionId)
    end
    if LeanTween.isTweening(hideActionId) then
        LeanTween.cancel(hideActionId)
    end
    
    self.m_btnCheck.interactable = false
    self.m_btnClose.interactable = false
    ViewScaleAni:Hide(self.transform.gameObject)

    if ThemeLoader.themeKey ~= nil then
        SlotsGameLua.m_bReelPauseFlag = false
    end
    -- SlotsCardsHandler:checkThemeEnd()
    -- LeanTween.delayedCall(0.6, function()
    --     if self.transform ~= nil then
    --         Unity.Object.Destroy(self.transform.gameObject)
    --     end
    -- end)
end

function SlotsCardsGetCardsPop:collectBtnClicked(data, strGift)
    self.m_btnClose.gameObject:SetActive(true)
    self.m_trGetTextAni.gameObject:SetActive(false)

    self.m_btnCollect.gameObject:SetActive(false)
    self.m_btnCollect.onClick:RemoveAllListeners()
    self.m_btnCollect.interactable = false

    local cardCount = #data
    local offset = 250
    if cardCount > 6 then
        offset = -100 / 6 * cardCount + 350
        if offset < 150 then
            offset = 150
        end
    end

    local bPortraitFlag = false
    if ThemeLoader.themeKey ~= nil then
        bPortraitFlag = not ScreenHelper:isLandScape() and (not BuyView:isActiveShow())
        if bPortraitFlag then
            offset = 200
            -- offset = -100 / 6 * cardCount + 300
        end
    end
    local map = {} --map = {4,4,5} 表示有3行，每行的成员个数
    local rowCount = bPortraitFlag and math.ceil( #data / 6 ) or math.ceil( #data / 12 ) --以6为一行，计算有几行
    local tatal = 0
    for i=1,rowCount do
        local memberCount = math.ceil( #data / rowCount )
        tatal = tatal + memberCount
        table.insert( map, memberCount )
    end
    if tatal > #data then
        local dValue = tatal - #data
        for i=1,dValue do
            if i > #map then
                i = i - #map
            end
            map[i] = map[i] - 1
        end
    end
    --TODO 重新生成获得的卡牌，做动画
    for k,v in pairs(data) do
        local count = #data --指这一行有几个
        local row = 1 --第几行
        local n = k --第几个
        if bPortraitFlag then
            while n > map[row] do
                n = n - map[row]
                row = row + 1
                if map[row] == nil then
                    break
                end
            end
            count = map[row] ~= nil and map[row] or map[row - 1]
        else
            while n > map[row] do
                n = n - map[row]
                row = row + 1
                if map[row] == nil then
                    break
                end
            end
            count = map[row] ~= nil and map[row] or map[row - 1]
        end
        local fx = (count - 1) * offset/2 - (n - 1) * offset
        local fy = -40 - (row - 1) * 296
        if bPortraitFlag and #data > 6 then
            fy = 75 - (row - 1) * 224
        elseif not bPortraitFlag and #data > 12 then
            fy = 68 - (row - 1) * 216
        end
        local targetPos = Unity.Vector3(fx, fy, 0) --计算卡牌位置
        local maxOffset = (k-1) * 100 + 300
        local path = "Card.prefab"
        local prefab = AssetBundleHandler:LoadSlotsCardsAsset(path)
        local card = Unity.Object.Instantiate(prefab).transform
        
        card:SetParent(self.m_trCardsContainer)
        card.localScale = Unity.Vector3.zero
        card.anchoredPosition3D = Unity.Vector3.zero
        card.localRotation = Unity.Quaternion.Euler(0,0,0)
        local cardItem = ShowCard:new(card.gameObject, SlotsCardsManager.album, v.themeKey, v.cardKey)
        cardItem:showBackBG()
        cardItem:showFlyAni(delay, targetPos, maxOffset, cardCount)
        delay = delay + 0.5
        table.insert(self.cardItems, cardItem)
    end
    if bPortraitFlag then
        self.m_btnCheck.transform.anchoredPosition = Unity.Vector2(self.btnCheckOriPos.x, self.btnCheckOriPos.y - (math.ceil( #data / 6 ) - 1) * 224)
    else
        if math.ceil( #data / 12 ) > 1 then
            self.m_btnCheck.transform.anchoredPosition = Unity.Vector2(self.btnCheckOriPos.x, self.btnCheckOriPos.y - 30) 
        else
            self.m_btnCheck.transform.anchoredPosition = self.btnCheckOriPos
        end
    end
    delay = delay + (#data + 1) * 0.5
    local showBtnAction = LeanTween.delayedCall(0.5 + delay, function()
        if self.transform ~= nil then
            self.m_btnCheck.gameObject:SetActive(true)
            self.m_btnCheck.interactable = true
            
            if strGift == SlotsCardsGiftManager.GiftTable[1] then
                local hideAction = LeanTween.delayedCall(2, function()
                    self:Hide()
                end)
                hideActionId = hideAction.id
                -- Debug.Log("hideActionID ----------- ".. hideActionId)
            end
        end
    end)
    showBtnActionId = showBtnAction.id
    -- Debug.Log("showBtnAction -------- ".. showBtnActionId)
end