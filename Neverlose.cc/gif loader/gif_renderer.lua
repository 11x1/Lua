-- paste python script output here
local frames = {
  Http.Get('image-url'),
}

-- loaded frame array
local loaded_images = {}
-- render settings
local gif = {
  speed = Menu.SliderInt("GIF Settings", "Render speed (1/f)", 1, 1, 100),
  pos_x = Menu.SliderInt("GIF Settings", "Pos x", 200, 1, EngineClient.GetScreenSize().x),
  pos_y = Menu.SliderInt("GIF Settings", "Pos y", 200, 1, EngineClient.GetScreenSize().y),
  Menu.Text("GIF Settings", "--------------FRAME SETTINGS---------------"),
  size_x = Menu.SliderInt("GIF Settings", "Size x", 200, 1, EngineClient.GetScreenSize().x),
  size_y = Menu.SliderInt("GIF Settings", "Size y", 200, 1, EngineClient.GetScreenSize().y),
  update = Menu.Button("GIF Settings", "Update frames"),
}

local delay = gif.speed:Get()
local image_num = 1
local framestage_counter = 0

Cheat.RegisterCallback("draw", function()
  if #loaded_images < 1 then return end
  Render.Image(loaded_images[image_num], Vector2.new( gif.pos_x:Get(), gif.pos_y:Get()), Vector2.new(gif.size_x:Get(), gif.size_y:Get()))
end)

Cheat.RegisterCallback("frame_stage", function(stage)
  if stage ~= 5 then return end
  framestage_counter = framestage_counter + 1
  if framestage_counter > 101 then framestage_counter = 0 end
  delay = gif.speed:Get()
  if framestage_counter % delay == 0 then
  if image_num < #loaded_images then image_num = image_num + 1 else image_num = 1 end
  end
end)

gif.update:RegisterCallback(function()
  loaded_images = {}
  local frame_loading_counter = 1
  for i, v in pairs(frames) do
    local frame = frames[frame_loading_counter]
    local image_loaded = Render.LoadImage(frame, Vector2.new(gif.size_x:Get(), gif.size_y:Get()))
    table.insert(loaded_images, 1, image_loaded)
    frame_loading_counter = frame_loading_counter + 1
  end
end)
