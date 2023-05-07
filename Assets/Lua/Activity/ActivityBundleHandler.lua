ActivityAudioHandler = CommonAudioHandler:New()

function ActivityAudioHandler:InitActivityAudio()
    local name = "~ActivityAudioHandler"
    local bundleName = "Activity_"..ActiveManager.activeType
    local assetPathDir = "Assets/ResourceABs/Activity/"..ActiveManager.activeType.."/"
    local tableLoadAudioInfo = {
        {bundleName = bundleName, assetPathDir = assetPathDir}
    }
    
    self:Init(name, tableLoadAudioInfo)
end

ActivityBundleHandler = DelayLoadBundleHandlerGenerator:New()
function ActivityBundleHandler:InitBundleInfo()
    local bundleName = ActiveManager:GetBundleName()
    self:Init(bundleName, ActivityAudioHandler)
end