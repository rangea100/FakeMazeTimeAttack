extends Node
#システム設定
var fullscreen_mode:bool = true
var resoltion_nomber:int = 0
var map_rotaition:bool = false
var sensitivity:float = 0.5
var audio:Array = [true,true,true,true]
var volume:Array = [1.0,0.5,0.5,0.5]
var player_name:String
var develoer_mode:bool = false
var graphics:int = 1
var collision_miss = false

#難易度設定
var map_size:int =21
var item_can_use:bool = true
var trap_installation:bool = true
var dark_mode:bool = false
var regulation:Array
var map_save:bool = false
#ロード
var map:Array
var saved_map:Array
var load_map_size:int
var load_item_can_use:bool = true
var load_trap_installation:bool = true
var load_dark_mode:bool = false
#フィルター設定
var filter_setting:Array = [[false,false],[false,false],[false,false]]
var filter:bool = false
var name_filter:String

#描画設定
var current_env: Environment = null
var preset: GraphicsPreset
func set_preset(path: String) -> void:
	var res = load(path)
	if res == null:
		push_error("プリセットがロードできません: " + path)
		return
	preset = res
func register_env(env: Environment):
	if env == null:
		push_error("register_env: Environment が null です")
		return
	current_env = env
	print("Environment registered:", current_env)
func apply_preset_safe(preset):
	if current_env == null:
		push_error("Environment がまだ登録されていません")
		return
	call_deferred("apply_preset", preset)
func apply_preset(preset: GraphicsPreset):
	print(current_env)
	if current_env == null:
		push_error("apply_preset: Environment が登録されていません")
		return
	if preset == null:
		push_error("apply_preset: present が登録されていません")
		return
	current_env.ssao_enabled = preset.ssao_enabled
	current_env.ssr_enabled = preset.ssr_enabled
	current_env.glow_enabled = preset.glow_enabled
	current_env.volumetric_fog_enabled = preset.volumetric_fog_enabled
	current_env.sdfgi_enabled = preset.sdfgi_enabled
	current_env.volumetric_fog_enabled = true
	current_env.volumetric_fog_albedo = Color(0.23, 0.0, 0.17)
	current_env.volumetric_fog_density = 0.05

	ProjectSettings.set_setting("rendering/anti_aliasing/quality/msaa", preset.msaa)
	ProjectSettings.set_setting("rendering/anti_aliasing/quality/fxaa", preset.fxaa)
	ProjectSettings.set_setting("rendering/anti_aliasing/quality/taa", preset.taa)
	current_env.fog_density = (0.5 if Settings.dark_mode else 0.1)
	current_env.fog_light_color = Color(0.23,0.00,0.17)
	current_env.fog_light_energy = 0.38
	current_env.background_color = Color(0,0,0)
