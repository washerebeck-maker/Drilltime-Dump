Config = {}

Config.BlipSprite = 566
Config.BlipColor = 1
Config.BlipText = 'Workbench'

Config.UseLimitSystem = false

Config.CraftingStopWithDistance = true

Config.ExperiancePerCraft = 0

Config.HideWhenCantCraft = true

Config.ImagesPath = 'nui://ox_inventory/web/images/'

Config.Categories = {
	['drugs'] = {
		['drugs'] = { Label = 'drugs', Image = 'adminkeycard', Jobs = {}},
	},
	['work'] = {
		['work'] = { Label = 'CraftDrugs', Image = 'cocainebrick', Jobs = {}},
	},
	['Bullets'] = {
		['bullet'] = { Label = 'Bullets', Image = 'ammo-rifle2', Jobs = {}},
	},
	['Printer'] = {
		['printer'] = { Label = '3DGun', Image = 'WEAPON_3DG17SWITCH', Jobs = {}},
	},
	['Prmgunlicense'] = {
		['prmgunlicense'] = { Label = 'GUN PLUG', Image = 'prmgunlicense', Jobs = {}},
	},
	['fgpfive'] = {
		['fgpfive'] = { Label = 'Weapon Crafting', Image = 'fgpfive', Jobs = {}},
	},
	['shoestore'] = {
		['shoestore'] = { Label = 'Shoe Crafting', Image = 'snewspwtow', Jobs = {}},
	},
}

Config.PermanentItems = {
	['weedscissors'] = true
}

