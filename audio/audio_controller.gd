extends Node2D

@export var mute: bool = false

@onready var music_main := $Music  # Nhạc menu Main
@onready var music_special := $MusicSpecial  # Nhạc menu Special
@onready var music_level_special := $MusicLevelSpecial  # Nhạc trong level Special

func _ready():
	# Bật loop cho tất cả nhạc
	_enable_loop(music_main)
	_enable_loop(music_special)
	_enable_loop(music_level_special)

func _enable_loop(audio_player: AudioStreamPlayer):
	"""Bật loop cho AudioStreamPlayer, tự động detect loại stream"""
	if not audio_player or not audio_player.stream:
		return
	
	var stream = audio_player.stream
	
	# Check loại stream và set loop theo đúng cách
	if stream is AudioStreamMP3:
		stream.loop = true
	elif stream is AudioStreamOggVorbis:
		stream.loop = true
	elif stream is AudioStreamWAV:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD


# Phát nhạc nền

func stop_all_music():
	music_main.stop()
	music_special.stop()
	music_level_special.stop()

func play_main_music():
	if mute: return
	stop_all_music()
	music_main.play()

func play_special_music():
	if mute: return
	stop_all_music()
	music_special.play()

func play_level_special_music():
	"""Phát nhạc khi vào level Special (1-10)"""
	if mute: return
	stop_all_music()
	music_level_special.play()

# Phát âm thanh khi nhảy
func play_jump() -> void:
	if not mute:	
		$Jump.play()
# âm thanh khi ngã 
func play_fall() -> void:
	if not mute:
		$fall.play()
# Phát âm thanh bước chân (loop khi chạy)
func play_walk() -> void:
	if not mute and not $Walk.playing:
		$Walk.play()

# Dừng âm thanh bước chân
func stop_walk() -> void:
	if $Walk.playing:
		$Walk.stop()

# Phát âm thanh khi lên level
func play_level_up() -> void:
	if not mute:
		$LevelUp.play()

func play_checkpoint() -> void:
	if not mute:
		$checkpoint.play()

func play_respawn() -> void:
	if not mute:	
		$Respawn.play()

# Phát âm thanh click
func play_click() -> void:
	if not mute:
		$Click.play()

# Kết thúc màn chơi (dừng nhạc, phát end game)
func play_end_level() -> void:
	if not mute:
		$Music.stop()
		$EndLevel.play()

# Dừng tất cả âm thanh
func stop_all() -> void:
	$Music.stop()
	$Jump.stop()
	$Click.stop()
	$EndLevel.stop()
	
func stop_music() -> void:
	if $Music.playing:
		$Music.stop()
