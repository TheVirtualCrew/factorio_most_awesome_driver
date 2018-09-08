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
    local global_setting = settings.global;
    local player_setting = settings.get_player_settings(player);

    if not player.valid or not player_setting["awesomedrivermod-show-table"].value then
      if flow then
        flow.destroy()
      end
      return
    end

    if global_setting["awesomedrivermod-hide-when-car-not-researched"].value then
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
        style = 'awesomedriver_table_style'
      }
      table.style.column_alignments[1] = "right"

      if (self.multiplayer) then
        table.add { type = 'label', name = prefix .. 'hit_label', caption = { "hits" }, style = 'bold_label' }
        table.add { type = 'label', name = prefix .. 'hit_value', caption = "0" }

        if global_setting['awesomedrivermod-multiplayer-show-global-hit'].value then
          table.add { type = 'label', name = prefix .. 'hit_since_label', caption = { "time-last-hit" }, style = 'bold_label' }
          table.add { type = 'label', name = prefix .. 'hit_since_value', caption = "00:00:00" }
        end

        if player_setting['awesomedrivermod-multiplayer-show-highscore'].value then
          table.add { type = 'label', name = prefix .. 'highscore_label', caption = { "highscore" }, style = 'bold_label' }
          table.add { type = 'label', name = prefix .. 'highscore_value', caption = "0" }
        end
      end

      table.add { type = 'label', name = prefix .. 'player_hit_label', caption = { "player-hits" }, style = 'bold_label' }
      table.add { type = 'label', name = prefix .. 'player_hit_value', caption = "0" }

      if player_setting['awesomedrivermod-show-global-hit'].value then
        table.add { type = 'label', name = prefix .. 'player_hit_since_label', caption = { "player-time-last-hit" }, style = 'bold_label' }
        table.add { type = 'label', name = prefix .. 'player_hit_since_value', caption = "00:00:00" }
      end

      if player_setting['awesomedrivermod-show-driving-hit'].value then
        table.add { type = 'label', name = prefix .. 'player_drivetime_label', caption = { "drivetime" }, style = 'bold_label' }
        table.add { type = 'label', name = prefix .. 'player_drivetime_value', caption = "0" }
      end

      if player_setting['awesomedrivermod-show-highscore'].value then
        table.add { type = 'label', name = prefix .. 'player_highscore_label', caption = { "player-highscore" }, style = 'bold_label' }
        table.add { type = 'label', name = prefix .. 'player_highscore_value', caption = "0" }
      end
      self:update_table();
    end

    if player.admin and global_setting['awesomedrivermod-show-change-buttons'].value then
      local button_table = flow[prefix .. 'table_buttons']
      if button_table == nil then
        button_table = flow.add {
          type = 'table',
          column_count = 3,
          name = prefix .. 'table_buttons'
        }
        button_table.add { type = 'button', style = "awesomedriver_button_style", name = prefix .. "min_button", caption = "-" }
        button_table.add { type = 'button', style = "awesomedriver_button_style", name = prefix .. "plus_button", caption = "+" }
        button_table.add { type = 'button', style = "awesomedriver_button_style", name = prefix .. "reset_button", caption = { "reset" } }
        if self.multiplayer then
          button_table.add { type = 'button', style = "awesomedriver_button_style", name = prefix .. "reset_button_all", caption = { "reset all" } }
        end
      end
    end

    return table;
  end,
  update_table = function(self)
    local table
    local forceData
    local playerData
    local prefix = self.parent.data.prefix
    local new_data

    for _, player in pairs(game.players) do
      table = self:get_table(player)
      if table then
        forceData = self.parent:get_force_data(player.force)
        playerData = self.parent:get_player_data(player)

        if forceData then
          new_data = {
            hit_value = forceData.counter,
            hit_since_value = self.get_time_display(forceData.last_hit_tick),
            player_hit_value = playerData.counter,
            player_hit_since_value = self.get_time_display(playerData.last_hit_tick),
            player_drivetime_value = self.get_time_display(self.parent:get_player_current_driving_time(player), false),
            player_highscore_value = self.get_time_display(playerData.highscore, false)
          };

          for k, v in pairs(new_data) do
            if table[prefix .. k] then
              table[prefix .. k].caption = v
            end
          end
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
      return '00:00:00'
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
    local update
    for _, player in pairs(game.players) do
      table = self:get_table(player)
      forceData = self.parent:get_force_data(player.force)
      playerData = self.parent:get_player_data(player)

      if table and forceData then
        update = {
          hit_since_value = self.get_time_display(forceData.last_hit_tick),
          player_drivetime_value = self.get_time_display(self.parent:get_player_current_driving_time(player), false),
          player_hit_since_value = self.get_time_display(playerData.last_hit_tick)
        }

        for i, v in pairs(update) do
          if table[prefix .. i] then
            table[prefix .. i].caption = v
          end
        end

      end
    end
  end,
  reset_tables = function(self, forced)
    forced = forced or false
    local changed = false
    local count = #game.players
    if (count > 1 and not self.multiplayer) then
      self.multiplayer = true
      changed = true
    elseif (count == 1 and self.multiplayer) then
      self.multiplayer = false
      changed = true
    end

    if changed or forced then
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
        playerData.counter = 0
        playerData.last_hit_tick = forceData.last_hit_tick
        self:update_table()
      elseif event.element.name == prefix .. "reset_button_all" then
        for _, fd in pairs(parent.data.forces) do
          fd.counter = 0
          fd.last_hit_tick = 0
          fd.highscore = 0
        end
        for _, data in pairs(parent.data.player) do
          for i, value  in pairs(data) do
            if i == 'runtime-per-user' then
              data[i] = { x = nil, y = nil }
            else
              data[i] = 0
            end
          end
        end
      end
    end
  end
}

return gui

