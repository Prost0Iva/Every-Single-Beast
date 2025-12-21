extends Node2D

#Динамические данные мира
var world_data: Dictionary = {
	"chunk_size": 16,
	"world_freq": .001,
	"world_seed": null,
	"Chunks": {},
	"Player": {
		"Position": [0, 0]
 }
}

#ID Биомов:
#0 - Ocean
#1 - Plains
#3 - Сoast
#5 - Beach
#6 - Taiga
#8 - SnowyWasteland
#10 - Desert
@onready var biome_tile_map: TileMapLayer = $BiomeTileMap
#Объедки:
var oak_tree = "res://gameplay/object/ambient/oak_tree.tscn"

#Параметры генерации
var chunk_size: int
var world_seed: int

#Инструменты
var noise = FastNoiseLite.new()
var rng = RandomNumberGenerator.new()
var thread: Thread

func _ready():
	#Загружаем данные мира, если были сохранены ранее
	load_world()
	#Задаём нужные параметры
	$"../Player".position = Vector2(world_data["Player"]["Position"][0], world_data["Player"]["Position"][1])
	noise.frequency = world_data["world_freq"]
	chunk_size = world_data["chunk_size"]
	if world_data["world_seed"]:
		world_seed = world_data["world_seed"]
		#print("сид из сейва")
	#Генерируем сид, если не задан пользовательский
	if not world_seed:
		world_seed = rng.randi()
		world_data["world_seed"] = world_seed
		#print("сид рандомны")

var last_player_chunk_pos: Vector2i = Vector2i(7, 7)
func _physics_process(_delta: float):
	var player_pos = $"../Player".position
	world_data["Player"]["Position"][0] = player_pos.x
	world_data["Player"]["Position"][1] = player_pos.y
	var player_tile_pos = pos_convert(player_pos, "Def", "Tile")
	var player_chunk_pos = pos_convert(player_pos, "Def", "Chunk")
	
	if player_chunk_pos != last_player_chunk_pos:
		get_render_chunks_pos(player_chunk_pos)
		last_player_chunk_pos = player_chunk_pos
	
	#print("Координаты игрока: ", player_pos, "\n",\
	#"Координаты клетки: ", player_tile_pos, "\n",\
	#"Координаты чанка: ", player_chunk_pos)

var chunks_in_render_dist: Dictionary = {}
func get_render_chunks_pos(pos: Vector2i):
	var start = Vector2i(pos.x - Settings.render_distance, pos.y - Settings.render_distance)
	var end = Vector2i(pos.x + Settings.render_distance, pos.y + Settings.render_distance)
	var chunks_to_render: Array = []
	var chunks_to_unrender: Array = []
	
	for x in range(start.x, end.x + 1):
		for y in range(start.y, end.y + 1):
			var chunk = Vector2i(x, y)
			if chunk not in chunks_in_render_dist:
				chunks_to_render.append(chunk)
			chunks_in_render_dist[chunk] = true
	
	for i in chunks_in_render_dist.keys():
		if !chunks_in_render_dist[i]:
			chunks_to_unrender.append(i)
		else:
			chunks_in_render_dist[i] = false
	await render_chunks(chunks_to_render, chunks_to_unrender)

func render_chunks(to_set: Array, to_remove: Array):
	for i in to_set:
		set_chunk(i)
		await get_tree().process_frame
	for i in to_remove:
		remove_chunk(i)
		chunks_in_render_dist.erase(i)
		await get_tree().process_frame

func between(value: float, start: float, end: float):
	return value >= start and value < end

func pos_convert(pos: Vector2, from: String, to: String):
	match from:
		"Def":
			match to:
				"Tile":
					return biome_tile_map.local_to_map(pos)
				"Chunk":
					var tile_pos = biome_tile_map.local_to_map(pos)
					var chunk_pos = Vector2i(tile_pos / chunk_size)
					if tile_pos.x < 0 and tile_pos.y >= 0:
						chunk_pos.x -= 1
						return chunk_pos
					if tile_pos.x >= 0 and tile_pos.y < 0:
						chunk_pos.y -= 1
						return chunk_pos
					if tile_pos.x < 0 and tile_pos.y < 0:
						chunk_pos.x -= 1
						chunk_pos.y -= 1
						return chunk_pos
					else: return chunk_pos
		"Tile":
			match to:
				"Def":
					return biome_tile_map.map_to_local(pos)
				"Chunk":
					return Vector2i(pos / chunk_size)
		"Chunk":
			match to:
				"Tile":
					return Vector2i(pos * chunk_size)
				"Def":
					return biome_tile_map.map_to_local(pos * chunk_size)

func set_chunk(chunk_pos: Vector2i):
	var start = pos_convert(chunk_pos, "Chunk", "Tile")
	var end = Vector2i(start.x + chunk_size, start.y + chunk_size)
	if thread == null or not thread.is_alive():
		thread = Thread.new()
		var call_func = Callable(self, "get_chunk_data")
		call_func = call_func.bind(start, end, chunk_pos)
		thread.start(call_func)
		thread.wait_to_finish()

