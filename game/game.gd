# Copyright © 2018 Hugo Locurcio and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends Node

signal bricks_changed
signal goals_changed
signal time_limit_changed
signal time_left_changed

# Level holder
var level: Node

# The number of destroyable bricks left (used to check if the "bricks" goal was completed)
var bricks_left := 0 setget set_bricks_left

# Goal information
# Key is the description, value is the number of balls left
var goals := {} setget set_goals

onready var level_timer := $LevelTimer as Timer

func _ready() -> void:
	randomize()
	change_level("1")

func _process(delta: float) -> void:
	emit_signal("time_left_changed", level_timer.time_left)

# Changes to a new level and initializes data displayed by the HUD.
func change_level(level_name: String) -> void:
	if level:
		level.queue_free()

	level = load("res://levels/" + level_name + ".tscn").instance()
	add_child(level)

	level_timer.wait_time = level.time_limit
	emit_signal("time_limit_changed", level.time_limit)
	level_timer.start()

	self.bricks_left = level.get_tree().get_nodes_in_group("brick").size()
	self.goals = {}

	for goal in level.get_tree().get_nodes_in_group("goal"):
		self.goals[goal.description] = goal.balls_required

# Checks whether the player is allowed to exit and changes the level if they are.
func _on_exit_requested() -> void:
	if bricks_left > 0:
		return

	# Check if all goals have been completed
	for goal in goals:
		if goals[goal] > 0:
			return

	# Player is allowed to exit, change level
	# TODO

func _on_brick_destroyed() -> void:
	self.bricks_left -= 1

func _on_goal_ball_received(goal: Goal) -> void:
	self.goals[goal.description] = goal.balls_required

func set_bricks_left(bricks: int) -> void:
	bricks_left = bricks
	emit_signal("bricks_changed", bricks)

func set_goals(goals_: Dictionary) -> void:
	goals = goals_
	emit_signal("goals_changed", goals)
