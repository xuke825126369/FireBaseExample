require("Lua/ThridLuaPlugin/thirdplugin")

require("Lua/Utility/CSharpApiToLua")
require("Lua/Utility/LuaAutoBindMonoBehaviour")
require("Lua/Utility/LogManager")
require("Lua/Utility/LuaHelper")
require("Lua/Utility/LuaUtil")
require("Lua/Utility/DelegateCache")
require("Lua/Utility/NumberAddLuaAni")

require("Lua/Utility/UnityCoroutine")
require("Lua/Utility/CoroutineHelper")
require("Lua/Utility/MoneyFormatHelper")
require("Lua/Utility/LeanTweenHelper")
require("Lua/Utility/NumberTween")

require("Lua/CFG/BuyCFG")
require("Lua/CFG/GameConst")
require("Lua/CFG/enumThemeType")
require("Lua/CFG/FormulaHelper")
require("Lua/CFG/EventName")
require("Lua/CFG/SkuInfoType")

require("Lua/Handler/CommonDbHandler")
require("Lua/Handler/DownloadStatus")
require("Lua/Handler/enumLoginType")
require("Lua/Handler/AssetBundleHandler")
require("Lua/Handler/EventHandler")
require("Lua/Handler/AtlasHandler")
require("Lua/Handler/SettingHandler")
require("Lua/Handler/SceneHandler")
require("Lua/Handler/GlobalAudioHandler")
require("Lua/Handler/ThemeLoader")
require("Lua/Handler/ScreenHelper")
require("Lua/Handler/AdsConfigHandler")
require("Lua/Handler/GameHelper")
require("Lua/Handler/CommonAudioHandler")
require("Lua/Handler/TimeHandler")
require("Lua/Handler/DelayLoadBundleHandlerGenerator")

require("Lua/Handler/UserInfoHandler")
require("Lua/Handler/PlayerHandler")
require("Lua/Handler/GMGiftHandler")
require("Lua/Handler/LocalDbHandler")

require("Lua/Handler/GlobalTempData")
require("Lua/Handler/VipHandler")
require("Lua/Handler/PopStackViewHandler")
require("Lua/Handler/CSharpVersionHandler")
require("Lua/Handler/NewUserHandler")

require("Lua/Handler/ThemeHelper")
require("Lua/Handler/ThemeLoader")
require("Lua/Handler/ThemeConfigModifyHandler")
require("Lua/Handler/ThemeAllDataHandler")
require("Lua/Handler/ThemeSingleLevelDataHandler")
require("Lua/Handler/ThemeReturnRateDyncmaicSwitch")
require("Lua/Handler/ThemeUnLockHandler")

require("Lua/Handler/FireBaseLoginHandler")
require("Lua/Handler/RechargeHandler")
require("Lua/Handler/AppAdsEventHandler")
require("Lua/Handler/AppLocalEventHandler")

require("Lua/SdkHandler/UnityPurchasingHandler")
require("Lua/SdkHandler/GoogleAdsHandler")
require("Lua/Handler/SystemAwardHandler")
require("Lua/Handler/BonusHandler")

require("Lua.Activity.ActiveManager")
require("Lua/Activity/PickBonus/PickBonusManager")
require("Lua/Activity/SlotsCards2020/SlotsCardsManager")
require("Lua/Activity/Lounge/LoungeManager")

require("Lua/LobbyScene/Store/BuyHandler")
require("Lua/LobbyScene/FlashSale/FlashSaleHandler")
require("Lua/LobbyScene/FreeBonusGame/FreeBonusGameHandler")
require("Lua/LobbyScene/Inbox/InBoxHandler")

require("Lua/LobbyScene/Missions/DailyMission/DailyMissionHandler")
require("Lua/LobbyScene/Missions/RoyalPass/RoyalPassHandler")
require("Lua/LobbyScene/Missions/LuckyEgg/LuckyEggHandler")
require("Lua/LobbyScene/Missions/FlashChallenge/FlashChallengeHandler")
require("Lua/LobbyScene/DailyBonus/DailyBonusDataHandler")

require("Lua/Booster/BoostHandler")

require("Lua/Effect/GoPool")
require("Lua/Effect/CoinFly")
require("Lua/Effect/ViewAlphaAni")
require("Lua/Effect/ViewScaleAni")

math.randomseed(TimeHandler:GetTimeStamp())
Debug.SetPrefix("Client")
Debug.SetOpen()

Main = {}
function Main:Init()
    Unity.Camera.main.nearClipPlane = 1;
    Unity.Camera.main.farClipPlane = 5000;
    Debug.LogWithColor("屏幕分辨率: "..Unity.Screen.currentResolution:ToString())
    Debug.LogWithColor("屏幕宽高: "..Unity.Screen.width.." | "..Unity.Screen.height)
    
    UserInfoHandler:Init()
    PlayerHandler:Init()
    TimeHandler:Init()
    GMGiftHandler:Init()
    LocalDbHandler:Init()

    GlobalAudioHandler:Init()
    SceneHandler:Init()
    self:Test()
end

function Main:Release()
    
end

function Main:Test()
    -- for i = 1, 1000 do
    --     ThemeReturnRateHelper:AutoGetTableFeatureSpinCountRate1()
    -- end
end



