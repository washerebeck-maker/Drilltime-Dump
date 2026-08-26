Config = {
	uncarryZone = {
		points = {
			vector3(-1258.6223, 677.4656, 10),
			vector3(-1257.8907, 629.1152, 10),
			vector3(-1342.4801, 624.6143, 10),
			vector3(-1344.8429, 683.2642, 10),
		},
		thickness = 100,
		debug = false,
	},
	carryRadius = 3.0,
	cooldownMs = 30000,
	carry = {
		carrier = {
			dict = 'missfinale_c2mcs_1',
			anim = 'fin_c2_mcs_1_camman',
			controlFlag = 50,
		},
		target = {
			dict = 'nm',
			anim = 'firemans_carry',
			controlFlag = 33,
		},
		duration = 100000,
		attach = {
			distans = 0.15,
			distans2 = 0.27,
			height = 0.63,
			spin = 0.0,
		},
	},
}