Config.Recipes = {

	['prjbaby2'] = {
		Level = 0,
		Category = 'drugs',
		isGun = false,
		Jobs = {'weedstore'}, 
		JobGrades = {0,1,}, 
		Amount = 90,
		SuccessRate = 100,
		requireBlueprint = false,
		Time = 15, 
		Ingredients = {
			['prjbaby3'] = 90,
		}
	},
	['prjbaby1'] = {
		Level = 0,
		Category = 'drugs',
		isGun = false,
		Jobs = {'weedstore'}, 
		JobGrades = {0,1,}, 
		Amount = 18,
		SuccessRate = 100,
		requireBlueprint = false,
		Time = 25, 
		Ingredients = {
			['prjbaby2'] = 108,
			['pooch_bag'] = 18,
		}
	},
        -- GUNPLUGS
	['WEAPON_LONETAXIN'] = {
		Level = 1,
		Category = 'prmgunlicense',
		isGun = true,
		Jobs = {}, 
		JobGrades = {}, 
		Amount = 1,
		SuccessRate = 100,
		requireBlueprint = false,
		Time = 60, 
		Ingredients = {
			['prmgunlicense'] = 245,
			['ghostmetal'] = 5,
		}
	},
	['WEAPON_ROLYR99'] = {
		Level = 1,
		Category = 'prmgunlicense',
		isGun = true,
		Jobs = {}, 
		JobGrades = {}, 
		Amount = 1,
		SuccessRate = 100,
		requireBlueprint = false,
		Time = 60, 
		Ingredients = {
			['prmgunlicense'] = 485,
			['ghostmetal'] = 11,
		}
	},
	['WEAPON_NOTGONEUSEONE'] = {
		Level = 1,
		Category = 'prmgunlicense',
		isGun = true,
		Jobs = {}, 
		JobGrades = {}, 
		Amount = 1,
		SuccessRate = 100,
		requireBlueprint = false,
		Time = 60, 
		Ingredients = {
			['prmgunlicense'] = 385,
			['ghostmetal'] = 5,
		}
	},
	['WEAPON_PUMPKIN'] = {
		Level = 1,
		Category = 'prmgunlicense',
		isGun = true,
		Jobs = {}, 
		JobGrades = {}, 
		Amount = 1,
		SuccessRate = 100,
		requireBlueprint = false,
		Time = 60, 
		Ingredients = {
			['prmgunlicense'] = 115,
			['ghostmetal'] = 2,
		}
	},
	['WEAPON_REDZONEBABY'] = {
		Level = 1,
		Category = 'prmgunlicense',
		isGun = true,
		Jobs = {}, 
		JobGrades = {}, 
		Amount = 1,
		SuccessRate = 100,
		requireBlueprint = false,
		Time = 60, 
		Ingredients = {
			['newbbredzonex'] = 3450,
		}
	},
	['WEAPON_HELLOKITTY'] = {
		Level = 1,
		Category = 'prmgunlicense',
		isGun = true,
		Jobs = {}, 
		JobGrades = {}, 
		Amount = 1,
		SuccessRate = 100,
		requireBlueprint = false,
		Time = 60, 
		Ingredients = {
			['prmgunlicense'] = 245,
			['ghostmetal'] = 7,
		}
	},
	['WEAPON_WEBSICA'] = {
		Level = 1,
		Category = 'prmgunlicense',
		isGun = true,
		Jobs = {}, 
		JobGrades = {}, 
		Amount = 1,
		SuccessRate = 100,
		requireBlueprint = false,
		Time = 60, 
		Ingredients = {
			['prmgunlicense'] = 315,
			['ghostmetal'] = 2,
		}
	},
	['WEAPON_CANDY4'] = {
		Level = 1,
		Category = 'prmgunlicense',
		isGun = true,
		Jobs = {}, 
		JobGrades = {}, 
		Amount = 1,
		SuccessRate = 100,
		requireBlueprint = false,
		Time = 60, 
		Ingredients = {
			['prmgunlicense'] = 115,
			['ghostmetal'] = 2,
		}
	},
	['WEAPON_UMP2X'] = {
		Level = 1,
		Category = 'prmgunlicense',
		isGun = true,
		Jobs = {}, 
		JobGrades = {}, 
		Amount = 1,
		SuccessRate = 100,
		requireBlueprint = false,
		Time = 60, 
		Ingredients = {
			['prmgunlicense'] = 215,
			['ghostmetal'] = 2,
		}
	},
	['WEAPON_GLEESTRIKER'] = {
		Level = 1,
		Category = 'prmgunlicense',
		isGun = true,
		Jobs = {}, 
		JobGrades = {}, 
		Amount = 1,
		SuccessRate = 100,
		requireBlueprint = false,
		Time = 60, 
		Ingredients = {
			['prmgunlicense'] = 280,
			['ghostmetal'] = 2,
		}
	},
	['WEAPON_SINCERESICA'] = {
		Level = 1,
		Category = 'prmgunlicense',
		isGun = true,
		Jobs = {}, 
		JobGrades = {}, 
		Amount = 1,
		SuccessRate = 100,
		requireBlueprint = false,
		Time = 60, 
		Ingredients = {
			['prmgunlicense'] = 360,
			['ghostmetal'] = 2,
		}
	},
	['WEAPON_DRILLSR47'] = {
		Level = 1,
		Category = 'prmgunlicense',
		isGun = true,
		Jobs = {}, 
		JobGrades = {}, 
		Amount = 1,
		SuccessRate = 100,
		requireBlueprint = false,
		Time = 60, 
		Ingredients = {
			['prmgunlicense'] = 400,
			['ghostmetal'] = 2,
		}
	},
	['WEAPON_G19X'] = {
		Level = 1,
		Category = 'prmgunlicense',
		isGun = true,
		Jobs = {}, 
		JobGrades = {}, 
		Amount = 1,
		SuccessRate = 100,
		requireBlueprint = false,
		Time = 60, 
		Ingredients = {
			['prmgunlicense'] = 270,
			['ghostmetal'] = 2,
		}
	},
	['WEAPON_DTVECT'] = {
		Level = 1,
		Category = 'prmgunlicense',
		isGun = true,
		Jobs = {}, 
		JobGrades = {}, 
		Amount = 1,
		SuccessRate = 100,
		requireBlueprint = false,
		Time = 60, 
		Ingredients = {
			['prmgunlicense'] = 185,
			['ghostmetal'] = 2,
		}
	},
	['WEAPON_FATHOE'] = {
		Level = 1,
		Category = 'prmgunlicense',
		isGun = true,
		Jobs = {}, 
		JobGrades = {}, 
		Amount = 1,
		SuccessRate = 100,
		requireBlueprint = false,
		Time = 60, 
		Ingredients = {
			['prmgunlicense'] = 170,
			['ghostmetal'] = 2,
		}
	},
	['WEAPON_CRBHOE'] = {
		Level = 1,
		Category = 'prmgunlicense',
		isGun = true,
		Jobs = {}, 
		JobGrades = {}, 
		Amount = 1,
		SuccessRate = 100,
		requireBlueprint = false,
		Time = 60, 
		Ingredients = {
			['prmgunlicense'] = 245,
			['ghostmetal'] = 2,
		}
	},
	['WEAPON_SEMIHOE'] = {
		Level = 1,
		Category = 'prmgunlicense',
		isGun = true,
		Jobs = {}, 
		JobGrades = {}, 
		Amount = 1,
		SuccessRate = 100,
		requireBlueprint = false,
		Time = 60, 
		Ingredients = {
			['prmgunlicense'] = 270,
			['ghostmetal'] = 2,
		}
	},
	['WEAPON_KAWSUMP'] = {
		Level = 1,
		Category = 'prmgunlicense',
		isGun = true,
		Jobs = {}, 
		JobGrades = {}, 
		Amount = 1,
		SuccessRate = 100,
		requireBlueprint = false,
		Time = 60, 
		Ingredients = {
			['prmgunlicense'] = 300,
			['ghostmetal'] = 2,
		}
	},
	['WEAPON_JKJ4O4'] = {
		Level = 1,
		Category = 'prmgunlicense',
		isGun = true,
		Jobs = {}, 
		JobGrades = {}, 
		Amount = 1,
		SuccessRate = 100,
		requireBlueprint = false,
		Time = 60, 
		Ingredients = {
			['prmgunlicense'] = 330,
			['ghostmetal'] = 2,
		}
	},
	['WEAPON_HEAVYSHOTGUN'] = {
		Level = 1,
		Category = 'prmgunlicense',
		isGun = true,
		Jobs = {}, 
		JobGrades = {}, 
		Amount = 1,
		SuccessRate = 100,
		requireBlueprint = false,
		Time = 60, 
		Ingredients = {
			['prmgunlicense'] = 270,
			['ghostmetal'] = 2,
		}
	},
	['WEAPON_GFXSIX'] = {
		Level = 1,
		Category = 'prmgunlicense',
		isGun = true,
		Jobs = {}, 
		JobGrades = {}, 
		Amount = 1,
		SuccessRate = 100,
		requireBlueprint = false,
		Time = 60, 
		Ingredients = {
			['prmgunlicense'] = 100,
			['ghostmetal'] = 2,
		}
	},
	['WEAPON_SKULLPISTOL'] = {
		Level = 1,
		Category = 'prmgunlicense',
		isGun = true,
		Jobs = {}, 
		JobGrades = {}, 
		Amount = 1,
		SuccessRate = 100,
		requireBlueprint = false,
		Time = 60, 
		Ingredients = {
			['prmgunlicense'] = 666,
			['ghostmetal'] = 6,
		}
	},
	['WEAPON_M4HYPERBEAST'] = {
		Level = 1,
		Category = 'prmgunlicense',
		isGun = true,
		Jobs = {}, 
		JobGrades = {}, 
		Amount = 1,
		SuccessRate = 100,
		requireBlueprint = false,
		Time = 60, 
		Ingredients = {
			['prmgunlicense'] = 120,
			['ghostmetal'] = 2,
		}
	},
	['WEAPON_WALKDOWNARP'] = {
		Level = 1,
		Category = 'prmgunlicense',
		isGun = true,
		Jobs = {}, 
		JobGrades = {}, 
		Amount = 1,
		SuccessRate = 100,
		requireBlueprint = false,
		Time = 60, 
		Ingredients = {
			['prmgunlicense'] = 175,
			['ghostmetal'] = 2,
		}
	},
	['WEAPON_PAINTBALL'] = {
		Level = 1,
		Category = 'prmgunlicense',
		isGun = true,
		Jobs = {}, 
		JobGrades = {}, 
		Amount = 1,
		SuccessRate = 100,
		requireBlueprint = false,
		Time = 60, 
		Ingredients = {
			['prmgunlicense'] = 85,
			['ghostmetal'] = 2,
		}
	},
	['WEAPON_M4A1SPURPLE'] = {
		Level = 1,
		Category = 'prmgunlicense',
		isGun = true,
		Jobs = {}, 
		JobGrades = {}, 
		Amount = 1,
		SuccessRate = 100,
		requireBlueprint = false,
		Time = 60, 
		Ingredients = {
			['prmgunlicense'] = 175,
			['ghostmetal'] = 2,
		}
	},
	['WEAPON_BAS_P_RED'] = {
		Level = 1,
		Category = 'prmgunlicense',
		isGun = true,
		Jobs = {}, 
		JobGrades = {}, 
		Amount = 1,
		SuccessRate = 100,
		requireBlueprint = false,
		Time = 60, 
		Ingredients = {
			['prmgunlicense'] = 155,
			['ghostmetal'] = 2,
		}
	},
	['WEAPON_MACHETE'] = {
		Level = 1,
		Category = 'prmgunlicense',
		isGun = true,
		Jobs = {}, 
		JobGrades = {}, 
		Amount = 1,
		SuccessRate = 100,
		requireBlueprint = false,
		Time = 60, 
		Ingredients = {
			['prmgunlicense'] = 150,
			['ghostmetal'] = 2,
		}
	},
	['WEAPON_APPURPLE'] = {
		Level = 1,
		Category = 'prmgunlicense',
		isGun = true,
		Jobs = {}, 
		JobGrades = {}, 
		Amount = 1,
		SuccessRate = 100,
		requireBlueprint = false,
		Time = 60, 
		Ingredients = {
			['prmgunlicense'] = 165,
			['ghostmetal'] = 2,
		}
	},
	['contractstriker'] = {
		Level = 0,
		Category = 'prmgunlicense',
		isGun = false,
		Jobs = {}, 
		JobGrades = {}, 
		Amount = 1,
		SuccessRate = 100,
		requireBlueprint = false,
		Time = 15,
		Ingredients = {
			['consalol'] = 2,
			['contract'] = 1,
		}
	},
	['ghostmetal'] = {
		Level = 0,
		Category = 'prmgunlicense',
		isGun = true,
		Jobs = {}, 
		JobGrades = {}, 
		Amount = 1,
		SuccessRate = 100,
		requireBlueprint = false,
		Time = 35,
		Ingredients = {
			['metalscrapnew'] = 1,
			['metalscxpnew'] = 1,
			['screwdripnew'] = 1,
			['plasticscrapnew'] = 1,
		}
	},
	['dtokenmodveta'] = {
		Level = 0,
		Category = 'prmgunlicense',
		isGun = true,
		Jobs = {}, 
		JobGrades = {}, 
		Amount = 1,
		SuccessRate = 100,
		requireBlueprint = false,
		Time = 35,
		Ingredients = {
			['ghostmetal'] = 5,
		}
	},
	-- Bullets
	['crackpooch3000'] = {
		Level = 1,
		Category = 'work',
		isGun = false,
		Jobs = {}, 
		JobGrades = {}, 
		Amount = 330,
		SuccessRate = 100,
		requireBlueprint = false,
		Time = 60, 
		Ingredients = {
			['bakingsoda'] = 10,
			['pooch_bag'] = 330,
			['ratpoison'] = 10,
			['drugscales'] = 1,
			['cocainebrick'] = 1,
		}
	},
	['lsdtab'] = {
		Level = 1,
		Category = 'work',
		isGun = false,
		Jobs = {}, 
		JobGrades = {}, 
		Amount = 330,
		SuccessRate = 100,
		requireBlueprint = false,
		Time = 60, 
		Ingredients = {
			['bakingsoda'] = 10,
			['lsddrop'] = 330,
			['ratpoison'] = 10,
			['drugscales'] = 1,
			['cocainebrick'] = 1,
		}
	},
	['pooch_whippets'] = {
		Level = 1,
		Category = 'work',
		isGun = false,
		Jobs = {}, 
		JobGrades = {}, 
		Amount = 330,
		SuccessRate = 100,
		requireBlueprint = false,
		Time = 60, 
		Ingredients = {
			['whippetscartridges'] = 10,
			['drugscales'] = 1,
			['cocainebrick'] = 1,
		}
	},
	['meth_poooch'] = {
		Level = 1,
		Category = 'work',
		isGun = false,
		Jobs = {}, 
		JobGrades = {}, 
		Amount = 330,
		SuccessRate = 100,
		requireBlueprint = false,
		Time = 60, 
		Ingredients = {
			['bakingsoda'] = 10,
			['pooch_bag'] = 330,
			['ratpoison'] = 10,
			['drugscales'] = 1,
			['cocainebrick'] = 1,
		}
	},
	['bottle_xanaxnew'] = {
		Level = 1,
		Category = 'work',
		isGun = false,
		Jobs = {}, 
		JobGrades = {}, 
		Amount = 330,
		SuccessRate = 100,
		requireBlueprint = false,
		Time = 60, 
		Ingredients = {
			['bakingsoda'] = 10,
			['icoke'] = 200,
			['medbottle'] = 330,
			['ratpoison'] = 10,
			['drugscales'] = 1,
			['cocainebrick'] = 1,
		}
	},
	['finxsdwax'] = {
		Level = 1,
		Category = 'work',
		isGun = false,
		Jobs = {}, 
		JobGrades = {}, 
		Amount = 330,
		SuccessRate = 100,
		requireBlueprint = false,
		Time = 60, 
		Ingredients = {
			['bakingsoda'] = 10,
			['nuggsxawax'] = 200,
			['ratpoison'] = 10,
			['drugscales'] = 1,
			['cocainebrick'] = 1,
		}
	},
	['tuzi_pooch'] = {
		Level = 1,
		Category = 'work',
		isGun = false,
		Jobs = {}, 
		JobGrades = {}, 
		Amount = 330,
		SuccessRate = 100,
		requireBlueprint = false,
		Time = 60, 
		Ingredients = {
			['bakingsoda'] = 10,
			['icoke'] = 200,
			['medbottle'] = 330,
			['ratpoison'] = 10,
			['drugscales'] = 1,
			['cocainebrick'] = 1,
		}
	},
	['double_cup'] = {
		Level = 1,
		Category = 'work',
		isGun = false,
		Jobs = {}, 
		JobGrades = {}, 
		Amount = 330,
		SuccessRate = 100,
		requireBlueprint = false,
		Time = 60, 
		Ingredients = {
			['bakingsoda'] = 10,
			['lean_bottle'] = 150,
			['medbottle'] = 330,
			['ratpoison'] = 10,
			['drugscales'] = 1,
			['cocainebrick'] = 1,
		}
	},
	['hero_pooch'] = {
		Level = 1,
		Category = 'work',
		isGun = false,
		Jobs = {}, 
		JobGrades = {}, 
		Amount = 330,
		SuccessRate = 100,
		requireBlueprint = false,
		Time = 60, 
		Ingredients = {
			['bakingsoda'] = 10,
			['pooch_bag'] = 330,
			['lean_bottle'] = 20,
			['rawfent'] = 10,
			['icoke'] = 15,
			['water'] = 1,
			['ratpoison'] = 10,
			['drugscales'] = 1,
			['cocainebrick'] = 1,
		}
	},
	['perc_pooch'] = {
		Level = 1,
		Category = 'work',
		isGun = false,
		Jobs = {}, 
		JobGrades = {}, 
		Amount = 330,
		SuccessRate = 100,
		requireBlueprint = false,
		Time = 60, 
		Ingredients = {
			['bakingsoda'] = 10,
			['pooch_bag'] = 330,
			['ratpoison'] = 10,
			['drugscales'] = 1,
			['cocainebrick'] = 1,
		}
	},
	['coke_pooch'] = {
		Level = 1,
		Category = 'work',
		isGun = false,
		Jobs = {}, 
		JobGrades = {}, 
		Amount = 330,
		SuccessRate = 100,
		requireBlueprint = false,
		Time = 60, 
		Ingredients = {
			['bakingsoda'] = 10,
			['pooch_bag'] = 330,
			['ratpoison'] = 10,
			['drugscales'] = 1,
			['cocainebrick'] = 1,
		}
	},
	['newdrugxll'] = {
		Level = 1,
		Category = 'work',
		isGun = false,
		Jobs = {}, 
		JobGrades = {}, 
		Amount = 330,
		SuccessRate = 100,
		requireBlueprint = false,
		Time = 60, 
		Ingredients = {
			['bakingsoda'] = 10,
			['pooch_bag'] = 330,
			['pcpppcp'] = 165,
			['drugscales'] = 1,
			['cocainebrick'] = 1,
		}
	},
	['spfentpooch'] = {
		Level = 1,
		Category = 'work',
		isGun = false,
		Jobs = {}, 
		JobGrades = {}, 
		Amount = 330,
		SuccessRate = 100,
		requireBlueprint = false,
		Time = 60, 
		Ingredients = {
			['bakingsoda'] = 10,
			['pooch_bag'] = 330,
			['ratpoison'] = 10,
			['lean_bottle'] = 20,
			['rawfent'] = 10,
			['icoke'] = 15,
			['water'] = 1,
			['drugscales'] = 1,
			['cocainebrick'] = 1,
		}
	},
	['contractstriker'] = {
		Level = 0,
		Category = 'work',
		isGun = false,
		Jobs = {}, 
		JobGrades = {}, 
		Amount = 1,
		SuccessRate = 100,
		requireBlueprint = false,
		Time = 15,
		Ingredients = {
			['consalol'] = 2,
			['contract'] = 1,
		}
	},
	['ghostmetal'] = {
		Level = 0,
		Category = 'work',
		isGun = true,
		Jobs = {}, 
		JobGrades = {}, 
		Amount = 1,
		SuccessRate = 100,
		requireBlueprint = false,
		Time = 35,
		Ingredients = {
			['metalscrapnew'] = 1,
			['metalscxpnew'] = 1,
			['screwdripnew'] = 1,
			['plasticscrapnew'] = 1,
		}
	},
	['dtokenmodveta'] = {
		Level = 0,
		Category = 'work',
		isGun = true,
		Jobs = {}, 
		JobGrades = {}, 
		Amount = 1,
		SuccessRate = 100,
		requireBlueprint = false,
		Time = 35,
		Ingredients = {
			['ghostmetal'] = 5,
		}
	},
        -- AMMO
	['ammo-9'] = {
		Level = 0,
		Category = 'bullet',
		isGun = false,
		Jobs = {'Ammunation'}, 
		JobGrades = {1,2,3,4,}, 
		Amount = 200,
		SuccessRate = 100,
		requireBlueprint = false,
		Time = 10, 
		Ingredients = {
			['gunpowder'] = 200,
			['ammo9craft'] = 200,
		}
	},
	['ammo-rifle2'] = {
		Level = 0,
		Category = 'bullet',
		isGun = false,
		Jobs = {'Ammunation'}, 
		JobGrades = {1,2,3,4,}, 
		Amount = 200,
		SuccessRate = 100,
		requireBlueprint = false,
		Time = 10, 
		Ingredients = {
			['gunpowder'] = 200,
			['ammo762craft'] = 200,
		}
	},
	['ammo-rifle'] = {
		Level = 0,
		Category = 'bullet',
		isGun = false,
		Jobs = {'Ammunation'}, 
		JobGrades = {1,2,3,4,}, 
		Amount = 200,
		SuccessRate = 100,
		requireBlueprint = false,
		Time = 10, 
		Ingredients = {
			['gunpowder'] = 200,
			['ammoriflecraft'] = 200,
		}
	},
	['ammo-shotgun'] = {
		Level = 0,
		Category = 'bullet',
		isGun = false,
		Jobs = {'Ammunation'}, 
		JobGrades = {1,2,3,4,}, 
		Amount = 200,
		SuccessRate = 100,
		requireBlueprint = false,
		Time = 10, 
		Ingredients = {
			['gunpowder'] = 200,
			['ammoshotguncraft'] = 200,
		}
	},
	['ammo-45acp'] = {
		Level = 0,
		Category = 'bullet',
		isGun = false,
		Jobs = {'Ammunation'}, 
		JobGrades = {1,2,3,4,}, 
		Amount = 200,
		SuccessRate = 100,
		requireBlueprint = false,
		Time = 10, 
		Ingredients = {
			['gunpowder'] = 200,
			['ammo45craft'] = 200,
		}
	},
	--printer
	['WEAPON_RON2MADICK'] = {
		Level = 1,
		Category = 'printer',
		isGun = true,
		Jobs = {}, 
		JobGrades = {}, 
		Amount = 1,
		SuccessRate = 100,
		requireBlueprint = false,
		Time = 60, 
		Ingredients = {
			['dremgrmsaax'] = 3300,
			['wparrdone'] = 1700,
			['wparrdotwo'] = 1700,
			['wparrdonethree'] = 1700,
		}
	},
	['WEAPON_UMP3X'] = {
		Level = 0,
		Category = 'printer',
		isGun = true,
		Jobs = {}, 
		JobGrades = {}, 
		Amount = 1,
		SuccessRate = 100,
		requireBlueprint = false,
		Time = 65, 
		Ingredients = {
			['dremgrmsaax'] = 3500,
			['wparrdone'] = 2550,
			['wparrdotwo'] = 2550,
			['wparrdonethree'] = 2550,
		}
	},
	['WEAPON_XOXO'] = {
		Level = 0,
		Category = 'printer',
		isGun = true,
		Jobs = {}, 
		JobGrades = {}, 
		Amount = 1,
		SuccessRate = 100,
		requireBlueprint = false,
		Time = 65,
		Ingredients = {
			['dremgrmsaax'] = 4000,
			['wparrdone'] = 3350,
			['wparrdotwo'] = 3350,
			['wparrdonethree'] = 3350,
		}
	},
	---------------------------------------
	['WEAPON_SR40'] = {
		Level = 0,
		Category = 'fgpfive',
		isGun = true,
		Jobs = {}, 
		JobGrades = {}, 
		Amount = 1,
		SuccessRate = 100,
		requireBlueprint = false,
		Time = 35,
		Ingredients = {
			['fgpfive'] = 55,
			['fgpfour'] = 55,
			['fgpthree'] = 55,
			['fgptwo'] = 55,
			['fgpone'] = 55,
			['ghostmetal'] = 2,
		}
	},
	['WEAPON_P30L'] = {
		Level = 0,
		Category = 'fgpfive',
		isGun = true,
		Jobs = {}, 
		JobGrades = {}, 
		Amount = 1,
		SuccessRate = 100,
		requireBlueprint = false,
		Time = 35,
		Ingredients = {
			['fgpfive'] = 55,
			['fgpfour'] = 55,
			['fgpthree'] = 55,
			['fgptwo'] = 55,
			['fgpone'] = 55,
			['ghostmetal'] = 2,
		}
	},
	['WEAPON_PISTOL_MK2'] = {
		Level = 0,
		Category = 'fgpfive',
		isGun = true,
		Jobs = {}, 
		JobGrades = {}, 
		Amount = 1,
		SuccessRate = 100,
		requireBlueprint = false,
		Time = 35,
		Ingredients = {
			['fgpfive'] = 55,
			['fgpfour'] = 55,
			['fgpthree'] = 55,
			['fgptwo'] = 55,
			['fgpone'] = 55,
			['ghostmetal'] = 2,
		}
	},
	['WEAPON_HEAVYPISTOL'] = {
		Level = 0,
		Category = 'fgpfive',
		isGun = true,
		Jobs = {}, 
		JobGrades = {}, 
		Amount = 1,
		SuccessRate = 100,
		requireBlueprint = false,
		Time = 35,
		Ingredients = {
			['fgpfive'] = 55,
			['fgpfour'] = 55,
			['fgpthree'] = 55,
			['fgptwo'] = 55,
			['fgpone'] = 55,
			['ghostmetal'] = 2,
		}
	},
	['WEAPON_T1911'] = {
		Level = 0,
		Category = 'fgpfive',
		isGun = true,
		Jobs = {}, 
		JobGrades = {}, 
		Amount = 1,
		SuccessRate = 100,
		requireBlueprint = false,
		Time = 35,
		Ingredients = {
			['fgpfive'] = 55,
			['fgpfour'] = 55,
			['fgpthree'] = 55,
			['fgptwo'] = 55,
			['fgpone'] = 55,
			['ghostmetal'] = 2,
		}
	},
	['WEAPON_ILLGLOCK17'] = {
		Level = 0,
		Category = 'fgpfive',
		isGun = true,
		Jobs = {}, 
		JobGrades = {}, 
		Amount = 1,
		SuccessRate = 100,
		requireBlueprint = false,
		Time = 35,
		Ingredients = {
			['fgpfive'] = 220,
			['fgpfour'] = 220,
			['fgpthree'] = 220,
			['fgptwo'] = 220,
			['fgpone'] = 220,
			['ghostmetal'] = 6,
		}
	},
	['WEAPON_GLOCK26'] = {
		Level = 0,
		Category = 'fgpfive',
		isGun = true,
		Jobs = {}, 
		JobGrades = {}, 
		Amount = 1,
		SuccessRate = 100,
		requireBlueprint = false,
		Time = 35,
		Ingredients = {
			['fgpfive'] = 220,
			['fgpfour'] = 220,
			['fgpthree'] = 220,
			['fgptwo'] = 220,
			['fgpone'] = 220,
			['ghostmetal'] = 6,
		}
	},
	['WEAPON_APPISTOL'] = {
		Level = 0,
		Category = 'fgpfive',
		isGun = true,
		Jobs = {}, 
		JobGrades = {}, 
		Amount = 1,
		SuccessRate = 100,
		requireBlueprint = false,
		Time = 35,
		Ingredients = {
			['fgpfive'] = 220,
			['fgpfour'] = 220,
			['fgpthree'] = 220,
			['fgptwo'] = 220,
			['fgpone'] = 220,
			['ghostmetal'] = 6,
		}
	},
	['WEAPON_GFXFIVE'] = {
		Level = 0,
		Category = 'fgpfive',
		isGun = true,
		Jobs = {}, 
		JobGrades = {}, 
		Amount = 1,
		SuccessRate = 100,
		requireBlueprint = false,
		Time = 35,
		Ingredients = {
			['fgpfive'] = 220,
			['fgpfour'] = 220,
			['fgpthree'] = 220,
			['fgptwo'] = 220,
			['fgpone'] = 220,
			['ghostmetal'] = 6,
		}
	},
	['WEAPON_FNBLACKZIP'] = {
		Level = 0,
		Category = 'fgpfive',
		isGun = true,
		Jobs = {}, 
		JobGrades = {}, 
		Amount = 1,
		SuccessRate = 100,
		requireBlueprint = false,
		Time = 35,
		Ingredients = {
			['fgpfive'] = 220,
			['fgpfour'] = 220,
			['fgpthree'] = 220,
			['fgptwo'] = 220,
			['fgpone'] = 220,
			['ghostmetal'] = 6,
		}
	},
	['WEAPON_GFXSWITCH2'] = {
		Level = 0,
		Category = 'fgpfive',
		isGun = true,
		Jobs = {}, 
		JobGrades = {}, 
		Amount = 1,
		SuccessRate = 100,
		requireBlueprint = false,
		Time = 35,
		Ingredients = {
			['fgpfive'] = 220,
			['fgpfour'] = 220,
			['fgpthree'] = 220,
			['fgptwo'] = 220,
			['fgpone'] = 220,
			['ghostmetal'] = 6,
		}
	},
	['WEAPON_TARP'] = {
		Level = 0,
		Category = 'fgpfive',
		isGun = true,
		Jobs = {}, 
		JobGrades = {}, 
		Amount = 1,
		SuccessRate = 100,
		requireBlueprint = false,
		Time = 35,
		Ingredients = {
			['fgpfive'] = 370,
			['fgpfour'] = 370,
			['fgpthree'] = 370,
			['fgptwo'] = 370,
			['fgpone'] = 370,
			['ghostmetal'] = 8,
		}
	},
	['WEAPON_SURREALGFX5'] = {
		Level = 0,
		Category = 'fgpfive',
		isGun = true,
		Jobs = {}, 
		JobGrades = {}, 
		Amount = 1,
		SuccessRate = 100,
		requireBlueprint = false,
		Time = 35,
		Ingredients = {
			['fgpfive'] = 370,
			['fgpfour'] = 370,
			['fgpthree'] = 370,
			['fgptwo'] = 370,
			['fgpone'] = 370,
			['ghostmetal'] = 8,
		}
	},
	['WEAPON_LBTARP'] = {
		Level = 0,
		Category = 'fgpfive',
		isGun = true,
		Jobs = {}, 
		JobGrades = {}, 
		Amount = 1,
		SuccessRate = 100,
		requireBlueprint = false,
		Time = 35,
		Ingredients = {
			['fgpfive'] = 370,
			['fgpfour'] = 370,
			['fgpthree'] = 370,
			['fgptwo'] = 370,
			['fgpone'] = 370,
			['ghostmetal'] = 8,
		}
	},
	['WEAPON_DMK18'] = {
		Level = 0,
		Category = 'fgpfive',
		isGun = true,
		Jobs = {}, 
		JobGrades = {}, 
		Amount = 1,
		SuccessRate = 100,
		requireBlueprint = false,
		Time = 35,
		Ingredients = {
			['fgpfive'] = 370,
			['fgpfour'] = 370,
			['fgpthree'] = 370,
			['fgptwo'] = 370,
			['fgpone'] = 370,
			['ghostmetal'] = 8,
		}
	},
	['WEAPON_SOREALTHREE'] = {
		Level = 0,
		Category = 'fgpfive',
		isGun = true,
		Jobs = {}, 
		JobGrades = {}, 
		Amount = 1,
		SuccessRate = 100,
		requireBlueprint = false,
		Time = 35,
		Ingredients = {
			['fgpfive'] = 485,
			['fgpfour'] = 485,
			['fgpthree'] = 485,
			['fgptwo'] = 485,
			['fgpone'] = 485,
			['ghostmetal'] = 8,
		}
	},
	['WEAPON_THOMPSON'] = {
		Level = 0,
		Category = 'fgpfive',
		isGun = true,
		Jobs = {}, 
		JobGrades = {}, 
		Amount = 1,
		SuccessRate = 100,
		requireBlueprint = false,
		Time = 35,
		Ingredients = {
			['fgpfive'] = 485,
			['fgpfour'] = 485,
			['fgpthree'] = 485,
			['fgptwo'] = 485,
			['fgpone'] = 485,
			['ghostmetal'] = 8,
		}
	},
	['WEAPON_SOREALTWO'] = {
		Level = 0,
		Category = 'fgpfive',
		isGun = true,
		Jobs = {}, 
		JobGrades = {}, 
		Amount = 1,
		SuccessRate = 100,
		requireBlueprint = false,
		Time = 35,
		Ingredients = {
			['fgpfive'] = 485,
			['fgpfour'] = 485,
			['fgpthree'] = 485,
			['fgptwo'] = 485,
			['fgpone'] = 485,
			['ghostmetal'] = 8,
		}
	},
	['WEAPON_KRISSVECTOR'] = {
		Level = 0,
		Category = 'fgpfive',
		isGun = true,
		Jobs = {}, 
		JobGrades = {}, 
		Amount = 1,
		SuccessRate = 100,
		requireBlueprint = false,
		Time = 35,
		Ingredients = {
			['fgpfive'] = 485,
			['fgpfour'] = 485,
			['fgpthree'] = 485,
			['fgptwo'] = 485,
			['fgpone'] = 485,
			['ghostmetal'] = 8,
		}
	},
	['WEAPON_SOREALFOUR'] = {
		Level = 0,
		Category = 'fgpfive',
		isGun = true,
		Jobs = {}, 
		JobGrades = {}, 
		Amount = 1,
		SuccessRate = 100,
		requireBlueprint = false,
		Time = 35,
		Ingredients = {
			['fgpfive'] = 485,
			['fgpfour'] = 485,
			['fgpthree'] = 485,
			['fgptwo'] = 485,
			['fgpone'] = 485,
			['ghostmetal'] = 8,
		}
	},
	['snewspwone'] = {
		Level = 0,
		Category = 'shoestore',
		isGun = false,
		Jobs = {'shoestore'},
		JobGrades = {}, 
		Amount = 5,
		SuccessRate = 100,
		requireBlueprint = false,
		Time = 3,
		Ingredients = {
			['fmaterialnewone'] = 20,
			['fmaterialnewthreee'] = 20,
			['fmaterialnewtwo'] = 20,
		}
	},
	['shnewbox3'] = {
		Level = 0,
		Category = 'shoestore',
		isGun = false,
		Jobs = {'shoestore'},
		JobGrades = {}, 
		Amount = 20,
		SuccessRate = 100,
		requireBlueprint = false,
		Time = 3,
		Ingredients = {
			['fmaterialnewone'] = 20,
			['fmaterialnewthreee'] = 20,
			['fmaterialnewtwo'] = 20,
		}
	},
	['snewspwtow'] = {
		Level = 0,
		Category = 'shoestore',
		isGun = false,
		Jobs = {'shoestore'},
		JobGrades = {}, 
		Amount = 25,
		SuccessRate = 100,
		requireBlueprint = false,
		Time = 3,
		Ingredients = {
			['fmaterialnewone'] = 25,
			['fmaterialnewthreee'] = 25,
			['fmaterialnewtwo'] = 25,
		}
	},
}



