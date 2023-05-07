require("Lua/LobbyScene/LobbyScene")
require("Lua/GlobalScene/GlobalScene")

SceneHandler = {}

function SceneHandler:Init()
    GlobalScene:Init()
    LobbyScene:Init()
end
