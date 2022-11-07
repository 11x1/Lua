local indicator = { }

indicator.pos = vec2_t(100, 100)
indicator.size = vec2_t(200, 100)
indicator.difference = vec2_t(0, 0)
indicator.dragging = false
indicator.font = render.get_default_font( )

indicator.shot_count = 0
indicator.data = { }

local colors = {
    ['hit'] = color_t( 0, 255, 0, 255 ),
    ['occlusion'] = color_t( 187, 189, 140, 255 ),
    ['resolver'] = color_t( 255, 0, 0, 255 ),
    ['spread'] = color_t( 189, 173, 140, 255 ),
    ['prediction error'] = color_t( 209, 121, 121, 255 ),
    ['server rejection'] = color_t( 122, 93, 194, 255 ),
    ['ping'] = color_t( 212, 255, 0, 255 ),
    ['ping (target death)'] = color_t( 117, 122, 88, 255 )
}

local on_aimbot_miss = function( ctx )
    local reason = ctx.reason_string

    indicator.data[ ctx.reason_string ] = ( indicator.data[ ctx.reason_string ] or 0 ) + 1


    indicator.shot_count = indicator.shot_count + 1
end

local on_aimbot_hit = function( ... )
    indicator.data[ "hit" ] = ( indicator.data[ "hit" ] or 0 ) + 1

    indicator.shot_count = indicator.shot_count + 1
end

local draw_circle = function( center_pos, radius, start, end_, color )
    local segments = { center_pos }

    for i = start, end_ do
        local angle = math.rad( i )
        local x = center_pos.x + math.cos( angle ) * radius
        local y = center_pos.y + math.sin( angle ) * radius

        segments[ #segments + 1 ] = vec2_t( x, y )
    end

    render.polygon( segments, color )
end

indicator.handlers = { }
indicator.handlers.handle_dragging = function( )
    if indicator.dragging or ( input.is_key_held( e_keys.MOUSE_LEFT ) and input.is_mouse_in_bounds( indicator.pos, indicator.size ) ) then
        indicator.pos = input.get_mouse_pos() - indicator.difference
        indicator.dragging = true
      else
        indicator.difference = input.get_mouse_pos() - indicator.pos
    end

    if not input.is_key_held( e_keys.MOUSE_LEFT ) then
        indicator.dragging = false
    end
end

indicator.handlers.handle_drawing = function( )
    local start = indicator.pos + vec2_t( 40, indicator.size.y / 2 )

    -- render gray circle when no data
    if indicator.shot_count == 0 then
        draw_circle( start, 30, 0, 360, color_t( 100, 100, 100, 255 ) )
        return
    end

    -- render hit circle
    local current_start = 0
    local different_names = 0
    for name, value in pairs( indicator.data ) do
        local percent = value / indicator.shot_count
        local end_ = current_start + ( percent * 360 )

        local color = colors[ name ] or color_t( 0, 0, 0, 255 )

        draw_circle( start, 30, current_start, end_ + 5, color )
        current_start = current_start + ( percent * 360 )

        different_names = different_names + 1
    end

    -- render text on right
    local y_start = indicator.size.y / 2
    local height = different_names * 15

    y_start = y_start - ( height / 2 )

    local text_start = indicator.pos + vec2_t( 80, y_start )
    for name, value in pairs( indicator.data ) do
        local color = colors[ name ] or color_t( 0, 0, 0, 255 )

        render.rect_filled( text_start + vec2_t( 0, 2 ), vec2_t( 10, 10 ), color, 2 )
        render.text( indicator.font, string.format( '%.0f%% %s', value / indicator.shot_count * 100, name ), text_start + vec2_t( 15, 0 ), color_t( 255, 255, 255, 255 ) )
        text_start = text_start + vec2_t( 0, 15 )
    end
end

local on_paint = function( )
    indicator.handlers.handle_dragging( )
    indicator.handlers.handle_drawing( )
end

callbacks.add( e_callbacks.AIMBOT_MISS, on_aimbot_miss )
callbacks.add( e_callbacks.AIMBOT_HIT, on_aimbot_hit )
callbacks.add( e_callbacks.PAINT, on_paint )
