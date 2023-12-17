-- Wrappers for everything because this api feels like neverlose's on release
-- I just cant handle the camelcase sorry xx

-- unload script and check console for the config
local config_table = { [ 'name' ] = { [ 'include entity index' ] = false, [ 'select font' ] = 'pixel', [ 'text color' ] = { 200, 200, 200, 255 }, [ 'area_id' ] = '1' }, [ 'health' ] = { [ 'select font' ] = 'pixel', [ 'text color' ] = { 100, 255, 100, 255 }, [ 'hide on full' ] = true, [ 'area_id' ] = '2' }, [ 'overheal' ] = { [ 'select font' ] = 'pixel', [ 'text color' ] = { 237, 233, 157, 255 }, [ 'area_id' ] = '4' }, [ 'scoped' ] = { [ 'select font' ] = 'pixel', [ 'text color' ] = { 50, 200, 152, 255 }, [ 'area_id' ] = '4' }, [ 'ubercharged' ] = { [ 'select font' ] = 'pixel', [ 'text color' ] = { 255, 100, 100, 255 }, [ 'area_id' ] = '4' }, [ 'cloaked' ] = { [ 'select font' ] = 'pixel', [ 'text color' ] = { 150, 100, 255, 255 }, [ 'area_id' ] = '4' }, [ 'bonk' ] = { [ 'select font' ] = 'pixel', [ 'text color' ] = { 255, 255, 0, 255 }, [ 'area_id' ] = '4' }, [ 'distance' ] = { [ 'select font' ] = 'pixel', [ 'text color' ] = { 178, 178, 178, 255 }, [ 'area_id' ] = '3' }, [ 'charging' ] = { [ 'select font' ] = 'pixel', [ 'text color' ] = { 255, 0, 0, 255 }, [ 'area_id' ] = '4' }, [ 'covered' ] = { [ 'select font' ] = 'pixel', [ 'jarate' ] = { 255, 215, 0, 255 }, [ 'milk' ] = { 255, 255, 255, 255 }, [ 'both' ] = { 230, 80, 140, 255 }, [ 'area_id' ] = '4' }, [ 'model_options_menu' ] = { [ 'box style' ] = 'none', [ 'override material' ] = true, [ 'wireframe' ] = false, [ 'chams' ] = 'flat', [ 'chams color' ] = { 50, 91, 117, 255 }, [ 'backtrack modulation' ] = true, [ 'backtrack start' ] = { 0, 67, 110, 255 }, [ 'backtrack end' ] = { 109, 21, 55, 255 } }, [ 'health' ] = { [ 'bar color' ] = { 0, 255, 0, 255 },[ 'area_id' ] = '2',[ 'thickness' ] = 5 } }

local vector = { }
local vector_mt = { }

function vector_mt.__add( self, vec2 )
    if type( vec2 ) == "number" then
        return vector.new( self.x + vec2, self.y + vec2, self.z + vec2 )
    end

    return vector.new( self.x + vec2.x, self.y + vec2.y, self.z + vec2.z )
end

function vector_mt.__sub( self, vec2 )
    return vector_mt.__add( self, vec2 * -1 )
end

function vector_mt.__mul( self, vec2 )
    if type( vec2 ) == "number" then
        return vector.new( self.x * vec2, self.y * vec2, self.z * vec2 )
    end

    return vector.new( self.x * vec2.x, self.y * vec2.y, self.z * vec2.z )
end

function vector_mt.__div( self, vec2 )
    if type( vec2 ) == "number" then
        return vector.new( self.x / vec2, self.y / vec2, self.z / vec2 )
    end

    return vector.new( self.x / vec2.x, self.y / vec2.y, self.z / vec2.z )
end

function vector_mt.__unm( self )
    return self * -1
end

function vector_mt.__eq( self, vec2 )
    if type( vec2 ) ~= "table" then
        return false
    end

    return self.x == vec2.x and self.y == vec2.y and self.z == vec2.z
end

function vector_mt.__len( self )
    return math.sqrt( self.x ^ 2 + self.y ^ 2 + self.z ^ 2 )
end

function vector_mt.__tostring( self )
    return ( 'vector( %.2f, %.2f, %.2f )' ):format( self.x, self.y, self.z )
end

function vector_mt.unpack( self )
    return self.x, self.y, self.z
end

function vector.new( x, y, z )
    local vx, vy, vz = x, y, z

    if x == nil then
        vx, vy, vz = 0, 0, 0
    end

    if vy == nil then
        vy = x
        vz = x
    end

    if vz == nil then
        vz = 0
    end

    local new_vec = {
        x = vx,
        y = vy,
        z = vz,
        unpack = vector_mt.unpack
    }

    setmetatable( new_vec, vector_mt )

    return new_vec
end

setmetatable( vector, {
    __call = function( self, ... )
        return vector.new( ... )
    end
} )


local color = { }
local color_mt = { }

local function parse_hex_string( hex_string )
    if #hex_string == 6 then
        hex_string = hex_string .. 'FF'
    end

    hex_string = hex_string:gsub( '#', '' )

    local to_return = { }
    for i = 1, 8, 2 do
        table.insert(
            to_return,
            tonumber( ( '0x%s' ):format( hex_string:sub( i, i + 1 ) ) )
        )
    end

    return table.unpack( to_return )
end

function color_mt.unpack( self )
    return self.r, self.g, self.b, self.a
end

function color.new( r, g, b, a )
    if type( r ) == "string" then
        r, g, b, a = parse_hex_string( r )
    end

    if g == nil then
        g, b = r, r
        a = 255
    end

    if b == nil then
        a = g
        g, b = r, r
    end

    if a == nil then
        a = 255
    end

    local new_color = {
        r = r, g = g, b = b, a = a,
        unpack = color_mt.unpack
    }

    setmetatable( new_color, color_mt ) -- dont have an use for this atm, here for future usage

    return new_color
end

setmetatable( color, {
    __call = function( self, ... )
        return color.new( ... )
    end
} )

function color.hue_to_rgb( hue_degrees )
    local hue = hue_degrees / 360

    local r, g, b = 0, 0, 0

    if hue < 1 / 6 then
        r = 1
        g = hue * 6
    elseif hue < 2 / 6 then
        r = 1 - ( hue - 1 / 6 ) * 6
        g = 1
    elseif hue < 3 / 6 then
        g = 1
        b = ( hue - 2 / 6 ) * 6
    elseif hue < 4 / 6 then
        g = 1 - ( hue - 3 / 6 ) * 6
        b = 1
    elseif hue < 5 / 6 then
        r = ( hue - 4 / 6 ) * 6
        b = 1
    else
        r = 1
        b = 1 - ( hue - 5 / 6 ) * 6
    end

    return color( math.floor( r * 255 ), math.floor( g * 255 ), math.floor( b * 255 ) )
end

function color.hsb_to_rgb( h, s, b )
    local rgb = { r = 0, g = 0, b = 0 }

    if s == 0 then
        rgb.r = b * 255
        rgb.g = b * 255
        rgb.b = b * 255
    else
        local hue = ( h == 360 ) and 0 or h

        local sector = math.floor( hue / 60 )
        local sector_pos = ( hue / 60 ) - sector

        local p = b * ( 1 - s )
        local q = b * ( 1 - s * sector_pos )
        local t = b * ( 1 - s * ( 1 - sector_pos ) )

        if sector == 0 then
            rgb.r = b * 255
            rgb.g = t * 255
            rgb.b = p * 255
        elseif sector == 1 then
            rgb.r = q * 255
            rgb.g = b * 255
            rgb.b = p * 255
        elseif sector == 2 then
            rgb.r = p * 255
            rgb.g = b * 255
            rgb.b = t * 255
        elseif sector == 3 then
            rgb.r = p * 255
            rgb.g = q * 255
            rgb.b = b * 255
        elseif sector == 4 then
            rgb.r = t * 255
            rgb.g = p * 255
            rgb.b = b * 255
        elseif sector == 5 then
            rgb.r = b * 255
            rgb.g = p * 255
            rgb.b = q * 255
        end
    end

    return color(
        math.floor( rgb.r ),
        math.floor( rgb.g ),
        math.floor( rgb.b )
    )
end

function color.rgb_to_hsb( color_obj )
    local hue, saturation, brightness = 0, 0, 0

    local r = color_obj.r / 255
    local g = color_obj.g / 255
    local b = color_obj.b / 255

    local max = math.max( r, g, b )
    local min = math.min( r, g, b )

    brightness = max

    if max == 0 then
        saturation = 0
    else
        saturation = ( max - min ) / max
    end

    if max == min then
        hue = 0
    else
        local delta = max - min

        if max == r then
            hue = ( g - b ) / delta
        elseif max == g then
            hue = 2 + ( b - r ) / delta
        elseif max == b then
            hue = 4 + ( r - g ) / delta
        end

        hue = hue * 60

        if hue < 0 then
            hue = hue + 360
        end
    end

    return hue, saturation, brightness
end


local renderer = {
    fontflags = {
        [ 'i' ] = FONTFLAG_ITALIC, -- italic
        [ 'u' ] = FONTFLAG_UNDERLINE, -- underline
        [ 's' ] = FONTFLAG_STRIKEOUT, -- strikeout
        [ 'a' ] = FONTFLAG_ANTIALIAS, -- antialiasing
        [ 'b' ] = FONTFLAG_GAUSSIANBLUR, -- gaussianblur
        [ 'd' ] = FONTFLAG_DROPSHADOW, -- shadow
        [ 'o' ] = FONTFLAG_OUTLINE, -- outline
    }
}

function renderer.line( s, e, c )
    draw.Color( c:unpack( ) )
    draw.Line( s.x, s.y, e.x, e.y )
end

function renderer.line3d( s, e, c )
    local screen_pos1 = client.WorldToScreen( Vector3( s.x, s.y, s.z ) )
    local screen_pos2 = client.WorldToScreen( Vector3( e.x, e.y, e.z ) )

    if screen_pos1 and screen_pos2 then
        renderer.line(
            vector( screen_pos1[ 1 ], screen_pos1[ 2 ] ),
            vector( screen_pos2[ 1 ], screen_pos2[ 2 ] ),
            c
        )
    end
end

function renderer.rect( s, sz, c )
    draw.Color( c:unpack( ) )
    draw.OutlinedRect( s.x, s.y, s.x + sz.x, s.y + sz.y )
end

function renderer.rect_filled( s, sz, c )
    draw.Color( c:unpack( ) )
    draw.FilledRect( s.x, s.y, s.x + sz.x, s.y + sz.y )
end

function renderer.rect_fade_single_color( s, sz, c1, a1, a2, horiz )
    if horiz == nil then
        horiz = false
    end

    draw.Color( c1:unpack( ) )
    draw.FilledRectFade( s.x, s.y, s.x + sz.x, s.y + sz.y, a1, a2, horiz )
end

function renderer.rect_fade( s, sz, c1, c2, horiz )
    if horiz == nil then
        horiz = false
    end

    draw.Color( c1:unpack( ) )
    local a1 = c1.a
    draw.FilledRectFade( s.x, s.y, s.x + sz.x, s.y + sz.y, a1, 0, horiz )

    draw.Color( c2:unpack( ) )
    local a2 = c2.a
    draw.FilledRectFade( s.x, s.y, s.x + sz.x, s.y + sz.y, 10, a2, horiz )
end

function renderer.textured_rect( s, sz, texture )
    draw.Color(255, 255, 255, 255);
    draw.TexturedRect( texture, s.x, s.y, s.x + sz.x, s.y + sz.y )
end

function renderer.circle( s, r, c, p )
    if p == nil then
        p = 60
    end

    draw.Color( c:unpack( ) )
    draw.OutlinedCircle( s.x, s.y, r, p )
end

function renderer.circle_filled( s, r, c, p ) -- ! fix thx franz
    if p == nil then
        p = 60
    end

    draw.Color( c:unpack( ) )
    draw.OutlinedCircle( s.x, s.y, r, p )
end

function renderer.text( pos, col, text )
    draw.Color( col:unpack( ) )
    draw.Text( pos.x, pos.y, text )
end

function renderer.measure_text( text )
    return vector( draw.GetTextSize( text ) )
end

function renderer.create_font( fontname, sz_in_px, weight, flags_str )
    -- flags is expected to be a string
    -- i - italic
    -- u - underline
    -- s - strikeout
    -- a - antialiasing
    -- b - gaussianblur
    -- d - shadow
    -- o - outline

    local flags = flags_str == nil and FONTFLAG_CUSTOM | FONTFLAG_ANTIALIAS or flags_str == '' and FONTFLAG_NONE or FONTFLAG_CUSTOM

    if flags_str ~= nil then
        local letter = ''
        for i = 1, #flags_str do
            letter = string.sub( flags_str, i, i )

            if renderer.fontflags[ letter ] then
                flags = flags | renderer.fontflags[ letter ]
            end
        end
    end

    return draw.CreateFont( fontname, sz_in_px, weight, flags )
end

function renderer.use_font( font )
    draw.SetFont( font )
end

local player = { }
local player_mt = { }

function player_mt.is_valid( self )
    return self.lbox_ref:IsValid( )
end

function player_mt.get_name( self )
    return self.lbox_ref:GetName( )
end

function player_mt.get_index( self )
    return self.lbox_ref:GetIndex( )
end

function player_mt.get_pos( self )
    local lbox_vec = self.lbox_ref:GetAbsOrigin( )

    return vector( lbox_vec:Unpack( ) )
end

function player_mt.get_health( self )
    return self.lbox_ref:GetHealth( )
end

function player_mt.is_alive( self )
    return self.lbox_ref:IsAlive( )
end

function player_mt.is_dormant( self )
    return self.lbox_ref:IsDormant( )
end

function player_mt.get_max_health( self )
    return self.lbox_ref:GetMaxhealth( )
end

function player_mt.get_health_pc( self )
    return player_mt.get_health( self ) / player_mt.get_max_health( self )
end

function player_mt.is_crit_boosted( self )
    return self.lbox_ref:IsCritBoosted( )
end

function player_mt.in_freezecam( self )
    return self.lbox_ref:IsInFreezecam( )
end

function player_mt.get_team( self )
    return self.lbox_ref:GetTeamNumber( )
end

function player.new( lbox_ref )
    local player_data = { lbox_ref = lbox_ref }

    setmetatable( player_data, player_mt )

    return player_data
end

setmetatable( player, {
    __call = function( self, ... )
        return player.new( ... )
    end
} )


local lbox_localised_input = input
local input = { keys = { } }
local function new_keypress_data( )
    return {
        last_state = false,
        pressed = false
    }
end

function input.is_key_down( key )
    return lbox_localised_input.IsButtonDown( key )
end

function input.get_mouse_pos( )
    return lbox_localised_input.GetMousePos( )
end

function input.get_poll_tick( )
    return lbox_localised_input.GetPollTick( )
end

function input.is_button_pressed( key )
    if not input.keys[ key ] then
        input.keys[ key ] = new_keypress_data( )
    end

    local keydata = input.keys[ key ]

    return keydata.pressed
end

function input.update_keys( )
    for key in pairs( input.keys ) do
        local keydata = input.keys[ key ]
        local is_key_down = input.is_key_down( key )

        if is_key_down and not keydata.last_state then
            keydata.pressed = true
        else
            keydata.pressed = false
        end

        keydata.last_state = is_key_down
    end
