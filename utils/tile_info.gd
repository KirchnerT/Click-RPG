class_name TileInfo

var ground_tile: String
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

# TODO Add ground tile class with sprite info. Also things like flamable
