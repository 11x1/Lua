local gui = {}

--[[
  @elem text
  tab : string
  text : string
]]
function gui.text(tab, text)
    local data = {}

    data.type = "text"
    data.tab = tab
    data.text = text
    data.enabled = true

    return data
end

--[[
  @elem slider
  tab : string
  text : string
  default : number/float
  min : number/float
  max : number/float
]]
function gui.slider(tab, text, default, min, max, callbacks)
    local data = {}

    if default > max then default = max end
    if default < min then default = min end

    data.type = "slider"
    data.tab = tab
    data.text = text
    data.default = default
    data.min = min
    data.max = max
    data.enabled = true
    data.callbacks = {}
    if callbacks then
      for k, v in pairs(callbacks) do
        table.insert(data.callbacks, v)
      end
    end

    return data
end

--[[
  @elem combo
  tab : string
  text : string
  options : table
  default : number
]]
function gui.combo(tab, text, options, default, callbacks)
    local data = {}
    
    data.type = "combo"
    data.tab = tab
    data.text = text
    data.options = options
    data.default = default
    data.enabled = true
    data.open = false
    data.callbacks = {}
    if callbacks then
      for k, v in pairs(callbacks) do
        table.insert(data.callbacks, v)
      end
    end
    
    return data
end

--[[
  @elem multi_combo
  tab : string
  text : string
  options : table
  default : table
]]
function gui.multi_combo(tab, text, options, defaults, callbacks)
    local data = {}
    
    data.type = "multi_combo"
    data.tab = tab
    data.text = text
    data.options = options
    data.defaults = defaults
    data.enabled = true
    data.open = false
    data.callbacks = {}
    if callbacks then
      for k, v in pairs(callbacks) do
        table.insert(data.callbacks, v)
      end
    end
    
    return data
end

--[[
  @elem button
  tab : string
  text : string
]]
function gui.button(tab, text, callbacks)
    local data = {}
    
    data.type = "button"
    data.tab = tab
    data.text = text
    data.enabled = true
    data.callbacks = {}
    if callbacks then
      for k, v in pairs(callbacks) do
        table.insert(data.callbacks, v)
      end
    end

    return data
end

function gui.switch(tab, text, default, callbacks)
    local data = {}

    data.type = "switch"
    data.tab = tab
    data.text = text
    data.default = default
    data.enabled = true
    data.callbacks = {}
    if callbacks then
      for k, v in pairs(callbacks) do
        table.insert(data.callbacks, v)
      end
    end
    
    data.selected = false

    return data
end

function gui.textbox(tab, text, default, callbacks)
  local data = {}

  data.type = "textbox"
  data.tab = tab
  data.text = text
  data.default = default
  data.enabled = true
  data.callbacks = {}
  data.selected = false
  if callbacks then
    for k, v in pairs(callbacks) do
      table.insert(data.callbacks, v)
    end
  end

  return data
end

function gui.keybind(tab, text)
  local data = {}

  data.tab = tab
  data.type = "keybind"
  data.text = text
  data.key = nil
  data.default = nil
  data.mode = 1
  data.enabled = true
  data.open = false
  data.options = {"none", "hold", "toggle", "always on"}
  data.key = "none"
  data.selected = false
  data.last_press = 0
  data.state = false

  return data
end

function gui.colorpicker(tab, text, default)
  local data = {}

  data.type = "color"
  data.tab = tab
  data.text = text
  data.default = default
  data.enabled = true
  data.selected = false
  data.color = Color.new(1,1,1)
  data.open = false

  data.big_color = Color.new(1, 0, 0)
  data.selected_color = Color.new(1, 0, 0)
  data.final_color = Color.new(1, 0, 0)
  data.x_p_exact = 0
  data.y_p_exact = 1
  data.p_final = 1

  data.all_colors = {
    pos = Vector2.new(0, 0),
    init = false,
  }

  data.exact_colors = {
    pos = Vector2.new(0, 0),
    init = false,
  }

  data.final_colors = {
    pos = Vector2.new(0, 0),
    init = false,
  }

  return data
end

function gui.newrow(tab)
  local data = {}

  data.tab = tab
  data.type = "newrow"

  return data
end

return gui
