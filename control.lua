require('util');
require("mod-gui")
local gui = require("util/gui")

local equalPosition = function(a, b)
  if a.x == nil or b.x == nil or a.y == nil or b.y == nil then return false end
  return a.x == b.x and a.y == b.y
end

local awesomedrivermod = {
  data = {
    forces = {},
    count_spacer = 60,
    prefix = 'awesomedrivermod_',
    player = {}
  },
  globalSetup = false,
  init_player = function(self, player)
    self:init_global()

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
        last_entity_position = { x = nil, y = nil }
      }
    end

    self:init_force(player.force)

    local gui = gui
    gui:reset_tables()
    gui:get_table(player)
  end,
  init_global = function(self)
    if self.globalSetup == false then
      self.globalSetup = true
    end
    local gui = gui
    if gui.parent == nil then
      gui.parent = self
    end
  end,
  init_force = function(self, force)
    if force and force.valid and not self.is_ignored_force(force) and not self.data.forces[force.name] then
      self.data.forces[force.name] = {
        counter = 0,
        last_hit_tick = game.tick
      }
    end
  end,
  trigger_hit = function(self, event)
    if not event.cause
        or not event.cause.valid
        or event.cause.type ~= 'car'
        or self.is_ignored_force(event.entity.force)
        or self.is_ignored_force(event.force) then
      return
    end

    local player = event.cause.get_driver() and event.cause.get_driver().player
    local equalPosition = equalPosition
    local gui = gui
    local entity_driver = event.entity.type == 'car' and event.entity.get_driver()

    -- check if not hitting ourselves
    if entity_driver and entity_driver.player and entity_driver.player.name == player.name then
      return
    end

    if not player or not player.valid or self.is_ignored_force(player.force) then
      return
    end

    local playerData = self:get_player_data(player)

    if (not equalPosition(event.entity.position, playerData.last_entity_position)
        or (equalPosition(event.entity.position, playerData.last_entity_position)
        and playerData.last_hit_tick < (game.tick - self.data.count_spacer))) then
      local forceData = self:get_force_data(player.force)

      forceData.counter = forceData.counter + 1
      forceData.last_hit_tick = game.tick
      playerData.last_entity_position = event.entity.position
      playerData.counter = playerData.counter + 1
      playerData.last_hit_tick = forceData.last_hit_tick

      gui:update_table()
    end
  end,
  is_ignored_force = function(force)
    local disallow = {
      enemy = true,
      spectator = true,
      neutral = true
    }

    if not force or not force.valid then return false end

    return disallow[force.name] or false
  end,
  get_force_data = function(self, force)
    if not force or not force.valid or self.is_ignored_force(force) or not self.data.forces[force.name] then
      return false
    end

    return self.data.forces[force.name]
  end,
  get_player_data = function(self, player)
    if not player or not player.valid or not self.data.player[player.index] then
      return false
    end

    return self.data.player[player.index]
  end
}

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
  if #game.players >= 1 then
    for _, player in pairs(game.players) do
      awesomedrivermod:init_player(player);
    end
  end
end)

script.on_load(function()
  awesomedrivermod:init_global()
  if #game.players >= 1 then
    for _, player in pairs(game.players) do
      awesomedrivermod:init_player(player);
    end
  end
end)

script.on_event(defines.events.on_research_finished, function(event)
  local tech = event.research

  if settings.global["awesomedrivermod-hide-when-car-not-researched"].value then
    if tech.valid and tech.name == 'automobilism' and tech.researched and tech.force and #tech.force.players > 0 then
      for _, player in pairs(tech.force.players) do
        awesomedrivermod:init_player(player)
      end
    end
  end
end)

script.on_event(defines.events.on_force_created, function(event)
  awesomedrivermod:init_force(event.force)
end)

script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
  local setting = event.setting
  local prefix = awesomedrivermod.data.prefix

  if setting == "awesomedrivermod-hide-when-car-not-researched" then
    for _, player in pairs(game.players) do
      if player.gui.left[prefix .. "flow"] then
        player.gui.left[prefix .. "flow"].destroy()
      end
      awesomedrivermod:init_player(player)
    end
  elseif setting == "awesomedrivermod-show-table" then
    local player = game.players[event.player_index]
    if player and player.valid then
      gui:get_table(player)
    end
  end
end)
