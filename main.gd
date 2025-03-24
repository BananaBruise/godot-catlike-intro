extends Node2D

## Clock to be spawned
@export var clock_scene: PackedScene

## Clock radius in pixels
@export var clock_radius:= 128.0

@export_group("Nodes")
@export var bottom: Node2D
@export var ground: Node2D

var _window_width: float

# override
func _ready() -> void:
	get_window().size_changed.connect(_on_size_changed)
	_on_size_changed()
	
func _on_size_changed() -> void:
	var window_size = get_window().size
	_window_width = window_size.x
	
	# init bottom boundary
	bottom.position.y = window_size.y + 2 * clock_radius # delete when clock is fully off screen

	# init ground physics boundary
	ground.position = Vector2(
		0.5 * _window_width,
		window_size.y + 0.5 * clock_radius
	)
	ground.scale = Vector2(_window_width, clock_radius)
	
func _on_bottom_body_entered(body: Node2D) -> void:
	body.queue_free()

func _on_spawn_timer_timeout() -> void:
	var clock := clock_scene.instantiate() as Clock
	clock.start_time = Clock.StartTimeMode.RANDOM_TIME
	clock.time_scale = randf_range(Clock.TIME_SCALE_MIN, Clock.TIME_SCALE_MAX)
	clock.setUniformScale(randf_range(Clock.SCALE_MIN, Clock.SCALE_MAX))
	
	# init clock
	var window_size = get_window().size
	clock.position = Vector2(
		randf_range(clock_radius, _window_width - clock_radius), 
		-3 * clock_radius # start off screen
	)
	add_child(clock)
