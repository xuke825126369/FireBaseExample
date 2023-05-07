local SplashType = {}

SplashType.None = 0
SplashType.FiveInRow = 1 -- 这个加到这里 但是不排队了。。 也不会影响spin按钮的状态。。。
SplashType.BigWin = 2
SplashType.MegaWin = 3
SplashType.EpicWin = 4
SplashType.Jackpot = 5
SplashType.Line = 6

SplashType.CustomWindow = 7 -- 比如SnowWhite关的转轮弹窗..要在其它各种功能窗口前
SplashType.Bonus = 8
SplashType.BonusGameEnd = 9

SplashType.ReSpin = 10
SplashType.ReSpinEnd = 11
SplashType.FreeSpin = 12
SplashType.FreeSpinEnd = 13

SplashType.Wait = 14
SplashType.Max = 15

return SplashType