Config.Workbenches = {

	--[[ dont change order ]] 
	{access = true, coords = vector3(114.5064, -2669.8132, 6.0030), jobs = {}, blip = false, recipes = {}, radius = 3.0 , category = 'Printer', Text = '[~b~E~w~] REDZONE CRAFTS',Title = "3DGun",label="3DGun Bench"},
	{access = true, coords = vector3(948.6526, -198.2546, 79.2920), jobs = {}, blip = true, recipes = {}, radius = 3.0 , category = 'work', Text = '[~b~E~w~] Craft Drugs',Title = "Drugs",label="Drugs Crafting"},
	{access = true, coords = vector3(687.2953, 1268.5927, 354.9359), jobs = {}, blip = true, recipes = {}, radius = 3.0 , category = 'work', Text = '',Title = "Drugs",label="Drugs Crafting"},
	{access = true, coords = vector3(-1243.2657, 779.4111, 189.3623), jobs = {}, blip = true, recipes = {}, radius = 3.0 , category = 'work', Text = '',Title = "Drugs",label="Drugs Crafting"},
	{access = true, coords = vector3(-282.4997, -2209.0269, 11.0689), jobs = {}, blip = false, recipes = {}, radius = 3.0 , category = 'Prmgunlicense', Text = '[~b~E~w~] GUN CRAFT',Title = "GUNPLUG",label="GUN PLUG"},
	{access = true, coords = vector3(17.0891, -1106.3145, 29.7972), jobs = {}, blip = false, recipes = {}, radius = 3.0 , category = 'Bullets', Text = '',Title = "Bullets",label="Bullet Crafting"},
	{access = true, coords = vector3(13.6256, -1099.7574, 29.7443), jobs = {}, blip = false, recipes = {}, radius = 4.0 , category = 'Bullets', Text = '',Title = "Bullets",label="Bullet Crafting"},
	--{access = true, coords = vector3(-282.4337, -2208.8320, 10.0706), jobs = {}, blip = false, recipes = {}, radius = 3.0 , category = 'fgpfive', Text = '[~b~E~w~] GUN CRAFT',Title = "WeaponCraft",label="Weapons"},
	{access = true, coords = vector3(-4.6983, -185.7572, 57.0794), jobs = {}, blip = false, recipes = {}, radius = 3.0 , category = 'shoestore', Text = '',Title = "Shoes",label="Shoes Crafting"},
	{access = true, coords = vector3(109.9286, -1100.0826, 29.3077), jobs = {}, blip = false, recipes = {}, radius = 3.0 , category = 'drugs', Text = '',Title = "drugs",label="Bubba Crafting"},
}
 

Config.Text = {

    ['not_enough_ingredients'] = 'You dont have enough ingredients',
	['not_enough_level'] = 'You dont have the necessary craft level',
    ['you_cant_hold_item'] = 'You cant hold the item',
    ['item_crafted'] = 'Item crafted!',
    ['wrong_job'] = 'You cant open this workbench',
    ['workbench_hologram'] = '[~b~E~w~] Workbench',
    ['wrong_usage'] = 'Wrong usage of command',
    ['inv_limit_exceed'] = 'Inventory limit exceeded! Clean up before you lose more',
    ['crafting_failed'] = 'You failed to craft the item!'

}



