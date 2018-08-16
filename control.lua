--
-- Create by TheVirtualCrew
--

require('util');
require("mod-gui")
local gui = require("util/gui")
local awesomedrivermod = require("util/awesomedrivermod")

script.on_event(defines.events.on_player_joined_game, function(event)
  local player = game.players[event.player_index]
  awesomedrivermod:init_player(player)
end)

script.on_nth_tick(60, function(e)
  if awesomedrivermod.globalSetup then
    gui:update_time_display()
  end
end)

script.on_event({ defines.events.on_entity_damaged, defines.events.on_entity_died }, function(event)
  awesomedrivermod:trigger_hit(event)
end)

script.on_event({ defines.events.on_gui_click }, function(event)
  gui:on_gui_click(event)
end)

-- setup: Make sure the data is accesible when changing/updating mods
script.on_init(function()
  awesomedrivermod:init_global()
  if game and #game.players >= 1 then
    for _, player in pairs(game.players) do
      awesomedrivermod:init_player(player);
    end
  end
end)

script.on_load(function()
  awesomedrivermod:init_global()
end)

script.on_event(defines.events.on_research_finished, function(event)
  awesomedrivermod:on_research_finished(event);
end)

script.on_event(defines.events.on_force_created, function(event)
  awesomedrivermod:init_force(event.force)
end)

script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
  awesomedrivermod:on_runtime_mod_setting_changed(event)
end)

script.on_event(defines.events.on_player_driving_changed_state, function(event)
  awesomedrivermod:on_player_driving_changed_state(event)
end)
