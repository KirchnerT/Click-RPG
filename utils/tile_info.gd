class_name TileInfo

var tile_sprite_info: TileSpriteInfo
var biome: Biomes = Biomes.UNKNOWN
var is_walkable: bool = true
var entity: Object
var status_effects: Dictionary = {}  # key: effect name, value: custom data (e.g. duration)

enum Biomes {
	UNKNOWN,
	FOREST,
	MOUNTAIN,
	PLAINS,
	GRASSLANDS,
	WATER
}

class TileSpriteInfo:
	var atlas_coords: Vector2i
	var source_id: int

# TODO Also things like flamable
