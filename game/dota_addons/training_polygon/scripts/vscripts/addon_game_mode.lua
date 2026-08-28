-- This is the entry-point to your game mode and should be used primarily to precache models/particles/sounds/etc

require('internal/util')
require('gamemode')

function Precache( context )

  PrecacheResource("soundfile", "soundevents/custom_sounds.vsndevts", context)
  PrecacheResource("particle", "particles/econ/events/ti8/msg_deny_ti8.vpcf", context)
  PrecacheResource("particle", "particles/newplayer_fx/last_hit_streak.vpcf", context)
  PrecacheResource("particle", "particles/custom/range_display.vpcf", context)
  PrecacheResource("particle", "particles/ui_mouseactions/range_display.vpcf", context)
  PrecacheModel("models/items/kunkka/kunkka_immortal/kunkka_shark_fin.vmdl", context)
  PrecacheModel("models/items/kunkka/kunkka_immortal/kunkka_shark_immortal.vmdl", context)
  PrecacheModel("models/items/kunkka/kunkka_immortal/kunkka_shark_immortal_splash_a.vmdl", context)

end

-- Create the game mode when we activate
function Activate()
  GameRules.GameMode = GameMode()
  GameRules.GameMode:_InitGameMode()
end

