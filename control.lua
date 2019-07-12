--
-- Create by TheVirtualCrew
--

require('util');
require("mod-gui")
events = {
  on_car_crash = script.generate_event_name()
}
global.data = {
  forces = {},
  count_spacer = 60,
  prefix = 'awesomedrivermod_',
  player = {},
  globalSetup = false
};
require("util/awesomedrivermod")
local awesomedrivermod = awesomedrivermod
require('util/gui');
local gui = gui

local function init_globals()
  global.data = global.data or {
    forces = {},
    count_spacer = 60,
    prefix = 'awesomedrivermod_',
    player = {},
    globalSetup = false
  };
  global.data.globalSetup = false;
end

script.on_event(defines.events.on_player_joined_game, function(event)
  local player = game.players[event.player_index]
  awesomedrivermod:init_player(player)
end)

script.on_event(defines.events.on_player_changed_force, function(event)
  local player = game.players[event.player_index]
  gui:reset_tables(true)
  awesomedrivermod:init_player(player)
end)

script.on_nth_tick(60, function(event)
  if (event.tick > 0) then
    if not global.data.globalSetup then
      awesomedrivermod:init_global()
      if game and #game.players >= 1 then
        for _, player in pairs(game.players) do
          awesomedrivermod:init_player(player);
        end
      end
    end
    if global.data.globalSetup then
      gui:update_time_display()
    end
  end
end)

script.on_event({ defines.events.on_entity_damaged, defines.events.on_entity_died }, function(event)
  awesomedrivermod:trigger_hit(event)
end)

script.on_event(defines.events.on_gui_click, function(event)
  gui:on_gui_click(event)
end)

-- setup: Make sure the data is accesible when changing/updating mods
script.on_init(function()
  init_globals();
end)

script.on_configuration_changed(function()
  init_globals();
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

remote.add_interface('most_awesome_driver', {
  get_event = function(name)
    if events[name] then
      return events[name]
    end
    return nil;
  end
});