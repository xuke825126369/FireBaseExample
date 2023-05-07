CookingFeverConfig = {}
CookingFeverConfig.N_MAX_LEVEL = 5 --从1开始
CookingFeverConfig.N_MAX_ACTION = 100 --硬币上限
CookingFeverConfig.N_INGREDIENT = 54 --配料种类
CookingFeverConfig.N_DISH = 18 --菜的种类
CookingFeverConfig.tableBasketPrice = {5, 10, 20} --买原材料的篮子的价格

CookingFeverConfig.Dishes = {
    HotDog = 1, 
    Noodle = 2,

    MisoSoup = 3, 
    FishFillets = 4,
    Pizza = 5,

    ChickenRoll = 6,
    BeefSashimi = 7,
    ApplePie = 8,
    Escargot = 9,

    Pancake = 10,
    Gyoza = 11,
    CubanMojoChicken = 12,
    BasilPestoPasta = 13, --罗勒松子意面

    HomemadeSoup = 14,
    Sukiyaki = 15,
    FrenchBeef = 16,
    StirFryVegetables = 17,
    Tempura = 18,
}

CookingFeverConfig.Ingredients = {
    Apple = 1, 
    Avocado = 2, --牛油果
    Lemon = 3, 
    Orange = 4,
    Asparagus = 5, --芦笋
    Broccoli = 6, --西兰花
    Carrot = 7,
    Celery = 8, --法国香菜
    Rosemary = 9, --迷迭香
    Garlic = 10,
    Mushroom = 11,
    Kelp = 12,
    Basil = 13, --罗勒
    Potato = 14,
    SweetPepper = 15,
    Beef = 16,
    Fish = 17,
    Drumsticks = 18,
    Prawn = 19, --对虾
    RawEscargot = 20,
    Biscuits = 21,
    Flour = 22,
    Bread = 23,
    PineapleBun = 24,
    RawNoodle = 25,
    Rice = 26,
    Tofu = 27,
    Onion = 28,
    Tomato = 29,
    Chilli = 30,
    Milk = 31,
    Butter = 32,
    Mozzarella = 33, --奶酪
    Cheese = 34,
    Sausage = 35,
    Eggs = 36,
    Ketchup = 37,
    Cream = 38,
    Mustard = 39, --黄芥末
    Honey = 40,
    Wasabi = 41, --山葵
    Salt = 42,
    SoySauce = 43,
    Pepper = 44,
    CuminPowder = 45,
    Water = 46,
    ChopingBoard = 47,
    Chopsticks = 48,
    Bowl = 49,
    Colander = 50, --滤水器
    FryingPan = 51,
    Pan = 52,
    Pot = 53,
    ServingTray = 54,
}

--资源名称
function CookingFeverConfig:getDishNameById(nId)
    if self.tableDishName == nil then
        self.tableDishName = {}
        for k, v in pairs(CookingFeverConfig.Dishes) do
            self.tableDishName[v] = k
        end
    end
    return self.tableDishName[nId]
end

function CookingFeverConfig:getIngredientNameById(nId)
    if self.tableIngredientName == nil then
        self.tableIngredientName = {}
        for k, v in pairs(CookingFeverConfig.Ingredients) do
            self.tableIngredientName[v] = k
        end
    end
    return self.tableIngredientName[nId]
end

--UI上显示的名字
function CookingFeverConfig:getInredientUIName(nId)
    if nId == CookingFeverConfig.Ingredients.RawNoodle then
        return "Noodle"
    elseif nId == CookingFeverConfig.Ingredients.Mozzarella then
        return "Cheese"
    elseif nId == CookingFeverConfig.Ingredients.Pepper then
        return "Pepper"
    elseif nId == CookingFeverConfig.Ingredients.CuminPowder then
        return "Curry Powder"
    elseif nId == CookingFeverConfig.Ingredients.ChopingBoard then
        return "Choping Board"
    elseif nId == CookingFeverConfig.Ingredients.ServingTray then
        return "Serving Tray"
    elseif nId == CookingFeverConfig.Ingredients.PineapleBun then
        return "Bread"
    elseif nId == CookingFeverConfig.Ingredients.RawEscargot then
        return "Escargot"
    else
        return self:getIngredientNameById(nId)
    end
end

