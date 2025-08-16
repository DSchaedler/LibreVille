# LibreVille
# A simple isometric city builder game using DragonRuby Game Toolkit.
# Copyright (c) 2025 Dee Schaedler. All rights reserved.
# https://github.com/DSchaedler/LibreVille
# Readme and License at https://raw.githubusercontent.com/DSchaedler/LibreVille/refs/heads/main/README.md
# TLDR: LibreVille is Shareware. You can use, modify, and distribute this code freely, but you cannot sell it or use it in a commercial product without permission.

# Helper function for producing Random Numbers in a Range.
def randr(min, max)
  rand(max - min + 1) + min
end

# Functions to convert between Cartesian and Isometric coordinates.
# Technically to_isometric and from_isometric are the same function, but with different default angles.

def to_isometric(x, y, angle = -45)
  angle_radians = angle.to_radians
  iso_x = ( x * Math.cos(angle_radians) ) - (y * Math.sin(angle_radians))
  iso_y = ( x * Math.sin(angle_radians) ) + (y * Math.cos(angle_radians))
  return iso_x, iso_y
end

def from_isometric(iso_x, iso_y, angle = 45 )
  xangle_radians = angle.to_radians
  iso_x = ( x * Math.cos(angle_radians) ) - (y * Math.sin(angle_radians))
  iso_y = ( x * Math.sin(angle_radians) ) + (y * Math.cos(angle_radians))
  return iso_x, iso_y
end

def logic args
  # This is where you would put any game logic that needs to run every frame.

  args.state.rotation ||= -45   # (Integer Angle) Isometric View Angle

  # Create an array of arrays, for a grid.
  grid_size = 10
  args.state.matrix ||= grid_size.map { |i| 
    grid_size.map { |i|

      building = randr(0,9) # 10% chance of spawning a building. TODO, remove when editing is implemented.
      if building == 9
        skin = randr(0,3) # Choose a random skin for the building.
        case skin
        when 0
          "sprites/kenney/isometric_tiles_buildings/buildingTiles_001.png"
        when 1
          "sprites/kenney/isometric_tiles_buildings/buildingTiles_002.png"
        when 2
          "sprites/kenney/isometric_tiles_buildings/buildingTiles_003.png"
        when 3
          "sprites/kenney/isometric_tiles_buildings/buildingTiles_004.png"
        else
          "sprites/kenney/isometric_tiles_city/city_tiles_066.png" # Default to a city tile if something goes wrong.
        end
      else
        "sprites/kenney/isometric_tiles_city/city_tiles_066.png"
      end
    }
  }
end

def render_matrix args
  # ==Magic Numbers==
  args.state.sprite_scale     = 1   # (Float %)       Shrink or grow the sprites
  args.state.iso_scale        = 0.5   # (Float %)       Adjust vertical spacing to account for isometric distortion
  args.state.sprite_grouping  = 8     # (Integer)       Account for extra pixels on the sides of sprites

  # TODO Hardcode these values - Grab some reference numbers from the kenney assets
  args.state.spritebox ||= args.gtk.calcspritebox "sprites/kenney/isometric_tiles_base/landscape_tiles_067.png"
  args.state.sprite_width ||= args.state.spritebox.x
  args.state.sprite_height ||= args.state.spritebox.y

  # Determine a universal spacing for all sprites.
  args.state.sprite_spacing = (args.state.sprite_height - args.state.sprite_grouping) * args.state.sprite_scale
  args.state.horizontal_scale = args.state.sprite_width * args.state.sprite_scale

  # Iterate through every row. We need to be careful about row/column order so that it renders correctly.
  # TODO: Make all gameplay elements render based on Y value, with lower Y values on top.
  rows = 1
  while rows <= args.state.matrix.length
    current_row = args.state.matrix[rows-1] # -1 because arrays are zero-indexed.
      columns = current_row.length # This should always equal the grid size, but we check it anyway in case we ever decide to have rows with fewer tiles.
      while columns > 0

        # Create reference coordinates for the sprite.
        reference_x = (rows * args.state.sprite_spacing)
        reference_y = ((columns - 1) * args.state.sprite_spacing)
        
        # Convert the reference coordinates to isometric coordinates.
        x_isometric, y_isometric = to_isometric(reference_x, reference_y, args.state.rotation)

        # The sprite path is stored in the matrix, so we have to get it from there.
        path = args.state.matrix[rows-1][columns-1]

        # The sprites have different heights, and DR requires a height value.
        # TODO: Make all sprites the same height, so we can hardcode this value.
        height = args.gtk.calcspritebox(path).y

        if args.state.rotation == 0
          x_alignment = reference_x * ( 0.75 + args.state.iso_scale )
          y_alignment = reference_y * (args.state.sprite_scale / ( 1+ args.state.iso_scale ))
        else
          x_alignment = x_isometric
          y_alignment = (y_isometric * args.state.iso_scale ) + (720 / 2) - (args.state.sprite_height / 5)
        end

        args.outputs.sprites << { 
          x: x_alignment, 
          y: y_alignment, # We have to adjust the Y value to account for the isometric distortion. Adding 720 / 2 centers the isometric view vertically.
          anchor_x: 0.5, # Center the sprite horizontally.
          anchor_y: 0, # Anchor the sprite to the bottom, so sprites of different heights remain grid aligned.
          w: args.state.horizontal_scale,
          h: height,
          path: path
        }
        columns = columns - 1
    end
    rows = rows + 1
  end
