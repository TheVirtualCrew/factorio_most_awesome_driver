--
-- Created by IntelliJ IDEA.
-- User: timvroom
-- Date: 11/08/2018
-- Time: 01:08
-- To change this template use File | Settings | File Templates.
--

data.raw["gui-style"].default.awesomedriver_table_style =
{
  type = "table_style",
  cell_padding = 0,
  horizontal_spacing = 1,
  vertical_spacing = 4,
  -- same as frame
  column_graphical_set =
  {
    type = "composition",
    filename = "__core__/graphics/gui.png",
    priority = "extra-high-no-scale",
    corner_size = { 3, 3 },
    position = { 0, 0 },
    opacity = 0.8
  },
  odd_row_graphical_set =
  {
    type = "composition",
    filename = "__core__/graphics/gui.png",
    priority = "extra-high-no-scale",
    corner_size = { 3, 3 },
    position = { 78, 0 },
    opacity = 0.5
  }
}

data.raw["gui-style"].default.awesomedriver_button_style =
{
  type = "button_style",
  font = "default",
  align = "middle-center",
  padding = 1,
  default_font_color = { r = 1, g = 1, b = 1 },
  default_graphical_set =
  {
    type = "composition",
    filename = "__core__/graphics/gui.png",
    priority = "extra-high-no-scale",
    corner_size = { 3, 3 },
    position = { 0, 0 },
    opacity = 0.8
  },
  left_click_sound =
  {
    {
      filename = "__core__/sound/gui-click.ogg",
      volume = 1
    }
  }
}