--菜谱
CookingFeverConfig.Recipe = {
    ----------Level 1----------
    [CookingFeverConfig.Dishes.HotDog] = 
    {
        Ingredient = 
        {
            CookingFeverConfig.Ingredients.Sausage,
            CookingFeverConfig.Ingredients.Bread,
            CookingFeverConfig.Ingredients.Ketchup,
            CookingFeverConfig.Ingredients.Mustard,
            CookingFeverConfig.Ingredients.Orange, 
        },
        Count = 
        {
            1,2,1,1,1
        }
    },

    [CookingFeverConfig.Dishes.Noodle] = 
    {
        Ingredient = 
        {
            CookingFeverConfig.Ingredients.RawNoodle,
            CookingFeverConfig.Ingredients.Sausage,
            CookingFeverConfig.Ingredients.Carrot,
            CookingFeverConfig.Ingredients.Water, 
            CookingFeverConfig.Ingredients.Biscuits,
        },
        Count = 
        {
            3,1,2,2,1
        }
    },
    ----------Level 2----------
    [CookingFeverConfig.Dishes.MisoSoup] = 
    {
        Ingredient = 
        {
            CookingFeverConfig.Ingredients.Tofu,
            CookingFeverConfig.Ingredients.Kelp,
            CookingFeverConfig.Ingredients.Water,                
            CookingFeverConfig.Ingredients.Orange,
            CookingFeverConfig.Ingredients.Bowl,
            CookingFeverConfig.Ingredients.Chopsticks,
        },
        Count = 
        {
            2,1,5,1,1,1
        }
    },

    [CookingFeverConfig.Dishes.FishFillets] = 
    {
        Ingredient = 
        {
            CookingFeverConfig.Ingredients.Fish, 
            CookingFeverConfig.Ingredients.Butter,
            CookingFeverConfig.Ingredients.Asparagus, 
            CookingFeverConfig.Ingredients.Lemon,
            CookingFeverConfig.Ingredients.Pepper,
            CookingFeverConfig.Ingredients.FryingPan,
        },
        Count = 
        {
            3,2,1,1,1,1
        }
    },

    [CookingFeverConfig.Dishes.Pizza] = 
    {
        Ingredient = 
        {
            CookingFeverConfig.Ingredients.Flour, 
            CookingFeverConfig.Ingredients.Butter,
            CookingFeverConfig.Ingredients.Tomato,
            CookingFeverConfig.Ingredients.Ketchup,
            CookingFeverConfig.Ingredients.Water,
            CookingFeverConfig.Ingredients.Basil,
        },
        Count = 
        {
            5,2,1,2,1,1
        }
    },
    ----------Level 3----------
    [CookingFeverConfig.Dishes.ChickenRoll] = 
    {
        Ingredient = 
        {
            CookingFeverConfig.Ingredients.Flour, 
            CookingFeverConfig.Ingredients.Drumsticks,
            CookingFeverConfig.Ingredients.Tomato,
            CookingFeverConfig.Ingredients.Carrot,
            CookingFeverConfig.Ingredients.SweetPepper,
            CookingFeverConfig.Ingredients.Ketchup,
            CookingFeverConfig.Ingredients.Basil,
        },
        Count = 
        {
            5,1,2,2,1,1,1
        }
    },

    [CookingFeverConfig.Dishes.BeefSashimi] = 
    {
        Ingredient = 
        {
            CookingFeverConfig.Ingredients.Beef,
            CookingFeverConfig.Ingredients.Eggs,
            CookingFeverConfig.Ingredients.Celery,
            CookingFeverConfig.Ingredients.Orange,
            CookingFeverConfig.Ingredients.Pepper, 
            CookingFeverConfig.Ingredients.Wasabi,
            CookingFeverConfig.Ingredients.SoySauce,
        },
        Count = 
        {
            5,2,1,1,1,1,1
        }
    },

    [CookingFeverConfig.Dishes.ApplePie] = 
    {
        Ingredient = 
        {
            CookingFeverConfig.Ingredients.Flour, 
            CookingFeverConfig.Ingredients.Butter,
            CookingFeverConfig.Ingredients.Eggs,
            CookingFeverConfig.Ingredients.Milk,
            CookingFeverConfig.Ingredients.Apple,
            CookingFeverConfig.Ingredients.Lemon,
            CookingFeverConfig.Ingredients.Cream,
        },
        Count = 
        {
            3,1,2,1,2,1,1
        }
    },

    [CookingFeverConfig.Dishes.Escargot] = 
    {
        Ingredient = 
        {
            CookingFeverConfig.Ingredients.RawEscargot,
            CookingFeverConfig.Ingredients.Butter, 
            CookingFeverConfig.Ingredients.Garlic,
            CookingFeverConfig.Ingredients.Lemon,
            CookingFeverConfig.Ingredients.Basil,
            CookingFeverConfig.Ingredients.Pepper,
            CookingFeverConfig.Ingredients.Salt,
        },
        Count = 
        {
            6,2,1,1,1,1,1
        }
    },
    ----------Level 4----------
    [CookingFeverConfig.Dishes.Pancake] = 
    {
        Ingredient = 
        {
            CookingFeverConfig.Ingredients.Flour, 
            CookingFeverConfig.Ingredients.Butter,
            CookingFeverConfig.Ingredients.Eggs,
            CookingFeverConfig.Ingredients.Milk,
            CookingFeverConfig.Ingredients.Water,
            CookingFeverConfig.Ingredients.Honey,
            CookingFeverConfig.Ingredients.Lemon,
            CookingFeverConfig.Ingredients.Pan,
        },
        Count = 
        {
            5,1,2,2,2,1,1,1
        }
    },

    [CookingFeverConfig.Dishes.Gyoza] = 
    {
        Ingredient = 
        {
            CookingFeverConfig.Ingredients.Flour, 
            CookingFeverConfig.Ingredients.Drumsticks,
            CookingFeverConfig.Ingredients.Beef,
            CookingFeverConfig.Ingredients.Chilli,
            CookingFeverConfig.Ingredients.Pepper,
            CookingFeverConfig.Ingredients.Basil,
            CookingFeverConfig.Ingredients.Lemon,
            CookingFeverConfig.Ingredients.SoySauce,
        },
        Count = 
        {
            5,1,2,1,1,1,1,1
        }
    },

    [CookingFeverConfig.Dishes.CubanMojoChicken] = 
    {
        Ingredient = 
        {
            CookingFeverConfig.Ingredients.Rice, 
            CookingFeverConfig.Ingredients.Drumsticks,
            CookingFeverConfig.Ingredients.Avocado,
            CookingFeverConfig.Ingredients.CuminPowder,
            CookingFeverConfig.Ingredients.Celery,
            CookingFeverConfig.Ingredients.Pepper,
            CookingFeverConfig.Ingredients.Salt,
            CookingFeverConfig.Ingredients.ChopingBoard,
        },
        Count = 
        {
            3,2,2,1,1,1,1,1
        }
    },

    [CookingFeverConfig.Dishes.BasilPestoPasta] = 
    {
        Ingredient = 
        {
            CookingFeverConfig.Ingredients.Flour, 
            CookingFeverConfig.Ingredients.Butter,
            CookingFeverConfig.Ingredients.RawNoodle,
            CookingFeverConfig.Ingredients.Garlic,
            CookingFeverConfig.Ingredients.Mozzarella,
            CookingFeverConfig.Ingredients.Basil,
            CookingFeverConfig.Ingredients.PineapleBun,
            CookingFeverConfig.Ingredients.Pepper,
        },
        Count = 
        {
            3,2,1,1,1,2,1,1
        }
    },
    ----------Level 5----------
    [CookingFeverConfig.Dishes.HomemadeSoup] = 
    {
        Ingredient = 
        {
            CookingFeverConfig.Ingredients.Beef,
            CookingFeverConfig.Ingredients.Butter,
            CookingFeverConfig.Ingredients.Carrot,
            CookingFeverConfig.Ingredients.Tomato,
            CookingFeverConfig.Ingredients.Onion,
            CookingFeverConfig.Ingredients.Celery,
            CookingFeverConfig.Ingredients.Chilli,
            CookingFeverConfig.Ingredients.Salt,
            CookingFeverConfig.Ingredients.Water,
            CookingFeverConfig.Ingredients.PineapleBun, 
        },
        Count = 
        {
            2,1,2,2,1,2,1,1,5,2
        }
    },

    [CookingFeverConfig.Dishes.Sukiyaki] = 
    {
        Ingredient = 
        {
            CookingFeverConfig.Ingredients.Beef, 
            CookingFeverConfig.Ingredients.Tofu,
            CookingFeverConfig.Ingredients.Carrot,
            CookingFeverConfig.Ingredients.Mushroom,    
            CookingFeverConfig.Ingredients.SoySauce,
            CookingFeverConfig.Ingredients.Wasabi,
            CookingFeverConfig.Ingredients.Water,
            CookingFeverConfig.Ingredients.Orange,      
            CookingFeverConfig.Ingredients.Chopsticks,
            CookingFeverConfig.Ingredients.ChopingBoard,
        },
        Count = 
        {
            3,2,2,1,1,1,2,2,1,1
        }
    },

    [CookingFeverConfig.Dishes.FrenchBeef] = 
    { 
        Ingredient = 
        {
            CookingFeverConfig.Ingredients.Beef,
            CookingFeverConfig.Ingredients.Butter, 
            CookingFeverConfig.Ingredients.Cheese,
            CookingFeverConfig.Ingredients.Milk,
            CookingFeverConfig.Ingredients.Tomato,
            CookingFeverConfig.Ingredients.Carrot,
            CookingFeverConfig.Ingredients.Mushroom,
            CookingFeverConfig.Ingredients.Orange,
            CookingFeverConfig.Ingredients.Garlic,
            CookingFeverConfig.Ingredients.Rosemary,    
        },
        Count = 
        {
            3,1,1,2,1,1,2,1,2,1
        }
    },

    [CookingFeverConfig.Dishes.StirFryVegetables] = 
    {
        Ingredient = 
        {
            CookingFeverConfig.Ingredients.Broccoli,
            CookingFeverConfig.Ingredients.SweetPepper,
            CookingFeverConfig.Ingredients.Asparagus,
            CookingFeverConfig.Ingredients.Mushroom,
            CookingFeverConfig.Ingredients.Garlic,
            CookingFeverConfig.Ingredients.Carrot,
            CookingFeverConfig.Ingredients.Rosemary,
            CookingFeverConfig.Ingredients.SoySauce,
            CookingFeverConfig.Ingredients.Pepper,
            CookingFeverConfig.Ingredients.Salt,    
        },
        Count = 
        {
            3,2,1,2,1,3,1,1,2,1
        }              
    },

    [CookingFeverConfig.Dishes.Tempura] = 
    {
        Ingredient = 
        {
            CookingFeverConfig.Ingredients.Flour, 
            CookingFeverConfig.Ingredients.Prawn,
            CookingFeverConfig.Ingredients.Wasabi,
            CookingFeverConfig.Ingredients.Celery, 
            CookingFeverConfig.Ingredients.Orange,
            CookingFeverConfig.Ingredients.Onion,
            CookingFeverConfig.Ingredients.SoySauce,        
            CookingFeverConfig.Ingredients.Chopsticks,
            CookingFeverConfig.Ingredients.Colander,
            CookingFeverConfig.Ingredients.Pot,
        },
        Count = 
        {
            5,1,1,2,1,1,2,2,1,1
        }     
    },
}