end

def user_interface args
  icon_zoom_in      = "sprites/kenney/game_icons/png/white/2x/zoom_in.png"
  icon_zoom_out         = "sprites/kenney/game_icons/png/white/2x/zoom_out.png"
  icon_menu             = "sprites/kenney/game_icons/png/white/2x/bars_horizontal.png"
  icon_grid_menu        = "sprites/kenney/game_icons/png/white/2x/menu_grid.png"
  icon_rotate_isometric = "sprites/kenney/game_icons_expansion/png/white/2x/device_tilt_right.png"
  icon_rotate_cartesian = "sprites/kenney/game_icons_expansion/png/white/2x/device_tilt_left.png"

  args.state.menu_button_rect       ||= args.layout.rect(row: 0,                                col: args.layout.col_max_index, w: 1, h: 1)
  args.state.zoom_in_button_rect    ||= args.layout.rect(row: (args.layout.row_max_index - 1),  col: args.layout.col_max_index, w: 1, h: 1)
  args.state.zoom_out_button_rect   ||= args.layout.rect(row: args.layout.row_max_index,        col: args.layout.col_max_index, w: 1, h: 1)
  args.state.grid_menu_button_rect  ||= args.layout.rect(row: 0,                                col: 0,                         w: 1, h: 1)
  args.state.rotate_button_rect     ||= args.layout.rect(row: args.layout.row_max_index,        col: 0,                         w: 1, h: 1)

  args.outputs.sprites << args.state.menu_button_rect.merge(path: icon_menu)
  args.outputs.sprites << args.state.zoom_in_button_rect.merge(path: icon_zoom_in)
  args.outputs.sprites << args.state.zoom_out_button_rect.merge(path: icon_zoom_out)
  args.outputs.sprites << args.state.grid_menu_button_rect.merge(path: icon_grid_menu)

  if args.state.rotation == -45
    args.outputs.sprites << args.state.rotate_button_rect.merge(path: icon_rotate_cartesian)
  else
    args.outputs.sprites << args.state.rotate_button_rect.merge(path: icon_rotate_isometric)
  end

  if args.inputs.mouse.up
    if args.state.menu_button_rect.intersect_rect? args.inputs.mouse
      args.state.show_menu ||= false
      args.state.show_menu = !args.state.show_menu
    end

    if args.state.zoom_in_button_rect.intersect_rect? args.inputs.mouse
      # TODO: Implement Render Targets to allow zooming in and out.
    end

    if args.state.zoom_out_button_rect.intersect_rect? args.inputs.mouse
      # TODO: Implement Render Targets to allow zooming in and out.
    end

    if args.state.grid_menu_button_rect.intersect_rect? args.inputs.mouse
      # TODO: Implement grid menu for selecting view.
    end

    if args.state.rotate_button_rect.intersect_rect? args.inputs.mouse
      puts "clicked rotate"
      if args.state.rotation == -45
        args.state.rotation = 0
      else
        args.state.rotation = -45
      end
    end
  end

end

def tile_menu args
  icon_residential  = "sprites/kenney/game_icons/png/white/2x/home.png"
  icon_commercial   = "sprites/kenney/game_icons/png/white/2x/shopping_cart.png"
  icon_industrial   = "sprites/kenney/game_icons/png/white/2x/wrench.png"
  icon_road         = "sprites/kenney/game_icons/png/white/2x/bars_vertical.png"
  icon_nothing      = "sprites/kenney/game_icons/png/white/2x/cross.png"
  icon_attraction   = "sprites/kenney/game_icons/png/white/2x/star.png"
end

def debug_interface args
  args.state.show_debug ||= false
  if args.inputs.keyboard.key_up.tab
    args.state.show_debug = !args.state.show_debug
  end
  
  if args.state.show_debug
    args.outputs.primitives << args.layout.debug_primitives
    fps_rect = args.layout.rect(row: 0, col: 0, w: 1, h: 1)
    args.outputs.labels << fps_rect.merge(text: "FPS: #{args.gtk.current_framerate.round}", r: 255, g: 255, b: 255)
  end
end

# Main Loop
def tick args

  logic args

  args.outputs.background_color = [29, 32, 43]

  render_matrix args
  user_interface args
  debug_interface args

end