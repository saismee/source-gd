extends Node

var uvaxes = {
	x = UVAxis.new(0, 1, 0, 0, 0.25, 0, 0, 1, 0, 0.25),
	y = UVAxis.new(1, 0, 0, 0, 0.25, 0, 0, 1, 0, 0.25),
	z = UVAxis.new(1, 0, 0, 0, 0.25, 0, 1, 0, 0, 0.25),
}

func to_kv_string(root: VMF, key: String, dict: Variant) -> String:
	var out = VString.new([
		key,
		"{"
	])
	
	for index in (dict if dict is Dictionary else dict.size()):
		if dict[index] is bool:
			out.append('	"' + str(index) + ('" "1"' if dict[index] else '" "0"'))
		elif (dict[index] is Array) or (dict[index] is Dictionary):
			out.append(to_kv_string(root, index, dict[index]))
		elif dict[index] is VBase:
			#out.append('	"' + str(index) + '" "' + dict[index].collapse(root) + '"')
			out.append(dict[index].collapse(root))
		else:
			out.append('	"' + str(index) + '" "' + str(dict[index]) + '"')
	out.append("}")
	return out.collapse()

# classes
class VString:
	var text: PackedStringArray
	func _init(text: Array) -> void:
		self.text = PackedStringArray(text)
	
	func append(text: String) -> void:
		self.text.append(text)
	
	func collapse() -> String:
		return "\n".join(self.text)

class VMF:
	var versioninfo: Dictionary
	var visgroups: Array
	var world: Dictionary
	var entities: VArray
	
	var ent_count: int
	
	func _init() -> void:
		self.ent_count = 0
		self.versioninfo = {
			"editorversion": 0,
			"editorbuild": 0,
			"mapversion": 0,
			"formatversion": 0,
			"prefab": false
		}
		self.visgroups = []
		self.world = {
			"mapversion": 0,
			"classname": "worldspawn",
			"skyname": "",
			"solids": VArray.new()
		}
		self.entities = VArray.new()
	
	func get_uid() -> String:
		ent_count += 1
		return str(ent_count)
	
	func add(entity: BaseEntity) -> void:
		if entity is BaseSolid:
			self.world.solids.append(entity)
		else:
			self.entities.append(entity)
	
	func collapse() -> String:
		var out = VString.new([
			SourceGD.to_kv_string(self, "version_info", self.versioninfo),
			SourceGD.to_kv_string(self, "visgroups", self.visgroups),
			SourceGD.to_kv_string(self, "world", self.world),
			self.entities.collapse(self)
		])
		
		return out.collapse()

class VArray extends VBase:
	var array: Array
	func _init() -> void:
		self.array = []
	
	func append(obj: VBase):
		array.append(obj)
	
	func collapse(root: VMF) -> String:
		var out = VString.new([])
		for index in array.size():
			out.append(array[index].collapse(root))
		return out.collapse()

class VDictionary extends VBase:
	var dict: Dictionary
	func _init() -> void:
		self.dict = {}
	
	func collapse(root: VMF) -> String:
		var out = VString.new([])
		for index in (self.dict):
			if self.dict[index] is bool:
				out.append('	"' + str(index) + ('" "1"' if self.dict[index] else '" "0"'))
			elif (self.dict[index] is Array) or (self.dict[index] is Dictionary):
				out.append(SourceGD.to_kv_string(root, index, self.dict[index]))
			elif self.dict[index] is VBase:
				out.append('"' + str(index) + '" "' + dict[index].collapse(root) + '"')
			else:
				out.append('	"' + str(index) + '" "' + str(self.dict[index]) + '"')
		return out.collapse()
	
	func _set(key: StringName, value: Variant) -> bool:
		self.dict[str(key)] = value
		return true

class VBase:
	func collapse(root: VMF) -> String:
		return ""

class BaseEntity extends VBase:
	var classname: String

class VVector extends VBase:
	var x: float
	var y: float
	var z: float
	var flip: bool
	
	func _init(vec: Vector3 = Vector3.ZERO) -> void:
		self.x = vec.x
		self.y = vec.y
		self.z = vec.z
	
	func collapse(root: VMF) -> String:
		return str(self.z) + " " + str(self.x) + " " + str(self.y)
			# im unsure why swapping x and z works, but it does...

class Vertex extends VVector:
	func collapse(root: VMF) -> String:
		return str(self.x) + " " + str(self.z) + " " + str(self.y)

class Entity extends BaseEntity:
	var flags: Array
	var values: VDictionary
	
	func _init(classname: String, position: Vector3 = Vector3.ZERO, rotation: Vector3 = Vector3.ZERO) -> void:
		self.classname = classname
		self.flags = []
		self.values = VDictionary.new()
		self.values["origin"] = VVector.new(position)
		self.values["angles"] = Vertex.new(rotation) # hacky workaround 😡
	
	func _set(key: StringName, value: Variant) -> bool:
		self.values[str(key)] = value
		return true
	
	func collapse(root: VMF) -> String:
		return VString.new([
			"entity",
			"{",
			'	"id" "' + root.get_uid() + '"',
			'	"classname" "' + self.classname + '"',
			self.values.collapse(root),
			"}"
		]).collapse()

class BaseSolid extends BaseEntity:
	var sides: Array
	func _init(sides: Array) -> void:
		self.sides = sides
	
	func collapse(root: VMF) -> String:
		var out = VString.new([
			'solid',
			'{',
			'	"id" "' + root.get_uid() + '"'
		])
		
		for side in self.sides:
			out.append(side.collapse(root))
		
		out.append("}")
		
		return out.collapse()

