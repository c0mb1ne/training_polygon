if Notifications == nil then
  Notifications = class({})
end
--TODO: add icons to sounds to make them look cute, but i havent figure out how i can display emoticons properly without extracting them and putting in custom game files
function Notifications:Init()
  self.notificationsSounds={
    frog={sounds={"soundboard.frog"},icon="todo",displayName="frog"},
    sproing={sounds={"sproing"},icon="todo",displayName="sproing"},
    pain1={sounds={
        "dark_willow_sylph_pain_21",
        "wr_arc_pain_02",
        "qop_arc_pain_05",
        "qop_arc_pain_04",
        "pain_pain_03",
        "phass_pain_08",
        "phass_pain_06",
        "ench_pain_01",
        "ench_pain_06",
        "dro_pain_01",
        "dro_pain_03",
        "dro_pain_04",
        "dpro_pain_16",
        "dpro_pain_17",
        "winwyv_anger_03",
        "pain_anger_01",
        "naga_anger_03",
        "naga_anger_04",
        "luna_pain_05",
        "wind_pain_05"
      },
      icon="todo",
      displayName="pain1_pack"
    },
    oof={sounds={
        "bristleback_bristle_pain_01",
        "arc_warden_arcwar_pain_18",
        "warl_pain_03",
        "visa_pain_08",
        "tusk_pain_07",
        "slark_pain_07",
        "drag_pain_03",
        "jug_pain_08",
        "husk_pain_08"
      },
      icon="todo",
      displayName="oof_pack"
    },
    aaah={sounds={
        "vipe_pain_06",
        "snapfire_pain_09",
        "silen_pain_06",
        "pa_asan_pain_09",
        "pangolin_pain_21",
        "omni_pain_07",
        "magn_pain_03",
        "lion_pain_04",
        "grimstroke_pain_25"
      },
      icon="todo",
      displayName="aaah_pack"
    }
  }
  CustomGameEventManager:RegisterListener("notifications_get_sounds", function(_, event)
    Notifications:SendSounds()
  end)
  CustomGameEventManager:RegisterListener("notifications_set_sound", function(_, event)
    Notifications:SetSound(event)
  end)
  self.goodSound="frog"
  self.badSound="sproing"
end
function Notifications:Show(strColor,strText,strIcon)
  --color can be 'green' 'red'
  --text can be whatever, but would be nice to add support of localize string
  --icon can be 'none' 'pepega' 'pogchamp' or ability icon by name, for ex: 'axe_berserkers_call'
  local sound 
  if strColor=="green" then
    sound=self.goodSound
  else
    sound=self.badSound
  end
  local soundToPlay=self.notificationsSounds[sound].sounds[RandomInt(1,#self.notificationsSounds[sound].sounds)]
  print('[Notifications] Playing sound:',soundToPlay)
  CustomGameEventManager:Send_ServerToAllClients("show_notification",{color=strColor,text=strText,icon=strIcon,sound=soundToPlay})
end
function Notifications:SendSounds()
  CustomGameEventManager:Send_ServerToAllClients("notifications_send_sounds", {data=self.notificationsSounds})
end
function Notifications:SetSound(args)
  if args.type=="bad" then
    self.badSound=args.id
  end
  if args.type=="good" then
    self.goodSound=args.id
  end
  --[[ DeepPrintTable(args) ]]
end
Notifications:Init()