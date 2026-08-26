-----------------For support, scripts, and more----------------
--------------- https://discord.gg/wasabiscripts  -------------
---------------------------------------------------------------

Config = {}

Config.PaymentAccount = 'bank' -- Payment account you want to pay from(For example; 'money', 'bank', 'black_money')

Config.ClothingShops = {

	{
		blip = {
			enabled = true, -- Blip enabled?
			sprite = 73, -- The Blip type. List: https://docs.fivem.net/docs/game-references/blips/#blips
			color = 47, -- The Blip color. List: https://docs.fivem.net/docs/game-references/blips/#blip-colors
			scale = 1.0, -- Size of blip
			string = 'Clothing Shop'
		},
		coords = vec3(1693.2, 4828.11, 42.07), -- Coords of shop
		distance = 7, -- Distance to show text UI pormpt
		price = 1200, -- Price to use this shop(False for free)
	},

	{
		blip = {
			enabled = true, 
			sprite = 73, 
			color = 47, 
			scale = 1.0, 
			string = 'Clothing Shop'
		},
		coords = vec3(155.1893, -1094.4204, 29.3650),
		distance = 10, 
		price = 1200, 
	},

	{
		blip = {
			enabled = false, 
			sprite = 73, 
			color = 47, 
			scale = 1.0, 
			string = 'Clothing Shop'
		},
		coords = vec3(-3334.9785, 1806.9288, 38.5088),
		distance = 5, 
		price = 1200, 
	},

	{
		blip = {
			enabled = false, 
			sprite = 73, 
			color = 47, 
			scale = 1.0, 
			string = 'Clothing Shop'
		},
		coords = vec3(-435.2807, 1098.5719, 330.9964),
		distance = 5, 
		price = 1200, 
	},

	{
		blip = {
			enabled = false, 
			sprite = 73, 
			color = 47, 
			scale = 1.0, 
			string = 'Clothing Shop'
		},
		coords = vec3(-1232.7880, 818.7059, 194.1455),
		distance = 5, 
		price = 1200, 
	},

	{
		blip = {
			enabled = true, 
			sprite = 73, 
			color = 47, 
			scale = 0.8, 
			string = 'Clothing Shop'
		},
		coords = vec3(1172.7880, -1305.8462, 35.2794),
		distance = 8, 
		price = 1200, 
	},

	{
		blip = {
			enabled = true, 
			sprite = 73, 
			color = 47, 
			scale = 1.0, 
			string = 'Clothing Shop'
		},
		coords = vec3(-322.2168, -1923.0046, 21.4812),
		distance = 8, 
		price = 1200, 
	},

	{
		blip = {
			enabled = false, 
			sprite = 73, 
			color = 47, 
			scale = 1.0, 
			string = 'Clothing Shop'
		},
		coords = vec3(704.1473, 1257.7803, 365.0709),
		distance = 3, 
		price = 1200, 
	},

	{
		blip = {
			enabled = false, 
			sprite = 73, 
			color = 47, 
			scale = 1.0, 
			string = 'Clothing Shop'
		},
		coords = vec3(-3346.2485, 566.7565, 16.5978),
		distance = 4, 
		price = 1200, 
	},

	{
		blip = {
			enabled = false, 
			sprite = 73, 
			color = 47, 
			scale = 1.0, 
			string = 'Clothing Shop'
		},
		coords = vec3(-2595.3894, 1914.3357, 163.7213),
		distance = 3, 
		price = 100, 
	},

	{
		blip = {
			enabled = false, 
			sprite = 73, 
			color = 47, 
			scale = 1.0, 
			string = 'Clothing Shop'
		},
		coords = vec3(-619.0461, 1259.3677, 330.2077),
		distance = 3, 
		price = 1200, 
	},

	{
		blip = {
			enabled = true, 
			sprite = 73, 
			color = 47, 
			scale = 1.0, 
			string = 'Clothing Shop'
		},
		coords = vec3(-705.5, -149.22, 37.42),
		distance = 7, 
		price = 1200, 
	},

	{
		blip = {
			enabled = false, 
			sprite = 73, 
			color = 47, 
			scale = 1.0, 
			string = 'Clothing Shop'
		},
		coords = vec3(-796.2230, 332.1716, 153.8050),
		distance = 3, 
		price = 1200, 
	},

	{
		blip = {
			enabled = false, 
			sprite = 73, 
			color = 47, 
			scale = 1.0, 
			string = 'Clothing Shop'
		},
		coords = vec3(175.1087, 619.7775, 212.1012),
		distance = 3, 
		price = 1200, 
	},

	{
		blip = {
			enabled = false, 
			sprite = 73, 
			color = 47, 
			scale = 1.0, 
			string = 'Clothing Shop'
		},
		coords = vec3(261.2266, -1003.1484, -99.0086),
		distance = 2, 
		price = 1200, 
	},

	{
		blip = {
			enabled = false, 
			sprite = 73, 
			color = 47, 
			scale = 1.0, 
			string = 'Clothing Shop'
		},
		coords = vec3(713.0703, 1257.6570, 360.3433),
		distance = 3, 
		price = 1200, 
	},

	{
		blip = {
			enabled = false, 
			sprite = 73, 
			color = 47, 
			scale = 1.0, 
			string = 'Clothing Shop'
		},
		coords = vec3(-144.9644, 1267.6569, 321.5937),
		distance = 4, 
		price = 1200, 
	},

	{
		blip = {
			enabled = false, 
			sprite = 73, 
			color = 47, 
			scale = 1.0, 
			string = 'Clothing Shop'
		},
		coords = vec3(-2836.2561, 1407.0123, 105.0900),
		distance = 3, 
		price = 1200, 
	},

	{
		blip = {
			enabled = false, 
			sprite = 73, 
			color = 47, 
			scale = 1.0, 
			string = 'Clothing Shop'
		},
		coords = vec3(374.1450, 410.3493, 142.1003),
		distance = 2, 
		price = 1200, 
	},

	{
		blip = {
			enabled = false, 
			sprite = 73, 
			color = 47, 
			scale = 1.0, 
			string = 'Clothing Shop'
		},
		coords = vec3(350.8386, -994.2687, -99.1472),
		distance = 2, 
		price = 1200, 
	},

	{
		blip = {
			enabled = false, 
			sprite = 73, 
			color = 47, 
			scale = 1.0, 
			string = 'Clothing Shop'
		},
		coords = vec3(-812.0980, 180.1259, 76.7455),
		distance = 4, 
		price = 1200, 
	},

	{
		blip = {
			enabled = false, 
			sprite = 73, 
			color = 47, 
			scale = 1.0, 
			string = 'Clothing Shop'
		},
		coords = vec3(461.5097, -997.4192, 31.1320),
		distance = 4, 
		price = 1200, 
	},

	{
		blip = {
			enabled = false, 
			sprite = 73, 
			color = 47, 
			scale = 1.0, 
			string = 'Clothing'
		},
		coords = vec3(-66.6421, 827.7715, 231.3299),
		distance = 3, 
		price = 1200, 
	},

	{
		blip = {
			enabled = true, 
			sprite = 73, 
			color = 47, 
			scale = 1.0, 
			string = 'Clothing Shop'
		},
		coords = vec3(1692.0994, 3653.5618, 35.3470),
		distance = 7, 
		price = 1200, 
	},

	{
		blip = {
			enabled = false, 
			sprite = 73, 
			color = 47, 
			scale = 1.0, 
			string = 'Clothing Shop'
		},
		coords = vec3(229.0965, -1483.0833, 29.3209),
		distance = 3, 
		price = 1200, 
	},

	{
		blip = {
			enabled = true, 
			sprite = 73, 
			color = 47, 
			scale = 1.0, 
			string = 'Clothing Shop'
		},
		coords = vec3(-1192.61, -768.4, 17.32),
		distance = 3, 
		price = 0, 
	},

	{
		blip = {
			enabled = false, 
			sprite = 73, 
			color = 47, 
			scale = 1.0, 
			string = 'Clothing Shop'
		},
		coords = vec3(138.1971, -1292.3759, 23.5624),
		distance = 3, 
		price = 0, 
	},

	{
		blip = {
			enabled = true, 
			sprite = 73, 
			color = 47, 
			scale = 1.0, 
			string = 'Clothing Shop'
		},
		coords = vec3(425.91, -801.03, 29.49),
		distance = 3, 
		price = 1200, 
	},

	{
		blip = {
			enabled = true, 
			sprite = 73, 
			color = 47, 
			scale = 1.0, 
			string = 'Clothing Shop'
		},
		coords = vec3(-168.73, -301.41, 39.73),
		distance = 3, 
		price = 1200, 
	},

	{
		blip = {
			enabled = true, 
			sprite = 73, 
			color = 47, 
			scale = 1.0, 
			string = 'Clothing Shop'
		},
		coords = vec3(75.39, -1398.28, 29.38),
		distance = 3, 
		price = 1200, 
	},

	{
		blip = {
			enabled = true, 
			sprite = 73, 
			color = 47, 
			scale = 1.0, 
			string = 'Clothing Shop'
		},
		coords = vec3(-827.39, -1075.93, 11.33),
		distance = 3, 
		price = 1200, 
	},

	{
		blip = {
			enabled = true, 
			sprite = 73, 
			color = 47, 
			scale = 1.0, 
			string = 'Clothing Shop'
		},
		coords = vec3(-1445.86, -240.78, 49.82),
		distance = 7, 
		price = 1200, 
	},

	{
		blip = {
			enabled = true, 
			sprite = 73, 
			color = 47, 
			scale = 1.0, 
			string = 'Clothing Shop'
		},
		coords = vec3(9.22, 6515.74, 31.88),
		distance = 7, 
		price = 1200, 
	},

	{
		blip = {
			enabled = true, 
			sprite = 73, 
			color = 47, 
			scale = 1.0, 
			string = 'Clothing Shop'
		},
		coords = vec3(615.35, 2762.72, 42.09),
		distance = 7, 
		price = 1200, 
	},

	{
		blip = {
			enabled = true, 
			sprite = 73, 
			color = 47, 
			scale = 0.3, 
			string = 'Clothing Shop'
		},
		coords = vec3(1191.61, 2710.91, 38.22),
		distance = 12, 
		price = 1200, 
	},

	{
		blip = {
			enabled = false, 
			sprite = 73, 
			color = 47, 
			scale = 0.3, 
			string = 'Clothing Shop'
		},
		coords = vec3(107.6100, -1304.2572, 29.2189),
		distance = 4, 
		price = 0, 
	},

	{
		blip = {
			enabled = true, 
			sprite = 73, 
			color = 47, 
			scale = 0.3, 
			string = 'Clothing Shop'
		},
		coords = vec3(-3171.32, 1043.56, 20.86),
		distance = 12, 
		price = 1200, 
	},

	{
		blip = {
			enabled = true, 
			sprite = 73, 
			color = 47, 
			scale = 1.0, 
			string = 'Clothing Shop'
		},
		coords = vec3(-1105.52, 2707.79, 19.11),
		distance = 7, 
		price = 1200, 
	},

	{
		blip = {
			enabled = true, 
			sprite = 73, 
			color = 47, 
			scale = 1.0, 
			string = 'Clothing Shop'
		},
		coords = vec3(-1119.24, -1440.6, 5.23),
		distance = 7, 
		price = 1200, 
	},

	{
		blip = {
			enabled = true, 
			sprite = 73, 
			color = 47, 
			scale = 1.0, 
			string = 'Clothing Shop'
		},
		coords = vec3(124.82, -224.36, 54.56),
		distance = 7, 
		price = 1200, 
	},
}

