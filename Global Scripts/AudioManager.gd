extends Node
## AudioManager.gd — global audio singleton.
##
## Handles one-shot 2D (non-positional) and 3D (positional) sounds with
## random pitch variance, plus simple crossfaded music/ambience.
## Uses small pools of pre-instanced players instead of creating a new
## node per sound, so short/frequent SFX (glitch stingers, UI clicks,
## vent hiss) don't churn the scene tree.
##
## SETUP:
## Project Settings > Autoload > add this script, name it "AudioManager".
## Make sure the bus names below exist in Project Settings > Audio > Buses
## (or edit the constants to match your bus layout).

# ---------------------------------------------------------------------------
# CONFIG
# ---------------------------------------------------------------------------

const BUS_MASTER := "Master"
const BUS_SFX := "SFX"
const BUS_MUSIC := "Music"
const BUS_VOICE := "Voice"  # e.g. Handler phone calls

## Starting size of each pool. Pools grow automatically if exhausted,
## so this is a "warm start" size, not a hard cap.
const POOL_SIZE_2D := 8
const POOL_SIZE_3D := 8

## Default random pitch variance applied when a call doesn't specify one.
## pitch_scale ends up in [base - variance, base + variance].
const DEFAULT_PITCH_VARIANCE := 0.05

var _pool_2d: Array[AudioStreamPlayer] = []
var _pool_3d: Array[AudioStreamPlayer3D] = []

var _music_player_a: AudioStreamPlayer
var _music_player_b: AudioStreamPlayer
var _active_music_player: AudioStreamPlayer
var _music_tween: Tween


func _ready() -> void:
	_build_pools()
	_build_music_players()


# ---------------------------------------------------------------------------
# POOL SETUP
# ---------------------------------------------------------------------------

func _build_pools() -> void:
	for i in POOL_SIZE_2D:
		var p := AudioStreamPlayer.new()
		p.bus = BUS_SFX
		add_child(p)
		_pool_2d.append(p)

	for i in POOL_SIZE_3D:
		var p3 := AudioStreamPlayer3D.new()
		p3.bus = BUS_SFX
		add_child(p3)
		_pool_3d.append(p3)


func _build_music_players() -> void:
	_music_player_a = AudioStreamPlayer.new()
	_music_player_a.bus = BUS_MUSIC
	add_child(_music_player_a)

	_music_player_b = AudioStreamPlayer.new()
	_music_player_b.bus = BUS_MUSIC
	_music_player_b.volume_db = -80.0
	add_child(_music_player_b)

	_active_music_player = _music_player_a


func _get_free_2d_player() -> AudioStreamPlayer:
	for p in _pool_2d:
		if not p.playing:
			return p
	# Pool exhausted: grow rather than cut off a sound that's still playing.
	var p := AudioStreamPlayer.new()
	p.bus = BUS_SFX
	add_child(p)
	_pool_2d.append(p)
	return p


func _get_free_3d_player() -> AudioStreamPlayer3D:
	for p in _pool_3d:
		if not p.playing:
			return p
	var p := AudioStreamPlayer3D.new()
	p.bus = BUS_SFX
	add_child(p)
	_pool_3d.append(p)
	return p


func _random_pitch(base_pitch: float, variance: float) -> float:
	if variance <= 0.0:
		return base_pitch
	return base_pitch + randf_range(-variance, variance)


# ---------------------------------------------------------------------------
# PUBLIC API — ONE-SHOT SOUNDS
# ---------------------------------------------------------------------------

## Plays a non-positional sound (UI clicks, phone ring, Handler voice,
## glitch stingers). Returns the player in case the caller wants to track
## or stop it manually.
func play_sound(
	stream: AudioStream,
	bus: String = BUS_SFX,
	volume_db: float = 0.0,
	pitch_scale: float = 1.0,
	pitch_variance: float = DEFAULT_PITCH_VARIANCE
) -> AudioStreamPlayer:
	if stream == null:
		push_warning("AudioManager.play_sound called with a null stream.")
		return null

	var player := _get_free_2d_player()
	player.stream = stream
	player.bus = bus
	player.volume_db = volume_db
	player.pitch_scale = _random_pitch(pitch_scale, pitch_variance)
	player.play()
	return player


## Plays a positional 3D sound at a world position (vent rattle, machinery
## hum, footsteps).
func play_sound_3d(
	stream: AudioStream,
	world_position: Vector3,
	bus: String = BUS_SFX,
	volume_db: float = 0.0,
	pitch_scale: float = 1.0,
	pitch_variance: float = DEFAULT_PITCH_VARIANCE,
	max_distance: float = 20.0
) -> AudioStreamPlayer3D:
	if stream == null:
		push_warning("AudioManager.play_sound_3d called with a null stream.")
		return null

	var player := _get_free_3d_player()
	player.stream = stream
	player.bus = bus
	player.global_position = world_position
	player.volume_db = volume_db
	player.pitch_scale = _random_pitch(pitch_scale, pitch_variance)
	player.max_distance = max_distance
	player.play()
	return player


