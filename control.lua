require('util');
require("mod-gui")

local prefix = 'carcrashcounter_';
local carcrashcounter = {
  counter = 0,
  last_hit_tick = 0,
  last_entity_position = '',
  count_spacer = 10
}

local equalPosition = function(a, b)
  return a.x == b.x and a.y == b.y
end

local get_table = function(player)
  local prefix = prefix
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
  end

  local button_table = flow[prefix..'table_buttons']
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

  return table;
end

local get_time_display = function()
  local carcrashcounter = carcrashcounter
  local ticks = (game.tick - carcrashcounter.last_hit_tick) / 60
  local time = {
    hours = math.floor(ticks / 3600),
    minutes = math.floor(ticks % 3600 / 60),
    seconds = math.floor(ticks % 60)
  }
  return string.format('%02d:%02d:%02d', time.hours, time.minutes, time.seconds)
end

local car_crash_update = function(e)
  -- strange check because hits fire twice because the car gets damage as well
  if e.entity.type == 'car' then
    return
  end

  local equalPosition = equalPosition
  local prefix = prefix
  local carcrashcounter = carcrashcounter

  if carcrashcounter.last_hit_tick >= game.tick - carcrashcounter.count_spacer then
    return
  end

  if (e.force and e.force.name == 'player'
      and e.entity.force.name == 'player'
      and ((not equalPosition(e.entity.position, carcrashcounter.last_entity_position))
      or (equalPosition(e.entity.position, carcrashcounter.last_entity_position) and carcrashcounter.last_hit_tick < (game.tick - (carcrashcounter.count_spacer * 6))))
      and e.cause and e.cause.type == 'car') then
    carcrashcounter.counter = carcrashcounter.counter + 1
    carcrashcounter.last_hit_tick = game.tick
    carcrashcounter.last_entity_position = util.table.deepcopy(e.entity.position)


    local table = get_table(game.players[1]);
    if table ~= nil and table[prefix .. 'hit_value'] ~= nil then
      table[prefix .. 'hit_value'].caption = carcrashcounter.counter
    end
  end
end


script.on_event(defines.events.on_player_joined_game, function(event)
  local player = game.players[event.player_index]
  local table = get_table(player)
  local carcrashcounter = carcrashcounter

  table.add { type = 'label', name = prefix .. 'hit_label', caption = { "hits" }, style = 'bold_label' }
  table.add { type = 'label', name = prefix .. 'hit_value', caption = carcrashcounter.counter }
  table.add { type = 'label', name = prefix .. 'hit_since_label', caption = { "time-last-hit" }, style = 'bold_label' }
  table.add { type = 'label', name = prefix .. 'hit_since_value', caption = get_time_display(), style = 'bold_label' }
end)

script.on_nth_tick(60, function(e)
  local prefix = prefix
  local player = game.players[1]
  local table = get_table(player)
  if table ~= nil and table[prefix .. 'hit_since_value'] ~= nil then
    table[prefix .. 'hit_since_value'].caption = get_time_display()
  end
end)

script.on_event({ defines.events.on_entity_damaged }, car_crash_update)

script.on_event({ defines.events.on_entity_died }, car_crash_update)

script.on_event({ defines.events.on_gui_click }, function(event)
  local prefix = prefix
  local player = game.players[1]

  if event.element.valid then
    local table = get_table(player)
    local carcrashcounter = carcrashcounter
    if event.element.name == prefix .. "min_button" then
      carcrashcounter.counter = carcrashcounter.counter - 1
      if carcrashcounter.counter < 0 then
        carcrashcounter.counter = 0;
      end
      table[prefix.."hit_value"].caption = carcrashcounter.counter
    elseif event.element.name == prefix .. "plus_button" then
      carcrashcounter.counter = carcrashcounter.counter + 1
      table[prefix.."hit_value"].caption = carcrashcounter.counter
    elseif event.element.name == prefix .. "reset_button" then
      carcrashcounter.counter = 0
      carcrashcounter.last_hit_tick = game.tick
      table[prefix.."hit_value"].caption = carcrashcounter.counter
      table[prefix.."hit_since_value"].caption = get_time_display()
    end
  end
end)