Config.BarberShops = {

	{
		blip = {
			enabled = false,
			sprite = 71, 
			color = 8, 
			scale = 1.0,
			string = 'Hair Salon'
		},
		coords = vec3(-278.1253, -1947.2382, 29.9856), 
		distance = 5,
		price = 1450,
	},


	{
		blip = {
			enabled = true,
			sprite = 71, 
			color = 8, 
			scale = 1.0,
			string = 'Hair Salon'
		},
		coords = vec3(-1443.2546, -395.8094, 35.8594), 
		distance = 4,
		price = 1450,
	},
}

Config.TattooShops = {

	{
		blip = {
			enabled = false,
			sprite = 75, 
			color = 1, 
			scale = 1.0,
			string = 'Tattoo Shop'
		},
		coords = vec3(1322.6, -1651.9, 51.2), 
		distance = 7,
		price = 350,
	},

}
--=========================================================
--		SOLUTION FOR INVISIBLE PLAYER
--=========================================================

Config.DefaultSkin = {
	["headOverlays"]={
		["eyebrows"]={["style"]=0,["color"]=0,["opacity"]=0},
		["makeUp"]={["style"]=0,["color"]=0,["opacity"]=0},
		["bodyBlemishes"]={["style"]=0,["color"]=0,["opacity"]=0},
		["blush"]={["style"]=0,["color"]=0,["opacity"]=0},
		["ageing"]={["style"]=0,["color"]=0,["opacity"]=0},
		["beard"]={["style"]=0,["color"]=0,["opacity"]=0},
		["moleAndFreckles"]={["style"]=0,["color"]=0,["opacity"]=0},
		["blemishes"]={["style"]=0,["color"]=0,["opacity"]=0},
		["chestHair"]={["style"]=0,["color"]=0,["opacity"]=0},
		["lipstick"]={["style"]=0,["color"]=0,["opacity"]=0},
		["sunDamage"]={["style"]=0,["color"]=0,["opacity"]=0},
		["complexion"]={["style"]=0,["color"]=0,["opacity"]=0}
	},
	["faceFeatures"]={
		["jawBoneWidth"]=0,
		["chinBoneLowering"]=0,
		["eyesOpening"]=0,
		["eyeBrownHigh"]=0,
		["jawBoneBackSize"]=0,
		["cheeksBoneHigh"]=0,
		["eyeBrownForward"]=0,
		["nosePeakHigh"]=0,
		["neckThickness"]=0,
		["nosePeakLowering"]=0,
		["chinBoneLenght"]=0,
		["noseWidth"]=0,
		["noseBoneHigh"]=0,
		["chinBoneSize"]=0,
		["nosePeakSize"]=0,
		["cheeksBoneWidth"]=0,
		["noseBoneTwist"]=0,
		["chinHole"]=0,
		["cheeksWidth"]=0,
		["lipsThickness"]=0
	},
	["headBlend"]={
		["shapeMix"]=0,
		["shapeSecond"]=0,
		["skinSecond"]=0,
		["shapeFirst"]=0,
		["skinMix"]=0,
		["skinFirst"]=0
	},
	["components"]={
		{["drawable"]=0,["texture"]=0,["component_id"]=0},
		{["drawable"]=0,["texture"]=0,["component_id"]=1},
		{["drawable"]=0,["texture"]=0,["component_id"]=2},
		{["drawable"]=0,["texture"]=0,["component_id"]=3},
		{["drawable"]=0,["texture"]=0,["component_id"]=4},
		{["drawable"]=0,["texture"]=0,["component_id"]=5},
		{["drawable"]=0,["texture"]=0,["component_id"]=6},
		{["drawable"]=0,["texture"]=0,["component_id"]=7},
		{["drawable"]=0,["texture"]=0,["component_id"]=8},
		{["drawable"]=0,["texture"]=0,["component_id"]=9},
		{["drawable"]=0,["texture"]=0,["component_id"]=10},
		{["drawable"]=0,["texture"]=0,["component_id"]=11}
	},
	["props"]={
		{["drawable"]=-1,["prop_id"]=1,["texture"]=-1},
		{["drawable"]=-1,["prop_id"]=2,["texture"]=-1},
		{["drawable"]=-1,["prop_id"]=6,["texture"]=-1},
		{["drawable"]=-1,["prop_id"]=7,["texture"]=-1},
		{["drawable"]=-1,["prop_id"]=0,["texture"]=-1}
	},
	["hair"]={
		["style"]=0,
		["highlight"]=0,
		["color"]=0
	},
	["tattoos"]={},
	["eyeColor"]=-1,
	["model"]="mp_m_freemode_01"
}
