--
-- Create by TheVirtualCrew
--

local mod_gui = require('mod-gui')

local gui = {
  parent = nil,
  multiplayer = false,
  init_player_gui = function(self, player)
    local button_flow = mod_gui.get_button_flow(player)
    local prefix = self.parent.data.prefix
    if not button_flow[prefix .. 'top_button'] then
    end

    self:get_table(player)
  end,
  get_table = function(self, player)
    local prefix = self.parent.data.prefix
    local flow = player.gui.left[prefix .. 'flow']

    if not player.valid or not player.mod_settings["awesomedrivermod-show-table"].value then
      if flow then
        flow.destroy()
      end
      return
    end

    if settings.global["awesomedrivermod-hide-when-car-not-researched"].value then
      local tech = player.force.technologies.automobilism;
      if tech.valid and not tech.researched then
        return
      end
    end

    if flow == nil then
      flow = player.gui.left.add { type = "scroll-pane", name = prefix .. "flow" }
    end

    local table = flow[prefix .. 'table']
    if table == nil then
      table = flow.add {
        type = 'table',
        column_count = 2,
        name = prefix .. 'table',
        style = 'carcrash_table_style'
      }
      table.style.column_alignments[1] = "right"

      table.add { type = 'label', name = prefix .. 'hit_label', caption = { "hits" }, style = 'bold_label' }
      table.add { type = 'label', name = prefix .. 'hit_value', caption = "0" }
      table.add { type = 'label', name = prefix .. 'hit_since_label', caption = { "time-last-hit" }, style = 'bold_label' }
      table.add { type = 'label', name = prefix .. 'hit_since_value', caption = "00:00:00" }

      if (self.multiplayer) then
        table.add { type = 'label', name = prefix .. 'player_hit_label', caption = { "player-hits" }, style = 'bold_label' }
        table.add { type = 'label', name = prefix .. 'player_hit_value', caption = "0" }
        table.add { type = 'label', name = prefix .. 'player_hit_since_label', caption = { "player-time-last-hit" }, style = 'bold_label' }
        table.add { type = 'label', name = prefix .. 'player_hit_since_value', caption = "00:00:00" }
      end

      table.add { type = 'label', name = prefix .. 'player_drivetime_label', caption = { "drivetime" }, style = 'bold_label' }
      table.add { type = 'label', name = prefix .. 'player_drivetime_value', caption = "0" }
      table.add { type = 'label', name = prefix .. 'player_highscore_label', caption = { "highscore" }, style = 'bold_label' }
      table.add { type = 'label', name = prefix .. 'player_highscore_value', caption = "0" }
    end

    if player.admin then
      local button_table = flow[prefix .. 'table_buttons']
      if button_table == nil then
        button_table = flow.add {
          type = 'table',
          column_count = 3,
          name = prefix .. 'table_buttons'
        }
        button_table.add { type = 'button', style = "carcrash_button_style", name = prefix .. "min_button", caption = "-" }
        button_table.add { type = 'button', style = "carcrash_button_style", name = prefix .. "plus_button", caption = "+" }
        button_table.add { type = 'button', style = "carcrash_button_style", name = prefix .. "reset_button", caption = { "reset" } }
      end
    end

    return table;
  end,
  update_table = function(self)
    local table
    local forceData
    local playerData
    local prefix = self.parent.data.prefix
    for _, player in pairs(game.players) do
      table = self:get_table(player)
      if table then
        forceData = self.parent:get_force_data(player.force)
        playerData = self.parent:get_player_data(player)
        if (forceData) then
          table[prefix .. "hit_value"].caption = forceData.counter
          table[prefix .. "hit_since_value"].caption = self.get_time_display(forceData.last_hit_tick)

          if self.multiplayer then
              table[prefix .. "player_hit_value"].caption = playerData.counter
              table[prefix .. "player_hit_since_value"].caption = self.get_time_display(playerData.last_hit_tick)
          end
          table[prefix .. "player_drivetime_value"].caption = self.get_time_display(self.parent:get_player_current_driving_time(player), false)
          table[prefix .. "player_highscore_value"].caption = self.get_time_display(playerData.highscore, false)
        end
      end
    end
  end,
  get_time_display = function(last_hit_tick, calculate)
    if (calculate == nil) then
      calculate = true
    end

    local ticks = last_hit_tick / 60

    if calculate then
      ticks = (game.tick - last_hit_tick) / 60
    end
    if last_hit_tick == 0 then
      return '?'
    end
    local time = {
      hours = math.floor(ticks / 3600),
      minutes = math.floor(ticks % 3600 / 60),
      seconds = math.floor(ticks % 60)
    }
    return string.format('%02d:%02d:%02d', time.hours, time.minutes, time.seconds)
  end,
  update_time_display = function(self)
    local table
    local forceData
    local playerData
    local prefix = self.parent.data.prefix
    for _, player in pairs(game.players) do
      table = self:get_table(player)
      forceData = self.parent:get_force_data(player.force)
      playerData = self.parent:get_player_data(player)

      if table and forceData then
        table[prefix .. "hit_since_value"].caption = self.get_time_display(forceData.last_hit_tick)
        if self.multiplayer and playerData then
          table[prefix .. "player_hit_since_value"].caption = self.get_time_display(playerData.last_hit_tick)
        end
        table[prefix .. "player_drivetime_value"].caption = self.get_time_display(self.parent:get_player_current_driving_time(player), false)

      end
    end
  end,
  reset_tables = function(self)
    local changed = false
    local count = #game.players
    if (count > 1 and not self.multiplayer) then
      self.multiplayer = true
      changed = true
    elseif (count == 1 and self.multiplayer) then
      self.multiplayer = false
      changed = true
    end

    if changed then
      local prefix = self.parent.data.prefix
      for _, player in pairs(game.players) do
        if player.gui.left[prefix .. "flow"] then
          player.gui.left[prefix .. "flow"].destroy()
        end
      end
    end
  end,
  on_gui_click = function(self, event)
    local player = game.players[event.player_index]

    if event.element.valid then
      local parent = self.parent
      local prefix = parent.data.prefix
      local forceData = parent:get_force_data(player.force)
      local playerData = parent:get_player_data(player)

      if event.element.name == prefix .. "min_button" then
        forceData.counter = forceData.counter - 1
        if forceData.counter < 0 then
          forceData.counter = 0;
        end
        playerData.counter = playerData.counter - 1
        if playerData.counter < 0 then
          playerData.counter = 0;
        end
        self:update_table()
      elseif event.element.name == prefix .. "plus_button" then
        forceData.counter = forceData.counter + 1
        playerData.counter = playerData.counter + 1
        self:update_table()
      elseif event.element.name == prefix .. "reset_button" then
        forceData.counter = 0
        forceData.last_hit_tick = game.tick
        for _, data in pairs(parent.data.player) do
          data.counter = 0
          data.last_hit_tick = forceData.last_hit_tick
        end
        self:update_table()
      end
    end
  end
}

return gui

