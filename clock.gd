class_name Clock
extends RigidBody2D

enum StartTimeMode{ 
	SYSTEM_TIME,
	RANDOM_TIME,
	FIXED_TIME,
	OFFSET_TIME
}
const TIME_SCALE_MIN := -10.0
const TIME_SCALE_MAX := 10.0
const SCALE_MIN := 0.25
const SCALE_MAX := 1.0

## Speed at which clock runs relative to normal
@export_range(0.0, 5.0, 0.1, "or_greater", "or_less") var time_scale := 1.0
## Manually set start time
@export var start_time := StartTimeMode.SYSTEM_TIME:
	set(mode):
		start_time = mode
		notify_property_list_changed()
		
@export_group("Fixed or Offset Start Time")
@export_range(0,59) var start_second := 0
@export_range(0,59) var start_minute := 0
@export_range(-11,11) var start_hour := 0

@export_group("Nodes")
@export var collision_shape: CollisionShape2D
@export var visualization: Node2D
@export_subgroup("Arms")
@export var second_arm: Node2D
@export var minute_arm: Node2D
@export var hour_arm: Node2D

var seconds := 0.0

# override
func _ready() -> void:
	match start_time:
		StartTimeMode.RANDOM_TIME:
			seconds = randf_range(0.0, 43200.0) # rand up to 12 hours
			
		StartTimeMode.SYSTEM_TIME:
			seconds = currentTimeInSec()
			
		StartTimeMode.FIXED_TIME:
			seconds = toSeconds(start_second, start_minute, start_hour)
			
		StartTimeMode.OFFSET_TIME:
			seconds = currentTimeInSec() + toSeconds(start_second, start_minute, start_hour)

func _process(delta: float) -> void:
	seconds += delta * time_scale
	var s := fmod(seconds, 60.0) / 60
	second_arm.rotation = s * TAU
	minute_arm.rotation = fmod((seconds / 60.0), 60.0) * TAU / 60
	hour_arm.rotation = fmod((seconds / 3600.0), 12.0) * TAU / 12
	visualization.self_modulate = Color.from_hsv(
		s,
		0.25,
		1.0
	)

func _validate_property(property: Dictionary):
	# disable unneeded properties when SYSTEM_TIME or RANDOM_TIME
	if property.name in ["start_second", "start_minute", "start_hour"] and start_time in [StartTimeMode.SYSTEM_TIME, StartTimeMode.RANDOM_TIME]:
		property.usage = PROPERTY_USAGE_NO_EDITOR

# helpers
func toSeconds(sec: int, minute: int, hour: int) -> float:
	return float( sec + minute * 60 + hour * 3600) 
	
func currentTimeInSec() -> float:
	var current_time:= Time.get_datetime_dict_from_system()
	return toSeconds(current_time.second, current_time.minute, current_time.hour)

func setUniformScale(scale_factor: float) -> void:
	var scale_vector = Vector2(scale_factor, scale_factor)
	collision_shape.scale = scale_vector
	visualization.scale = scale_vector
	mass = pow(scale_factor, 2) # mass is quadratic bc 2D
