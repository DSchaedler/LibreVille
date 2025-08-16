# Helper function for producing Random Numbers in a Range.
def randr(min, max)
  rand(max - min + 1) + min
end

# Main Loop
def tick args

  # ==Magic Numbers==
  args.state.sprite_scale     = 1   # (Float %)       Shrink or grow the sprites
  args.state.iso_scale        = 0.5   # (Float %)       Adjust vertical spacing to account for isometric distortion
  args.state.sprite_grouping  = 8     # (Integer)       Account for extra pixels on the sides of sprites
  args.state.rotation         = -45   # (Integer Angle) Isometric View Angle

  # TODO Hardcode these values - Grab some reference numbers from the kenney assets
  args.state.spritebox ||= args.gtk.calcspritebox "sprites/kenney/isometric_tiles_base/landscape_tiles_067.png"
  args.state.sprite_width ||= args.state.spritebox.x
  args.state.sprite_height ||= args.state.spritebox.y

  # Determine a universal spacing for all sprites.
  args.state.sprite_spacing = (args.state.sprite_height - args.state.sprite_grouping) * args.state.sprite_scale
  args.state.horizontal_scale = args.state.sprite_width * args.state.sprite_scale

  args.outputs.background_color = [29, 32, 43]

  # Create an array of arrays, for a grid of zeroes
  grid_size = 10
  args.state.matrix ||= grid_size.map { |i| 
    grid_size.map { |i|
      building = randr(0,9)
      if building == 9
        skin = randr(0,3)
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
          "sprites/kenney/isometric_tiles_city/city_tiles_066.png"
        end
      else
        "sprites/kenney/isometric_tiles_city/city_tiles_066.png"
      end
    }
  }

  # Iterate through every row
rows = args.state.matrix.length
  rows = 1
  
  while rows <= args.state.matrix.length
    current_row = args.state.matrix[rows-1]
      columns = current_row.length

      while columns > 0

        reference_x = (rows * args.state.sprite_spacing)
        reference_y = ((columns - 1) * args.state.sprite_spacing)
        path = args.state.matrix[rows-1][columns-1]
        height = args.gtk.calcspritebox(path).y

        x_rotation = ((reference_x * Math.cos(args.state.rotation.to_radians)) - (reference_y * Math.sin(args.state.rotation.to_radians)))
        y_rotation = ((reference_x * Math.sin(args.state.rotation.to_radians)) + (reference_y * Math.cos(args.state.rotation.to_radians)))
        args.outputs.sprites << { 
          x:  x_rotation, 
          y:  (y_rotation * args.state.iso_scale ) + (720 / 2), 
          anchor_x: 0.5,
          anchor_y: 0,
          w: args.state.horizontal_scale,
          h: height,
          path: path,
          angle_anchor_x: 0.5,
          angle_anchor_y: 0.5,
          primitive_marker: :solid }
        
        columns = columns - 1
    end

    rows = rows + 1
  end
end