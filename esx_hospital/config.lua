Config = {}

Config.EnableBlips = false
Config.EnablePeds = true

Config.DoctorLimit = false
Config.maxDoctor = 0
Config.doctorPrice = 5000
Config.Doctor = {
	{x = 309.5407, y = -593.8032, z = 43.2840, heading = 350.4, type = 'legal'},
	{x = -1265.7107, y = 327.4467, z = 65.4975, heading = 98.3668, type = 'legal'},
	{x = -864.8069, y = -2163.3555, z = 9.8725, heading = 137.6117, type = 'legal'},
	{x = 1988.7032, y = 4009.9031, z = 35.6080, heading = 243.4396, type = 'legal'}
}

Config.Clutch = {
	Locations = {
		{ coords = vector4(61.6725, -155.6025, 1.8600, 206.2210), therapy_room = vector4(64.2488, -73.6187, 4.8061, 94.9899)},
	},
	EnableNPC = true,
	Price = 9000,
	AnimDuration = 20, --seconds
	Anim = 'amb@world_human_yoga@female@base',
	NPCModel = 's_m_m_paramedic_01'
}

function DrawText3D(x,y,z,text,size)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)

    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text)) / 370
    DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 41, 11, 41, 68)
end