
local PlatesReplacements = {
    {
        texture1 = {name = 'plate01', texture = 'https://i.imgur.com/AaYnMK9.png',  width = 540, height = 300},
        texture2 = {name = 'plate01_n',  texture = 'https://i.imgur.com/Q3uw6V7.png', width = 540, height = 300},
    },
    {
        texture1 = {name = 'plate02', texture = 'https://i.imgur.com/AaYnMK9.png',  width = 540, height = 300},
        texture2 = {name = 'plate02_n',  texture = 'https://i.imgur.com/Q3uw6V7.png', width = 540, height = 300},
    },
    {
        texture1 = {name = 'plate03', texture = 'https://i.imgur.com/AaYnMK9.png',  width = 540, height = 300},
        texture2 = {name = 'plate03_n',  texture = 'https://i.imgur.com/Q3uw6V7.png', width = 540, height = 300},
    },
    {
        texture1 = {name = 'plate04', texture = 'https://i.imgur.com/AaYnMK9.png',  width = 540, height = 300},
        texture2 = {name = 'plate04_n',  texture = 'https://i.imgur.com/Q3uw6V7.png', width = 540, height = 300},
    },
    {
        texture1 = {name = 'plate05', texture = 'https://i.imgur.com/AaYnMK9.png',  width = 540, height = 300},
        texture2 = {name = 'plate05_n',  texture = 'https://i.imgur.com/Q3uw6V7.png', width = 540, height = 300},
    },
    {
        texture1 = {name = 'yankton_plate', texture = 'https://i.imgur.com/AaYnMK9.png',  width = 540, height = 300},
        texture2 = {name = 'yankton_plate_n',  texture = 'https://i.imgur.com/Q3uw6V7.png', width = 540, height = 300},
    },
}

for k,v in pairs(PlatesReplacements) do
    local textureDic = CreateRuntimeTxd('duiTxd')
    local object = CreateDui(v.texture1.texture, v.texture1.width, v.texture1.height)
    local handle = GetDuiHandle(object)
    CreateRuntimeTextureFromDuiHandle(textureDic, "duiTex", handle)
    AddReplaceTexture('vehshare', v.texture1.name, 'duiTxd', 'duiTex') 

    local object = CreateDui(v.texture2.texture, v.texture2.width, v.texture2.height) 
    local handle = GetDuiHandle(object) 
    CreateRuntimeTextureFromDuiHandle(textureDic, "duiTex2", handle) 
    AddReplaceTexture('vehshare', v.texture2.name, 'duiTxd', 'duiTex2') 
end