end

function table.remove( table, value )
    for i = 1, #table do
        if table[ i ] == value then
            table[ i ] = nil
            return true
        end
    end
    return false
end

function table.find( table, value )
    for i = 1, #table do
        if table[ i ] == value then
            return i
        end
    end
end

-- https://stackoverflow.com/questions/72783502/how-does-one-reverse-the-items-in-a-table-in-lua
-- its 3am and im tired
function table.reverse(tab)  
    for i = 1, #tab//2, 1 do
        tab[i], tab[#tab-i+1] = tab[#tab-i+1], tab[i]
    end
    return tab
end


local function is_in_bounds( pos, sz, pos_to_find_in )
    local mouse = input.get_mouse_pos( )
    local x, y = table.unpack( mouse )

    if pos_to_find_in then
        x, y = pos_to_find_in.x, pos_to_find_in.y
    end

    return x >= pos.x and y >= pos.y and x <= pos.x + sz.x and y <= pos.y + sz.y
end

local entity = { }

function entity.get_local_player( )
    return player.new( entities.GetLocalPlayer( ) )
end

function entity.get_players( only_enemies )
    local players = entities.FindByClass( 'CTFPlayer' )
    local return_players = { }

    for _, player_ in ipairs( players ) do
        if ( only_enemies and player_:GetTeamNumber( ) ~= entities.GetLocalPlayer( ):GetTeamNumber( ) ) or not only_enemies then
            table.insert(
                return_players,
                player.new( player_ )
            )
        end
    end

    return return_players
end

local menu_opened = true

local myEnt = nil
local model_spin = vector( 0, 0, 0 )
local model_sequence = 3

callbacks.Unregister( "CreateMove", "mycreate" )
callbacks.Register( "CreateMove", "mycreate", function( cmd )
    local pLocal = entity.get_local_player( )

    if pLocal.lbox_ref == nil then
        return
    end

    if not myEnt then 
        myEnt = entities.CreateEntityByName( "player" )
        myEnt:SetAbsOrigin( Vector3( 50, 50, 500 ) )
        myEnt:SetPropInt( 42, 'm_iTeamNum' )

        print( 'created' )
    else
        myEnt:SetPropInt( model_sequence, 'm_nSequence' )
    end
end )

local camW = 400
local camH = 300 * 1.2
local camStartX = 400
local camStartY = 300

local dragging_camera = false

local cameraTexture = materials.CreateTextureRenderTarget( "cameraTexture123", camW, camH )
local cameraMaterial = materials.Create( "cameraMaterial123", [[
    UnlitGeneric
    {
        $basetexture    "cameraTexture123"
    }
]] )

local our_view = nil

local function clamp( v, min, max )
    return math.min( max, math.max( min, v ) )
end

local function get_camera( cv, offset_vector )
    -- wouldve loved to just shove this problem into ai
    -- but theyre all so incompetent :333333333
    local ent_pos = myEnt:GetAbsOrigin( )

    -- Original default angle and pos 
    customView.angles = EulerAngles( 0, 180, 0 )
    customView.origin = ent_pos + Vector3( 80, 80, 90 )

    -- we need to keep the same distance from the entity origin (0, 0, 0) and only rotate the customView(camera) around the entity rotate the customView(camera) around the entity 
    local distance = ( customView.origin - ent_pos ):Length( ) -- get the distance between the camera and the entity
    local pos = customView.origin

    local x_ang = offset_vector.x / 2
    local pitch_ang = -offset_vector.y / 5

    pitch_ang = clamp( pitch_ang, -20, 20 )

    local new_pos_pitch_z = pos.z + distance * math.sin( math.rad( pitch_ang ) )

    local new_pos = Vector3(
        pos.x + distance * math.cos( math.rad( x_ang ) ),
        pos.x + distance * math.sin( math.rad( x_ang ) ),
        new_pos_pitch_z
    )

    customView.origin = new_pos - Vector3( 80, 80, 50 )
    customView.angles = EulerAngles( pitch_ang, x_ang - 180, 0 )
end

callbacks.Register("PostRenderView", function(view)
    if myEnt == nil or not menu_opened then return end

    local scr_w, scr_h = draw.GetScreenSize( )

    local aspect_ratio = 1 / ( scr_w / scr_h )

    customView = view

    get_camera( customView, model_spin )
    
    customView.fov = 30
    customView.aspectRatio = aspect_ratio
    customView.zFar = 180
    customView.zNear = 1

    -- push our custom view ontop of the stack, on the cameraTexture mat
    render.Push3DView( customView, E_ClearFlags.VIEW_CLEAR_COLOR | E_ClearFlags.VIEW_CLEAR_DEPTH, cameraTexture )

    -- we can disable skybox rendering to save a tiny amount of fps
    render.ViewDrawScene( false, false, customView )

    render.PopView( )

    our_view = customView
end)

local is_changing_view = false
local started_pos = vector( )
local function handle_model_spin( )
    local start = vector( camStartX, camStartY )
    local size = vector( camW, camH )

    local in_bounds = is_in_bounds( start, size )
    local m1_pressed = input.is_key_down( MOUSE_LEFT )
    local m_pos = vector( table.unpack( input.get_mouse_pos( ) ) )

    if in_bounds and m1_pressed and not is_changing_view then
        is_changing_view = true
        started_pos = model_spin + vector( table.unpack( input.get_mouse_pos( ) ) )
    end

    if is_changing_view then
        local diff = started_pos - m_pos

        model_spin = diff
    end

    if not m1_pressed then
        is_changing_view = false
    end
end

local function get_view_pos2d( pos_3d, view )
    local pos = client.WorldToScreen( pos_3d, view )

    if not pos then return nil end

    local w, h = draw.GetScreenSize( )

    local perc = {
        pos[ 1 ] / w,
        pos[ 2 ] / h
    }

    return vector(
        math.floor( camStartX + perc[ 1 ] * camW ),
        math.floor( camStartY + perc[ 2 ] * camH )
    )
end


local default_font = renderer.create_font( 'Verdana', 12, 100, 'a' )
local preview_text_font = renderer.create_font( 'Smallest Pixel-7', 10, 0, 'obd' )
local arial = renderer.create_font( 'Arial', 10, 0, 'ao' )
local verdana = renderer.create_font( 'Verdana', 10, 0, 'ao' )

local esp = {
    box = nil,
    font = preview_text_font,
    alpha_mod = 1
}

function esp.set_font( font )
    esp.font = font
end

function esp.set_alpha_modifier( mod )
    esp.alpha_mod = mod
end

local function render_2d_box( box_start, box_size )
    if esp.box == 'rectangle' then
        renderer.rect(
            box_start + vector( 1, 1 ),
            box_size - vector( 2, 2 ),
            color( 255 )
        )
    elseif esp.box == 'outline' then
        renderer.rect(
            box_start + vector( 1, 0 ),
            box_size - vector( 2, 0 ),
            color( 0 )
        )

        renderer.rect(
            box_start + vector( 2, 1 ),
            box_size - vector( 4, 2 ),
            color( 255 )
        )

        renderer.rect(
            box_start + vector( 3, 2 ),
            box_size - vector( 6, 4 ),
            color( 0 )
        )
    elseif esp.box == 'corners' then
        local width = math.floor( box_size.x * 0.3 )
        local height = width

        -- ! please someone refactor this this looks horrible oh my god

        -- top left
        renderer.rect(
            box_start + vector( 1, 0 ),
            vector( 3, height ),
            color( 0 )
        )

        renderer.rect(
            box_start + vector( 1, 0 ),
            vector( width, 3 ),
            color( 0 )
        )

        renderer.line(
            box_start + vector( 2, 1 ),
            box_start + vector( width, 1 ),
            color( 255 )
        )

        renderer.line(
            box_start + vector( 2, 2 ),
            box_start + vector( 2, height - 1 ),
            color( 255 )
        )

        -- lower right
        renderer.rect(
            box_start + box_size - vector( width, 3 ),
            vector( width, 3 ),
            color( 0 )
        )

        renderer.rect(
            box_start + box_size - vector( 3, height ),
            vector( 3, height ),
            color( 0 )
        )

        renderer.line(
            box_start + box_size - vector( width - 1, 2 ),
            box_start + box_size - vector( 1, 2 ),
            color( 255 )
        )

        renderer.line(
            box_start + box_size - vector( 2, height - 1 ),
            box_start + box_size - vector( 2, 1 ),
            color( 255 )
        )

        -- top right
        renderer.rect(
            box_start + vector( box_size.x - width, 0 ),
            vector( width, 3 ),
            color( 0 )
        )

        renderer.rect(
            box_start + vector( box_size.x - 3, 0 ),
            vector( 3, height ),
            color( 0 )
        )

        renderer.line(
            box_start + vector( box_size.x - width + 1, 1 ),
            box_start + vector( box_size.x - 1, 1 ),
            color( 255 )
        )

        renderer.line(
            box_start + vector( box_size.x - 2, 2 ),
            box_start + vector( box_size.x - 2, height - 1 ),
            color( 255 )
        )

        -- bottom left
        renderer.rect(
            box_start + vector( 1, box_size.y - height ),
            vector( 3, height ),
            color( 0 )
        )

        renderer.rect(
            box_start + vector( 1, box_size.y - 3 ),
            vector( width, 3 ),
            color( 0 )
        )

        renderer.line(
            box_start + vector( 2, box_size.y - height + 1 ),
            box_start + vector( 2, box_size.y - 1 ),
            color( 255 )
        )

        renderer.line(
            box_start + vector( 2, box_size.y - 2 ),
            box_start + vector( width, box_size.y - 2 ),
            color( 255 )
        )
    end
end

local function get_2d_box_pos_size( ent, mins, maxs )
    local ent_pos = ent:GetAbsOrigin( )

    local bbox_min = ent_pos + mins
    local bbox_max = ent_pos + maxs

    local top = ent_pos + Vector3( 0, 0, bbox_max.z - bbox_min.z );

    local pos_screen = get_view_pos2d( ent_pos, our_view )
    local top_screen = get_view_pos2d( top, our_view )

    if not pos_screen or not top_screen then return end

    local pos = vector(
        math.floor( top_screen.x - ( ( pos_screen.y - top_screen.y ) / 2 ) / 2 ),
        top_screen.y
    )

    local size = vector(
        math.floor( ( pos_screen.y - top_screen.y ) / 2 ),
        pos_screen.y - top_screen.y
    )

    return pos, size
end

local function get_2d_box_bounds( ent )
    local ent_model = ent:GetModel( )

    if not ent_model then
        return nil
    end

    local mins, maxs = models.GetModelRenderBounds( ent_model )

     -- mins, maxs seemed very weird to me so i defaulted to hardcoded bbox size
    local w, h = 40, 40

    mins.x, mins.y = -w/2, -h/2
    maxs.x, maxs.y = w, h

    local ent_pos = ent:GetAbsOrigin( )
    
    local all_corners = {
        mins,
        mins + Vector3( maxs.x, 0, 0 ),
        mins + Vector3( maxs.x, maxs.y, 0 ),
        mins + Vector3( 0, maxs.y, 0 ),
        mins + Vector3( 0, maxs.y, maxs.z ),
        mins + maxs,
        mins + Vector3( maxs.x, 0, maxs.z ),
        mins + Vector3( 0, 0, maxs.z ),
    }

    -- -- render 3d bbox
    -- for i = 1, #all_corners do
    --     for j = i + 1, #all_corners do
    --         renderer.line3d( ent_pos + all_corners[ i ], ent_pos + all_corners[ j ], color( 255 ) )
    --     end
    -- end

    for corner_idx = 1, #all_corners do
        local corner_pos_abs = all_corners[ corner_idx ]
        local corner_pos_relative = ent_pos + corner_pos_abs

        local screen_pos = client.WorldToScreen( corner_pos_relative )

        if not screen_pos then return end

        all_corners[ corner_idx ] = vector( table.unpack( screen_pos ) )
    end

    -- sort table by y
    table.sort( all_corners, function( pos1, pos2 )
        return pos1.y < pos2.y
    end )

    local min_y = all_corners[ 1 ].y
    local max_y = all_corners[ 8 ].y

    -- sort table by x
    table.sort( all_corners, function( pos1, pos2 )
        return pos1.x < pos2.x
    end )

    local min_x = all_corners[ 1 ].x
    local max_x = all_corners[ 8 ].x

    local pos = vector(
        min_x, min_y
    )

    local size = vector(
        max_x - min_x, max_y - min_y
    )

    return pos, size
end


local options_menu = { }
local options_menus = { }

local open_menu = nil
local open_menu_pos = nil

local option_height = 20
local option_pad = 5

local allow_passthrough_id = nil
local skip_handle = false

local options = { }

local option_id_iterator = 0
local function gen_option_id( )
    option_id_iterator = option_id_iterator + 1
    return tostring( option_id_iterator )
end

function options.new_checkbox( name, default_value )
    local checkbox = { }

    checkbox.name = name
    checkbox.state = default_value

    checkbox.id = gen_option_id( )

    renderer.use_font( preview_text_font )
    checkbox.text_size = renderer.measure_text( checkbox.name )
    checkbox.check_size = vector( checkbox.text_size.y )
    checkbox.padding_between_check_and_text = 5
    checkbox.size = vector( option_pad + checkbox.check_size.x + checkbox.padding_between_check_and_text + checkbox.text_size.x + option_pad, option_height )

    checkbox.hovered = false
    checkbox.visible = true

    function checkbox:get( )
        return self.state
    end

    function checkbox:get_config( )
        return ( '[ \'%s\' ] = %s' ):format( self.name, self.state )
    end

    function checkbox:set_config( config_value )
        self.state = config_value
    end

    function checkbox:set_visible( new_vis_state )
        self.visible = new_vis_state
    end

    function checkbox:get_width( )
        return self.size.x
    end

    function checkbox:get_height( )
        return option_height
    end

    function checkbox:does_prevent_closing( )
        return false
    end

    function checkbox:handle( pos, width )
        local size = vector( width, self.size.y )

        local in_bounds = is_in_bounds( pos, size - vector( 0, option_height - self.text_size.y ) )
        local m1_pressed = input.is_button_pressed( MOUSE_LEFT )

        checkbox.hovered = not self.state and in_bounds

        if in_bounds and m1_pressed and ( not allow_passthrough_id or allow_passthrough_id == self.id ) then
            self.state = not self.state
        end
    end

    function checkbox:render( pos, width )
        local add_to_top = math.floor( ( option_height - self.text_size.y ) / 2 )

        if not skip_handle then
            self:handle( pos + vector( 0, add_to_top ), width ) -- check for state
        end

        -- draw checkbox
        local box_start = pos + vector( option_pad, add_to_top )

        renderer.rect_filled(
            box_start,
            self.check_size,
            color( 40 )
        )

        if self.state then
            renderer.rect_filled(
                box_start + vector( 1, 1 ),
                self.check_size - vector( 2, 2 ),
                color( 200 )
            )
        end

        -- draw text
        local text_start = box_start + vector( self.check_size.x + self.padding_between_check_and_text, 1 )
        local text_color = self.state and color( 200 ) or self.hovered and color( 150 ) or color( 100 )

        renderer.use_font( preview_text_font )
        renderer.text(
            text_start,
            text_color,
            self.name
        )
    end

    return checkbox
end


function options.new_combo( name, ... )
    local combo = { }

    combo.id = gen_option_id( )

    combo.name = name
    combo.items = { ... }
    combo.selected = 1
    combo.last_selected = 0
    combo.hovered_item = nil

    combo.open = false
    combo.visible = true

    local longest_item = 0
    for i = 1, #combo.items do
        renderer.use_font( preview_text_font )

        local w = renderer.measure_text( combo.items[ i ] ).x

        if w > longest_item then
            longest_item = w
        end
    end

    renderer.use_font( preview_text_font )
    combo.text_size = renderer.measure_text( combo.name )
    combo.combobox_size = vector( option_pad + longest_item + option_pad, option_height - 2 - 2 )
    combo.padding_between_text_and_combo = 0
    combo.size = vector( option_pad + combo.combobox_size.x + option_pad, combo.text_size.y + combo.padding_between_text_and_combo + combo.combobox_size.y + option_pad )

    combo.item_height = 12

    combo.hovered = false
    combo.topmost = true

    function combo:get_config( )
        return ( '[ \'%s\' ] = \'%s\'' ):format( self.name, self.items[ self.selected ] )
    end

    function combo:set_config( config_value )
        if type( config_value ) == 'number' then
            self.selected = config_value
        else
            self.selected = table.find( self.items, config_value )
        end
    end

    function combo:get( )
        return self.selected, self.items[ self.selected ]
    end

    function combo:set_visible( new_vis_state )
        self.visible = new_vis_state
    end

    function combo:get_width( )
        return self.size.x
    end

    function combo:get_height( )
        return self.size.y
    end

    function combo:does_prevent_closing( )
        local just_changed = false
        if self.last_selected ~= self.selected and not self.open then
            self.last_selected = self.selected
            just_changed = true
        end

        return ( combo.open and combo.hovered_item ~= nil ) or just_changed
    end

    function combo:close( )
        self.open = false
    end

    function combo:dont_allow_passthrough( )
        return self.open and self.hovered
    end

    function combo:handle( pos, width )
        self.size.x = width

        local box_start = pos + vector( option_pad, self.size.y - option_pad - self.combobox_size.y )
        local box_size = vector( width - option_pad * 2, self.combobox_size.y )

        local in_bounds = is_in_bounds( box_start, box_size )
        local m1_pressed = input.is_button_pressed( MOUSE_LEFT )

        self.hovered = in_bounds or self.open

        if in_bounds and m1_pressed and ( not allow_passthrough_id or allow_passthrough_id == self.id ) then
            self.open = not self.open
        end

        local item_start = vector( box_start.x, pos.y + self.size.y + option_pad )
        local item_size = vector( box_size.x, #self.items * self.item_height )
        local in_items_bounds = is_in_bounds( item_start, item_size )

        if not in_bounds and m1_pressed and not in_items_bounds then
            self.open = false
            return false
        end

        if self.open then
            local item_start_y = item_start.y

            local mouse = input.get_mouse_pos( )
            local x, y = table.unpack( mouse )

            local is_x_in_bounds = x > box_start.x and x < box_start.x + box_size.x

            local y_diff = y - item_start_y

            local idx_hovered = y_diff // self.item_height + 1

            self.hovered_item = idx_hovered

            local idx_in_bounds = idx_hovered > 0 and idx_hovered <= #self.items

            if not idx_in_bounds or not is_x_in_bounds then
                self.hovered_item = nil
            end

            if m1_pressed and idx_in_bounds then
                self.selected = idx_hovered
                self.open = false
                return true
            end
        end
    end

    function combo:render( pos, width )
        --self:handle( pos, width )

        -- render title
        local text_start = pos + vector( option_pad, 0 )
        renderer.use_font( preview_text_font )
        renderer.text( text_start, color( 200 ), self.name )

        local box_start = pos + vector( option_pad, self.size.y - option_pad - self.combobox_size.y )
        local box_size = vector( width - option_pad * 2, self.combobox_size.y )

        -- render combo bg
        renderer.rect_filled(
            box_start,
            box_size,
            color( 30 )
        )

        -- render combo selected item
        text_start = box_start + vector( option_pad, box_size.y / 2 - math.floor( self.text_size.y / 2 ) )
        local text_col = self.hovered and color( 150 ) or color( 100 )
        renderer.text(
            text_start, text_col, self.items[ self.selected ]
        )

        if self.open then
            box_start = box_start + vector( 0, self.combobox_size.y )
            box_size = vector( box_size.x, option_pad + #self.items * self.item_height + option_pad )

            renderer.rect_filled(
                box_start,
                box_size,
                color( 31 )
            )

            local item_start = box_start + vector( option_pad, option_pad )

            for item_idx = 1, #self.items do
                renderer.use_font( preview_text_font )

                local col = item_idx == self.selected and color( 200 ) or self.hovered_item == item_idx and color( 150 ) or color( 100 )

                renderer.text( item_start, col, self.items[ item_idx ] )

                item_start.y = item_start.y + self.item_height
            end
        end
    end

    return combo
end

local zero_opacity_bg = ( function( )
    local texture = {
        0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1,
        1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0,
        0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1,
        1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0,
    
    }
    
    local colors = {
        '\xDD\xDD\xDD\xFF',
        '\x88\x88\x88\xFF'
    }
    
    local texture_data = { }
    
    for i = 1, #texture do
        local val = texture[ i ]
    
        table.insert( texture_data, colors[ val + 1 ] )
    end
    
    local color_data = table.concat( texture_data, '' )
    local texture_obj = draw.CreateTextureRGBA( color_data, 16, 4 )
    
    callbacks.Register( "Unload", function( )
        draw.DeleteTexture( texture_obj )
    end )

    return texture_obj
end )( )

local function render_color_head( pos, size )
    renderer.rect_filled(
        pos,
        size,
        color( 255 )
    )

    renderer.rect(
        pos,
        size,
        color( 0 )
    )
end

function options.new_colorpicker( name, default_color )
    local colorpicker = { }

    colorpicker.id = gen_option_id( )

    colorpicker.name = name
    colorpicker.color = default_color

    colorpicker.open = false
    colorpicker.in_colorpicker = false

    renderer.use_font( preview_text_font )
    colorpicker.name_size = renderer.measure_text( colorpicker.name )

    colorpicker.size = vector( 0, option_pad + colorpicker.name_size.y + option_pad )
    colorpicker.head_size = vector( option_height - option_pad )

    colorpicker.visible = true

    colorpicker.hovered = false

    colorpicker.picker = {
        gap = vector( 4 ),
        big = vector( 80, 80 ),
        hue = vector( 16, 80 ),
        opacity = vector( 80 + 16 + 4, 16 )
    }

    colorpicker.picker.total = colorpicker.picker.big + vector( colorpicker.picker.hue.x, colorpicker.picker.opacity.y ) + colorpicker.picker.gap * 3 -- left right middle, top middle bottom

    colorpicker.changing = {
        big = false,
        hue = false,
        opacity = false
    }

    local h, s, b = color.rgb_to_hsb( colorpicker.color )

    colorpicker.values = {
        big = vector( s, 1 - b ),
        hue = h / 360,
        opacity = colorpicker.color.a
    }

    colorpicker.areas = {
        hue = h,
        saturation = s,
        brightness = b,
    }

    function colorpicker:get_config( )
        return ( '[ \'%s\' ] = { %i, %i, %i, %i }' ):format( self.name, self.color:unpack( ) )
    end

    function colorpicker:set_config( config_value )
        self.color = color( config_value[ 1 ], config_value[ 2 ], config_value[ 3 ], config_value[ 4 ] )

        local h, s, b = color.rgb_to_hsb( self.color )

        self.values = {
            big = vector( s, 1 - b ),
            hue = h / 360,
            opacity = colorpicker.color.a
        }
    
        self.areas = {
            hue = h,
            saturation = s,
            brightness = b,
        }
    end

    function colorpicker:get( )
        return self.color
    end

    function colorpicker:set_visible( new_vis_state )
        self.visible = new_vis_state
    end

    function colorpicker:get_width( )
        return self.size.x
    end

    function colorpicker:get_height( )
        return self.size.y
    end

    function colorpicker:does_prevent_closing( )
        return self.open and self.in_colorpicker
    end

    function colorpicker:close( )
        self.open = false
    end

    function colorpicker:handle( pos, width )
        self.hovered = is_in_bounds( pos, self.size )

        local is_m1_pressed = input.is_button_pressed( MOUSE_LEFT )

        if self.hovered and is_m1_pressed then
            self.open = not self.open
        end

        if self.open then
            local text_start = pos + vector( option_pad, option_pad )
            local colorpicker_size = self.head_size
            local colorpicker_start = vector( pos.x + width - option_pad - colorpicker_size.x, text_start.y - math.floor( colorpicker_size.y / 2 ) + math.floor( self.name_size.y / 2 ) )
            local picker_size = self.picker.total
            local picker_start = vector( colorpicker_start.x + colorpicker_size.x + option_pad * 2, colorpicker_start.y + math.floor( colorpicker_size.y / 2 - picker_size.y / 2 ) )

            self.in_colorpicker = is_in_bounds( picker_start, picker_size )

            local is_m1_down = input.is_key_down( MOUSE_LEFT )

            local color_box_start = picker_start + self.picker.gap
            local color_box_size = self.picker.big
            local in_big_bounds = is_in_bounds( color_box_start, color_box_size )

            local hue_start = color_box_start + vector( color_box_size.x + self.picker.gap.x, 0  )
            local hue_size = self.picker.hue
            local in_hue_bounds = is_in_bounds( hue_start, hue_size )

            local opacity_start = color_box_start + vector( 0, color_box_size.y + self.picker.gap.y )
            local opacity_size = self.picker.opacity
            local in_opacity_bounds = is_in_bounds( opacity_start, opacity_size )

            if not self.in_colorpicker and is_m1_pressed and not self.hovered then
                self.open = false
                self.changing.big = false
                self.changing.hue = false
                self.changing.opacity = false

                if allow_passthrough_id == self.id then
                    allow_passthrough_id = nil
                end
            end

            if is_m1_down and ( not allow_passthrough_id or allow_passthrough_id == self.id ) then
                if in_big_bounds and not self.changing.hue and not self.changing.opacity then
                    self.changing.big = true
                    self.changing.hue = false
                    self.changing.opacity = false
                elseif in_hue_bounds and not self.changing.big and not self.changing.opacity then
                    self.changing.big = false
                    self.changing.hue = true
                    self.changing.opacity = false
                elseif in_opacity_bounds and not self.changing.big and not self.changing.hue then
                    self.changing.big = false
                    self.changing.hue = false
                    self.changing.opacity = true
                end
            else
                self.changing.big = false
                self.changing.hue = false
                self.changing.opacity = false
            end

            local mouse = input.get_mouse_pos( )
            local x, y = table.unpack( mouse )
            local mouse_pos = vector( x, y )
        
            if self.changing.big then
                local diff = mouse_pos - color_box_start
                local diff_pc = diff / color_box_size

                diff_pc.x = clamp( diff_pc.x, 0, 1 )
                diff_pc.y = clamp( diff_pc.y, 0, 1 )

                self.values.big = diff_pc
            elseif self.changing.hue then
                local y_diff = mouse_pos.y - hue_start.y
                local y_diff_pc = clamp( y_diff / hue_size.y, 0, 1 )

                self.values.hue = y_diff_pc
            elseif self.changing.opacity then
                local x_diff = mouse_pos.x - opacity_start.x
                local x_diff_pc = clamp( x_diff / opacity_size.x, 0, 1 )

                self.values.opacity = x_diff_pc
            end


            self.areas.hue = math.floor( self.values.hue * 360 + 0.5 )
            self.areas.saturation = self.values.big.x
            self.areas.brightness = 1 - self.values.big.y

            local rgb_color = color.hsb_to_rgb( self.areas.hue, self.areas.saturation, self.areas.brightness )
            rgb_color.a = clamp( math.floor( self.values.opacity * 255 + 0.5 ), 0, 255 )

            self.color = rgb_color
        end

        if not self.hovered and is_m1_pressed and self.open and not self.in_colorpicker then
            self.open = self:close( )
        end
    end

    function colorpicker:render( pos, width )
        self.size.x = width

        if not skip_handle then
            self:handle( pos, width )
        end

        -- render title
        local text_start = pos + vector( option_pad, option_pad )
        local text_color = self.hovered and color( 200 ) or color( 150 )

        renderer.use_font( preview_text_font )
        renderer.text(
            text_start + vector( 0, 1 ), -- i hate it looks bad wo the (0,1) vec ok!>!>>!!?!??!?
            text_color,
            self.name
        )

        -- render colorpicker
        local colorpicker_size = self.head_size
        local colorpicker_start = vector( pos.x + width - option_pad - colorpicker_size.x, text_start.y - math.floor( colorpicker_size.y / 2 ) + math.floor( self.name_size.y / 2 ) )

        renderer.rect_filled(
            colorpicker_start,
            colorpicker_size,
            self.color
        )

        renderer.rect(
            colorpicker_start,
            colorpicker_size,
            color( 0 )
        )

        if self.open then
            local picker_size = self.picker.total
            local picker_start = vector( colorpicker_start.x + colorpicker_size.x + option_pad * 2, colorpicker_start.y + math.floor( colorpicker_size.y / 2 - picker_size.y / 2 ) )

            renderer.rect_filled(
                picker_start,
                picker_size,
                color( 40 )
            )

            renderer.rect(
                picker_start,
                picker_size,
                color( 0 )
            )

            -- render color box
            -- white to black vertical
            local color_box_start = picker_start + self.picker.gap
            local color_box_size = self.picker.big

            -- erm what the frick, no clue how but this seems to give the closest and best representation of a color picker (the main part)
            renderer.rect_fade_single_color(
                color_box_start,
                color_box_size,
                color( 255, 255, 255 ), 255, 0,
                false
            )

            local hue_to_rgb = color.hue_to_rgb( self.areas.hue )

            renderer.rect_fade_single_color(
                color_box_start,
                color_box_size,
                hue_to_rgb, 0, 255,
                true
            )
            
            renderer.rect_fade_single_color(
                color_box_start,
                color_box_size,
                color( 0, 0, 0 ), 0, 255,
                false
            )

            renderer.rect_fade_single_color(
                color_box_start,
                color_box_size,
                color( 0, 0, 0 ), 0, 255,
                false
            )

            -- render big one head
            local head_pos = color_box_start + color_box_size * self.values.big
            head_pos.x = math.floor( head_pos.x )
            head_pos.y = math.floor( head_pos.y )

            renderer.circle(
                head_pos,
                2,
                color( 0 ),
                4
            )

            renderer.circle(
                head_pos,
                1,
                color( 255 ),
                4
            )

            -- render hue oh god
            local hue_start = color_box_start + vector( color_box_size.x + self.picker.gap.x, 0  )
            local hue_size = self.picker.hue

            for i = 0, 300, 60 do
                local color_1 = color.hue_to_rgb( i )
                local color_2 = color.hue_to_rgb( i + 60 )

                renderer.rect_fade_single_color(
                    hue_start + vector( 0, math.floor( i / 360 * hue_size.y + 0.5 ) ),
                    vector( hue_size.x, math.floor( hue_size.y / 6 + ( i == 300 and 1 or 5 ) - 4 ) ),
                    color_1,
                    255,
                    100, false
                )

                renderer.rect_fade_single_color(
                    hue_start + vector( 0, math.floor( i / 360 * hue_size.y + 0.5 ) + 2 ),
                    vector( hue_size.x, math.floor( hue_size.y / 6 + ( i == 300 and 1 or 5 ) - 4 ) ),
                    color_2,
                    0,
                    255, false
                )
            end

            -- render hue slider head
            local slider_offset = vector( 2, 2 )
            local hue_slider_size = vector( hue_size.x, 0 ) + slider_offset * 2
            local hue_slider_pos = hue_start + vector( -slider_offset.x, math.floor( hue_size.y * self.values.hue ) - slider_offset.y )

            render_color_head( hue_slider_pos, hue_slider_size )

            -- render opacity
            local opacity_start = color_box_start + vector( 0, color_box_size.y + self.picker.gap.y )
            local opacity_size = self.picker.opacity

            renderer.textured_rect(
                opacity_start,
                opacity_size,
                zero_opacity_bg
            )

            renderer.rect_fade_single_color(
                opacity_start,
                opacity_size,
                color( 255 ), 0, 255, true
            )

            -- render opacity head
            local opacity_slider_size = vector( hue_slider_size.y, hue_slider_size.x )
            local opacity_slider_pos = opacity_start + vector( math.floor( opacity_size.x * self.values.opacity ) - slider_offset.x, -slider_offset.y )

            render_color_head( opacity_slider_pos, opacity_slider_size )
        end
    end

    return colorpicker
end

local menu_id_iterator = 0
local function gen_menu_id( )
    menu_id_iterator = menu_id_iterator + 1
    return tostring( menu_id_iterator )
end

function options_menu.new( given_options )
    local menu = { }

    menu.open = false

    menu.id = gen_menu_id( )

    menu.options = given_options
    menu.options_dict = { }

    menu.width = 150
    menu.height = option_pad * 2

    for i = 1, #menu.options do
        local option = menu.options[ i ]
        local new_width = option:get_width( )

        if new_width > menu.width then
            menu.width = new_width
        end

        menu.options_dict[ option.name ] = option

        menu.height = menu.height + option:get_height( )
    end

    menu.size = vector( menu.width, menu.height )

    function menu:get_option( opt_name )
        return self.options_dict[ opt_name ]
    end

    function menu:get_config( )
        local config_str_tbl = { }
        for opt_idx = 1, #self.options do
            local data = self.options[ opt_idx ]:get_config( )
            table.insert( config_str_tbl, data )
        end

        return config_str_tbl
    end

    function menu:set_config( config_data )
        for key, value in pairs( config_data ) do
            local opt = self:get_option( key )

            if opt then
                opt:set_config( value )
            end
        end
    end

    function menu:toggle_visibility( new_state )
        if new_state == nil then
            self.open = not self.open
        else
            self.open = new_state
        end

        -- close all stuff
        for item_idx = 1, #self.options do
            local opt = self.options[ item_idx ]

            if opt.close then
                opt:close( )
            end
        end
    end

    function menu:is_something_preventing_closing( )
        for idx = 1, #self.options do
            if self.options[ idx ]:does_prevent_closing( ) then
                return true
            end
        end

        return false
    end

    function menu:render( pos )
        if not self.open then return end

        local render_start = pos

        -- render bg
        renderer.rect_filled(
            render_start,
            self.size,
            color( 20 )
        )
        local opt_pos = render_start + vector( 0, option_pad )

        local render_after = { }

        allow_passthrough_id = nil


        local new_y_size = option_pad * 2

        skip_handle = false
        for i = 1, #self.options do
            local option = self.options[ i ]

            if not option.visible then goto next_opt end

            if not option.topmost then
                option:render( opt_pos, self.width )
            else
                table.insert( render_after, { opt = option, pos = vector( opt_pos.x, opt_pos.y ) } )

                skip_handle = option:handle( opt_pos, self.width )
                if option:dont_allow_passthrough( ) then
                    allow_passthrough_id = option.id
                end
            end

            local opt_height = option:get_height( )

            new_y_size = new_y_size + opt_height
            opt_pos.y = opt_pos.y + opt_height

            ::next_opt::
        end

        self.size.y = new_y_size

        for i = #render_after, 1, -1 do
            local data = render_after[ i ]

            data.opt:render( data.pos, self.width )
        end
    end

    table.insert( options_menus, menu )
    return menu
end

local docker = { }
local docker_areas = { }
local docker_texts = { }
local docker_sliders = { }

local dragging_id = nil
local id_iterator = 0
local area_id_iterator = 0

local docker_enums = {
    [ 'text' ] = 0,
    [ 'slider' ] = 1
}

local docker_area_flow = {
    [ 'vertical' ] = 0,
    [ 'horizontal' ] = 1
}

local function gen_id( )
    id_iterator = id_iterator + 1
    return tostring( id_iterator )
end

local function gen_area_id( )
    area_id_iterator = area_id_iterator + 1
    return tostring( area_id_iterator )
end

local docker_bank = { }

function docker_bank.new( title, pos, max_width )
    local docker_bank_obj = { }

    docker_bank_obj.title = title

    docker_bank_obj.pos = pos
    docker_bank_obj.max_width = max_width

    docker_bank_obj.size = vector( max_width, 0 )

    docker_bank_obj.items = { }
    docker_bank_obj.keys = { }

    function docker_bank_obj:add( docker_obj )
        table.insert( self.keys, docker_obj.id )
        docker_bank_obj.items[ docker_obj.id ] = docker_obj

        docker_obj.backup_bank = self
    end

    function docker_bank_obj:remove( docker_obj )
        table.remove( self.keys, docker_obj.id )
        docker_bank_obj.items[ docker_obj.id ] = nil
    end

    function docker_bank_obj:draw( )
        -- this could be sped up by caching the posistions
        local row = 1
        local offset = 0

        local remove_next = { }

        renderer.use_font( preview_text_font )
        renderer.text(
            self.pos + vector( 5, 0 ),
            color( 255 ),
            self.title
        )

        local text_start = self.pos + vector( 5, 0 )

        if #self.keys == 0 then
            renderer.text(
                text_start + vector( 0, row * 16 ),
                color( 255, 100 ),
                'no elements left'
            )
        end

        for key_idx = 1, #self.keys do
            local docker_obj = self.items[ self.keys[ key_idx ] ]

            local start_pos = text_start + vector( offset, row * 16 )

            if not docker_obj then goto continue end

            local name = docker_obj.text

            local text_sz = renderer.measure_text( name )

            local in_bounds = is_in_bounds( start_pos, text_sz )
            local mouse_held = input.is_key_down( MOUSE_LEFT )

            local mouse = input.get_mouse_pos( )
            local x, y = table.unpack( mouse )
            local mouse_pos = vector( x, y )

            if not is_changing_view and in_bounds and mouse_held and dragging_id == nil and docker_obj.dragging_pos == nil then
                dragging_id = docker_obj.id
                self.dragging_difference = start_pos - mouse_pos
            end

            -- were dragging this element
            if dragging_id == docker_obj.id and mouse_held then
                docker_obj.dragging_pos = mouse_pos + self.dragging_difference

                start_pos = docker_obj.dragging_pos

                docker_obj:handle_drag( )
            end

            if dragging_id == docker_obj.id and not mouse_held then
                dragging_id = nil

                local new_parent = docker_obj:handle_drop( )

                if new_parent then
                    table.insert( remove_next, docker_obj )
                    --print( 'removed bank, attempting to assign new parent (area)' )

                    new_parent:handle_drop( docker_obj )
                end
            end

            local bg_color = in_bounds and color( 100 ) or color( 50 )

            renderer.rect_filled(
                start_pos,
                text_sz,
                bg_color
            )

            renderer.text(
                start_pos,
                color( 255 ),
                name
            )

            if offset - text_sz.x >= self.max_width then
                row = row + 1
                offset = 0
            else
                offset = offset + text_sz.x + 5
            end

            ::continue::
        end

        for i = 1, #remove_next do
            self:remove( remove_next[ i ] )
        end

        -- cleanup nil keys
        local new_keys = { }
        for key = 1, #self.keys do
            if self.keys[ key ] then
                table.insert( new_keys, self.keys[ key ] )
            end
        end

        self.keys = new_keys
        self.size.y = 16 * ( row + 2 )
    end

    return docker_bank_obj
end

local base_pos = vector( 400, 200 )

local item_bank_bars = docker_bank.new(
    'slider objects',
    base_pos + vector( 125, 300 ),
    75
)

local item_bank_text = docker_bank.new(
    'text items',
    base_pos + vector( 125, 310 ),
    75
)

function docker.text( text, given_options, callback )
    local text_obj = { }

    text_obj.text = text
    text_obj.options_menu = #given_options > 0 and options_menu.new( given_options ) or nil
    text_obj.callback_fn = callback

    text_obj.type = docker_enums[ 'text' ]

    text_obj.id = gen_id( )

    text_obj.dragging_pos = nil
    text_obj.parent = nil
    text_obj.backup_bank = nil

    text_obj.value_str = 'preview_str'

    text_obj.overridden_params = nil

    text_obj.color = color( 255, 0, 0 )
    text_obj.background_color = color( 20 )

    text_obj.esp = {
        area_id = nil,
        offset_pos = nil,
        flow = nil
    }

    function text_obj:get_config( )
        local menu_config_tbl = text_obj.options_menu and text_obj.options_menu:get_config( ) or nil

        if not menu_config_tbl then
            menu_config_tbl = { }
        end

        table.insert( menu_config_tbl, ( '[ \'area_id\' ] = \'%s\'' ):format( self.parent and self.parent.id or nil ) )

        local menu_config_str = '{ ' .. table.concat( menu_config_tbl, ', ' ) .. ' }'

        local config_str = ( '[ \'%s\' ] = %s' ):format( self.text, menu_config_str )

        return config_str
    end

    function text_obj:set_config( config_data_tbl )
        if not self.options_menu then return end

        for key, value in pairs( config_data_tbl ) do
            if key == 'area_id' then
                if value ~= 'nil' then
                    for area_idx = 1, #docker_areas do
                        local area = docker_areas[ area_idx ]
                        if area.id == value then
                            area:add( self )
                            break
                        end
                    end
                end
            else
                local opt = self:get_option( key )

                if opt then
                    opt:set_config( value )
                end
            end
        end
    end

    function text_obj:get_option( name )
        if #self.options_menu.options == 0 then return nil end

        return self.options_menu.options_dict[ name ]
    end

    function text_obj:set_color( new_col )
        self.color = new_col
    end

    function text_obj:handle_drag( )
        for area_idx = 1, #docker_areas do
            local area = docker_areas[ area_idx ]

            area:handle_hovering_with_item( false )

            local in_area_bounds = is_in_bounds( area.pos, area.size, self.dragging_pos )

            if in_area_bounds then
                area:handle_hovering_with_item( true, self )
            end
        end
    end

    function text_obj:handle_drop( use_mouse )
        local area_hovering = nil

        for area_idx = 1, #docker_areas do
            local area = docker_areas[ area_idx ]

            local in_area_bounds = is_in_bounds( area.pos, area.size, not use_mouse and self.dragging_pos or nil )

            if in_area_bounds then
                area_hovering = area
                break
            end
        end

        if not area_hovering then
            local bank = self.backup_bank
            local has_backup = false
            for item_idx = 1, #bank.keys do
                local key = bank.keys[ item_idx ]

                if key == self.id then
                    has_backup = true
                    break
                end
            end

            if not has_backup then
                if self.parent then
                    self.parent:remove( self )
                end
                bank:add( self )
            end
        end

        self.dragging_pos = nil

        return area_hovering
    end

    function text_obj:callback( ... )
        if self.callback_fn then
            return self.callback_fn( self, ... )
        end
    end

    function text_obj:handle_options_menu( params )
        local pos = params.pos
        local text_sz = params.text_sz

        local in_bounds = is_in_bounds( pos, text_sz )
        
        local is_mouse2_pressed = input.is_button_pressed( MOUSE_RIGHT )

        local opt_menu = self.options_menu

        if opt_menu == nil then return end

        local preventing_close = opt_menu:is_something_preventing_closing( )

        if not is_changing_view and in_bounds and is_mouse2_pressed then
            local new_state = not opt_menu.open

            if new_state == false and not preventing_close then
                opt_menu:toggle_visibility( new_state )
            else
                opt_menu:toggle_visibility( )
            end

            if dragging_id ~= nil then
                opt_menu:toggle_visibility( false )
            end
        end

        if is_mouse2_pressed and not in_bounds then
            opt_menu:toggle_visibility( false )
        end

        local is_mouse1_pressed = input.is_button_pressed( MOUSE_LEFT )
        local menu_start = pos + vector( text_sz.x + option_pad, 0 )
        local in_menu_bounds = is_in_bounds( menu_start, opt_menu.size )

        if is_mouse1_pressed and not in_menu_bounds then
            if not preventing_close then
                opt_menu:toggle_visibility( false )
            end
        end
    end

    function text_obj:render( params )
        if self.overridden_params then
            params = self.overridden_params
        end

        local pos = params.pos
        local area = params.area

        renderer.use_font( esp.font )

        renderer.text(
            pos, self.color, self.value_str
        )

        if not dragging_id then
            self.esp.area_id = self.parent.id
            self.esp.flow = area.flow
        end
    end

    function text_obj:render_esp( render_text, offset, box_start, box_size )
        local offset_pos = box_start + offset

        renderer.use_font( esp.font )

        local r, g, b, a = self.color:unpack( )
        local render_color = color( r, g, b, math.floor( esp.alpha_mod * a ) )

        renderer.text(
            offset_pos,
            render_color,
            render_text
        )
    end

    function text_obj:handle_area_drag( params ) -- when the element in in an area already
        self.overridden_params = nil

        local has_menu_overlay = open_menu and open_menu_pos

        local pos = params.pos
        local width = params.width
        local area = params.area
        local text_sz = params.text_size

        if area.flow == docker_area_flow[ 'horizontal' ] then
            local center = pos + vector( math.floor( width / 2 ), 0 )

            pos.x = center.x - math.floor( text_sz.x / 2 )
        end

        local in_bounds = is_in_bounds( pos, text_sz )
        local mouse_held = input.is_key_down( MOUSE_LEFT )
        local mouse = input.get_mouse_pos( )
        local x, y = table.unpack( mouse )
        local mouse_pos = vector( x, y )

        if not has_menu_overlay and not is_changing_view and in_bounds and mouse_held and dragging_id == nil and self.dragging_pos == nil then
            dragging_id = self.id
            self.dragging_difference = pos - mouse_pos
        end

        -- were dragging this element
        -- handle dragging here
        local hovering = nil
        if dragging_id == self.id and mouse_held then
            self.dragging_pos = mouse_pos + self.dragging_difference

            pos = self.dragging_pos

            for area_idx = 1, #docker_areas do
                local area = docker_areas[ area_idx ]
    
                area:handle_hovering_with_item( false )
    
                local in_area_bounds = is_in_bounds( area.pos, area.size )
    
                if in_area_bounds then
                    area:handle_hovering_with_item( true, self )
                    hovering = area
                end
            end

            self.overridden_params = {
                pos = pos,
                width = width,
                area = area
            }

            if hovering and hovering.pos ~= self.parent.pos then
                local new_width = hovering.size.x

                self.overridden_params = {
                    pos = pos,
                    width = new_width,
                    area = hovering
                }
            end
        end

        if dragging_id == self.id and not mouse_held then
            dragging_id = nil

            local new_parent = self:handle_drop( true )

            if new_parent then
                -- if we drop the text in the same parent, check if we have to reorder
                if self.parent.pos == new_parent.pos then
                    new_parent:reorder( self, mouse_pos )
                else
                    new_parent:handle_drop( self )
                end
            end
        end
    end

    table.insert( docker_texts, text_obj )
    item_bank_text:add( text_obj )

    return text_obj
end

function docker.slider( text, given_options, callback )
    local slider_obj = { }

    slider_obj.text = text
    slider_obj.options_menu = #given_options > 0 and options_menu.new( given_options ) or nil
    slider_obj.callback_fn = callback

    slider_obj.thickness = 3

    slider_obj.type = docker_enums[ 'slider' ]

    slider_obj.id = gen_id( )

    slider_obj.dragging_pos = nil
    slider_obj.parent = nil
    slider_obj.backup_bank = nil

    slider_obj.value_frac = 1

    slider_obj.overridden_params = nil

    slider_obj.color = color( 255, 0, 0 )
    slider_obj.background_color = color( 20 )

    slider_obj.esp = {
        area_id = nil,
        offset_pos = nil,
        flow = nil
    }

    slider_obj.last_poll = 0

    function slider_obj:get_config( )
        local menu_config_tbl = self.options_menu and self.options_menu:get_config( ) or nil

        if not menu_config_tbl then
            menu_config_tbl = { }
        end

        table.insert( menu_config_tbl, ( '[ \'area_id\' ] = \'%s\'' ):format( self.parent and self.parent.id or nil ) )
        table.insert( menu_config_tbl, ( '[ \'thickness\' ] = %i' ):format( self.thickness ) )

        local menu_config_str = '{ ' .. table.concat( menu_config_tbl, ',' ) .. ' }'

        local config_str = ( '[ \'%s\' ] = %s' ):format( self.text, menu_config_str )

        return config_str
    end

    function slider_obj:get_option( name )
        if #self.options_menu.options == 0 then return nil end

        return self.options_menu.options_dict[ name ]
    end

    function slider_obj:set_config( config_data )
        for key, value in pairs( config_data ) do
            if key == 'area_id' then
                if value ~= 'nil' then
                    for area_idx = 1, #docker_areas do
                        local area = docker_areas[ area_idx ]
                        if area.id == value then
                            area:add( self )
                            break
                        end
                    end
                end
            elseif key == 'thickness' then
                self.thickness = value
            end
        end
    end

    function slider_obj:handle_drag( )
        for area_idx = 1, #docker_areas do
            local area = docker_areas[ area_idx ]

            area:handle_hovering_with_item( false )

            local in_area_bounds = is_in_bounds( area.pos, area.size, self.dragging_pos )

            if in_area_bounds then
                area:handle_hovering_with_item( true, self )
            end
        end
    end

    function slider_obj:handle_drop( use_mouse )
        local area_hovering = nil

        for area_idx = 1, #docker_areas do
            local area = docker_areas[ area_idx ]

            local in_area_bounds = is_in_bounds( area.pos, area.size, not use_mouse and self.dragging_pos or nil )

            if in_area_bounds then
                area_hovering = area
                break
            end
        end

        if not area_hovering then
            local bank = self.backup_bank
            local has_backup = false
            for item_idx = 1, #bank.keys do
                local key = bank.keys[ item_idx ]

                if key == self.id then
                    has_backup = true
                    break
                end
            end

            if not has_backup then
                if self.parent then
                    self.parent:remove( self )
                end
                bank:add( self )
            end
        end

        self.dragging_pos = nil

        return area_hovering
    end

    function slider_obj:add_thickness( amount )
        local new_thickness = self.thickness + amount

        new_thickness = clamp( new_thickness, 3, 10 )

        self.thickness = new_thickness
    end

    function slider_obj:callback( ... )
        if self.callback_fn then
            return self.callback_fn( self, ... )
        end
    end

    function slider_obj:handle_options_menu( params )
        local pos = params.pos
        local size = params.size

        local in_bounds = is_in_bounds( pos, size )
        
        local is_mouse2_pressed = input.is_button_pressed( MOUSE_RIGHT )

        local opt_menu = self.options_menu

        if opt_menu == nil then return end

        local preventing_close = opt_menu:is_something_preventing_closing( )

        if not is_changing_view and in_bounds and is_mouse2_pressed then
            local new_state = not opt_menu.open

            if new_state == false and not preventing_close then
                opt_menu:toggle_visibility( new_state )
            else
                opt_menu:toggle_visibility( )
            end

            if dragging_id ~= nil then
                opt_menu:toggle_visibility( false )
            end
        end

        if is_mouse2_pressed and not in_bounds then
            opt_menu:toggle_visibility( false )
        end

        local is_mouse1_pressed = input.is_button_pressed( MOUSE_LEFT )
        local menu_start = pos + vector( size.x + option_pad, 0 )
        local in_menu_bounds = is_in_bounds( menu_start, opt_menu.size )

        if is_mouse1_pressed and not in_menu_bounds then
            if not preventing_close then
                opt_menu:toggle_visibility( false )
            end
        end
    end

    function slider_obj:render( params )
        if self.overridden_params then
            params = self.overridden_params
        end

        local pos = params.pos
        local length = math.floor( params.length * slider_obj.value_frac )
        local area = params.area

        if area.flow == docker_area_flow[ 'vertical' ] then
            renderer.rect_filled(
                pos, vector( self.thickness, params.length ), self.background_color
            )

            renderer.rect_filled(
                pos, vector( self.thickness, length ), self.color
            )

            renderer.rect(
                pos,vector( self.thickness, params.length ), color( 0 )
            )
        else
            renderer.rect_filled(
                pos, vector( params.length, self.thickness ), self.background_color
            )

            renderer.rect_filled(
                pos, vector( length, self.thickness ), self.color
            )

            renderer.rect(
                pos,vector( params.length, self.thickness ), color( 0 )
            )
        end

        if not dragging_id then
            self.esp.area_id = self.parent.id
            self.esp.flow = area.flow
        end
    end

    function slider_obj:render_esp( pc, offset, box_start, box_size )
        local slider_start = box_start + offset

        local flow = self.esp.flow

        local true_height = box_size.y
        local height = math.floor( pc * box_size.y )

        local r, g, b, a = self.background_color:unpack( )
        local bg_render_color = color( r, g, b, math.floor( esp.alpha_mod * a ) )

        r, g, b, a = self.color:unpack( )
        local render_color = color( r, g, b, math.floor( ( esp.alpha_mod ^ 2 ) * a ) )

        local default_alpha = math.floor( esp.alpha_mod ^ 0.5 * 255 )
    
        if flow == docker_area_flow[ 'vertical' ] then
            local healthbar_start = slider_start + vector( 0, true_height - height )
    
            renderer.rect_filled(
                slider_start, vector( self.thickness, true_height ), bg_render_color
            )
    
            renderer.rect_filled(
                healthbar_start + vector( 1, 1 ), vector( self.thickness - 2, height - 2 ), render_color
            )
    
            renderer.rect(
                slider_start, vector( self.thickness, true_height ), color( 0, default_alpha )
            )
        else
            true_height = box_size.x
            height = math.floor( pc * box_size.x )
    
            renderer.rect_filled(
                slider_start, vector( true_height, self.thickness ), bg_render_color
            )
    
            renderer.rect_filled(
                slider_start + vector( 1, 1 ), vector( height - 1, self.thickness - 1 ), render_color
            )
    
            renderer.rect(
                slider_start, vector( true_height, self.thickness ), color( 0, default_alpha )
            )
        end
    end

    function slider_obj:handle_area_drag( params ) -- when the element in in an area already
        self.overridden_params = nil
        local has_menu_overlay = open_menu and open_menu_pos

        local pos = params.pos
        local length = params.length
        local area = params.area

        local sz = vector( )

        if area.flow == docker_area_flow[ 'vertical' ] then
            sz = vector( self.thickness, length )
        else
            sz = vector( length, self.thickness )
        end

        local in_bounds = is_in_bounds( pos, sz )
        local mouse_held = input.is_key_down( MOUSE_LEFT )

        local mouse = input.get_mouse_pos( )
        local x, y = table.unpack( mouse )
        local mouse_pos = vector( x, y )

        if in_bounds then
            local is_arrow_left_pressed = input.is_key_down( KEY_LEFT )
            local is_arrow_right_pressed = input.is_key_down( KEY_RIGHT )
            local last_poll_tick = input.get_poll_tick( )

            if ( is_arrow_left_pressed or is_arrow_right_pressed ) and last_poll_tick - self.last_poll > 50 then
                local amount = 0

                if is_arrow_left_pressed then amount = -1
                elseif is_arrow_right_pressed then amount = 1 end

                if is_arrow_left_pressed and is_arrow_right_pressed then amount = 0 end

                self:add_thickness(
                    amount
                )

                self.last_poll = last_poll_tick
            end
        end

        if not has_menu_overlay and not is_changing_view and in_bounds and mouse_held and dragging_id == nil and self.dragging_pos == nil then
            dragging_id = self.id
            self.dragging_difference = pos - mouse_pos
        end

        -- were dragging this element
        -- handle dragging here
        local hovering = nil
        if dragging_id == self.id and mouse_held then
            self.dragging_pos = mouse_pos + self.dragging_difference

            pos = self.dragging_pos

            for area_idx = 1, #docker_areas do
                local area = docker_areas[ area_idx ]
    
                area:handle_hovering_with_item( false )
    
                local in_area_bounds = is_in_bounds( area.pos, area.size )
    
                if in_area_bounds then
                    area:handle_hovering_with_item( true, self )
                    hovering = area
                end
            end

            self.overridden_params = {
                pos = pos,
                length = length,
                area = area
            }

            if hovering and hovering.pos ~= self.parent.pos then
                local new_length = hovering.flow == docker_area_flow[ 'vertical' ] and hovering.size.y or hovering.size.x

                if hovering.flow ~= area.flow then -- rotating the bar when moving it
                    if hovering.flow == docker_area_flow[ 'horizontal' ] then
                        -- calculating x so it feels natural
                        local before_y_range = length
                        local mouse_relative = mouse_pos.y - pos.y

                        local perc = mouse_relative / before_y_range

                        pos.x = mouse_pos.x - math.floor( ( perc ) * length )
                        pos.y = mouse_pos.y
                    else
                        local before_x_range = length
                        local mouse_relative = mouse_pos.x - pos.x

                        local perc = mouse_relative / before_x_range

                        pos.y = mouse_pos.y - math.floor( ( perc ) * length )
                        pos.x = mouse_pos.x
                    end
                end

                self.overridden_params = {
                    pos = pos,
                    length = new_length, --new_length,
                    area = hovering -- hovering.flow
                }
            end
        end

        if dragging_id == self.id and not mouse_held then
            dragging_id = nil

            local new_parent = self:handle_drop( true )

            if new_parent then
                new_parent:handle_drop( self )
            end
        end
    end

    table.insert( docker_sliders, slider_obj )
    item_bank_bars:add( slider_obj )
    return slider_obj
end

local docker_area = { }

function docker_area.new( pos, size, left_align_or_align_top, force_align, disallow_types )
    local docker_area_obj = { }

    docker_area_obj.pos = pos
    docker_area_obj.size = size

    docker_area_obj.flow = size.x > size.y and docker_area_flow[ 'horizontal' ] or docker_area_flow[ 'vertical' ]

    if force_align then
        docker_area_obj.flow = force_align
    end

    docker_area_obj.inverted = left_align_or_align_top == true

    docker_area_obj.texts = { }
    docker_area_obj.text_keys = { }
    
    docker_area_obj.sliders = { }
    docker_area_obj.slider_keys = { }

    docker_area_obj.linked_static_dockers = { }

    docker_area_obj.hovered = false
    docker_area_obj.sliders_total_thickness = 0

    docker_area_obj.id = gen_area_id( )
    docker_area_obj.not_allowed_types = disallow_types

    docker_area_obj.slider_pad = 2

    function docker_area_obj:add( docker_obj )
        docker_obj.parent = self

        self.hovered = false
        self.hovered_obj = nil
        --print( ( 'set obj(%s[%i]) parent %s' ):format( docker_obj.id, docker_obj.type, tostring( self.pos ) ) )

        if docker_obj.type == docker_enums[ 'text' ] then
            self.texts[ docker_obj.id ] = docker_obj
            table.insert( self.text_keys, docker_obj.id )
        elseif docker_obj.type == docker_enums[ 'slider' ] then
            self.sliders[ docker_obj.id ] = docker_obj
            table.insert( self.slider_keys, docker_obj.id )
        end
    end

    function docker_area_obj:remove( docker_obj )
        --print( ( 'removed obj(%s[%i]) parent %s' ):format( docker_obj.id, docker_obj.type, tostring( self.pos ) ) )

        if docker_obj.type == docker_enums[ 'text' ] then
            self.texts[ docker_obj.id ] = nil
            table.remove( self.text_keys, docker_obj.id )

            local new_table = { }
            for i = 1, #self.text_keys do
                local val = self.text_keys[ i ]

                if val then
                    table.insert( new_table, val )
                end
            end

            self.text_keys = new_table
        elseif docker_obj.type == docker_enums[ 'slider' ] then
            self.sliders[ docker_obj.id ] = nil
            table.remove( self.slider_keys, docker_obj.id )

            local new_table = { }
            for i = 1, #self.slider_keys do
                local val = self.slider_keys[ i ]

                if val then
                    table.insert( new_table, val )
                end
            end

            self.slider_keys = new_table
        end
    end

    function docker_area_obj:reorder( docker_obj, hovered_pos )
        self.hovered = false
        self.hovered_obj = nil

        local y_diff = hovered_pos.y - self.pos.y -- ill be hones,t i have no clue how this works, pray and test method 👍

        if self.flow == docker_area_flow[ 'horizontal' ] and not self.inverted then
            y_diff = self.pos.y + self.size.y - hovered_pos.y - self.sliders_total_thickness
        end

        if self.flow == docker_area_flow[ 'horizontal' ] then
            y_diff = y_diff - self.sliders_total_thickness
        end

        local new_idx = 1

        renderer.use_font( preview_text_font )
        local text_sz = renderer.measure_text( docker_obj.text )

        y_diff = y_diff

        local pc_y = y_diff / text_sz.y

        if pc_y > #self.text_keys then
            pc_y = 1
        else
            pc_y = pc_y % 1
        end

        if y_diff < 0 then new_idx = 1
        else new_idx = y_diff // text_sz.y + 1 end

        new_idx = clamp( new_idx, 1, #self.text_keys )

        if self.flow == docker_area_flow[ 'horizontal' ] and not self.inverted then
            -- new_idx = #self.text_keys - new_idx + 1
        end


        local old_docker_index = table.find( self.text_keys, docker_obj.id )
        local new_keys = { }

        for key_idx = 1, #self.text_keys do
            if key_idx == new_idx then
                if self.text_keys[ key_idx ] ~= docker_obj.id and pc_y >= 0.5 then
                    table.insert( new_keys, self.text_keys[ key_idx ] )
                    --print( 'moved ' .. self.texts[ self.text_keys[ key_idx ] ].text .. ' before elem' )
                end

                table.insert( new_keys, self.text_keys[ old_docker_index ] )

                if self.text_keys[ key_idx ] ~= docker_obj.id and pc_y < 0.5 then
                    table.insert( new_keys, self.text_keys[ key_idx ] )
                    --print( 'moved' .. self.texts[ self.text_keys[ key_idx ] ].text .. ' after elem' )
                end
            elseif self.text_keys[ key_idx  ] ~= docker_obj.id then
                table.insert( new_keys, self.text_keys[ key_idx ] )
            end
        end

        self.text_keys = new_keys
    end

    function docker_area_obj:update( new_pos, new_size )
        self.pos = new_pos
        self.size = new_size
    end

    function docker_area_obj:handle_hovering_with_item( state, obj )
        docker_area_obj.hovered = state

        if state then
            docker_area_obj.hovered_obj = obj -- ok i though of using disallowed things here but ig i can make box and stuff just a toggle since they go center only xx
        end
    end

    function docker_area_obj:handle_drop( docker_obj )
        if docker_obj.parent then
            docker_obj.parent:remove( docker_obj )
        end

        self:add( docker_obj )

        --print( 'assigned new parent (area), new children count: ' .. tostring( #self.slider_keys ) )
    end

    function docker_area_obj:on_draw( )
        local bg_color = self.hovered and color( 50, 150 ) or color( 0, 0 )
        
        renderer.rect_filled(
            self.pos,
            self.size,
            bg_color
        )

        -- first handle the sliders
        local slider_start = self.flow == docker_area_flow[ 'vertical' ] and ( -- vertical
            self.inverted and self.pos -- left aligned, so slider start pos is the same as area start pos 
                          or  self.pos + vector( self.size.x, 0 ) -- right aligned, slider start pos is to the right of the area, so we add the size x
        ) or ( -- horizontal
            self.inverted and self.pos -- inverted, aka the area is under our thing, align to top
                          or  self.pos + vector( 0, self.size.y ) -- start is on the bottom of the area
        )

        local sliders_total_thickness = 0
        local slider_pad = self.slider_pad

        for slider_idx = 1, #self.slider_keys do
            local slider = self.sliders[ self.slider_keys[ slider_idx ] ]

            if not slider then goto continue end

            -- try with is_preview, lua doesnt allow checking how many params there are so we do this
            local ok, preview_value, gave_preview = pcall( slider.callback, slider, myEnt )

            if not ok then -- if ent or sm went bad, try is_preview to true
                -- we expect only one return value
                ok, preview_value = pcall( slider.callback, slider, myEnt, true )
            else
                ok, preview_value = pcall( slider.callback, slider, myEnt, true )

                if preview_value == nil then
                    if gave_preview ~= nil then
                        preview_value = gave_preview
                    end
                end
            end

            if preview_value == nil then
                error( ( 'Please check your "%s" callback function. Tried to give it an entity and is_preview=true, all matching calls failed to return a preview value.' ):format( text.text ) )
            end

            slider.value_frac = preview_value

            local cur_slider_thickness = slider.thickness

            -- figure out the starting position
            if self.flow == docker_area_flow[ 'vertical' ] and not self.inverted then
                slider_start = slider_start - vector( cur_slider_thickness, 0 )
            elseif self.flow == docker_area_flow[ 'horizontal' ] and not self.inverted then
                slider_start = slider_start - vector( 0, cur_slider_thickness )
            end

            local slider_length = self.flow == docker_area_flow[ 'vertical' ] and self.size.y or self.size.x
            local slider_width = self.flow == docker_area_flow[ 'vertical' ] and slider.thickness or slider_length
            local slider_height = self.flow == docker_area_flow[ 'vertical' ] and slider_length or slider.thickness

            local slider_props = {
                pos = slider_start,
                length = slider_length,
                area = self,
                size = vector( slider_width, slider_height )
            }

            slider:handle_area_drag( slider_props )

            if slider.parent.id == self.id then
                slider:render( slider_props )
            end

            if slider.options_menu then
                slider:handle_options_menu( slider_props )

                if slider.options_menu.open and open_menu == nil then -- no menu open and our menu open
                    open_menu = slider.options_menu -- set menu and pos
                    open_menu_pos = slider_props.pos + vector( option_pad + slider_width, 0 )
                end

                -- open menu and matcehs ours
                if open_menu and open_menu.id == slider.options_menu.id then
                    open_menu_pos = slider_props.pos + vector( option_pad + slider_width, 0 ) -- update pos

                    if not slider.options_menu.open or dragging_id == slider.id then -- if the menu is closed, set new open menu as nil, OR if were dragging the element
                        open_menu = nil
                        open_menu_pos = nil
                    end
                end
            end

            if self.flow == docker_area_flow[ 'vertical' ] and not self.inverted then
                slider_start = slider_start - vector( slider_pad, 0 )
            elseif self.flow == docker_area_flow[ 'horizontal' ] and not self.inverted then
                slider_start = slider_start - vector( 0, slider_pad )
            elseif self.flow == docker_area_flow[ 'vertical' ] and self.inverted then
                slider_start = slider_start + vector( cur_slider_thickness + slider_pad, 0 )
            elseif self.flow == docker_area_flow[ 'horizontal' ] and self.inverted then
                slider_start = slider_start + vector( 0, cur_slider_thickness + slider_pad )
            end

            sliders_total_thickness = sliders_total_thickness + cur_slider_thickness + slider_pad

            ::continue::
        end

        self.sliders_total_thickness = sliders_total_thickness

        local text_start = self.flow == docker_area_flow[ 'vertical' ] and (
            self.inverted and slider_start + vector( slider_pad, 0 )
                          or  slider_start - vector( slider_pad, 0 )
        ) or (
            self.inverted and slider_start + vector( 0, slider_pad )
                          or  slider_start - vector( 0, slider_pad )
        )

        for text_index = 1, #self.text_keys do
            local text = self.texts[ self.text_keys[ text_index ] ]
            
            if not text then goto continue end
            
            -- callback can change font context, we want to change the context for this one cycle only
            esp.set_font( preview_text_font )

            -- try with is_preview, lua doesnt allow checking how many params there are so we do this
            local ok, preview_text, gave_preview = pcall( text.callback, text, myEnt )

            if not ok then -- if ent or sm went bad, try is_preview to true
                -- we expect only one return value
                ok, preview_text = pcall( text.callback, text, myEnt, true )
            else
                ok, preview_text = pcall( text.callback, text, myEnt, true )

                if preview_text == nil then
                    if gave_preview ~= nil then
                        preview_text = gave_preview
                    end
                end
            end

            if preview_text == nil then
                error( ( 'Please check your "%s" callback function. Tried to give it an entity and is_preview=true, all matching calls failed to return a preview string.' ):format( text.text ) )
            end

            text.value_str = tostring( preview_text )

            local text_pos = text_start
            renderer.use_font( esp.font )
            local text_sz = renderer.measure_text( text.value_str )

            if self.flow == docker_area_flow[ 'vertical' ] and not self.inverted then
                text_pos = text_start - vector( text_sz.x, 0 )
            elseif self.flow == docker_area_flow[ 'horizontal' ] and not self.inverted then
                text_pos = text_start - vector( 0, text_sz.y )
            end

            local text_props = {
                pos = text_pos,
                width = self.size.x,
                area = self,
                text_size = text_sz
            }

            text:handle_area_drag( text_props )

            if text.parent.id == self.id then -- 3 hours of debugging just to write this if statement, CHIPI CHIPI CHAPA CHAPA LUDI LUDI LABA LABA MAGICO MI LUBI LUBI BOOM BOOM BOOM BOOM
                text:render( text_props )
            end

            if text.options_menu then
                text_props.text_sz = text_sz
                text:handle_options_menu( text_props )

                if text.options_menu.open and open_menu == nil then -- no menu open and our menu open
                    open_menu = text.options_menu -- set menu and pos
                    open_menu_pos = text_props.pos + vector( option_pad + text_sz.x, 0 )
                end

                -- open menu and matcehs ours
                if open_menu and open_menu.id == text.options_menu.id then
                    open_menu_pos = text_props.pos + vector( option_pad + text_sz.x, 0 ) -- update pos

                    if not text.options_menu.open or dragging_id == text.id then -- if the menu is closed, set new open menu as nil, OR if were dragging the element
                        open_menu = nil
                        open_menu_pos = nil
                    end
                end
            end

            if self.flow == docker_area_flow[ 'vertical' ] then
                text_start.y = text_start.y + text_sz.y
            elseif self.flow == docker_area_flow[ 'horizontal' ] then
                text_start.x = self.pos.x

                if self.inverted then
                    text_start.y = text_start.y + text_sz.y
                else
                    text_start.y = text_start.y - text_sz.y
                end
            end

            ::continue::
        end
    end

    table.insert( docker_areas, docker_area_obj )
    return docker_area_obj
end

local new_top_area = docker_area.new(
    base_pos + vector( 150, 80 ),
    vector( 50, 70 ),
    false,
    docker_area_flow[ 'horizontal' ]
)

local new_left_area = docker_area.new(
    base_pos + vector( 110, 150 ),
    vector( 40, 100 ),
    false
)

local new_bottom_area = docker_area.new(
    base_pos + vector( 150, 250 ),
    vector( 50, 70 ),
    true,
    docker_area_flow[ 'horizontal' ]
)

local new_right_area = docker_area.new(
    base_pos + vector( 200, 150 ),
    vector( 40, 100 ),
    true
)

local custom_mats = { }

local function create_custom_mat( name, kv )
    custom_mats[ name ] = materials.Create( name, kv )
end

create_custom_mat( 'metallic', [[
"VertexLitGeneric"
{
    "$additive"                 "0"
    "$ignorez"					"0"
    "$envmap"					"env_cubemap"
    "$envmaptint"				"[1 0 0]"
    "$envmapfresnel"			"1"
    "$envmapfresnelminmaxexp"	"[0 1 2]"
}
]] )

create_custom_mat( 'glow', [[
"VertexLitGeneric"
{
    "$basetexture"  "vgui/white_additive"
    "$additive"                 "1"
    "$ignorez"					"0"
    "$envmap"					"env_cubemap"
    "$envmaptint"				"[0 0 0]"
    "$envmapfresnel"			"1"
    "$envmapfresnelminmaxexp"	"[0 1 2]"
}]] )

create_custom_mat( 'flat', [[
"UnlitGeneric" {
    "$basetexture"  "vgui/white_additive"
    "$ignorez"      "0"
    "$model"		"1"
    "$flat"			"1"
    "$nocull"		"1"
    "$selfillum"	"1"
    "$halflambert"	"1"
    "$wireframe"	"0"
}
]] )

local materials_key_to_mat = { }

for k, v in pairs( custom_mats ) do
    materials_key_to_mat[ k ] = v
end

local materials_list = { }
for k, _ in pairs( materials_key_to_mat ) do
    table.insert( materials_list, k )
end

local selected_mat_data = {
    material = nil,
    color_override = color( 255 ),
    backtrack_mod = false,
    backtrack_start = nil,
    backtrack_end = nil
}

local cached_model = nil

local model_options_menu = options_menu.new({ 
    options.new_combo( 'preview model', 'scout', 'soldier', 'pyro', 'demoman', 'heavy', 'engineer', 'medic', 'sniper', 'spy' ),
    options.new_combo( 'box style', 'none', 'rectangle', 'outline', 'corners' ),
    options.new_checkbox( 'override material', false ),
    options.new_checkbox( 'wireframe', false ),
    options.new_combo( 'chams', table.unpack( materials_list ) ),
    options.new_colorpicker( 'chams color', color( '00436e' ) ),
    options.new_checkbox( 'backtrack modulation', false ),
    options.new_colorpicker( 'backtrack start', color( '00436e' ) ),
    options.new_colorpicker( 'backtrack end', color( '6d1537' ) ),
})

local model_opt_name_to_modelname = { -- i could do 'models/player/%s.mdl':format aswell but demoman is very important in the model options
    [ 'scout' ] = 'models/player/scout.mdl',
    [ 'soldier' ] = 'models/player/soldier.mdl',
    [ 'pyro' ] = 'models/player/pyro.mdl',
    [ 'demoman' ] = 'models/player/demo.mdl',
    [ 'heavy' ] = 'models/player/heavy.mdl',
    [ 'engineer' ] = 'models/player/engineer.mdl',
    [ 'medic' ] = 'models/player/medic.mdl',
    [ 'sniper' ] = 'models/player/sniper.mdl',
    [ 'spy' ] = 'models/player/spy.mdl'
}

local function model_options_callback( )
    local self = model_options_menu

    local model_opt = self:get_option( 'preview model' )

    local _, model_name = model_opt:get( )
    if myEnt then
        local mdl_name = model_opt_name_to_modelname[ model_name ]

        if mdl_name ~= cached_model then
            myEnt:SetModel( mdl_name )
            cached_model = mdl_name

            if mdl_name == 'spy' then
                model_sequence = 12
            else
                model_sequence = 3
            end
        end
    end

    local box_style_opt = self:get_option( 'box style' )

    local override_mat_opt = self:get_option( 'override material' )

    local wireframe_opt = self:get_option( 'wireframe' )
    local material_opt = self:get_option( 'chams' )
    local chams_color_opt = self:get_option( 'chams color' )
    
    local backtrack_mod_opt = self:get_option( 'backtrack modulation' )
    local backtrack_start_opt = self:get_option( 'backtrack start' )
    local backtrack_end_opt = self:get_option( 'backtrack end' )

    local should_override_mat = override_mat_opt:get( )
    local override_backtrack = backtrack_mod_opt:get( )

    wireframe_opt:set_visible( should_override_mat )
    material_opt:set_visible( should_override_mat )
    chams_color_opt:set_visible( should_override_mat )
    backtrack_mod_opt:set_visible( should_override_mat )

    backtrack_start_opt:set_visible( should_override_mat and override_backtrack )
    backtrack_end_opt:set_visible( should_override_mat and override_backtrack )

    local _, box_style = box_style_opt:get( )
    esp.box = box_style

    if should_override_mat then
        local _, name = material_opt:get( )
        selected_mat_data.material = name
        selected_mat_data.color_override = chams_color_opt:get( )
        selected_mat_data.wireframe = wireframe_opt:get( )

        if override_backtrack then
            selected_mat_data.backtrack_mod = true
            selected_mat_data.backtrack_start = backtrack_start_opt:get( )
            selected_mat_data.backtrack_end = backtrack_end_opt:get( )
        end
    else
        selected_mat_data.material = nil
    end

    if not override_backtrack then
        selected_mat_data.backtrack_mod = false
    end
end

local function handle_model_menu( )
    local start_pos = new_top_area.pos + vector( option_pad, option_pad + new_top_area.size.y )
    local size = vector( new_top_area.size.x, new_left_area.size.y ) - vector( option_pad ) * 2

    local in_bounds = is_in_bounds( start_pos, size )
    local is_m2_pressed = input.is_button_pressed( MOUSE_RIGHT )

    local mouse = input.get_mouse_pos( )
    local x, y = table.unpack( mouse )
    local mouse_pos = vector( x, y )

    if in_bounds and not dragging_id and not is_changing_view and not model_options_menu.open and not open_menu then
        renderer.rect_filled(
            start_pos,
            size,
            color( 100, 100, 100, 10 )
        )
    end

    if in_bounds and is_m2_pressed then
        model_options_menu:toggle_visibility( )

        if model_options_menu.open then
            open_menu = model_options_menu
            open_menu_pos = mouse_pos + vector( math.floor( -model_options_menu.size.x / 2 ), option_pad )
        else
            open_menu = nil
            open_menu_pos = nil
        end
    end

    if model_options_menu.open then
        local in_menu_bounds = is_in_bounds( open_menu_pos, model_options_menu.size )
        local is_m1_pressed = input.is_button_pressed( MOUSE_LEFT )

        local is_preventing_close = model_options_menu:is_something_preventing_closing( )

        if is_m1_pressed and not in_menu_bounds and not is_preventing_close then
            model_options_menu:toggle_visibility( false )
            open_menu = nil
            open_menu_pos = nil
        end
    end

    model_options_callback( )
end

docker.slider( 'health', { options.new_colorpicker( 'bar color', color( 0, 255, 0 ) ) }, function( self, ent, is_preview )
    local health_opt = self:get_option( 'bar color' )

    self.color = health_opt:get( )
    
    if is_preview then
        return 1
    end
    
    local health_pc = ent:GetHealth( ) / ent:GetMaxHealth( )

    health_pc = clamp( health_pc, 0, 1 )

    return health_pc
end )

docker.text( 'name', { options.new_checkbox( 'include entity index', false ), options.new_combo( 'select font', 'pixel', 'arial', 'verdana' ), options.new_colorpicker( 'text color', color( 200, 200, 200 ) ) }, function( self, ent, is_preview )
    local entidx_opt = self:get_option( 'include entity index' )
    local font_opt = self:get_option( 'select font' )
    local color_opt = self:get_option( 'text color' )

    local should_include_entindex = entidx_opt:get( )
    local font_idx, font_name = font_opt:get( )

    if font_idx == 2 then
        esp.set_font( arial )
    elseif font_idx == 3 then
        esp.set_font( verdana )
    end

    self:set_color( color_opt:get( ) )
    

    if is_preview then
        local name = 'lmaobox.net'

        if should_include_entindex then
            name = name .. ' (12)'
        end

        return name
    end

    local ent_name = ent:GetName( )

    if should_include_entindex then
        ent_name = ( '%s (%i)' ):format( ent_name, ent:GetIndex( ) )
    end

    return ent_name, 'you can also return here but youd have to remove the "is_preview" case 4 lines above'
end )

docker.text(
    'health',
    {
        options.new_combo( 'select font', 'pixel', 'arial', 'verdana' ),
        options.new_colorpicker( 'text color', color( 100, 255, 100 ) ),
        options.new_checkbox( 'hide on full', true ) },
        
        function( self, ent, is_preview )
    local font_opt = self:get_option( 'select font' )
    local color_opt = self:get_option( 'text color' )
    local hide_on_full_opt = self:get_option( 'hide on full' )

    local font_idx, font_name = font_opt:get( )
    local text_color = color_opt:get( )
    local should_hide_hp = hide_on_full_opt:get( )

    if font_idx == 2 then
        esp.set_font( arial )
    elseif font_idx == 3 then
        esp.set_font( verdana )
    end

    self:set_color( text_color )

    if is_preview then
        return '175hp'
    end

    local ent_hp = ent:GetHealth( )

    if ent_hp == ent:GetMaxHealth( ) and should_hide_hp then
        return nil
    end

    return ent:IsAlive( ) and tostring( ent_hp ) .. 'hp' or nil
end )

docker.text( 'overheal', { options.new_combo( 'select font', 'pixel', 'arial', 'verdana' ), options.new_colorpicker( 'text color', color( 237, 233, 157 ) ) }, function( self, ent, is_preview )
    if is_preview then
        return 'OH'
    end
    
    local overhealed = ent:GetHealth( ) > ent:GetMaxHealth( )

    local font_opt = self:get_option( 'select font' )
    local color_opt = self:get_option( 'text color' )

    local font_idx, font_name = font_opt:get( )
    self:set_color( color_opt:get( ) )

    if font_idx == 2 then
        esp.set_font( arial )
    elseif font_idx == 3 then
        esp.set_font( verdana )
    end

    return overhealed and 'OH' or nil
end )

docker.text( 'scoped', { options.new_combo( 'select font', 'pixel', 'arial', 'verdana'  ), options.new_colorpicker( 'text color', color( 50, 200, 152 ) ) }, function( self, ent, is_preview )
    local font_opt = self:get_option( 'select font' )
    local color_opt = self:get_option( 'text color' )

    local font_idx, font_name = font_opt:get( )
    self:set_color( color_opt:get( ) )

    if font_idx == 2 then
        esp.set_font( arial )
    elseif font_idx == 3 then
        esp.set_font( verdana )
    end

    if is_preview then
        return 'scope'
    end


    if ent:InCond( TFCond_Zoomed ) then
        return 'scope'
    end

    return nil
end )

docker.text( 'ubercharged', { options.new_combo( 'select font', 'pixel', 'arial', 'verdana'  ), options.new_colorpicker( 'text color', color( 255, 100, 100 ) ) }, function( self, ent, is_preview )
    local font_opt = self:get_option( 'select font' )
    local color_opt = self:get_option( 'text color' )

    local font_idx, font_name = font_opt:get( )
    self:set_color( color_opt:get( ) )

    if font_idx == 2 then
        esp.set_font( arial )
    elseif font_idx == 3 then
        esp.set_font( verdana )
    end

    if is_preview then
        local texts = { 'ubercharged', 'kritz', 'uber & kritz' }
        
        local remainder = globals.CurTime( ) % #texts

        local idx = remainder // 1 + 1

        return texts[ idx ]
    end

    local is_uber = ent:InCond( TFCond_Ubercharged )
    local is_kritz = ent:InCond( TFCond_Kritzkrieged )

    if is_uber and is_kritz then
        return 'uber & kritz'
    elseif is_uber then
        return 'ubercharged'
    elseif is_kritz then
        return 'kritz'
    end

    return nil
end )

docker.text( 'cloaked', { options.new_combo( 'select font', 'pixel', 'arial', 'verdana'  ), options.new_colorpicker( 'text color', color( 150, 100, 255 ) ) }, function( self, ent, is_preview )
    local font_opt = self:get_option( 'select font' )
    local color_opt = self:get_option( 'text color' )

    local font_idx, font_name = font_opt:get( )
    self:set_color( color_opt:get( ) )

    if font_idx == 2 then
        esp.set_font( arial )
    elseif font_idx == 3 then
        esp.set_font( verdana )
    end

    if is_preview then
        return 'cloaked'
    end


    if ent:InCond( TFCond_Cloaked ) then
        return 'cloaked'
    end

    return nil
end )

docker.text( 'bonk', { options.new_combo( 'select font', 'pixel', 'arial', 'verdana'  ), options.new_colorpicker( 'text color', color( 255, 255, 0 ) ) }, function( self, ent, is_preview )
    local font_opt = self:get_option( 'select font' )
    local color_opt = self:get_option( 'text color' )

    local font_idx, font_name = font_opt:get( )
    self:set_color( color_opt:get( ) )

    if font_idx == 2 then
        esp.set_font( arial )
    elseif font_idx == 3 then
        esp.set_font( verdana )
    end

    if is_preview then
        return 'bonk!!!'
    end


    if ent:InCond( TFCond_Bonked ) then
        return 'bonk!!!'
    end

    return nil
end )

local one_hammer_unit_in_cm = 1.904
local one_meter_to_foot = 3.28084

docker.text( 'distance', { options.new_combo( 'select font', 'pixel', 'arial', 'verdana'  ), options.new_colorpicker( 'text color', color( 255, 0, 0 ) ) }, function( self, ent, is_preview )
    local font_opt = self:get_option( 'select font' )
    local color_opt = self:get_option( 'text color' )

    local font_idx, font_name = font_opt:get( )
    self:set_color( color_opt:get( ) )

    if font_idx == 2 then
        esp.set_font( arial )
    elseif font_idx == 3 then
        esp.set_font( verdana )
    end
    
    if is_preview then
        return '64ft'
    end
    
    local lp = entities.GetLocalPlayer( )

    if not lp then return end

    local lp_pos = lp:GetAbsOrigin( )
    local ent_pos = ent:GetAbsOrigin( )

    local distance_hu = ( ent_pos - lp_pos ):Length( )

    local dist_in_cm = distance_hu * one_hammer_unit_in_cm
    local dist_in_m = dist_in_cm / 100
    local dist_in_ft = dist_in_m * one_meter_to_foot

    return tostring( math.floor( dist_in_ft + 0.5 ) ) .. 'ft'
end )

docker.text( 'charging', { options.new_combo( 'select font', 'pixel', 'arial', 'verdana'  ), options.new_colorpicker( 'text color', color( 255, 0, 0 ) ) }, function( self, ent, is_preview )
    local font_opt = self:get_option( 'select font' )
    local color_opt = self:get_option( 'text color' )

    local font_idx, font_name = font_opt:get( )
    self:set_color( color_opt:get( ) )

    if font_idx == 2 then
        esp.set_font( arial )
    elseif font_idx == 3 then
        esp.set_font( verdana )
    end

    if is_preview then
        return 'charging'
    end


    if ent:InCond( TFCond_Charging ) then
        return 'charging'
    end

    return nil
end )

docker.text( 'covered', { options.new_combo( 'select font', 'pixel', 'arial', 'verdana'  ), options.new_colorpicker( 'jarate', color( 255, 215, 0 ) ), options.new_colorpicker( 'milk', color( 255 ) ), options.new_colorpicker( 'both', color( 230, 80, 140 ) ) }, function( self, ent, is_preview )
    local font_opt = self:get_option( 'select font' )
    local jarate_color_opt = self:get_option( 'jarate' )
    local milk_color_opt = self:get_option( 'milk' )
    local both_color_opt = self:get_option( 'both' )

    local font_idx, font_name = font_opt:get( )

    if font_idx == 2 then
        esp.set_font( arial )
    elseif font_idx == 3 then
        esp.set_font( verdana )
    end

    if is_preview then
        local texts = { 'jarate', 'milk', 'jarate & milk' }
               
        local remainder = globals.CurTime( ) % #texts

        local idx = remainder // 1 + 1

        local text_color = idx == 1 and jarate_color_opt:get( ) or
                      idx == 2 and milk_color_opt:get( ) or
                      idx == 3 and both_color_opt:get( )

        self:set_color( text_color )
        
        return texts[ idx ]
    end

    local is_jarate = ent:InCond( TFCond_Jarated )
    local is_milk = ent:InCond( TFCond_Milked )

    if is_jarate and is_milk then
        self:set_color( both_color_opt:get( ) )
        return 'jarate & milk'
    elseif is_jarate then
        self:set_color( jarate_color_opt:get( ) )
        return 'jarate'
    elseif is_milk then
        self:set_color( milk_color_opt:get( ) )
        return 'milk'
    end

    return nil
end )

local dormant_esp = {
    stay = 4,
    fade = 1,
    opacity = 0.5
}
local function render_enemy_esp( )
    local lp = entities.GetLocalPlayer( )

    if not lp then
        return
    end

    local our_origin = lp:GetAbsOrigin( )
    local players = entities.FindByClass( 'CTFPlayer' )

    local enemies = { }

    for _, ent in ipairs( players ) do

        get_2d_box_bounds( ent )

        if ent:IsAlive( ) and ent:GetTeamNumber( ) ~= lp:GetTeamNumber( ) then
            table.insert( enemies, ent )
        end
    end

    if #enemies == 0 then return end

    local current_time = globals.CurTime( )

    -- sort enemies by dist
    table.sort( enemies, function( ent1, ent2 )
        local ent1_dist_from_us = ( ent1:GetAbsOrigin( ) - our_origin ):Length( )
        local ent2_dist_from_us = ( ent2:GetAbsOrigin( ) - our_origin ):Length( )

        return ent1_dist_from_us > ent2_dist_from_us
    end )

    for enm_idx = 1, #enemies do
        local ent = enemies[ enm_idx ]

        local should_render = true

        esp.set_alpha_modifier( 1 )

        if ent:IsDormant( ) then
            local sim_time_diff = current_time - ent:GetPropFloat( 'm_flSimulationTime' )

            local alpha_modulation = dormant_esp.opacity

            if sim_time_diff < dormant_esp.fade then
                local fade_pc = sim_time_diff / dormant_esp.fade

                local subtract_alpha = fade_pc * dormant_esp.opacity

                alpha_modulation = 1 - subtract_alpha
            elseif sim_time_diff > dormant_esp.stay - dormant_esp.fade then
                if sim_time_diff > dormant_esp.stay then
                    should_render = false
                else
                    local fade_pc = ( sim_time_diff - ( dormant_esp.stay - dormant_esp.fade ) ) / dormant_esp.fade

                    local subtract_alpha = fade_pc * dormant_esp.opacity

                    alpha_modulation = dormant_esp.opacity - subtract_alpha
                end
            end

            esp.set_alpha_modifier( alpha_modulation )
        end

        if not should_render then goto next_ent end

        local alpha_default = esp.alpha_mod * 255

        local box_start, box_size = get_2d_box_bounds( ent )

        local offsets = { 
            [ new_top_area.id ] = vector( ),
            [ new_left_area.id ] = vector( ),
            [ new_bottom_area.id ] = vector( ),
            [ new_right_area.id ] = vector( )
        }

        if not box_start or not box_size then goto next_ent end

        if esp.box == 'rectangle' then
            renderer.rect(
                box_start + vector( 1, 1 ),
                box_size - vector( 2, 2 ),
                color( alpha_default )
            )
        elseif esp.box == 'outline' then
            renderer.rect(
                box_start + vector( 1, 0 ),
                box_size - vector( 2, 0 ),
                color( 0, alpha_default )
            )

            renderer.rect(
                box_start + vector( 2, 1 ),
                box_size - vector( 4, 2 ),
                color( 255, alpha_default )
            )

            renderer.rect(
                box_start + vector( 3, 2 ),
                box_size - vector( 6, 4 ),
                color( 0, alpha_default )
            )
        elseif esp.box == 'corners' then
            local width = math.floor( box_size.x * 0.3 )
            local height = width

            -- ! please someone refactor this this looks horrible oh my god

            -- top left
            renderer.rect(
                box_start + vector( 1, 0 ),
                vector( 3, height ),
                color( 0, alpha_default )
            )

            renderer.rect(
                box_start + vector( 1, 0 ),
                vector( width, 3 ),
                color( 0, alpha_default )
            )

            renderer.line(
                box_start + vector( 2, 1 ),
                box_start + vector( width, 1 ),
                color( 255, alpha_default )
            )

            renderer.line(
                box_start + vector( 2, 2 ),
                box_start + vector( 2, height - 1 ),
                color( 255, alpha_default )
            )

            -- lower right
            renderer.rect(
                box_start + box_size - vector( width, 3 ),
                vector( width, 3 ),
                color( 0, alpha_default )
            )

            renderer.rect(
                box_start + box_size - vector( 3, height ),
                vector( 3, height ),
                color( 0, alpha_default )
            )

            renderer.line(
                box_start + box_size - vector( width - 1, 2 ),
                box_start + box_size - vector( 1, 2 ),
                color( 255, alpha_default )
            )

            renderer.line(
                box_start + box_size - vector( 2, height - 1 ),
                box_start + box_size - vector( 2, 1 ),
                color( 255, alpha_default )
            )

            -- top right
            renderer.rect(
                box_start + vector( box_size.x - width, 0 ),
                vector( width, 3 ),
                color( 0, alpha_default )
            )

            renderer.rect(
                box_start + vector( box_size.x - 3, 0 ),
                vector( 3, height ),
                color( 0, alpha_default )
            )

            renderer.line(
                box_start + vector( box_size.x - width + 1, 1 ),
                box_start + vector( box_size.x - 1, 1 ),
                color( 255, alpha_default )
            )

            renderer.line(
                box_start + vector( box_size.x - 2, 2 ),
                box_start + vector( box_size.x - 2, height - 1 ),
                color( 255, alpha_default )
            )

            -- bottom left
            renderer.rect(
                box_start + vector( 1, box_size.y - height ),
                vector( 3, height ),
                color( 0, alpha_default )
            )

            renderer.rect(
                box_start + vector( 1, box_size.y - 3 ),
                vector( width, 3 ),
                color( 0, alpha_default )
            )

            renderer.line(
                box_start + vector( 2, box_size.y - height + 1 ),
                box_start + vector( 2, box_size.y - 1 ),
                color( 255, alpha_default )
            )

            renderer.line(
                box_start + vector( 2, box_size.y - 2 ),
                box_start + vector( width, box_size.y - 2 ),
                color( 255, alpha_default )
            )
        end

        local idx_to_startpos = {
            [ new_top_area.id ] = box_start,
            [ new_left_area.id ] = box_start,
            [ new_bottom_area.id ] = box_start + vector( 0, box_size.y ),
            [ new_right_area.id ] = box_start + vector( box_size.x, 0 )
        }

        local given = box_size

        local function get_box_size( area_id )
            if area_id == new_left_area.id or area_id == new_right_area.id then
                local given_height = given.y
                
                return vector( math.floor( new_left_area.size.x / new_left_area.size.y * given_height ), given_height )
            else
                return vector( given.x, math.floor( new_left_area.size.y / new_left_area.size.x * given.x ) )
            end
        end

        local areas = {
            new_bottom_area,
            new_top_area,
            new_left_area,
            new_right_area
        }

        for area_idx = 1, #areas do
            local area = areas[ area_idx ]

            for slider_idx = 1, #area.slider_keys do
                local slider = area.sliders[ area.slider_keys[ slider_idx ] ]

                if not slider.parent then goto next_object end

                local start_pos = idx_to_startpos[ area.id ]
                local return_value = slider:callback( ent )

                if return_value ~= nil then
                    local esp_area_box_size = get_box_size( area.id )

                    local offset = vector( )

                    if area.flow == docker_area_flow[ 'vertical' ] then
                        offset.x = offsets[ area.id ].x

                        if not area.inverted then
                            offset.x = ( offset.x + slider.thickness ) * -1
                        end
                    else
                        offset.y = offsets[ area.id ].y

                        if not area.inverted then
                            offset.y = offsets[ area.id ].y * -1 - slider.thickness
                        end
                    end

                    slider:render_esp( return_value, offset, start_pos, esp_area_box_size )

                    if area.flow == docker_area_flow[ 'vertical' ] then
                        offsets[ area.id ].x = offsets[ area.id ].x + slider.thickness + area.slider_pad
                    else
                        offsets[ area.id ].y = offsets[ area.id ].y + slider.thickness + area.slider_pad
                    end
                end

                ::next_object::
            end

            for text_idx = 1, #area.text_keys do
                local text = area.texts[ area.text_keys[ text_idx ] ]

                if not text.parent then goto next_object end

                local start_pos = idx_to_startpos[ area.id ]

                -- callback can change font context, we want to change the context for this one cycle only
                esp.set_font( preview_text_font )

                local return_value = text:callback( ent )

                renderer.use_font( esp.font )

                if return_value ~= nil then
                    return_value = tostring( return_value ) -- just to be sure

                    local esp_area_box_size = get_box_size( area.id )
                    
                    local text_sz = renderer.measure_text( return_value )
                    local offset = vector( offsets[ area.id ].x, offsets[ area.id ].y )

                    if area.flow == docker_area_flow[ 'vertical' ] then
                        if not area.inverted then
                            offset.x = ( offset.x + text_sz.x ) * -1
                        end
                    else
                        offset.y = offsets[ area.id ].y

                        offset.x = esp_area_box_size.x / 2 - text_sz.x / 2

                        if not area.inverted then
                            offset.y = ( offsets[ area.id ].y + text_sz.y - 5 ) * -1 
                        end
                    end

                    offset.x = math.floor( offset.x )
                    offset.y = math.floor( offset.y )

                    text:render_esp( return_value, offset, start_pos, esp_area_box_size )

                    offsets[ area.id ].y = offsets[ area.id ].y + text_sz.y - 3
                end

                ::next_object::
            end
        end

        ::next_ent::
    end
end

local function draw_preview_esp( ent )
    local box_start, box_size = vector( camStartX + 41, camStartY + 44 ), vector( 120, 240 )

    if ent and ent:GetModel( ) then
        local mins, maxs = models.GetModelBounds( ent:GetModel( ) )
        local got_box_start, got_box_size = get_2d_box_pos_size( ent, mins, maxs )

        if got_box_start ~= nil and got_box_size ~= nil then
            box_start, box_size = got_box_start, got_box_size
        end
    end

    render_2d_box( box_start, box_size )

    new_top_area.pos = box_start - vector( 0, 70 )
    new_top_area.size = vector( box_size.x, 70 )

    new_left_area.pos = box_start - vector( 70, 0 )
    new_left_area.size = vector( 70, box_size.y )

    new_bottom_area.pos = box_start + vector( 0, box_size.y )
    new_bottom_area.size = vector( box_size.x, 70 )

    new_right_area.pos = box_start + vector(  box_size.x, 0 )
    new_right_area.size = vector( 70, box_size.y )
end

-- try chams
local drawn_entities = { }

local function dist_to_color( dist, color_1, color_2 )
    local max_dist = 6

    local diff = color( color_2.r - color_1.r, color_2.g - color_1.g, color_2.b - color_1.b )

    local pc = dist / max_dist

    pc = 1 - clamp( pc, 0, 1 )

    return color(
        color_1.r + math.floor( diff.r * pc ),
        color_1.g + math.floor( diff.g * pc ),
        color_1.b + math.floor( diff.b * pc )
    )
end

local function onDrawModel( drawModelContext )
    local lp = entities.GetLocalPlayer( )
    local mat = selected_mat_data.material

    if not myEnt or not mat then return end

    local ctx_ent = drawModelContext:GetEntity( )

    local overriden_color = nil
    if ctx_ent and lp then
        -- were doing actual players
        local is_player = ctx_ent:IsPlayer( )

        if not is_player then return end

        if ctx_ent:GetTeamNumber( ) == lp:GetTeamNumber( ) then return end

        local index = tostring( ctx_ent:GetIndex( ) )

        if selected_mat_data.backtrack_mod then
            if not drawn_entities[ index ] then
                drawn_entities[ index ] = 1
            else
                drawn_entities[ index ] = drawn_entities[ index ] + 1
            end

            if drawn_entities[ index ] > 1 then
                overriden_color = dist_to_color( drawn_entities[ index ], selected_mat_data.backtrack_start, selected_mat_data.backtrack_end )
            end
        end
    else
        if drawModelContext:GetModelName( ) ~= cached_model then return end
    end

    local r, g, b, a = selected_mat_data.color_override:unpack( )


    if overriden_color then
        r, g, b, a = overriden_color:unpack( )
    end

    local material = materials_key_to_mat[ mat ]

    if mat == 'flat' or mat == 'glow' then
        material:SetShaderParam( '$color', Vector3( r / 255, g / 255, b / 255 ) )
        material:SetShaderParam( '$color2', Vector3( r / 255, g / 255, b / 255 ) )
    else
        material:SetShaderParam( '$envmaptint', Vector3( r / 255, g / 255, b / 255 ) )
    end

    material:SetMaterialVarFlag( 268435456, selected_mat_data.wireframe )

    drawModelContext:ForcedMaterialOverride( material )

    if selected_mat_data.accurate_color then
        drawModelContext:SuppressEngineLighting( )
    end
end

callbacks.Unregister( 'DrawModel', 'hook123' )
callbacks.Register("DrawModel", "hook123", onDrawModel)

local camera_drag_difference = vector( )
local function draw_background( )
    local left_overfill = 40
    local right_overfill = 40
    local top_overfill = 40

    local height = camH + item_bank_bars.size.y + item_bank_bars.size.y + top_overfill
    local padding = 5

    local start_pos = vector( camStartX - left_overfill - padding, camStartY - top_overfill - padding )
    local size = vector( camW + left_overfill + right_overfill + padding * 2, height + padding * 2 )

    local add_y = ( start_pos.y + size.y ) - ( item_bank_text.pos.y + item_bank_text.size.y )

    if add_y > 0 then
        size.y = size.y + add_y
    end

    renderer.rect_filled(
        start_pos,
        size,
        color( 0 )
    )

    -- render top bar to drag from
    local top_bar_start = start_pos
    local top_bar_size = vector( size.x, 20 )

    local in_bounds = is_in_bounds( top_bar_start, top_bar_size )
    local is_mouse1_down = input.is_key_down( MOUSE_LEFT )

    local mouse = input.get_mouse_pos( )
    local x, y = table.unpack( mouse )
    local mouse_pos = vector( x, y )

    if ( in_bounds and is_mouse1_down ) and not dragging_camera and not dragging_id and not is_changing_view then
        dragging_camera = true
        camera_drag_difference = vector( camStartX, camStartY ) - mouse_pos
    end

    if dragging_camera then
        camStartX = mouse_pos.x + camera_drag_difference.x

        camStartY = mouse_pos.y + camera_drag_difference.y
    end

    if not is_mouse1_down then
        dragging_camera = false
    end

    local bar_color = ( in_bounds or dragging_camera ) and color( 40 ) or color( 30 )

    renderer.rect_filled(
        top_bar_start,
        top_bar_size,
        bar_color
    )
end

callbacks.Register("Draw", function( )
    drawn_entities= { }

    -- not connected
    if myEnt and engine.GetMapName( ) == '' then
        print( 'deleted' )
        myEnt:Release( )
        myEnt = nil
    end

    -- local lp = entities.GetLocalPlayer( )
    -- if lp then
    --     local tbl = lp:EntitySpaceHitboxSurroundingBox( )

    --     local mins, maxs = tbl[ 1 ], tbl[ 2 ]

    --     mins = lp:GetAbsOrigin( ) + mins

    --     local all_corners = {
    --         mins,
    --         mins + Vector3( maxs.x, 0, 0 ),
    --         mins + Vector3( maxs.x, maxs.y, 0 ),
    --         mins + Vector3( 0, maxs.y, 0 ),
    --         mins + Vector3( 0, maxs.y, maxs.z ),
    --         mins + maxs,
    --         mins + Vector3( maxs.x, 0, maxs.z ),
    --         mins + Vector3( 0, 0, maxs.z ),
    --     }

    --     for i = 1, #all_corners do
    --         for j = i + 1, #all_corners do
    --             renderer.line3d( all_corners[ i ], all_corners[ j ], color( 255 ) )
    --         end
    --     end
    -- end

    local scr_w, scr_h = draw.GetScreenSize( )
    camW = math.floor( camH / scr_w * scr_h )

    item_bank_bars.pos = vector( camStartX, camStartY + camH )
    item_bank_bars.size = vector( camW, item_bank_bars.size.y )

    item_bank_text.pos = item_bank_bars.pos + vector( 0, item_bank_bars.size.y )
    item_bank_text.size = item_bank_bars.size

    input.update_keys( )

    if input.is_button_pressed( KEY_INSERT ) then
        menu_opened = not menu_opened

        if not menu_opened and myEnt and open_menu then
            open_menu.open = false
            open_menu = nil     
        end
    end

    if menu_opened then
        draw_background( )

        if myEnt ~= nil then
            render.DrawScreenSpaceRectangle( cameraMaterial, camStartX, camStartY, camW, camH, 0, 0, camW, camH, camW, camH )
        end

        draw_preview_esp( myEnt )

        renderer.use_font( default_font )
        item_bank_text:draw( )
        item_bank_bars:draw( )

        new_top_area:on_draw( )
        new_left_area:on_draw( )
        new_bottom_area:on_draw( )
        new_right_area:on_draw( )

        handle_model_menu( )
    end

    render_enemy_esp( )

    -- handle open menu
    if open_menu and open_menu_pos then
        open_menu:render( open_menu_pos )
    end

    if not myEnt or not our_view or not menu_opened then return end

    if dragging_id == nil and open_menu == nil and not dragging_camera then
        handle_model_spin( )
    end

    -- local cam_pos = client.WorldToScreen( customView.origin )

    -- if cam_pos and cam_pos[ 1 ] and cam_pos[ 2 ] then
    --     renderer.circle_filled(
    --         vector( cam_pos[ 1 ], cam_pos[ 2 ] ),
    --         4,
    --         color( 255, 0, 0 )
    --     )
    -- end
end)

local function load_config( )
    if config_table == nil then return end

    for obj_idx = 1, #docker_texts do
        local text_obj = docker_texts[ obj_idx ]

        if config_table[ text_obj.text ] then
            local text_config_data = config_table[ text_obj.text ]

            text_obj:set_config( text_config_data )

            if text_config_data[ 'area_id' ] ~= 'nil' then
                item_bank_text:remove( text_obj )
            end
        end
    end

    for obj_idx = 1, #docker_sliders do
        local slider_obj = docker_sliders[ obj_idx ]

        if config_table[ slider_obj.text ] then
            local slider_config_data = config_table[ slider_obj.text ]

            slider_obj:set_config( slider_config_data )

            if slider_config_data[ 'area_id' ] ~= 'nil' then
                item_bank_bars:remove( slider_obj )
            end
        end
    end

    if config_table[ 'model_options_menu' ] then
        local data = config_table[ 'model_options_menu' ]

        model_options_menu:set_config( data )
    end
end

load_config( )

local function save_config( )
    local configs_texts = { }
    for i = 1, #docker_texts do
        table.insert( configs_texts, docker_texts[ i ]:get_config( ) )
    end

    local configs_sliders = { }
    for i = 1, #docker_sliders do
        table.insert( configs_sliders, docker_sliders[ i ]:get_config( ) )
    end

    local slider_configs = table.concat( configs_sliders, ', ' )

    local model_setts_tbl = model_options_menu:get_config( )
    local model_setts = ( '[ \'model_options_menu\' ] = { %s }' ):format( table.concat( model_setts_tbl, ', ' ) )

    table.insert( configs_texts, model_setts )
    table.insert( configs_texts, slider_configs )

    local config = table.concat( configs_texts, ', ' )

    local minus_line = string.rep( '-', 25 )

    print(
        ( 'Please put the following text as the first line of the script to save your config.\n%s\n\nlocal config_table = { %s }\n\n%s' ):format( minus_line, config, minus_line )
    )
end

callbacks.Register( 'Unload', function( )
    save_config( )

    if myEnt then
        myEnt:Release( )
        myEnt = nil
    end
end )
