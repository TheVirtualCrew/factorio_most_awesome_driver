--
-- Created by IntelliJ IDEA.
-- User: timvroom
-- Date: 12/08/2018
-- Time: 11:17
-- To change this template use File | Settings | File Templates.
--

local gui = {
  parent = nil,
  multiplayer = false,
  create_table = function(self, player)
    local prefix = self.parent.data.prefix
    local flow = player.gui.left[prefix .. 'flow']

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

      table.add { type = 'label', name = prefix .. 'hit_label', caption = { "hits" }, style = 'bold_label' }
      table.add { type = 'label', name = prefix .. 'hit_value', caption = "0" }
      table.add { type = 'label', name = prefix .. 'hit_since_label', caption = { "time-last-hit" }, style = 'bold_label' }
      table.add { type = 'label', name = prefix .. 'hit_since_value', caption = "00:00:00", style = 'bold_label' }

      if (#game.players > 1) then
        table.add { type = 'label', name = prefix .. 'player_hit_label', caption = { "player-hits" }, style = 'bold_label' }
        table.add { type = 'label', name = prefix .. 'player_hit_value', caption = "0" }
        table.add { type = 'label', name = prefix .. 'player_hit_since_label', caption = { "player-time-last-hit" }, style = 'bold_label' }
        table.add { type = 'label', name = prefix .. 'player_hit_since_value', caption = "00:00:00", style = 'bold_label' }
      end
    end

    if player.admin then
      local button_table = flow[prefix .. 'table_buttons']
      if button_table == nil then
        button_table = flow.add {
          type = 'table',
          column_count = 3,
          name = prefix .. 'table_buttons',
          style = 'carcrash_table_style'
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
    local prefix = self.parent.data.prefix
    for index, player in pairs(game.players) do
      table = gui.get_table(player)
      table[prefix .."hit_value"].caption = self.parent.data.counter
      table[prefix .."hit_since_value"].caption = self.get_time_display(self.parent.data.last_hit_tick)

      if self.multiplayer then
        table[prefix .."player_hit_value"].caption = self.parent.data.player[index].counter
        table[prefix .."player_hit_since_value"].caption = self.get_time_display(self.parent.data.player[index].last_hit_tick)
      end
    end
  end,
  get_time_display = function(last_hit_tick)
    local ticks = (game.tick - last_hit_tick) / 60
    local time = {
      hours = math.floor(ticks / 3600),
      minutes = math.floor(ticks % 3600 / 60),
      seconds = math.floor(ticks % 60)
    }
    return string.format('%02d:%02d:%02d', time.hours, time.minutes, time.seconds)
  end,
  update_time_display = function(self)
    local table
    local prefix = self.parent.data.prefix
    for index, player in pairs(game.players) do
      table = self.get_table(player)
      table[prefix .."hit_since_value"].caption = self.get_time_display(self.parent.data.last_hit_tick)
      if self.multiplayer then
        table[prefix .."player_hit_since_value"].caption = self.get_time_display(self.parent.data.player[index].last_hit_tick)
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
        player.gui.left[prefix .. "flow"][prefix .. "table"].destroy()
        player.gui.left[prefix .. "flow"][prefix .. "table_buttons"].destroy()
      end
    end
  end,
  on_gui_click = function(self, event)
    local player = game.players[event.player_index]

    if event.element.valid then
      local parent = self.parent
      local prefix = parent.data.prefix
      if event.element.name == prefix .. "min_button" then
        parent.data.counter = parent.data.counter - 1
        if parent.data.counter < 0 then
          parent.data.counter = 0;
        end
        parent.data.player[player.index].counter = parent.data.player[player.index].counter - 1
        if parent.data.player[player.index].counter < 0 then
          parent.data.player[player.index].counter = 0;
        end
        self:update_table()
      elseif event.element.name == prefix .. "plus_button" then
        parent.counter = parent.counter + 1
        parent.data.player[player.index].counter = parent.data.player[player.index].counter + 1
        self:update_table()
      elseif event.element.name == prefix .. "reset_button" then
        parent.counter = 0
        parent.last_hit_tick = game.tick
        for index,data in pairs(parent.data.player) do
          data.player[index].counter = 0
          data.player[index].last_hit_tick = 0
        end
        self:update_table()
      end
    end
  end
}

return gui

