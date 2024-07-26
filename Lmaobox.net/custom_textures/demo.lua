local custom_textures = require( "custom_textures" )

local bg_texture = custom_textures.create(
    {
        0, 1, 0, 1,
        0, 1, 1, 1,
        0, 1, 0, 1,
        1, 1, 0, 1,
    },
    { 4, 4 },
    500, 100,
    {
        [ 0 ] = "\x00\x00\x00\xFF",
        [ 1 ] = "\x40\x40\x40\xFF"
    }
)

callbacks.Register("Draw", function( )
    draw.Color( 255, 255, 255, 255 )
    draw.FilledRect( 90, 90, 90 + 120, 90 + 520 )
    bg_texture:render( 100, 100 )
end )