--每关要做的菜
CookingFeverConfig.LevelInfo = {
    [1] = {
        CookingFeverConfig.Dishes.Noodle, 
        CookingFeverConfig.Dishes.HotDog, 
    },
    [2] = {
        CookingFeverConfig.Dishes.MisoSoup, 
        CookingFeverConfig.Dishes.FishFillets, 
        CookingFeverConfig.Dishes.Pizza, 
    },
    [3] = {
        CookingFeverConfig.Dishes.ChickenRoll, 
        CookingFeverConfig.Dishes.BeefSashimi, 
        CookingFeverConfig.Dishes.ApplePie, 
        CookingFeverConfig.Dishes.Escargot,
    },
    [4] = {
        CookingFeverConfig.Dishes.Pancake, 
        CookingFeverConfig.Dishes.Gyoza, 
        CookingFeverConfig.Dishes.CubanMojoChicken, 
        CookingFeverConfig.Dishes.BasilPestoPasta,
    },
    [5] = {
        CookingFeverConfig.Dishes.HomemadeSoup, 
        CookingFeverConfig.Dishes.Sukiyaki, 
        CookingFeverConfig.Dishes.FrenchBeef, 
        CookingFeverConfig.Dishes.StirFryVegetables,
        CookingFeverConfig.Dishes.Tempura,
    }
}

--完成一关奖励的卡包
CookingFeverConfig.LevelRewardCardPack = {
    [1] = {nPackType = SlotsCardsAllProbTable.PackType.Two, nCount = 1},
    [2] = {nPackType = SlotsCardsAllProbTable.PackType.Two, nCount = 2},
    [3] = {nPackType = SlotsCardsAllProbTable.PackType.Three, nCount = 2},
    [4] = {nPackType = SlotsCardsAllProbTable.PackType.Four, nCount = 1},
    [5] = {nPackType = SlotsCardsAllProbTable.PackType.Four, nCount = 2},
}

CookingFeverConfig.FinalPrizeRewardCardPack = {nPackType = SlotsCardsAllProbTable.PackType.Five, nCount = 2}