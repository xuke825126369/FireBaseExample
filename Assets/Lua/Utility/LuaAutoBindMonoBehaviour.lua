LuaAutoBindMonoBehaviour = {}
LuaAutoBindMonoBehaviour.checkTable = {}

function LuaAutoBindMonoBehaviour.Bind(gameObj, mLuaTable)
    if type(mLuaTable) ~= "table" then
        Debug.LogError("mLuaTable Type Error: "..type(mLuaTable))
    end
    
    if LuaAutoBindMonoBehaviour:CheckBindHaveError(gameObj, mLuaTable) then
        return
    end

    local bHave_StartMethond = mLuaTable["Start"] and type(mLuaTable["Start"]) == "function"
    local bHave_OnDisableMethond = mLuaTable["OnDisable"] and type(mLuaTable["OnDisable"]) == "function"
    local bHave_OnDestroyMethond = mLuaTable["OnDestroy"] and type(mLuaTable["OnDestroy"]) == "function"
    local bHave_UpdateMethond = mLuaTable["Update"] and type(mLuaTable["Update"]) == "function"
    local bHave_LateUpdateMethond = mLuaTable["LateUpdate"] and type(mLuaTable["LateUpdate"]) == "function"
     
    local bHave_OnApplicationFocusMethond = mLuaTable["OnApplicationFocus"] and type(mLuaTable["OnApplicationFocus"]) == "function"
    local bHave_OnApplicationPauseMethond = mLuaTable["OnApplicationPause"] and type(mLuaTable["OnApplicationPause"]) == "function"

    local lastBindBehaviour = nil
    if bHave_StartMethond or bHave_OnDestroyMethond or bHave_OnDisableMethond then
        lastBindBehaviour = CS.LuaBindBasicMonoBehaviour.Bind(gameObj, mLuaTable)
    end
    
    if bHave_UpdateMethond then
        lastBindBehaviour = CS.LuaBindUpdateMonoBehaviour.Bind(gameObj, mLuaTable)
    end 

    if bHave_LateUpdateMethond then
        lastBindBehaviour = CS.LuaBindOtherUpdateLuaBehaviour.Bind(gameObj, mLuaTable)
    end

    if bHave_OnApplicationFocusMethond or bHave_OnApplicationPauseMethond then
        lastBindBehaviour = CS.LuaBindApplicationBehaviour.Bind(gameObj, mLuaTable)
    end

    if not lastBindBehaviour then
        lastBindBehaviour = CS.LuaBindEmptyMonoBehaviour.Bind(gameObj, mLuaTable)
    end 

    return lastBindBehaviour
end

function LuaAutoBindMonoBehaviour.UnBind(gameObj, mLuaTable)
    CS.LuaBindMonoBehaviourBase.UnBind(gameObj, mLuaTable)
end

function LuaAutoBindMonoBehaviour.UnBindAll(gameObj)
    CS.LuaBindMonoBehaviourBase.UnBindAll(gameObj)
end

function LuaAutoBindMonoBehaviour:CheckBindHaveError(gameObj, mLuaTable)
    if self.checkTable[mLuaTable] then
        if self.checkTable[mLuaTable] == gameObj then
            Debug.Assert(false, "重复的Lua绑定: "..gameObj.name)
            return true
        end
    end
    self.checkTable[mLuaTable] = gameObj
    return false
end

