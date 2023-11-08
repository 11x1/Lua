--[[
  peek assistant, hold autopeek key (idfk what its called in neverlose, the auto retreat thing with no "on key release" option)
  
  » Support for backtrack, ghetto multipoint and defensive baiting
  » Custom peek points start offset, points span and amount
  » Different modes for various performance options (no multipoints, multipoints, single/multiple target(s), limbs selection)
  » Only works for SCOUT
  
  [ Q&A ]
  » Q: Waaaaaaaah it doesn't peek😭😭😭😢😢😿😿
  » A: Only works on Scout, lower your mindmg if it doesn peek
  
  » Q: Waaaaaaaah, it is broken peeking ((((((
  » A: Disable On Key Release on autp peek settings in RAGEBOT tab
]]

local vector = vector

local autopeek = ui.find("Aimbot", "Ragebot", "Main", "Peek Assist")
local mindmg = ui.find("Aimbot", "Ragebot", "Selection", "SSG-08", "Min. Damage")
local dt = ui.find("Aimbot", "Ragebot", "Main", "Double Tap")

function table.includes( table, ... )
    local vals = { ... }
    for i = 1, #table do
        for j = 1, #vals do
            if table[ i ] == vals[ j ] then
                return true
            end
        end
    end

    return false
end

local function rgba_to_hex( r, g, b, a )
    return string.format( '\a%02X%02X%02X%02X', r, g, b, a )
end
local eclipse_color = rgba_to_hex( 140, 140, 230, 255 )
local prefix = eclipse_color .. 'aipeek \aFFFFFF70~ \aFFFFFFDD'

ui.sidebar( 'AI peek', 'scroll-torah' )

local bullshit_group = ui.create( 'ai peek' )

local menu = {
    mode = bullshit_group:combo( 'Performance mode', 'Performant', 'Standard', 'Nasa calculations' ),
    bullshit_group:label( '\n' ),
    dot_offset = bullshit_group:slider( prefix .. 'dot start offset', 0, 20, 8 ),
    dot_span = bullshit_group:slider( prefix .. 'dot span', 0, 30, 5 ),
    dot_amount = bullshit_group:slider( prefix .. 'dot amount', 0, 5, 3 ),
    bullshit_group:label( '\n' ),
    mp_scale_head = bullshit_group:slider( prefix .. 'head scale', 0, 100, 70 ),
    mp_scale_chest = bullshit_group:slider( prefix .. 'body scale', 0, 100, 70 ),
    target_limbs = bullshit_group:switch( prefix .. 'target limbs' ),
}

local function is_mp_available( )
    return table.includes( { 'Standard', 'Nasa calculations' }, menu.mode:get( ) )
end

local function set_visible_mp( )
    local enable_higher_end = is_mp_available( )

    menu.mp_scale_head:visibility( enable_higher_end )
    menu.mp_scale_chest:visibility( enable_higher_end )
    menu.target_limbs:visibility( enable_higher_end )
end

menu.mode:set_callback( set_visible_mp )
set_visible_mp( )

local enemy_lc_data = { }
local function create_new_record( player )
    local data = { }

    data.player = player

    data.last_simtime = 0
    data.origin = player:get_origin( )

    data.breaking_lc = false
    data.defensive_active_until = 0
    data.defensive = false

    function data.update( )
        local simtime = to_ticks( player.m_flSimulationTime )
        local origin = player:get_origin( )

        local delta = simtime - data.last_simtime

        if delta < 0 then
            data.defensive_active_until = globals.tickcount + math.abs( delta )
        else
            data.breaking_lc = ( data.origin - origin ):length2dsqr( ) > 4096

            data.origin = origin
        end

        data.last_simtime = simtime

        data.defensive = data.defensive_active_until > globals.tickcount
    end

    enemy_lc_data[ player ] = data

    return data
end

-- god forbid this hardcode shit please dont send me into hell 🙏🙏🙏🙏
local tick_to_distance = {
    0,
    0.33566926072059,
    0.90550823109139,
    1.7094571925458,
    2.7475758645732,
    4.0198045277169,
    5.5243356897069,
    7.2423273783409,
    9.1564213090631,
    11.250673856852,
    13.510480438002,
    15.922361837797,
    18.473989413581,
    21.153990043142,
    23.951936812474,
    26.858254779359,
    29.864120158319,
    32.961441695549,
    36.142785057665,
    39.401338315411,
    42.730817707458,
    46.125502156263,
    49.580063421207,
    53.08964170921,
    56.649735547569,
    60.256252190999,
    63.905432011078,
    67.59383918326,
    71.318242246617,
    75.075708340563,
    78.863628408227,
    82.67942790961,
    86.520915828495,
    90.385926351936,
    94.272651987509,
    98.17890171902,
    102.08515145053,
    105.99140118205,
    109.89765091356,
    113.80390064508,
    117.7101503766,
    121.61640010812,
    125.52264983965,
    129.42889957117,
    133.3351493027,
    137.24139903422,
    141.14764876575,
    145.05389849727,
    148.9601482288,
    152.86639796033,
    156.77264769186,
    160.67889742339,
    164.58514715492,
    168.49139688645,
    172.39764661798,
    176.30389634951,
    180.21014608104,
    184.11639581258,
    188.02264554411,
    191.92889527564,
    195.83514500718,
    199.74139473871,
    203.64764447024,
    207.55389420178,
}

-- local function can_hit_in_x_ticks( player, start_pos, wanted_pos, ticks )
    -- local sim_ctx = player:simulate_movement( )
    -- sim_ctx:think( ticks )

    -- local wanted_distance = ( wanted_pos - player:get_origin( ) ):length2d( )
    -- local predicted_distance = ( sim_ctx.origin - player:get_origin( ) ):length2d( )

    -- return predicted_distance >= wanted_distance
-- end

local function can_hit_in_x_ticks( wanted_pos_distance, max_speed, ticks )
    local distance_mult = max_speed / 250
    local wanted_distance = wanted_pos_distance * distance_mult

    local max_distance = tick_to_distance[ ticks ] * distance_mult

    return wanted_distance <= max_distance
end


local debug_visuals = { }
local visuals = {
    peeking_points = { },
    found_point = nil,
}
local function debug_visualize( positions, tgt )
    if type( positions ) ~= 'table' then
        positions = { positions }
    end

    debug_visuals[ tgt:get_name( ) ] = positions
end

local function set_visual_peeking_points( points )
    visuals.peeking_points = points
end

local e_hitboxes = {
    [ 'head' ] = 1,
    [ 'stomach' ] = 2,
    [ 'chest' ] = 3,
    [ 'limbs' ] = 4
}

local hitboxes = {
    { 0 },
    { 2, 3, 4 },
    { 5, 6 },
    {
        13, 14, 15, 16, 17, 18, -- arms
        7, 8, 9, 10, -- legs
        11, 1, -- feet
    },
}

local cache = {
    autopeek_position = vector( 0, 0, 0 ),
    last_seen = 0,
    found_position = vector( 0, 0, 0 ),
    found_position_dist = 1,
}

local closest_enemy = nil

local function get_min_dmg( )
    return mindmg:get( )
end

local function reset_cache( )
    cache.last_seen = 0
    cache.found_position = vector( 0, 0, 0 )
end 

local function get_closest_enemy( )
    local screen_center = render.screen_size( ) / 2
   
    local smallest_distance = math.huge
    local closest_enemy_found = nil

    local enemies = entity.get_players( true )
    for i = 1, #enemies do
        local enemy = enemies[ i ]

        if enemy == nil then
            goto continue
        end

        --* only check for enemies that are alive and not dormant
        if not enemy:is_alive( ) or enemy:is_dormant( ) then
            goto continue
        end
        
        local enemy_position = enemy:get_origin( )
        
        local enemy_screen = enemy_position:to_screen( )
        
        if enemy_screen == nil or enemy_screen.x == nil or enemy_screen.y == nil then
            goto continue
        end

        local distance = ( enemy_screen - screen_center ):length( )

        if distance < smallest_distance then
            smallest_distance = distance
            closest_enemy_found = enemy
        end

        ::continue::
    end

    closest_enemy = closest_enemy_found
end

local function get_multipoint( ent, hitbox_center, scale )
    local target_pos = ent:get_origin( )

    local lp = entity.get_local_player( )
    local lp_pos = lp:get_origin( )

    local lp_to_tgt = target_pos - lp_pos
    local ang = lp_to_tgt:angles( )
    local new_yaw = ang.y

    local max_check_dist = 5

    local mp_poses = { }

    for side = -1, 1, 2 do
        local yaw = new_yaw + ( 90 * side )
        local yaw_rad = math.rad( yaw )

        local x = math.cos( yaw_rad )
        local y = math.sin( yaw_rad )

        local mp_start = hitbox_center + vector( x * max_check_dist, y * max_check_dist, 0 )
        local diff = hitbox_center - mp_start

        local trace = utils.trace_line( mp_start, hitbox_center, lp )

        local mp_pos = hitbox_center + ( diff * ( 1 - trace.fraction ) ) * scale

        table.insert( mp_poses, mp_pos )
    end

    return mp_poses
end

local function get_head_multipoint( ent, hitbox_center, scale )
    local lp = entity.get_local_player( )
    local side_mp = get_multipoint( ent, hitbox_center, scale )

    local max_check_dist = -5
    local mp_start = hitbox_center + vector( 0, 0, max_check_dist )
    local diff = hitbox_center - mp_start

    local trace = utils.trace_line( mp_start, hitbox_center, lp )

    local mp_pos = hitbox_center + ( diff * ( 1 - trace.fraction ) ) * scale

    table.insert( side_mp, mp_pos )

    return side_mp
end

local function get_player_points( player )
    -- TODO: multipoint head, chest stomach
    -- TODO: add menu customization for multipoints and normal hitboxes

    local points = { }
    local points_names = { }

    local extra_calc = is_mp_available( )

    local find = {
        head = true,
        chest = true,
        stomach = true,
        limbs = extra_calc and menu.target_limbs:get( )
    }

    local mp = {
        head = extra_calc,
        chest = extra_calc,
        stomach = extra_calc,
        limbs = false
    }

    local mp_scale = {
        head = menu.mp_scale_head:get( ) / 100,
        chest = menu.mp_scale_chest:get( ) / 100,
        stomach = menu.mp_scale_chest:get( ) / 100,
        limbs = 0
    }

    if find.head then
        local head_hitboxes = hitboxes[ e_hitboxes[ 'head' ] ]

        for i = 1, #head_hitboxes do
            local head = player:get_hitbox_position( head_hitboxes[ i ] )

            if not mp.head then
                table.insert( points, head )
                table.insert( points_names, 'head' )
            else
                local multipoints = get_head_multipoint( player, head, mp_scale.head )

                for mp_idx = 1, #multipoints do
                    table.insert( points, multipoints[ mp_idx ] )
                    table.insert( points_names, 'head' )
                end
            end
        end
    end

    if find.chest then
        local chest_hitboxes = hitboxes[ e_hitboxes[ 'chest' ] ]
        for i = 1, #chest_hitboxes do
            local chest = player:get_hitbox_position( chest_hitboxes[ i ] )

            if not mp.chest then
                table.insert( points, chest )
                table.insert( points_names, 'chest' )
            else
                local multipoints = get_multipoint( player, chest, mp_scale.chest )
                
                for mp_idx = 1, #multipoints do
                    table.insert( points, multipoints[ mp_idx ] )
                    table.insert( points_names, 'chest' )
                end
            end
        end
    end

    if find.stomach then
        local stomach_hitboxes = hitboxes[ e_hitboxes[ 'stomach' ] ]
        for i = 1, #stomach_hitboxes do
            local stomach = player:get_hitbox_position( stomach_hitboxes[ i ] )
            
            if not mp.stomach then
                table.insert( points, stomach )
                table.insert( points_names, 'stomach' )
            else
                local multipoints = get_multipoint( player, stomach, mp_scale.stomach )

                for mp_idx = 1, #multipoints do
                    table.insert( points, multipoints[ mp_idx ] )
                    table.insert( points_names, 'stomach' )
                end
            end
        end
    end

    if find.limbs then
        local limbs_hitboxes = hitboxes[ e_hitboxes[ 'limbs' ] ]
        for i = 1, #limbs_hitboxes do
            local limb = player:get_hitbox_position( limbs_hitboxes[ i ] )
            table.insert( points, limb )
            table.insert( points_names, 'limb' )
        end
    end

    return { points, points_names }
end

local function get_peeking_points( lp )
    local lp_origin = lp:get_origin( )
    local lp_eye = lp:get_eye_position( )

    local ang = render.camera_angles( )
    local yaw = ang.y

    local head_height = lp_eye.z - lp_origin.z

    -- we want 3 dots on boths sides of the player
    -- so:
    -- . . . p . . .
    -- p = player
    -- . = dot
    -- the dots are spaced out over a distance of 32 units

    local start_offset = menu.dot_offset:get( )
    local dots = menu.dot_amount:get( )
    local total_distance = menu.dot_span:get( )
    local gap = total_distance / dots

    local dot_positions = { }

    for i = -1, 1, 2 do
        local dot_yaw = yaw + ( 90 * i )

        -- convert yaw to forwardvector (vector with length 1)
        local forwardvector = vector( math.cos( math.rad( dot_yaw ) ), math.sin( math.rad( dot_yaw ) ), 0 )

        for dot_iter = 1, dots do
            -- get dot position disregarding the ground
            local dot_position = lp_eye + ( forwardvector * ( gap * dot_iter ) ) + ( forwardvector * start_offset )

            -- find ground height from dot position
            local trace_res = utils.trace_line( dot_position, dot_position + vector( 0, 0, -200 ), lp )

            -- if we hit the ground, set the dot position to the ground position + head height	
            local trace_fraction = trace_res.fraction
            if trace_fraction < 1 then
                local end_pos = trace_res.end_pos + vector( 0, 0, head_height )

                -- if the dot is too high, break the loop
                if ( end_pos.z - lp_origin.z ) > 40 then
                    dot_iter = dots
                end

                dot_position = end_pos
            end
            
            -- trace from eye to dot position to check if we can see the dot
            trace_res = utils.trace_line( lp_eye, dot_position, entity.get_players( ) )
            if trace_res.fraction == 1 then
                -- if we can see the dot, add it to the table
                table.insert( dot_positions, dot_position )
            else
                -- set point pos to smallest dist from the wall
                local last_dot_pos = lp_eye + ( ( forwardvector * ( gap * dot_iter ) ) + ( forwardvector * start_offset ) ) * trace_res.fraction - forwardvector * 19
                last_dot_pos.z = dot_position.z
                -- if we cant see the dot, break the loop
                table.insert( dot_positions, last_dot_pos )
                break
            end
        end
    end

    return dot_positions
end

local function can_hit_from_position( lp, position, target, target_hitpoints, announce )
    local minimum_damage = get_min_dmg( )

    local c_yes = color( 'FFABBC' ):to_hex( )
    local c_mismatch = color( 'ABB3FF' ):to_hex( )

    if minimum_damage > 100 then
        minimum_damage = target.m_iHealth + ( minimum_damage - 100 )
    end

    for j = 1, #target_hitpoints do
        local hitpoint = target_hitpoints[ 1 ][ j ]
        
        -- client.trace_bullet(from_player, from_x, from_y, from_z, to_x, to_y, to_z, skip_players)
        local simulated_dmg, trace = utils.trace_bullet( lp, position, hitpoint, lp )
        local hit_entity = trace.entity

        if hit_entity ~= nil then

            local hit_player_name = hit_entity:get_name( )
            local target_health = hit_entity.m_iHealth

            local dmg_diff = simulated_dmg - minimum_damage
            if dmg_diff > 0 then
                dmg_diff = '\a00FF00FF+' .. dmg_diff
            else
                dmg_diff = '\aFF0000FF' .. dmg_diff
            end

            if hit_entity and hit_entity == target then
                local wanted_dmg = minimum_damage

                if minimum_damage > 100 then
                    wanted_dmg = target_health + ( minimum_damage - 100 )
                end

                -- if mindmg is low enough or we can kill the target with one shot, return true or we can overall shoot the target
                if simulated_dmg >= target_health or simulated_dmg > wanted_dmg then
                    cache.found_position = position
                    cache.found_position_dist = ( cache.autopeek_position - cache.found_position ):length2d( )

                    if announce ~= nil then
                        common.add_notify( 'AI peek', ( '\aFFFFFFFFpeeking %s for %i in %s [%s]' ):format( hit_player_name, simulated_dmg, target_hitpoints[ 2 ][ j ], dmg_diff )  )

                        print_raw( ( '\a%sap\a8a8a8aFF . \aa3a3a3FFpeeking \a%s%s \aa3a3a3FFfor \a%s%i \aa3a3a3FFin \a%s%s \aa3a3a3FF[%s\aa3a3a3FF]' ):format(
                            c_mismatch, c_yes, hit_player_name, c_yes, simulated_dmg, c_yes, target_hitpoints[ 2 ][ j ], dmg_diff
                        ) )
                    end

                    return true, position, hit_entity
                end
            elseif hit_entity ~= nil and hit_entity:is_alive( ) then
                -- if we hit a different target,check if we can 1 shot it
                local wanted_dmg = minimum_damage

                if minimum_damage > 100 then
                    wanted_dmg = target_health + ( minimum_damage - 100 )
                end


                if simulated_dmg >= target_health or simulated_dmg > wanted_dmg then
                    cache.found_position = position

                    if announce then
                        common.add_notify( 'AI peek - mismatch', ( '\aFFFFFFFFpeeking %s for %i in %s [%s]' ):format( hit_player_name, simulated_dmg, target_hitpoints[ 2 ][ j ], dmg_diff )  )
                    end

                    return true, position, hit_entity
                end
            end
        end
    end

    return false
end

local function can_hit_from_positions( lp, positions, target, target_hitpoints )

    for i = 1, #positions do
        local position = positions[ i ]
        
        visuals.found_point = i

        local state, pos, ent = can_hit_from_position( lp, position, target, target_hitpoints, true )

        if state then
            return true, pos, ent
        end
    end

    visuals.found_point = nil
    return false, nil, nil
end

local function ready_to_shoot( lp, cmd )
    local slowdown = lp.m_flVelocityModifier < 0.9
    local has_user_input = cmd.in_moveleft == 1 or cmd.in_moveright == 1 or cmd.in_back == 1 or cmd.in_forward == 1 or cmd.in_jump == 1
    local wep = entity.get_local_player( ):get_player_weapon( )

    local next_shot_ready = false
    if wep then
        local reloading = wep.m_bInReload == 1
        local next_attack_ready = wep.m_flNextPrimaryAttack < globals.curtime

        if not reloading and next_attack_ready then
            next_shot_ready = true
        end
    end
    
    local can_normally_shoot = next_shot_ready --! and can_hit_normal( tgt )

    return not ( ( slowdown or has_user_input or not next_shot_ready ) and not can_normally_shoot )
end

local function move_to_pos( cmd, lp, lp_pos, new_pos )
    local distance = lp_pos:dist( new_pos ) + 5
    local unit_vec = ( new_pos - lp_pos ):normalized( )
    
    new_pos = lp_pos + unit_vec * ( distance + 5 )

    if cmd.forwardmove == 0 and cmd.sidemove == 0 and not cmd.in_forward and not cmd.in_back and not cmd.in_moveleft and not cmd.in_moveright then
        if distance >= 0.5 then
            local fwd1 = new_pos - lp_pos

            local pos1 = new_pos + fwd1:normalized( )*10

            local fwd = pos1 - lp_pos
            local ang = fwd:angles()
            local yaw = ang.y

            if yaw == nil then
                return
            end

            cmd.move_yaw = yaw
            cmd.in_speed = 0

            cmd.in_moveleft, cmd.in_moveright = 0, 0
            cmd.sidemove = 0


            if distance > 8 then
                cmd.forwardmove = 900000
            else
                local wishspeed = math.min( 450, math.max( 1.1+lp.m_flDuckAmount * 10, distance * 9 ) )
                local vel = lp.m_vecAbsVelocity:length2d( )
                if vel >= math.min( 250, wishspeed )+15 then
                    cmd.forwardmove = 0
                    cmd.in_forward = 0
                else
                    cmd.forwardmove = math.max( 6, vel >= math.min( 250, wishspeed ) and wishspeed * 0.9 or wishspeed )
                    cmd.in_forward = 1
                end
            end
        end
    end
end

local function handle_peek( cmd )
    local lp = entity.get_local_player( )
    local lp_pos = lp:get_eye_position( )

    cache.found_position.z = lp_pos.z
    

    move_to_pos( cmd, lp, lp_pos, cache.found_position )
end

local function handle_retreat( cmd )
    local lp = entity.get_local_player( )
    local lp_pos = lp:get_eye_position( )

    move_to_pos( cmd, lp, lp_pos, cache.autopeek_position )
end

local function is_doubletap_charged( )
    return rage.exploit:get( ) and dt:get( )
end

local debug = {
    state = 'disabled',
    step = 0,
    visual_step = 0,
}

local function set_state( new_state )
    debug.state = new_state
end

local e_visual_steps = {
    IDLE = 0,
    FINDING_TARGET = 1,
    SEARCHING_HITPOINTS = 2,
    CHECKING_HITPOINTS = 3,
    PEEKING = 4,
    RETREATING = 5,
    WAITING_FOR_SHOT = 6,
    NO_ENEMIES = 7,
    DT_NOT_CHARGED = 8,
}

local visual_texts = {
    [ e_visual_steps.IDLE ] = 'idle',
    [ e_visual_steps.FINDING_TARGET ] = 'finding target',
    [ e_visual_steps.SEARCHING_HITPOINTS ] = 'searching hitpoints',
    [ e_visual_steps.CHECKING_HITPOINTS ] = 'checking hitpoints',
    [ e_visual_steps.PEEKING ] = 'peeking',
    [ e_visual_steps.RETREATING ] = 'retreating',
    [ e_visual_steps.WAITING_FOR_SHOT ] = 'waiting for shot',
    [ e_visual_steps.NO_ENEMIES ] = 'no enemies',
    [ e_visual_steps.DT_NOT_CHARGED ] = 'dt not charged',
}

local e_steps = {
    IDLE = 0,
    FINDING_TARGET = 1,
    SEARCHING_HITPOINTS = 2,
    CHECKING_HITPOINTS = 3,
    PEEKING = 4,
    RETREATING = 5,
}

local function set_step( step )
    debug.step = step
end

local function set_visual_step( step )
    debug.visual_step = step
end

local peeking_points = { }
local function gpt_peek( cmd )
    local lp = entity.get_local_player( )

    if not lp then return end

    local pos = lp.m_vecOrigin
    local autopeek_state = autopeek:get( )
    if not autopeek_state then
        cache.autopeek_position = pos

        peeking_points = get_peeking_points( lp )

        reset_cache( )
        set_state( 'disabled' )
        set_step( e_steps.IDLE )
        set_visual_step( e_visual_steps.IDLE )
        return
    end

    set_visual_peeking_points( peeking_points )

    set_state( 'idle' )

    local distance = ( cache.autopeek_position - cache.found_position ):length2d( )
    local can_run = can_hit_in_x_ticks( distance, 250, 24 )

    local can_shoot = ready_to_shoot( lp, cmd )

    local can_hit_old_record = cache.last_peek_pos ~= nil and cache.last_peek_ent ~= nil and cache.last_peek_ent:is_player( )  and cache.last_peek_ent:is_alive( ) and can_hit_from_position( lp, cache.last_peek_pos , cache.last_peek_ent, get_player_points( cache.last_peek_ent ) )

    if ( ( cache.last_seen + 24 ) >= globals.tickcount or can_hit_old_record ) and can_run and can_shoot then
        handle_peek( cmd )
        set_state( 'peeking' )
        set_step( e_steps.PEEKING )
        set_visual_step( e_visual_steps.PEEKING )
        return --!!!!!!!!!!!!!!!!!!! REMOVE IF BAD
    elseif ( cache.autopeek_position - pos ):length2d( ) > 5 then
        handle_retreat( cmd )
        set_state( 'retreating' )
        
        set_step( e_steps.RETREATING )
        set_visual_step( e_visual_steps.RETREATING )
        return --!!!!!!!!!!!!!!!!!!! REMOVE IF BAD
    end

    if not can_shoot then
        set_step( e_steps.IDLE )
        set_visual_step( e_visual_steps.WAITING_FOR_SHOT )
        return
    end

    local dt_charged = is_doubletap_charged( )

    if not dt_charged then
        set_step( e_steps.FINDING_TARGET )
        set_visual_step( e_visual_steps.DT_NOT_CHARGED )
        return
    end
    
    local targets = menu.mode:get( ) == 'Nasa calculations' and entity.get_players( true ) or { closest_enemy }

    if #targets == 0 or targets[ 1 ] == nil then
        reset_cache( )
        set_state( 'idle' )
        set_step( e_steps.IDLE )
        set_visual_step( e_visual_steps.NO_ENEMIES )
        return
    end

    if can_shoot then
        set_step( e_steps.FINDING_TARGET )
        set_visual_step( e_visual_steps.FINDING_TARGET )
    end


    for idx = 1, #targets do
        local target = targets[ idx ]

        if not target or not target:is_alive( ) or target:is_dormant( ) then
            goto continue
        end
        
        local target_data = enemy_lc_data[ target ]

        if target_data == nil then
            target_data = create_new_record( target )
        end

        target_data.update( )

        local is_lc = target_data.breaking_lc
        local is_defensive =  target_data.defensive
        local can_peek = not is_lc and not is_defensive

        local hitpoints = get_player_points( target )
        debug_visualize( hitpoints[ 1 ], target )

        set_step( e_steps.SEARCHING_HITPOINTS )
        set_visual_step( e_visual_steps.SEARCHING_HITPOINTS )

        if not can_peek then
            set_step( e_steps.CHECKING_HITPOINTS )
            set_visual_step( e_visual_steps.CHECKING_HITPOINTS )
            goto continue
        end

        local can_hit, peek_pos, peek_ent = can_hit_from_positions( lp, peeking_points, target, hitpoints )

        if can_hit then

            cache.last_seen = globals.tickcount
            cache.last_peek_pos = peek_pos
            cache.last_peek_ent = peek_ent
            break
        end

        ::continue::
    end
end

events.createmove:set( gpt_peek )
events.aim_fire:set( function( )
    -- reset the last_seen variable since we just shot and want to retreat
    cache.last_seen = 0
end )

local x, y = 400, 400

local visual_progressbar = {
    lerped_pos = vector( 0, 0, 0 ),
    gap = 30,
    radius = 5,
    pad = vector( 3, 2, 0 )
}

local function render_screen_bar( )
    local lp = entity.get_local_player( )
    if not lp then return end

    -- render debug poses
    local enemies = entity.get_players( true )
    for idx, enemy in pairs( enemies ) do
        if enemy and enemy:is_alive( ) and not enemy:is_dormant( ) and debug_visuals[ enemy:get_name( ) ] then
            local tbl = debug_visuals[ enemy:get_name( ) ]
            for i = 1, #tbl do
                local position = tbl[ i ]
        
                local s = position:to_screen( )
        
                if s and s.x ~= nil and s.y ~= nil then
                    -- render.circle(position: vector, color: color, radius: number, start_deg: number, pct: number)
                    render.circle( s, color( 255, 0, 0, 255 ), 1, 0, 1 )
                end
            end
        end
    end
   
    -- render progress bar at bottom
    local step = debug.step
    if step == e_steps.RETREATING then
        set_step( e_steps.IDLE )
        step = debug.step
    end

    local screen = render.screen_size( )
    screen = vector( screen.x / 2, screen.y - 200, 0 )

    local null_pos = vector( screen.x - ( 2 * visual_progressbar.gap ), screen.y, 0 )
    local active_pos = vector( screen.x + ( ( step - 2 ) * visual_progressbar.gap ), screen.y, 0 )

    if visual_progressbar.lerped_pos.x == 0 then
        visual_progressbar.lerped_pos = active_pos
    end

    local max_width = 5 * visual_progressbar.gap
    visual_progressbar.lerped_pos = visual_progressbar.lerped_pos:lerp( active_pos, 0.1 )
    visual_progressbar.x = visual_progressbar.lerped_pos.x + visual_progressbar.radius * 2
    local progress = ( visual_progressbar.lerped_pos.x - null_pos.x ) / max_width

    for i = -2, 2, 1 do
        local pos = vector( screen.x + ( i * visual_progressbar.gap ), screen.y, 0 )

        render.circle(
            pos,
            color( 0, 0, 0, 255 ),
            visual_progressbar.radius + 2,
            0, 1
        )
    end

    --render.rect(position_a: vector, position_b: vector, color: color[, rounding: number, no_clamp: boolean])
    render.rect(
        vector( null_pos.x - 1, null_pos.y - visual_progressbar.radius / 2 - 1 ),
        vector( null_pos.x - 1, null_pos.y - visual_progressbar.radius / 2 - 1 ) + vector( max_width * 0.8, visual_progressbar.radius + 2 ),
        color( 0, 0, 0, 200 )
    )

    render.rect(
        vector( null_pos.x, null_pos.y - visual_progressbar.radius / 2 ),
        vector( null_pos.x, null_pos.y - visual_progressbar.radius / 2 ) + vector( max_width * progress, visual_progressbar.radius ),
        color( 0, 255, 0, 255 )
    )

    local lp_pos = lp.m_vecOrigin
    local dist_to_point = ( lp_pos - cache.found_position ):length2d( )
    local progress_to_point = ( cache.found_position_dist - dist_to_point ) / cache.found_position_dist

    if progress_to_point < 0 then
        progress_to_point = 0
    end

    if progress_to_point > 1 then
        progress_to_point = 1
    end

    -- renderer.rectangle(
    --     null_pos.x, null_pos.y + visual_progressbar.radius * 2,
    --     ( max_width * 0.8 ) * progress_to_point, visual_progressbar.radius / 2,
    --     ( 1 - progress_to_point ) * 255, progress_to_point * 255, 0, 255
    -- )
    render.rect(
        vector( null_pos.x, null_pos.y + visual_progressbar.radius * 2 ),
        vector( null_pos.x, null_pos.y + visual_progressbar.radius * 2 ) + vector( ( max_width * 0.8 ) * progress_to_point, visual_progressbar.radius / 2 ),
        color( ( 1 - progress_to_point ) * 255, progress_to_point * 255, 0, 255 )
    )

    for i = -2, 2, 1 do
        local draw_step = i + 2
        local pos = vector( screen.x + ( i * visual_progressbar.gap ), screen.y, 0 )

        local c = ( visual_progressbar.lerped_pos.x + visual_progressbar.radius ) >= pos.x and color( 0, 255, 0 ) or color( 0, 0, 0 )

        -- renderer.circle(
        --     pos.x, pos.y,
        --     c[ 1 ], c[ 2 ], c[ 3 ], 255,
        --     visual_progressbar.radius,
        --     0, 1
        -- )

        --render.circle(position: vector, color: color, radius: number, start_deg: number, pct: number)
        -- renderer.circle(
        --     pos.x, pos.y,
        --     0, 0, 0, 255,
        --     visual_progressbar.radius - 2,
        --     0, 1
        -- )
        render.circle(
            pos,
            color( 0, 0, 0, 255 ),
            visual_progressbar.radius - 2,
            0, 1
        )

        --render.text(font: FontObject, position: vector, color: color, flags: string, text:any[, ...])
        if draw_step == debug.step then
            render.text(
                1,
                vector( visual_progressbar.lerped_pos.x, visual_progressbar.lerped_pos.y - 12 ),
                color( 255 ),
                'c',
                visual_texts[ debug.visual_step ]
            )
        end
    end
end

local visual_points = {
    last_pressed = 0,
    last_state = false,
    animation_time = .2,
}

local function ease_in_back( time )
    local c1 = 1.70158
    local c3 = c1 + 1

    return c3 * time * time * time - c1 * time * time
end

local function render_peeking_point( pos, state )
    render.circle(
        pos,
        color( 255, 255, 255, 255 ),
        2, 0, 1
    )

    if state then
        --renderer.circle_outline(x, y, r, g, b, a, radius, start_degrees, percentage, thickness)
        render.circle_outline(
            pos,
            color( 0, 255, 0, 255 ),
            3, 0, 1,
            2
        )
    end
end

local function render_peeking_points( )
    local ap_state = autopeek:get( )

    if ap_state ~= visual_points.last_state then
        visual_points.last_pressed = globals.curtime
        visual_points.last_state = ap_state
    end

    -- clamp the difference to 0->visual_points.animation_time
    local diff = globals.curtime - visual_points.last_pressed
    diff = math.min( diff, visual_points.animation_time )

    local animation_factor = ease_in_back( diff / visual_points.animation_time )

    if not ap_state then
        animation_factor = 1 - animation_factor
    end

    if not ap_state and animation_factor <= 0.1 then return end

    local points = visuals.peeking_points

    for i = 1, #points do
        local point = points[ i ]

        local pos = render.world_to_screen( point )

        if pos ~= nil and pos.x ~= nil and pos.y ~= nil then
            render_peeking_point( pos, visuals.found_point == i )
        end
    end
end

events.render:set( function( )
    render_peeking_points( )

    if autopeek:get( ) then
        get_closest_enemy( )
        render_screen_bar( )
    end
end )


local function update_peek_points( )
    local lp = entity.get_local_player( )

    if not lp then return end

    peeking_points = get_peeking_points( lp )
    set_visual_peeking_points( peeking_points )
end

menu.dot_amount:set_callback( update_peek_points )
menu.dot_offset:set_callback( update_peek_points )
menu.dot_span:set_callback( update_peek_points )
