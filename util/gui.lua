--
-- Create by TheVirtualCrew
--

local mod_gui = require('mod-gui')

gui = {
  multiplayer = false,
  init_player_gui = function(self, player)
    local button_flow = mod_gui.get_button_flow(player)
    local prefix = global.data.prefix
    if not button_flow[prefix .. 'top_button'] then
    end

    self:get_table(player)
  end,
  get_table = function(self, player)
    if not player or not player.valid then
      return;
    end

    local prefix = global.data.prefix
    local frame_flow = player.gui.left
    local flow = frame_flow[prefix .. 'flow']
    local frame;
    local global_setting = settings.global;
    local player_setting = settings.get_player_settings(player);

    if flow then
      frame = flow[prefix.."frame"]
    else
      flow = frame_flow.add {
        type = "flow",
        name = prefix .. "flow",
        direction = 'vertical',
      }
      frame_flow.style.left_padding = 4
      frame_flow.style.top_padding = 4
      frame_flow.style.horizontally_stretchable = false
    end

    if not player_setting["awesomedrivermod-show-table"].value then
      if frame then
        frame.destroy()
      end
      return
    end

    if global_setting["awesomedrivermod-hide-when-car-not-researched"].value then
      local tech = player.force.technologies.automobilism;
      if tech.valid and not tech.researched then
        return
      end
    end

    if frame == nil then
      frame = flow.add {
        type = "frame",
        name = prefix .. "frame",
        direction = 'vertical',
      }
      if player_setting['awesomedrivermod-table-title'].value then
        frame.caption = player_setting['awesomedrivermod-table-title'].value
      end
      frame.style.horizontally_stretchable = false
    end

    local table = frame[prefix .. 'table']
    if table == nil then

      table = frame.add {
        type = 'table',
        column_count = 2,
        name = prefix .. 'table',
      }
      table.style.horizontal_spacing = 8
      table.style.vertical_spacing = 0
      table.style.column_alignments[1] = "right"

      if (self.multiplayer) then
        if player_setting['awesomedrivermod-multiplayer-show-global-hit'].value then
          table.add { type = 'label', name = prefix .. 'hit_label', caption = { "hits" }, style = 'bold_label' }
          table.add { type = 'label', name = prefix .. 'hit_value', caption = "0" }
          table.add { type = 'label', name = prefix .. 'hit_since_label', caption = { "time-last-hit" }, style = 'bold_label' }
          table.add { type = 'label', name = prefix .. 'hit_since_value', caption = "00:00:00" }
        end

        if player_setting['awesomedrivermod-multiplayer-show-highscore'].value then
          table.add { type = 'label', name = prefix .. 'highscore_label', caption = { "highscore" }, style = 'bold_label' }
          table.add { type = 'label', name = prefix .. 'highscore_value', caption = "0" }
        end

        if global_setting["awesomedrivermod-multiplayer-show-forces-button"].value then
          local buttonflow = mod_gui.get_button_flow(player)

          if not buttonflow[prefix .. 'mp_button'] then
            local button = buttonflow.add
              {
                type = "sprite-button",
                name = prefix .. "mp_button",
                style = mod_gui.button_style,
                sprite = "item-group/mad-car",
                tooltip = { "awesomdrivermod-mp-button-tooltip" }
              }
            button.style.visible = true
          end
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

    if player.admin and player_setting['awesomedrivermod-show-change-buttons'].value then
      local button_table = frame[prefix .. 'table_buttons']
      if button_table == nil then
        button_table = frame.add {
          type = 'flow',
          name = prefix .. 'table_buttons',
          direction = "horizontal"
        }
        local minus = button_table.add { type = 'button', name = prefix .. "min_button", caption = "-" }
        minus.style.minimal_width = 40;
        local plus = button_table.add { type = 'button', name = prefix .. "plus_button", caption = "+" }
        plus.style.minimal_width = 40;
        button_table.add { type = 'button', name = prefix .. "reset_button", caption = { "reset" } }
        if self.multiplayer then
          button_table.add { type = 'button', style = "awesomedriver_button_style", name = prefix .. "reset_button_all", caption = { "reset-all" } }
        end
      end
    end

    return table;
  end,
  update_table = function(self)
    local table
    local forceData
    local playerData
    local prefix = global.data.prefix
    local new_data

    for _, player in pairs(game.players) do
      table = self:get_table(player)
      if table then
        forceData = awesomedrivermod:get_force_data(player.force)
        playerData = awesomedrivermod:get_player_data(player)

        if forceData then
          new_data = {
            hit_value = forceData.counter,
            hit_since_value = self.get_time_display(forceData.last_hit_tick),
            player_hit_value = playerData.counter,
            player_hit_since_value = self.get_time_display(playerData.last_hit_tick),
            player_drivetime_value = self.get_time_display(awesomedrivermod:get_player_current_driving_time(player), false),
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

    if last_hit_tick == 0 or not last_hit_tick then
      return '00:00:00'
    end

    local ticks = last_hit_tick / 60

    if calculate then
      ticks = (game.tick - last_hit_tick) / 60
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
    local prefix = global.data.prefix
    local update
    for _, player in pairs(game.players) do
      table = self:get_table(player)
      forceData = awesomedrivermod:get_force_data(player.force)
      playerData = awesomedrivermod:get_player_data(player)

      if table and forceData then
        update = {
          hit_since_value = self.get_time_display(forceData.last_hit_tick),
          player_drivetime_value = self.get_time_display(awesomedrivermod:get_player_current_driving_time(player), false),
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
      local prefix = global.data.prefix
      for _, player in pairs(game.players) do
        if player.gui.left[prefix .. "frame"] then
          player.gui.left[prefix .. "frame"].destroy()
        end
      end
    end
  end,
  on_gui_click = function(self, event)
    local player = game.players[event.player_index]
    local element = event.element

    if element.valid then
      local parent = awesomedrivermod
      local prefix = global.data.prefix
      local forceData = parent:get_force_data(player.force)
      local playerData = parent:get_player_data(player)

      if element.name == prefix .. "min_button" then
        forceData.counter = forceData.counter - 1
        if forceData.counter < 0 then
          forceData.counter = 0;
        end
        playerData.counter = playerData.counter - 1
        if playerData.counter < 0 then
          playerData.counter = 0;
        end
        self:update_table()
      elseif element.name == prefix .. "plus_button" then
        forceData.counter = forceData.counter + 1
        playerData.counter = playerData.counter + 1
        self:update_table()
      elseif element.name == prefix .. "reset_button" then
        playerData.counter = 0
        playerData.last_hit_tick = game.tick;
        playerData.driving_ticks = 0;
        playerData.highscore = 0;
        playerData.last_entity_position = {}

        self:update_table()
      elseif element.name == prefix .. "reset_button_all" then
        for _, fd in pairs(parent.data.forces) do
          fd.counter = 0
          fd.last_hit_tick = 0
          fd.highscore = 0
        end
        for _, data in pairs(parent.data.player) do
          for i, value in pairs(data) do
            if i == 'runtime-per-user' then
              data[i] = { x = nil, y = nil }
            else
              data[i] = 0
            end
          end
        end
      elseif element.name == prefix .. "mp_button" then
        -- todo: create nice overview
      end
    end
  end,
  open_mp_table = function(self, player)
    local frame = player.gui
  end
}
