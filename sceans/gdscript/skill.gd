extends Control
class_name SkillManager
@onready var map_camera: Camera3D = $"../../../player/minimap/Camera3D"
@onready var view_but_bar: TextureProgressBar = $"../view_but_meter/TextureProgressBar"


func _ready() -> void:
	$SkillButton1.visible = false
	$SkillButton2.visible = false
	$SkillButton3.visible = false
# =========================
# キー入力チェック（_process）
# =========================
func _process(_delta):
	for node in get_children():
		# SkillButtonUI 型かチェック
		if node is SkillButtonUI:
			var skill_ui: SkillButtonUI = node
			# skill_data が null の場合はスキップ
			if skill_ui.skill_data == null:
				continue
			# 割り当てられたキーが押されたら発動
			if Input.is_action_just_pressed(skill_ui.skill_data.key):
				activate_skill(skill_ui)





# =========================
# スキル発動処理
# =========================
func activate_skill(skill_ui):
	if skill_ui.disabled or skill_ui.remaining_uses <= 0 or skill_ui.is_active or skill_ui.not_skill:
		return
	
	skill_ui.remaining_uses -= 1
	skill_ui.is_active = true
	skill_ui.update_ui()
	skill_ui.timer_node.start(skill_ui.skill_data.duration)
	
	# 発動時の処理
	match skill_ui.skill_data.name:
		"mapexpansion":
			var tween = create_tween()
			tween.tween_property(map_camera,"size",60,0.25)
			# 攻撃処理やエフェク
		"truemap":
			map_camera.set_cull_mask_value(2,true)
			map_camera.set_cull_mask_value(3,false)
			# 防御バフ処理
		"buttery":
			view_but_bar.value += 45
			# 回復処理
		_:
			print("未定義スキル:", skill_ui.skill_data.name)
	
	# Timer が終わったらスキル終了処理
	# Bind を使ってどのスキルUIか渡す
	skill_ui.timer_node.timeout.connect(_on_skill_timeout.bind(skill_ui))



# =========================
# スキル終了処理（match 文で管理）
# =========================
func _on_skill_timeout(skill_ui):
	skill_ui.is_active = false
	skill_ui.update_ui()
	
	match skill_ui.skill_data.name:
		"mapexpansion":
			var tween2 = create_tween()
			tween2.tween_property(map_camera,"size",20,0.25)
			await tween2.finished
		"truemap":
			map_camera.set_cull_mask_value(3,true)
			map_camera.set_cull_mask_value(2,false)
			# 防御バフ解除
		"buttery":
			pass
			# 継続回復停止
		_:
			print("未定義スキル終了:", skill_ui.skill_data.name)

# 全スキルを有効/無効にする
func set_all_skills_disabled(value: bool) -> void:
	for node in get_children():
		if node is SkillButtonUI:
			node.disabled = value
			node.update_ui()  # 表示も更新

func set_all_skills_notskill(value: bool) -> void:
	for node in get_children():
		if node is SkillButtonUI:
			node.not_skill = value
			node.update_ui()  # 表示も更新
