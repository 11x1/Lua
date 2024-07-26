local textures = { }

---@param txt_id number
---@param w number
---@param h number
---@return CustomTexture
local function create_new_texture( txt_id, w, h )
    ---@class CustomTexture
    local texture = { }

    ---@private
    texture._id = txt_id
    ---@private
    texture._w = w
    ---@private
    texture._h = h

    --* add to table to later automatically remove all custom textures
    table.insert( textures, txt_id )

    ---@param x number
    ---@param y number
    function texture:render( x, y )
        draw.Color( 255, 255, 255, 255 )
        draw.TexturedRect( self._id, x, y, x + self._w, y + self._h )
    end

    return texture
end

callbacks.Register("Unload", function( )
    for i = 1, #textures do
        draw.DeleteTexture( textures[ i ] )
    end
end )

local function log_base2( num )
    return math.log( num ) / math.log( 2 )
end

local function isPowerOfTwo( n )
    if n == 0 then
        return false
    end
    
    return math.ceil( log_base2( n ) ) == math.floor( log_base2( n ) )
end

---@param pattern table< number >
---@param pattern_size { [1] : number, [2] : number }
---@param width number
---@param height number
---@return CustomTexture texture_obj
local function create_texture( pattern, pattern_size, width, height, colors )
    local closest_2_power = {
        2 ^ math.floor( log_base2( width ) + 1 ),
        2 ^ math.floor( log_base2( width ) + 1 ),
    }

    if isPowerOfTwo( width ) then
        closest_2_power[ 1 ] = width
    end

    if isPowerOfTwo( height ) then
        closest_2_power[ 2 ] = height
    end

    closest_2_power[ 1 ] = math.max( closest_2_power[ 1 ], closest_2_power[ 2 ] )
    closest_2_power[ 2 ] = closest_2_power[ 1 ]
    
    local texture_data = { }
    for y = 0, closest_2_power[ 2 ] - 1 do
        local pattern_y = y % pattern_size[ 2 ]
        for x = 0, closest_2_power[ 1 ] - 1 do
            local pattern_x = x % pattern_size[ 1 ] + 1

            local pattern_pos = pattern_y * pattern_size[ 1 ] + pattern_x
            local pattern_val = pattern[ pattern_pos ]

            if y >= width or x >= height then
                pattern_val = -1
            end
            
            table.insert( texture_data, pattern_val )
        end
    end

    colors[ -1 ] = "\x00\x00\x00\x00"
    local raw_texture = { }
    for i = 1, #texture_data do
        local val = texture_data[ i ]

        local col = colors[ val ]
        
        table.insert( raw_texture, colors[ val ] )
    end
    
    local color_data = table.concat( raw_texture, '' )

    local texture_obj = draw.CreateTextureRGBA( color_data, closest_2_power[ 1 ], closest_2_power[ 2 ] )

    return create_new_texture( texture_obj, closest_2_power[ 1 ], closest_2_power[ 2 ] )
end

return { create = create_texture }
