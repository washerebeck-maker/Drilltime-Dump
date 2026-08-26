function canSellDealer(dealer, data) -- if you want to do some additional check, you can place your code here
    return true
end

Config.DrugDealerItems = {
    ['darkweb'] = {                   -- any unique name for this config
        pos = vector3(-843.82, 1147.28, 2.50), -- position of the dealer
        items = {
            blankss = {                       -- item name
                label = 'clone creditcards',            -- item label
                price = math.random(20000, 125000),   -- will be random between those two numbers in every server restart or you can use a fixed value
            },
        },
    },
    
}