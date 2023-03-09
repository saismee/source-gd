extends Node

func to_kv_string(root: VMF, key: String, dict) -> String:
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
	var entities: Array
	
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
			"solids": VSolids.new()
		}
	
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
		])
		
		return out.collapse()

class VSolids extends VBase:
	var solids = []
	func _init() -> void:
		pass
	
	func append(solid: BaseSolid):
		solids.append(solid)
	
	func collapse(root: VMF) -> String:
		var out = VString.new([])
		for index in solids.size():
			out.append(solids[index].collapse(root))
		return out.collapse()

class VBase:
	func collapse(root: VMF) -> String:
		return ""

class BaseEntity extends VBase:
	var classname: String

class VVector extends VBase:
	var x: float
	var y: float
	var z: float
	func _init(vec: Vector3 = Vector3.ZERO) -> void:
		self.x = vec.x
		self.y = vec.y
		self.z = vec.z
	
	func collapse(root: VMF) -> String:
		return str(self.x) + " " + str(self.z) + " " + str(self.y)

class Entity extends BaseEntity:
	pass

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
		var sides = []
		sides.append(Side.new(VPlane.new([
			VVector.new(Vector3(position.x - size.x/2, position.y + size.y/2, position.z + size.z/2)),
			VVector.new(Vector3(position.x + size.x/2, position.y + size.y/2, position.z + size.z/2)),
			VVector.new(Vector3(position.x + size.x/2, position.y + size.y/2, position.z - size.z/2)),
		]), ""))
		sides.append(Side.new(VPlane.new([
			VVector.new(Vector3(position.x - size.x/2, position.y - size.y/2, position.z - size.z/2)),
			VVector.new(Vector3(position.x + size.x/2, position.y - size.y/2, position.z - size.z/2)),
			VVector.new(Vector3(position.x + size.x/2, position.y - size.y/2, position.z + size.z/2)),
		]), ""))
		sides.append(Side.new(VPlane.new([
			VVector.new(Vector3(position.x - size.x/2, position.y + size.y/2, position.z + size.z/2)),
			VVector.new(Vector3(position.x - size.x/2, position.y + size.y/2, position.z - size.z/2)),
			VVector.new(Vector3(position.x - size.x/2, position.y - size.y/2, position.z - size.z/2)),
		]), ""))
		sides.append(Side.new(VPlane.new([
			VVector.new(Vector3(position.x + size.x/2, position.y - size.y/2, position.z + size.z/2)),
			VVector.new(Vector3(position.x + size.x/2, position.y - size.y/2, position.z - size.z/2)),
			VVector.new(Vector3(position.x + size.x/2, position.y + size.y/2, position.z - size.z/2)),
		]), ""))
		sides.append(Side.new(VPlane.new([
			VVector.new(Vector3(position.x + size.x/2, position.y + size.y/2, position.z + size.z/2)),
			VVector.new(Vector3(position.x - size.x/2, position.y + size.y/2, position.z + size.z/2)),
			VVector.new(Vector3(position.x - size.x/2, position.y - size.y/2, position.z + size.z/2)),
		]), ""))
		sides.append(Side.new(VPlane.new([
			VVector.new(Vector3(position.x + size.x/2, position.y - size.y/2, position.z - size.z/2)),
			VVector.new(Vector3(position.x - size.x/2, position.y - size.y/2, position.z - size.z/2)),
			VVector.new(Vector3(position.x - size.x/2, position.y + size.y/2, position.z - size.z/2)),
		]), ""))
		self.sides = sides

class Side extends BaseEntity:
	var plane: VPlane
	var material: String
#	var uaxis: UVAxis
	var lightmapscale: int
	var smoothing_groups: int
	func _init(plane: VPlane, material: String) -> void:
		self.plane = plane
		self.material = material
		self.lightmapscale = 16
		self.smoothing_groups = 0
	
	func collapse(root: VMF) -> String:
		return VString.new([
			'side',
			'{',
			'	"id" "' + root.get_uid() + '"',
			'	"plane" "' + self.plane.collapse(root) + '"',
			'	"material" "' + self.material.to_upper() + '"',
			'	"uaxis" "[0 0 0 0] 0.25"', # todo: convert uvaxis
			'	"vaxis" "[0 0 0 0] 0.25"', # todo: convert uvaxis
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
