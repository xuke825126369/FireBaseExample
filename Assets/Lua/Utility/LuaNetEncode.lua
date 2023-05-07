LuaNetEncode = {}

function LuaNetEncode:Encode(protobufPackageName, mSendData)
    if false then
        return rapidjson.encode(mSendData)
    else
        return pb.encode(protobufPackageName, mSendData)
    end
end
