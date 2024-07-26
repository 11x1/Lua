# Custom textures
Allows to create textures from a simple pattern (check `demo.lua`)  
No more are you required to have the texture sizes as a power of 2 (library handles it itself)
## ![screenshot](https://i.imgur.com/deQMakc.png)

# Using the library
### Requiring:
```lua
local custom_textures = require( "custom_textures" )
```

### Usage
`custom_textures.create( pattern, pattern_size, width, height, colors )`
| argument     | type                           | description                                                                                 |
|--------------|--------------------------------|---------------------------------------------------------------------------------------------|
| pattern      | `table<number...>`             | the pattern to repeat when rendering the texture                                            |
| pattern_size | `{[1] : number, [2] : number}` | pattern width and height                                                                    |
| width        | `number`                       | rendering width                                                                             |
| height       | `number`                       | rendering height                                                                            |
| colors       | `table<string...>`             | each key (number) in the table corresponds to the pattern's number and its associated color |

Check `demo.lua` for one usage example
