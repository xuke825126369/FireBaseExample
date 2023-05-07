CSharpVersionHandler = {}
CSharpVersionHandler.nAwardMoneyCount = 1000000
--------------------------------------------

function CSharpVersionHandler:orCSharpVersionDiff()
    if CS.GameBootConfig.Instance.mCSharpVersionConfig == nil then
        return false
    end 

    local versionList = CS.GameBootConfig.Instance.mCSharpVersionConfig.versionList
    for i = 0, versionList.Count - 1 do
        if tonumber(versionList[i]) > tonumber(Unity.Application.version) then
            return true
        end
    end 
    
    return false
end
