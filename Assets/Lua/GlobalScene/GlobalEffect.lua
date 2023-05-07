GlobalEffect = {}

function GlobalEffect:Init()
    local bundleName = "Global"
    local assetPath = "Assets/ResourceABs/Global/View/GlobalEffect.prefab"
    local goPrefab = AssetBundleHandler:LoadAsset(bundleName, assetPath)
    local goPanel = Unity.Object.Instantiate(goPrefab)
    
    local goParent = GlobalScene.Canvas_CoinsFly
    self.transform = goPanel.transform
    self.transform:SetParent(goParent, false)
    self.transform.localScale = Unity.Vector3.one
    self.transform.localPosition = Unity.Vector3.zero
    LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
    self.transform.gameObject:SetActive(true)
end