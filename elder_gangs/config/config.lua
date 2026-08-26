Config = {}

Config.DefaultAvatar = 'https://r2.fivemanage.com/lUIl47xHuNITHA2Mzmaz1/250.gif'

Config.Ranks = {
  [1] = { name = 'Recrut',  canManageGang = false, isLeader = false, isDefault = true },
  [2] = { name = 'Store Runner',  canManageGang = false, isLeader = false, isDefault = false },
  [3] = { name = 'Soldier',  canManageGang = false, isLeader = false, isDefault = false },
  [4] = { name = 'Gangster',  canManageGang = false, isLeader = false, isDefault = false },
  [5] = { name = 'Original Gangster', canManageGang = true,  isLeader = false, isDefault = false },
  [6] = { name = 'Leader',  canManageGang = true,  isLeader = true,  isDefault = false },
}

Config.PoliceJob = 'police'

Config.CopsInHoodCoolDown = 5 * 60
Config.ShootingCoolDown   = 5 * 60

Config.HoodAlert = {
  Enabled   = true,
  Resource  = 'mythic_notify',
  OwnHood   = true,      
  Id        = 'Gangs',    
  EnterType = 'error',
  Enter     = 'Beware you are entered {hood} hood, move tact',
  ExitType  = 'Success',
  Exit      = 'You have left {hood} hood',
}

Config.MaxDrugsAmount = 100
Config.SellDuration   = 30 * 60
Config.DrugTax        = 0.05
Config.MaxCraftAmount = 45

Config.RobTimer                = 180
Config.MaxRadiusToRob          = 15.0
Config.RobCooldown             = 1.5 * 60 * 60
Config.RequiredGangNumberToRob = 3
Config.RobSkillCheck           = { 'hard', 'hard', 'hard' }

Config.OpsPerLevel = 340

Config.PlayerMissions = {
  { item = 'coke_pooch', count = 330, extraXp = 185, extraMoney = 11500 },
  { item = 'meth_poooch', count = 370, extraXp = 170, extraMoney = 23000 },
  { item = 'lsdtab', count = 340, extraXp = 170, extraMoney = 71500 },
  { item = 'double_cup', count = 220, extraXp = 260, extraMoney = 23500 },
  { item = 'bottle_xanaxnew', count = 340, extraXp = 170, extraMoney = 33500 },
  { item = 'pooch_whippets', count = 340, extraXp = 170, extraMoney = 33500 },
  { item = 'finxsdwax', count = 420, extraXp = 235, extraMoney = 18500 },
  { item = 'newdrugxll', count = 288, extraXp = 300, extraMoney = 17500 },
  { item = 'oxycodone', count = 300, extraXp = 300, extraMoney = 12500 },
  { item = 'pooch_romm', count = 300, extraXp = 300, extraMoney = 12500 },
  { item = 'tuzi_pooch', count = 275, extraXp = 250, extraMoney = 15500 },
  { item = 'crackpooch3000', count = 320, extraXp = 200, extraMoney = 31500 },
  { item = 'wwbagogx', count = 275, extraXp = 215, extraMoney = 51500 },
  { item = 'runtzbagog', count = 275, extraXp = 330, extraMoney = 51500 },
  { item = 'prjbaby1', count = 375, extraXp = 325, extraMoney = 43500 },
}

Config.GangMissions = {
  { item = 'coke_pooch',   count = 2780, extraXp = 3300 },
  { item = 'meth_poooch',   count = 2250, extraXp = 3200 },
  { item = 'lsdtab', count = 2220, extraXp = 3500 },
  { item = 'double_cup',   count = 2780, extraXp = 4000 },
  { item = 'pooch_whippets',  count = 2360, extraXp = 3500 },
  { item = 'finxsdwax',   count = 2050, extraXp = 3200 },
  { item = 'newdrugxll', count = 2520, extraXp = 3500 },
  { item = 'oxycodone',   count = 2180, extraXp = 3000 },
  { item = 'pooch_romm',   count = 2180, extraXp = 3000 },
  { item = 'bottle_xanaxnew',   count = 2180, extraXp = 3000 },
  { item = 'tuzi_pooch',  count = 2100, extraXp = 3500 },
  { item = 'crackpooch3000', count = 2420, extraXp = 3500 },
  { item = 'runtzbagog',   count = 2280, extraXp = 4000 },
  { item = 'wwbagogx',  count = 2200, extraXp = 4500 },
  { item = 'prjbaby1',   count = 2380, extraXp = 3620 },
}

Config.GangMissionWindowSec = 24 * 60 * 60

Config.Kos = {
  OnlineMembers = 3,
  LockDuration  = 15 * 60,
  Label         = '%s',
  Sprite        = 84,
  Colour        = 0,
  Scale         = 1.0,
  ShortRange    = true,
  AreaScale     = 1.0,
  AreaAlpha     = 128,

  ActiveColour     = 27,
  ActiveShortRange = false,
  ActiveDuration   = 7 * 60,

  NotifyDuration = 60000,
  NotifyTarget = {
    Gang        = '',
    Title       = 'KOS NOTIFICATION',
    Description = 'Slide to your block {target} gang is waiting for yall',
    Type        = 'kos',
  },
  NotifyCaller = {
    Gang        = '',
    Title       = 'KOS NOTIFICATION',
    Description = 'Pull up to {target} block for backup !',
    Type        = 'kos',
  },
}