class CubeSolid extends BaseSolid:
	func _init(position: Vector3, size: Vector3) -> void:
		position = Vector3(position.z, position.y, position.x)
		var sides = []
		sides.append(Side.new(VPlane.new([
			Vertex.new(Vector3(position.x - size.x/2, position.y + size.y/2, position.z + size.z/2)),
			Vertex.new(Vector3(position.x + size.x/2, position.y + size.y/2, position.z + size.z/2)),
			Vertex.new(Vector3(position.x + size.x/2, position.y + size.y/2, position.z - size.z/2)),
		]), "TILE/WHITE_WALL_TILE003A", SourceGD.uvaxes.z))
		sides.append(Side.new(VPlane.new([
			Vertex.new(Vector3(position.x - size.x/2, position.y - size.y/2, position.z - size.z/2)),
			Vertex.new(Vector3(position.x + size.x/2, position.y - size.y/2, position.z - size.z/2)),
			Vertex.new(Vector3(position.x + size.x/2, position.y - size.y/2, position.z + size.z/2)),
		]), "TILE/WHITE_WALL_TILE003A", SourceGD.uvaxes.z))
		sides.append(Side.new(VPlane.new([
			Vertex.new(Vector3(position.x - size.x/2, position.y + size.y/2, position.z + size.z/2)),
			Vertex.new(Vector3(position.x - size.x/2, position.y + size.y/2, position.z - size.z/2)),
			Vertex.new(Vector3(position.x - size.x/2, position.y - size.y/2, position.z - size.z/2)),
		]), "TILE/WHITE_WALL_TILE003A", SourceGD.uvaxes.x))
		sides.append(Side.new(VPlane.new([
			Vertex.new(Vector3(position.x + size.x/2, position.y - size.y/2, position.z + size.z/2)),
			Vertex.new(Vector3(position.x + size.x/2, position.y - size.y/2, position.z - size.z/2)),
			Vertex.new(Vector3(position.x + size.x/2, position.y + size.y/2, position.z - size.z/2)),
		]), "TILE/WHITE_WALL_TILE003A", SourceGD.uvaxes.x))
		sides.append(Side.new(VPlane.new([
			Vertex.new(Vector3(position.x + size.x/2, position.y + size.y/2, position.z + size.z/2)),
			Vertex.new(Vector3(position.x - size.x/2, position.y + size.y/2, position.z + size.z/2)),
			Vertex.new(Vector3(position.x - size.x/2, position.y - size.y/2, position.z + size.z/2)),
		]), "TILE/WHITE_WALL_TILE003A", SourceGD.uvaxes.y))
		sides.append(Side.new(VPlane.new([
			Vertex.new(Vector3(position.x + size.x/2, position.y - size.y/2, position.z - size.z/2)),
			Vertex.new(Vector3(position.x - size.x/2, position.y - size.y/2, position.z - size.z/2)),
			Vertex.new(Vector3(position.x - size.x/2, position.y + size.y/2, position.z - size.z/2)),
		]), "TILE/WHITE_WALL_TILE003A", SourceGD.uvaxes.y))
		self.sides = sides

class UVAxis:
	var u: String : get = _get_u
	var v: String : get = _get_v
	var uaxis: Dictionary
	var vaxis: Dictionary
	
	func _init(x1: float, y1: float, z1: float, w1: float, scale1: float, x2: float, y2: float, z2: float, w2: float, scale2: float) -> void:
		self.uaxis = {
			x = x1,
			y = y1,
			z = z1,
			w = w1,
			scale = scale1
		}
		self.vaxis = {
			x = x2,
			y = y2,
			z = z2,
			w = w2,
			scale = scale2
		}
	
	func _get_u() -> String:
		return "[" + str(self.uaxis.x) + " " + str(self.uaxis.y) + " " + str(self.uaxis.z) + " " + str(self.uaxis.w) + "] " + str(uaxis.scale)
		
	func _get_v() -> String:
		return "[" + str(self.vaxis.x) + " " + str(self.vaxis.y) + " " + str(self.vaxis.z) + " " + str(self.vaxis.w) + "] " + str(uaxis.scale)


class Side extends BaseEntity:
	var plane: VPlane
	var material: String
	var uvaxis: UVAxis
	var lightmapscale: int
	var smoothing_groups: int
	func _init(plane: VPlane, material: String, uvaxis: UVAxis) -> void:
		self.plane = plane
		self.material = material
		self.lightmapscale = 16
		self.smoothing_groups = 0
		self.uvaxis = uvaxis
	
	func collapse(root: VMF) -> String:
		return VString.new([
			'side',
			'{',
			'	"id" "' + root.get_uid() + '"',
			'	"plane" "' + self.plane.collapse(root) + '"',
			'	"material" "' + self.material.to_upper() + '"',
			#'	"uaxis" "[1 0 0 0] 0.25"',
			#'	"vaxis" "[0 1 0 0] 0.25"',
			'	"uaxis" "' + uvaxis.u + '"',
			'	"vaxis" "' + uvaxis.v + '"',
			'	"rotation" "0"',
			'	"lightmapscale" "' + str(self.lightmapscale) + '"',
			'	"smoothing_groups" "' + str(self.smoothing_groups) + '"',
			'}'
		]).collapse()

class VPlane extends VBase:
	var vertices: Array
	func _init(vertices) -> void:
		self.vertices = vertices
	
	func collapse(root: VMF) -> String:
		return "(" + vertices[0].collapse(root) + ") (" + vertices[1].collapse(root) + ") (" + vertices[2].collapse(root) + ")"
