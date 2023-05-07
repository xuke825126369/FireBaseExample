SlotsCardsPrizesPop = {}
SlotsCardsPrizesPop.m_trContent = nil
SlotsCardsPrizesPop.m_listLeanTweenIds = {}

SlotsCardsPrizesPop.m_btnLeft = nil
SlotsCardsPrizesPop.m_btnRight = nil

local nCurIndex = 1
local fLastMousePosX = 0
local bIsMoving = false

function SlotsCardsPrizesPop:Show()
    if not LuaHelper.OrGameObjectExist(self.transform) then
        local goPrefab = AssetBundleHandler:LoadSlotsCardsAsset("PrizeIntroducePop.prefab")
        local goPanel = Unity.Object.Instantiate(goPrefab)
        self.transform = goPanel.transform
        self.transform:SetParent(LobbyScene.popCanvas, false)
        self.transform.localScale = Unity.Vector3.one
        self.transform.localPosition = Unity.Vector3.zero
        LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
        self.transform.gameObject:SetActive(false)

        self.m_trContent = self.transform:FindDeepChild("InfoContent")
        self.m_trCurrentContainer = self.transform:FindDeepChild("pageCurrent")

        local btn = self.transform:FindDeepChild("BtnClose"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(btn)
        btn.onClick:AddListener(function()
            SlotsCardsAudioHandler:PlaySound("click")
            self:Hide()
        end)
        self.m_btnLeft = self.transform:FindDeepChild("BtnLeft"):GetComponent(typeof(UnityUI.Button))
        self.m_btnRight = self.transform:FindDeepChild("BtnRight"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(self.m_btnLeft)
        DelegateCache:addOnClickButton(self.m_btnRight)
        self.m_btnLeft.onClick:AddListener(function()
            self:changeIndex(-1)
        end)
        self.m_btnRight.onClick:AddListener(function()
            self:changeIndex(1)
        end)
    end

    self.m_trCurrentContainer:GetChild(nCurIndex-1).gameObject:SetActive(false)
    nCurIndex = 1
    self:refreshBtnStatus()
    fLastMousePosX = 0
    bIsMoving = false
    self.m_trContent.anchoredPosition = Unity.Vector2.zero
    self.m_trCurrentContainer:GetChild(nCurIndex-1).gameObject:SetActive(true)
    ViewScaleAni:Show(self.transform.gameObject)
end

function SlotsCardsPrizesPop:Hide()
    LuaHelper.CancelLeanTween(self.m_listLeanTweenIds)
	self.m_listLeanTweenIds = {}
    ViewScaleAni:Hide(self.transform.gameObject)
end

function SlotsCardsPrizesPop:beginMoving()
    bIsMoving = true
    self.m_btnLeft.gameObject:SetActive(false)
    self.m_btnRight.gameObject:SetActive(false)
    
    local id = LeanTween.moveX(self.m_trContent, -1920 * (nCurIndex - 1), 0.5):setOnComplete(function()
        bIsMoving = false
        self:refreshBtnStatus()
    end).id
    table.insert( self.m_listLeanTweenIds, id )
end

function SlotsCardsPrizesPop:changeIndex(count)
    SlotsCardsAudioHandler:PlaySound("click")
    self.m_trCurrentContainer:GetChild(nCurIndex-1).gameObject:SetActive(false)
    nCurIndex = nCurIndex + count
    self.m_trCurrentContainer:GetChild(nCurIndex-1).gameObject:SetActive(true)
    self:beginMoving()
end

function SlotsCardsPrizesPop:refreshBtnStatus()
    if nCurIndex == 1 then
        self.m_btnLeft.gameObject:SetActive(false)
        self.m_btnRight.gameObject:SetActive(true)
    elseif nCurIndex == 6 then
        self.m_btnLeft.gameObject:SetActive(true)
        self.m_btnRight.gameObject:SetActive(false)
    else
        self.m_btnLeft.gameObject:SetActive(true)
        self.m_btnRight.gameObject:SetActive(true)
    end
end