func get_chunk_data(start: Vector2i, end: Vector2i, chunk_pos: Vector2i):
	var str_chp = str(chunk_pos)
	
	if str_chp not in world_data.get("Chunks"):
		var temp_seed: int
		var mois_seed: int
		temp_seed = world_seed + 1
		mois_seed = world_seed - 1
		world_data["Chunks"][str_chp] = { "Tiles": [], "Objects": {}, "Entities": {} }
		for x in range(start.x, end.x):
			for y in range(start.y, end.y):
				noise.seed = world_seed
				var height = 2 * abs(noise.get_noise_2d(x, y))
				noise.seed = temp_seed
				var temp = 2 * abs(noise.get_noise_2d(x, y))
				noise.seed = mois_seed
				var mois = 2 * abs(noise.get_noise_2d(x, y))
				
				var ambient = rng.randf_range(0, 1)
				var cell = str(Vector2i(x, y))
				
				if between(height, 0, .13):
					world_data["Chunks"][str_chp]["Tiles"].append(0)
				elif between(height, .15, .2):
					world_data["Chunks"][str_chp]["Tiles"].append(3)
				elif between(height, .2, .23):
					world_data["Chunks"][str_chp]["Tiles"].append(5)
				elif between(height, .23, 1):
					if between(temp, .4, .8):
						if between(mois, .3, .7):
							world_data["Chunks"][str_chp]["Tiles"].append(1)
							if between(ambient, 0, .008):
								world_data["Chunks"][str_chp]["Objects"][cell] = {"id": oak_tree}
						else: world_data["Chunks"][str_chp]["Tiles"].append(0)
					elif between(temp, .2, .4):
						if between(mois, .2, .7):
							world_data["Chunks"][str_chp]["Tiles"].append(6)
						else: world_data["Chunks"][str_chp]["Tiles"].append(0)
					elif between(temp, 0, .2):
						if between(mois, .7, 1):
							world_data["Chunks"][str_chp]["Tiles"].append(8)
						else: world_data["Chunks"][str_chp]["Tiles"].append(0)
					elif between(temp, .8, 1):
						if between(mois, 0, .3):
							world_data["Chunks"][str_chp]["Tiles"].append(10)
						else: world_data["Chunks"][str_chp]["Tiles"].append(0)
					else: world_data["Chunks"][str_chp]["Tiles"].append(0)
				else: world_data["Chunks"][str_chp]["Tiles"].append(0)
	call_deferred("place_chunk", start, end, chunk_pos)

func place_chunk(start: Vector2i, end: Vector2i, chunk_pos: Vector2i):
	var i: int = 0
	var str_chp = str(chunk_pos)
	
	for x in range(start.x, end.x):
		for y in range(start.y, end.y):
			var cell = Vector2i(x, y)
			var str_cell = str(cell)
			var tile_id = world_data["Chunks"][str_chp]["Tiles"][i]
			if str_cell in world_data["Chunks"][str_chp]["Objects"]:
				world_data["Chunks"][str_chp]["Objects"][str_cell]["scene"] = load(world_data["Chunks"][str_chp]["Objects"][str_cell]["id"]).instantiate()
				world_data["Chunks"][str_chp]["Objects"][str_cell]["scene"].position = pos_convert(cell, "Tile", "Def")
				add_child(world_data["Chunks"][str_chp]["Objects"][str_cell]["scene"])
			biome_tile_map.set_cell(cell, tile_id, Vector2i(0, tile_id))
			i += 1
			if i % 64 == 0:
				await get_tree().process_frame

func remove_chunk(chunk_pos: Vector2i):
	var start = pos_convert(chunk_pos, "Chunk", "Tile")
	var end = Vector2i(start.x + chunk_size, start.y + chunk_size)
	var i: int = 0
	for x in range(start.x, end.x):
		for y in range(start.y, end.y):
			var cell = Vector2i(x, y)
			var str_cell = str(cell)
			var str_chp = str(chunk_pos)
			biome_tile_map.erase_cell(cell)
			if str_cell in world_data["Chunks"][str_chp]["Objects"] and world_data["Chunks"][str_chp]["Objects"][str_cell]["scene"] != null:
				world_data["Chunks"][str_chp]["Objects"][str_cell]["scene"].queue_free()
			i += 1
			if i % 64 == 0:
				await get_tree().process_frame

func _exit_tree():
	save_world()

func load_world():
	if not FileAccess.file_exists("user://save_1.save"):
		return
	
	var save_file = FileAccess.open("user://save_1.save", FileAccess.READ)
	var json_string = save_file.get_line()

	var json = JSON.new()
	var error = json.parse(json_string)
	if error != OK:
		return

	world_data = json.get_data()

func save_world():
	#print("Мир сохранён")
	var save_file = FileAccess.open("user://save_1.save", FileAccess.WRITE)
	var json_string = JSON.stringify(world_data)
	save_file.store_line(json_string)
