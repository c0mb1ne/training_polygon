"use strict";
/*
client-side mirror of the UserConfig lua singleton (libraries/user_config.lua).
the server owns the data: this cache is filled by the "user_config_load" event
and updated optimistically on Set; saving to the backend is debounced server-side.

usage in any ui js (include this file in the xml first):
  UserConfigClient.OnLoad(function(){ ... UserConfigClient.Get("general","notif_good_sound") ... });
  UserConfigClient.Set("dodge", "camera_shake", false); //scope is "general" or a gamemode name
*/
//guard against double includes (menu pages and in-game huds share one js context):
//without it a second include would wipe the cache and duplicate the subscription
if (typeof UserConfigClient === "undefined") {
var UserConfigClient = (function () {
    var cache = { general: {}, modes: {} };
    var loaded = false;
    var loadCallbacks = [];

    function bucket(scope, create) {
        if (scope === "general") {
            return cache.general;
        }
        if (!cache.modes[scope] && create) {
            cache.modes[scope] = {};
        }
        return cache.modes[scope];
    }

    GameEvents.Subscribe("user_config_load", function (event) {
        if (event && event.data) {
            cache = event.data;
            if (!cache.general) { cache.general = {}; }
            if (!cache.modes) { cache.modes = {}; }
        }
        loaded = true;
        for (var i = 0; i < loadCallbacks.length; i++) {
            loadCallbacks[i](cache);
        }
        loadCallbacks = [];
    });

    return {
        Set: function (scope, key, value) {
            var b = bucket(scope, true);
            b[key] = value; //optimistic local update; the server validates and debounce-saves it
            GameEvents.SendCustomGameEventToServer("user_config_set", { scope: scope, key: key, value: value });
        },
        Get: function (scope, key) {
            var b = bucket(scope, false);
            return b ? b[key] : undefined;
        },
        //fires immediately if the config already arrived, otherwise waits for "user_config_load"
        OnLoad: function (cb) {
            if (loaded) {
                cb(cache);
            } else {
                loadCallbacks.push(cb);
            }
        },
        Request: function () {
            GameEvents.SendCustomGameEventToServer("user_config_get", {});
        },
        IsLoaded: function () {
            return loaded;
        }
    };
})();
UserConfigClient.Request();
} //end of double-include guard
