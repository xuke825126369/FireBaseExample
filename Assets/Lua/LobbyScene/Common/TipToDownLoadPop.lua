

TipToDownLoadPop = {}

TipToDownLoadPop.themeKeyDownloadInfo = {
    GoldMine = 9.6,
    GoldenVegas = 8.5,
    CrazyDollar = 9.8,
    ReelOfDragon = 10.5,
    MaYa = 7.2,
    DireWolf = 7.9,
    MagicLink = 8.3,
    PhoenixOfFire = 8.1,
    ReelFortunes = 10.2,
    DoggyAndDiamond = 8.8,
    SafariKing = 9.3,
    HappyChristmas = 8.6,
    BierMania = 6.9,
    Cleopatra = 10.3,
    GrannyWolf = 11.3,
    FuLink = 7.2,
    WildToro = 8.9,
    RhinoMania = 9.1,
}

function TipToDownLoadPop:createAndShow(themeKey)
    if(not self.gameObject) then
        self.tableName = "TipToDownLoadPop"
        self.gameObject = Unity.Object.Instantiate(Util.getHotPrefab("Assets/BaseHotAdd/Prefabs/TipToDownLoadPop.prefab"))
        self.transform = self.gameObject.transform
        self.transform:SetParent(LobbyScene.popCanvas, false)
        self.popController = PopController:new(self.gameObject)
        local btn = self.transform:FindDeepChild("CloseButton"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(btn)   
        btn.onClick:AddListener(function()
            self:onCloseBtnClicked()
        end)
        self.downloadText = self.transform:FindDeepChild("DownloadInfo"):GetComponent(typeof(TextMeshProUGUI))

        self.btnDownload = self.transform:FindDeepChild("DownloadBtn"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(self.btnDownload)   
        self.btnDownload.onClick:AddListener(function()
            self:onDownLoadBtnClicked()
        end)
    end
    self.themeKey = themeKey
    local size = self.themeKeyDownloadInfo[themeKey]
    if size == nil then
        size = 9.4
    end
    self.downloadText.text = "Needs to download resource to play this theme, the data size is "..size.."MB"
    self.btnDownload.interactable = true
    ViewScaleAni:Show(self.transform.gameObject)
end

function TipToDownLoadPop:onCloseBtnClicked()
    GlobalAudioHandler:PlayBtnSound()
    ViewScaleAni:Hide(self.transform.gameObject)
end

function TipToDownLoadPop:onDownLoadBtnClicked()
    self.btnDownload.interactable = false
    GlobalAudioHandler:PlayBtnSound()
    ThemeAssetBundleHandler:downloadAssetBundle(self.themeKey)
    self.popController:hide(true)
end

