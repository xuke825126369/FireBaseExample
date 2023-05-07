local Menu_LevelUI = {}

function Menu_LevelUI:new(go, nIndex, onClickFunc)
    local o = {}
	setmetatable(o, self)
	self.__index = self
    o:init(go, nIndex, onClickFunc)
    return o
end

function Menu_LevelUI:init(go, nIndex, onClickFunc)
    local tr = go.transform
    self.nIndex = nIndex
    self.goFinished = tr:FindDeepChild("Finished").gameObject
    self.goReward = tr:FindDeepChild("Reward").gameObject
    self.goLocked = tr:FindDeepChild("Locked").gameObject
    self.goCurrent = tr:FindDeepChild("Current").gameObject

    self.textCoins = tr:FindDeepChild("Reward/Coins/textCoinCount"):GetComponent(typeof(UnityUI.Text))
    local go = tr:FindDeepChild("Reward/SlotsCards").gameObject
    self.cardPackUI = CardPackUI:new(go)

    self.textSpinLeft = tr:FindDeepChild("Current/WheelSpin/Number"):GetComponent(typeof(UnityUI.Text))

    local spinBtns = tr:FindDeepChild("Current/Button"):GetComponent(typeof(UnityUI.Button))
    spinBtns.onClick:AddListener(onClickFunc)
    DelegateCache:addOnClickButton(spinBtns)
end

function Menu_LevelUI:set(nLevel, nCoin, nCardPackType, nCardPackCount, nAction)
    self.goFinished:SetActive(self.nIndex < nLevel)
    self.goReward:SetActive(self.nIndex >= nLevel)
    self.goLocked:SetActive(self.nIndex > nLevel)
    self.goCurrent:SetActive(self.nIndex == nLevel)
    self.textCoins.text = MoneyFormatHelper.coinCountOmit(nCoin)
    self.cardPackUI:set(nCardPackType, nCardPackCount)
    self.textSpinLeft.text = "SPIN LEFT:"..nAction
end

return Menu_LevelUI