## Convenience wrapper: plays a 3D sound at a node's current position.
## Good for static/near-static emitters (vent, terminal, phone). For a
## sound that must continuously follow a fast-moving object, put a real
## AudioStreamPlayer3D under that object instead of using the pool.
func play_sound_3d_at_node(
	stream: AudioStream,
	node: Node3D,
	bus: String = BUS_SFX,
	volume_db: float = 0.0,
	pitch_scale: float = 1.0,
	pitch_variance: float = DEFAULT_PITCH_VARIANCE,
	max_distance: float = 20.0
) -> AudioStreamPlayer3D:
	if node == null:
		push_warning("AudioManager.play_sound_3d_at_node called with a null node.")
		return null
	return play_sound_3d(stream, node.global_position, bus, volume_db, pitch_scale, pitch_variance, max_distance)


## Picks a random stream from an array before playing it 2D — useful for
## footstep/impact variation sets so the same sample doesn't repeat back
## to back.
func play_random_sound(
	streams: Array[AudioStream],
	bus: String = BUS_SFX,
	volume_db: float = 0.0,
	pitch_scale: float = 1.0,
	pitch_variance: float = DEFAULT_PITCH_VARIANCE
) -> AudioStreamPlayer:
	if streams.is_empty():
		push_warning("AudioManager.play_random_sound called with an empty array.")
		return null
	return play_sound(streams[randi() % streams.size()], bus, volume_db, pitch_scale, pitch_variance)


## 3D version of play_random_sound.
func play_random_sound_3d(
	streams: Array[AudioStream],
	world_position: Vector3,
	bus: String = BUS_SFX,
	volume_db: float = 0.0,
	pitch_scale: float = 1.0,
	pitch_variance: float = DEFAULT_PITCH_VARIANCE,
	max_distance: float = 20.0
) -> AudioStreamPlayer3D:
	if streams.is_empty():
		push_warning("AudioManager.play_random_sound_3d called with an empty array.")
		return null
	return play_sound_3d(streams[randi() % streams.size()], world_position, bus, volume_db, pitch_scale, pitch_variance, max_distance)


# ---------------------------------------------------------------------------
# PUBLIC API — MUSIC / AMBIENCE (crossfade between two decks)
# ---------------------------------------------------------------------------

## Plays looping music/ambience, crossfading out whatever is currently
## playing. Handy for swapping the room's ambient drone when the vent
## gets blocked and the environment shifts.
func play_music(stream: AudioStream, fade_time: float = 1.5, target_volume_db: float = 0.0, loop: bool = true) -> void:
	if stream == null:
		push_warning("AudioManager.play_music called with a null stream.")
		return

	var incoming := _music_player_b if _active_music_player == _music_player_a else _music_player_a
	var outgoing := _active_music_player

	if incoming.stream == stream and incoming.playing:
		return  # already playing this track

	incoming.stream = stream
	incoming.volume_db = -80.0
	incoming.play()

	if _music_tween:
		_music_tween.kill()
	_music_tween = create_tween()
	_music_tween.set_parallel(true)
	_music_tween.tween_property(incoming, "volume_db", target_volume_db, fade_time)
	_music_tween.tween_property(outgoing, "volume_db", -80.0, fade_time)
	_music_tween.set_parallel(false)
	_music_tween.tween_callback(outgoing.stop)

	_active_music_player = incoming


func stop_music(fade_time: float = 1.0) -> void:
	if not _active_music_player.playing:
		return
	if _music_tween:
		_music_tween.kill()
	_music_tween = create_tween()
	_music_tween.tween_property(_active_music_player, "volume_db", -80.0, fade_time)
	_music_tween.tween_callback(_active_music_player.stop)


# ---------------------------------------------------------------------------
# PUBLIC API — BUS CONTROL
# ---------------------------------------------------------------------------

## linear_volume in [0.0, 1.0] — converts to dB internally so callers
## (e.g. an options menu slider) don't have to think in decibels.
func set_bus_volume(bus_name: String, linear_volume: float) -> void:
	var idx := AudioServer.get_bus_index(bus_name)
	if idx == -1:
		push_warning("AudioManager: bus '%s' not found." % bus_name)
		return
	AudioServer.set_bus_volume_db(idx, linear_to_db(clamp(linear_volume, 0.0, 1.0)))


func set_bus_mute(bus_name: String, muted: bool) -> void:
	var idx := AudioServer.get_bus_index(bus_name)
	if idx == -1:
		push_warning("AudioManager: bus '%s' not found." % bus_name)
		return
	AudioServer.set_bus_mute(idx, muted)


## Stops every currently-playing pooled SFX immediately (2D and 3D).
## Music is untouched — use stop_music() for that.
func stop_all_sfx() -> void:
	for p in _pool_2d:
		if p.playing:
			p.stop()
	for p in _pool_3d:
		if p.playing:
			p.stop()
