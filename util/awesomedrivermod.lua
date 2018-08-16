--
-- Create by TheVirtualCrew
--

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
  setting = {
    enable = true,
    enable_force = false,
    disable_before_research = true,
    sidebar = {
      show_sidebar = true,
      show_hits = true,
      show_last_hit_time = true,
      show_last_driving_hit_time = true,
      show_highscore = true,
      show_force_hits = false,
      show_force_last_hit_time = false,
      show_force_highscore = false,
      show_buttons = false,
    },
  },
  player_setting = {},
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
        driving_ticks = 0,
        last_enter_tick = 0,
        highscore = 0,
        last_entity_position = { x = nil, y = nil }
      }
    end

    if not self.player_setting[player.index] then
      self.player_setting[player.index] = util.table.deepcopy(self.setting.sidebar)
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
        last_hit_tick = game.tick,
        highscore = 0,
      }
    end
  end,
  set_setting = function(self, key, value, player, global)
    local object
    if string.find(key, 'global') ~= nil then
      if (string.find(key, '.sidebar')) then

      else
      end

      local object = self.setting.sidebar
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

      local driving_ticks = playerData.driving_ticks + (game.tick - playerData.last_enter_tick)
      if (playerData.highscore < driving_ticks) then
        playerData.highscore = driving_ticks
      end
      playerData.driving_ticks = 0
      playerData.last_enter_tick = game.tick

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
  end,
  get_player_current_driving_time = function(self, player)
    local playerData = self:get_player_data(player)
    if playerData and playerData.is_driving then
      return playerData.driving_ticks + (game.tick - playerData.last_enter_tick)
    elseif playerData then
      return playerData.driving_ticks
    end

    return false
  end,
  on_research_finished = function(self, event)
    local tech = event.research

    if settings.global["awesomedrivermod-hide-when-car-not-researched"].value then
      if tech.valid and tech.name == 'automobilism' and tech.researched and tech.force and #tech.force.players > 0 then
        for _, player in pairs(tech.force.players) do
          self:init_player(player)
        end
      end
    end

  end,
  on_runtime_mod_setting_changed = function(self, event)
    local setting = event.setting
    local prefix = self.data.prefix

    if setting == "awesomedrivermod-hide-when-car-not-researched" then
      for _, player in pairs(game.players) do
        if player.gui.left[prefix .. "flow"] then
          player.gui.left[prefix .. "flow"].destroy()
        end
        self:init_player(player)
      end
    elseif setting == "awesomedrivermod-show-table" then
      local player = game.players[event.player_index]
      if player and player.valid then
        gui:get_table(player)
      end
    end
  end,
  on_player_driving_changed_state = function(self, event)
    local player = game.players[event.player_index]
    local entity = event.entity
    local playerData = self:get_player_data(player)

    if playerData.is_driving and (not entity or (entity and entity.type == 'car')) then
      playerData.is_driving = false
      playerData.driving_ticks = playerData.driving_ticks + (game.tick - playerData.last_enter_tick)
    elseif not playerData.is_driving and entity and entity.type == 'car' then
      playerData.is_driving = true
      playerData.last_enter_tick = game.tick
    end
  end
}

return awesomedrivermod
