# LibreVille
# A simple isometric city builder game using DragonRuby Game Toolkit.
# Copyright (c) 2025 Dee Schaedler. All rights reserved.
# https://github.com/DSchaedler/LibreVille
#
# Readme and License at 
# https://raw.githubusercontent.com/DSchaedler/LibreVille/refs/heads/main/README.md
#
# TLDR: LibreVille is Shareware. You can use, modify, and distribute this code
# freely, but you cannot sell it or use it in a commercial product without
# permission.

def const args

  args.state.money    ||= 10000

  args.state.tile_size     ||= {w: 131, h: 98}
  args.state.sprite_skew = (args.state.tile_size[:w] / args.state.tile_size[:h]) * 2.25

  args.state.grid_size     ||= 10
  args.state.grid_anchor   = {
    # Offset tile 0,0 so the whole grid is centered horizontally
    x: (1280 / 2) - ((args.state.grid_size / 2) * args.state.tile_size[:w]), 
    # Center tile 0,0 vertically, accounting for sprite height
    y: (720 / 2) - (args.state.tile_size[:h] / 2) 
    }

  args.state.matrix   ||= args.state.grid_size.map { |i| 
    args.state.grid_size.map { |i|
      {UUID: args.gtk.create_uuid, 
      type: :libreville_grass,
      path: "sprites/kenney/isometric_tiles_base/landscape_tiles_067.png",
      primitive_marker: :sprite,
      grid_x: i,
      grid_y: i
        }.merge(args.state.tile_size)
      }
    }

  args.state.matrix_coords ||= []
  args.state.z_layers = []

  rows = 1
  while rows <= args.state.matrix.length
    current_row = args.state.matrix[rows-1] # Adjust for zero index

      # Should equal grid size, check anyways.
      columns = current_row.length
      while columns > 0

        x = args.state.grid_anchor[:x] + ((rows - 2) + columns) * args.state.tile_size[:w] / 2
        y = args.state.grid_anchor[:y] + (-1 * (rows) * args.state.tile_size[:h] / args.state.sprite_skew) + columns * args.state.tile_size[:h] / args.state.sprite_skew
        
        args.state.matrix_coords[rows-1] ||= []
        args.state.matrix_coords[rows-1][columns-1] = args.state.matrix[rows-1][columns-1].merge(x: x, y: y)

        args.state.z_layers[current_row.length - columns] ||= []
        args.state.z_layers[current_row.length - columns] << args.state.matrix[rows-1][columns-1].merge(x: x, y: y)

        columns = columns - 1
    end
    rows = rows + 1
  end

end

# Helper function for producing Random Numbers in a Range.
def randr(min, max)
  rand(max - min + 1) + min
end

def render_z_layers args

  args.outputs.primitives << args.state.z_layers
  
end

def user_interface args
  icon_zoom_in      = "sprites/kenney/game_icons/png/white/2x/zoom_in.png"
  icon_zoom_out         = "sprites/kenney/game_icons/png/white/2x/zoom_out.png"
  icon_menu             = "sprites/kenney/game_icons/png/white/2x/bars_horizontal.png"
  icon_grid_menu        = "sprites/kenney/game_icons/png/white/2x/menu_grid.png"

  args.state.menu_button_rect       ||= args.layout.rect(row: 0,                                col: args.layout.col_max_index, w: 1, h: 1)
  args.state.zoom_in_button_rect    ||= args.layout.rect(row: (args.layout.row_max_index - 1),  col: args.layout.col_max_index, w: 1, h: 1)
  args.state.zoom_out_button_rect   ||= args.layout.rect(row: args.layout.row_max_index,        col: args.layout.col_max_index, w: 1, h: 1)
  args.state.grid_menu_button_rect  ||= args.layout.rect(row: 0,                                col: 0,                         w: 1, h: 1)
  args.state.rotate_button_rect     ||= args.layout.rect(row: args.layout.row_max_index,        col: 0,                         w: 1, h: 1)

  args.outputs.sprites << args.state.menu_button_rect.merge(path: icon_menu)
  args.outputs.sprites << args.state.zoom_in_button_rect.merge(path: icon_zoom_in)
  args.outputs.sprites << args.state.zoom_out_button_rect.merge(path: icon_zoom_out)
  args.outputs.sprites << args.state.grid_menu_button_rect.merge(path: icon_grid_menu)

  args.state.money_label_rect       ||= args.layout.rect(row: 0, col: 1, w: 1, h: 1)
  args.state.money_label_text       = "\$#{args.state.money}"

  args.outputs.labels << args.state.money_label_rect.merge(text: args.state.money_label_text, r: 0, g: 255, b: 0, font: "fonts/kenney/kenney_bold_extra.ttf", vertical_alignment_enum: 0, size_px: args.state.money_label_rect.h * 0.8)

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

  const args

  args.outputs.background_color = [29, 32, 43]

  render_z_layers args
  user_interface args
  debug_interface args

end