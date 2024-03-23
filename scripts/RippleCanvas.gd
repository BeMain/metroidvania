extends ColorRect

## The number of grid points in the simulation
## TODO: Don't require this to have the same ratio as the screen
@export var grid_points: Vector2i = Vector2i(192, 108): set = set_grid_points
## The size of the additional area, outside of the screen, where ripples are simulated. In world coordinates.
@export var simulation_margin: Vector2 = Vector2(288, 162)
## The size of the area where ripples are simulated. In world coordinates.
var grid_size: Vector2 :
	get:
		return 2 * simulation_margin + Vector2(ProjectSettings.get("display/window/size/viewport_width"), ProjectSettings.get("display/window/size/viewport_height"))
## The propagation speed of the waves
@export var wave_speed = 0.065
## Amplitude of newly created waves in the simulation
@export var initial_amplitude = 0.5
## Amplitude of the waves displayed on the canvas
@export var mesh_amplitude = 0.5
## Texture for the land mass
@export var land_texture : Texture = ImageTexture.create_from_image(Image.create(1, 1, false, Image.FORMAT_RGB8))

## Viewport that contains the simulation texture
@onready var simulation_viewport: SubViewport = $SimulationViewport
## Material that contains the simulation shader
@onready var simulation_material: ShaderMaterial = simulation_viewport.get_node("ColorRect").material
## Material of the surface, where ripples are displayed
@onready var surface_material: ShaderMaterial = material

## Current height map of the surface as raw byte array
var surface_data = PackedByteArray()

## Viewport texture that contains the rendered height
var simulation_texture: ViewportTexture
## The collision map
var collision_image: Image


func _ready():
	simulation_viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
	
	# Set simulation and collision textures from viewports
	simulation_texture = simulation_viewport.get_texture()
	
	get_tree().get_root().size_changed.connect(_on_window_size_changed)
	_on_window_size_changed()
	
	set_grid_points(grid_points)
	
	# Set uniforms of mesh shader
	surface_material.set_shader_parameter("simulation_texture", simulation_texture)
	surface_material.set_shader_parameter("simulation_texture_margin", simulation_margin / grid_size)
	surface_material.set_shader_parameter("amplitude", mesh_amplitude)


func _initialize():
	# Create an empty texture
	var img = Image.create(grid_points.x, grid_points.y, false, Image.FORMAT_RGB8)
	var tex = ImageTexture.create_from_image(img)
	
	collision_image = img.duplicate(true)

	# Initialize the simulation with the empty texture
	simulation_material.set_shader_parameter("z_tex", tex)
	simulation_material.set_shader_parameter("old_z_tex", tex.duplicate(true))
	simulation_material.set_shader_parameter("collision_texture", tex.duplicate(true))
	simulation_material.set_shader_parameter("old_collision_texture", tex.duplicate(true))
	simulation_material.set_shader_parameter("land_texture", land_texture)

	# Set simulation parameters
	var delta = 1.0 / ProjectSettings.get_setting("physics/common/physics_ticks_per_second")
	var a = wave_speed*wave_speed * delta*delta * grid_points.x * grid_points.y
	if a > 0.5:
		push_error("Sound ripples: a > 0.5; Unstable simulation.")
	simulation_material.set_shader_parameter("a", a)
	simulation_material.set_shader_parameter("amplitude", initial_amplitude)
	
	# Render one frame of the simulation viewport to make sure the simulation has been reset properly
	lock = true
	simulation_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	# Wait until the frame is rendered, then unlock
	await get_tree().process_frame
	lock = false

## The origin of the canvas during the last frame. Used to detect when the origin changes.
var previous_canvas_origin := Vector2(0,0)
func _physics_process(_delta):
	_update()
	surface_data = simulation_texture.get_image().get_data()
	
	var canvas_origin := get_viewport().canvas_transform.origin
	if (canvas_origin != previous_canvas_origin):
		_on_canvas_origin_changed(canvas_origin)
		previous_canvas_origin = canvas_origin

var lock = false
func _update():
	if not lock:
		lock = true
		update_collision_map()
		update_height_map()
		
		# Render one frame of the simulation viewport to update the simulation
		simulation_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE

		# Wait until the frame is rendered, then unlock
		await get_tree().process_frame
		lock = false

func set_grid_points(p_grid_points):
	grid_points = p_grid_points
	if is_inside_tree():
		# Set viewport sizes to simulation grid size
		simulation_viewport.size = grid_points
		simulation_viewport.get_node("ColorRect").get_rect().size = Vector2(grid_points)
		simulation_material.set_shader_parameter("grid_points", grid_points)
		_initialize()


## Update the collision texture
func update_collision_map():
	# Set current map as old map
	var old_collision_texture = simulation_material.get_shader_parameter("collision_texture")
	simulation_material.get_shader_parameter("old_collision_texture").set_image(old_collision_texture.get_image())
	simulation_material.get_shader_parameter("collision_texture").set_image(collision_image) # Set the current collision map from current render
	
	# Clear the collision map
	collision_image.fill(Color(0.0, 0.0, 0.0))

## Update the simulation texture
func update_height_map():
	var img = simulation_texture.get_image() # Get currently rendered map
	# Set current map as old map
	var old_height_map = simulation_material.get_shader_parameter("z_tex")
	simulation_material.get_shader_parameter("old_z_tex").set_image(old_height_map.get_image())
	simulation_material.get_shader_parameter("z_tex").set_image(img) # Set the current height map from current render


## Because we can only shift the height maps an integer number of pixels, we lose a lot of precision.
## This variable tracks the fraction of a pixel that was lost due to truncation during the last shift,
## so that we can interpolate and thus avoid "losing" those pixels.
var d_pixels_excess := Vector2(0,0)

## Move the ripple canvas and shift the height maps
## Called when the canvas moves
func _on_canvas_origin_changed(new_origin: Vector2):
	# Move the canvas
	global_position = -new_origin
	
	# Shift the height maps
	var d_origin := new_origin - previous_canvas_origin
	# I don't know why we multiply by 0.5 here... But it works :)
	var d_pixels = 0.5 * d_origin * Vector2(grid_points) / grid_size + d_pixels_excess # Add the fraction of a pixel that was truncated during the last shift
	d_pixels_excess = d_pixels - Vector2(Vector2i(d_pixels)) # Store the fraction of the pixel that we lost this shift due to truncation, so that we can add it the next shift
	
	var z_tex = simulation_material.get_shader_parameter("z_tex")
	z_tex.set_image(shift_image(z_tex.get_image(), d_pixels))
	var old_z_tex = simulation_material.get_shader_parameter("old_z_tex")
	old_z_tex.set_image(shift_image(old_z_tex.get_image(), d_pixels))


## Shift all pixels of an image a number of [steps]
func shift_image(img: Image, steps: Vector2i) -> Image:
	var new_img: Image = img.duplicate(true)
	new_img.fill(Color(0,0,0,1))
	new_img.blit_rect(img, Rect2i(-steps, img.get_size() - steps), steps)
	return new_img


## Update the size of the ripple canvas
## Called when the size of the window changes
func _on_window_size_changed():
	if is_inside_tree():
		size = get_tree().get_root().get_visible_rect().size
