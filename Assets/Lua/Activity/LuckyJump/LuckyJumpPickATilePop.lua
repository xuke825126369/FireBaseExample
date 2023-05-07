LuckyJumpPickATilePop = {} --包括两个界面，一个是转盘，一个是活动游戏界面
LuckyJumpPickATilePop.m_mapBeginPos = {}
LuckyJumpPickATilePop.m_mapBeginBtn = {}

function LuckyJumpPickATilePop:Show()
    if self.transform.gameObject == nil then
        local path = "Assets/LuckyJump/PickATile.prefab"
        local prefab = Util.getLuckyJumpPrefab(path)
        self.transform.gameObject = Unity.Object.Instantiate(prefab)
        self.transform = self.transform.gameObject.transform
        self.transform:SetParent(LobbyScene.popCanvas, false)
        local btn1 = self.transform:FindDeepChild("BtnBegin1"):GetComponent(typeof(UnityUI.Button))
        local btn2 = self.transform:FindDeepChild("BtnBegin2"):GetComponent(typeof(UnityUI.Button))
        table.insert( self.m_mapBeginBtn, btn1 )
        table.insert( self.m_mapBeginBtn, btn2 )
        -- self.popController = PopController:new(self.transform.gameObject)
        local btnClose = self.transform:FindDeepChild("CloseBtn"):GetComponent(typeof(UnityUI.Button))
        btnClose.onClick:AddListener(function()
            self:onCloseBtnClicked()
        end)
    end
    self:initBeginPosItem()
    -- ViewScaleAni:Show(self.transform.gameObject)
    self.transform.gameObject:SetActive(true)
    self.transform:SetAsLastSibling()
end

function LuckyJumpPickATilePop:onCloseBtnClicked()
    --TODO 显示退出动画

    LeanTween.delayedCall(0.5,function()
        self.transform.gameObject:SetActive(false)
    end)
end

function LuckyJumpPickATilePop:initBeginPosItem()
    for i=1,#self.m_mapBeginPos do
        local str = self.m_mapBeginPos[i][1].."-"..self.m_mapBeginPos[i][2]
        self.m_mapBeginBtn[i].transform.position = LuckyJumpManager.m_mapItem[str].transform.position
        self.m_mapBeginBtn[i].onClick:AddListener(function()
            local pos = {self.m_mapBeginPos[i][1],self.m_mapBeginPos[i][2]}
            LuckyJumpDataHandler.data.initPlayerPos = pos
            LuckyJumpDataHandler:updatePlayerPosition(pos)

            --TODO 显示退出动画
            LeanTween.delayedCall(0.5,function()
                self.transform.gameObject:SetActive(false)
                LuckyJumpManager:setCurPlayerPos(pos)
                LuckyJumpManager:setPlayerPos()
            end)
        end)
    end
end