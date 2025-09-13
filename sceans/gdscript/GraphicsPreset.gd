extends Resource
class_name GraphicsPreset

@export var name: String = "Default"
@export var ssao_enabled: bool = true
@export var ssr_enabled: bool = false
@export var glow_enabled: bool = true
@export var volumetric_fog_enabled: bool = false
@export var sdfgi_enabled: bool = false

@export_enum("None", "2x", "4x", "8x") var msaa: int = 0
@export var fxaa: bool = false
@export var taa: bool = false
