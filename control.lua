require('util');
require("mod-gui")
local gui = require("util/gui")

local equalPosition = function(a, b)
  return a.x == b.x and a.y == b.y
end

local awesomedrivermod = {
  data = {
    counter = 0,
    last_hit_tick = 0,
    count_spacer = 60,
    prefix = 'awesomedrivermod_',
    player = {}
  },
  globalSetup = false,
  initPlayer = function(self, player)
    self:initGlobal()

    if settings.global["awesomedrivermod-hide-when-car-not-researched"].value then
      local research = player.force.technologies.automobilism;
      if research and research.valid and not research.researched then
        return
      end
    end

    if self.data.player[player.index] == nil then
      self.data.player[player.index] = {
        counter = 0,
        last_hit_tick = 0,
        last_entity_position = {}
      }
    end

    local gui = gui
    gui:reset_tables()
    gui:get_table(player)
  end,
  initGlobal = function(self)
    if self.globalSetup == false then
      self.globalSetup = true
    end
    local gui = gui
    if gui.parent == nil then
      gui.parent = self
    end
  end,
  trigger_hit = function(self, event)
    if event.entity.type == 'car'
        or not event.cause
        or event.cause.type ~= 'car'
        or event.entity.force.name ~= 'player'
        or not event.force or event.force.name ~= 'player' then
      return
    end

    local player = event.cause.get_driver().player
    local equalPosition = equalPosition
    local gui = gui

    if ((not equalPosition(event.entity.position, self.data.player[player.index].last_entity_position)
        or (equalPosition(event.entity.position, self.data.player[player.index].last_entity_position) and self.data.player[player.index].last_hit_tick < (game.tick - self.data.count_spacer)))) then
      self.data.counter = self.data.counter + 1
      self.data.last_hit_tick = game.tick
      self.data.player[player.index].last_entity_position = event.entity.position
      self.data.player[player.index].counter = self.data.player[player.index].counter + 1
      self.data.player[player.index].last_hit_tick = self.data.last_hit_tick

      gui:update_table()
    end
  end
}

script.on_event(defines.events.on_player_joined_game, function(event)
  local player = game.players[event.player_index]
  awesomedrivermod:initPlayer(player)
end)

script.on_nth_tick(60, function(e)
  if awesomedrivermod.globalSetup then
    gui:update_time_display()
  end
end)

script.on_event({ defines.events.on_entity_damaged }, function(event)
  awesomedrivermod:trigger_hit(event)
end)

script.on_event({ defines.events.on_entity_died }, function(event)
  awesomedrivermod:trigger_hit(event)
end)

script.on_event({ defines.events.on_gui_click }, function(event)
  gui:on_gui_click(event)
end)


-- setup: Make sure the data is accesible when changing/updating mods
script.on_init(function()
  awesomedrivermod:initGlobal()
  if #game.players >= 1 then
    for _,player in pairs(game.players) do
      awesomedrivermod:initPlayer(player);
    end
  end
end)

script.on_load(function()
  awesomedrivermod:initGlobal()
  if #game.players >= 1 then
    for _,player in pairs(game.players) do
      awesomedrivermod:initPlayer(player);
    end
  end
end)

script.on_event(defines.events.on_research_finished, function(event)
  local tech = event.research

  if settings.global["awesomedrivermod-hide-when-car-not-researched"].value then
    if tech.valid and tech.name == 'automobilism' and tech.researched and tech.force and #tech.force.players > 0 then
      for _, player in pairs(tech.force.players) do
        awesomedrivermod:initPlayer(player)
      end
    end
  end
end)

script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
  local setting = event.setting
  local prefix = awesomedrivermod.data.prefix

  if setting == "awesomedrivermod-hide-when-car-not-researched" then
    for _, player in pairs(game.players) do
      if player.gui.left[prefix .. "flow"] then
        player.gui.left[prefix .. "flow"].destroy()
      end
    end
  elseif setting == "awesomedrivermod-show-table" then
    local player = game.players[event.player_index]
    if player and player.valid then
      gui:get_table(player)
    end
  end
end)
