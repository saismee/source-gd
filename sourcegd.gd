extends Node

# classes
class VMF:
	var version_info: Dictionary
	var visgroups: Array
	var world: Dictionary
	var entities: Array
	
	var totalchildren: int
	
	func _init():
		self.totalchildren = 0
		self.version_info = {
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
			"solids": []
		}
	
	func add(entity: BaseEntity):
		if entity is BaseSolid:
			self.world.solids.append(entity)
		else:
			self.entities.append(entity)
	
	func collapse():
		var out = ""

class BaseEntity:
	var classname: String

class Entity extends BaseEntity:
	pass

class BaseSolid extends BaseEntity:
	var sides: Array
	func _init(sides: Array):
		self.sides = sides

class CubeSolid extends BaseSolid:
	func _init(position: Vector3, size: Vector3):
		var sides = []
		sides.append(Side.new(VPlane.new([
			Vector3(position.x - size.x/2, position.y + size.y/2, position.z + size.z/2),
			Vector3(position.x + size.x/2, position.y + size.y/2, position.z + size.z/2),
			Vector3(position.x + size.x/2, position.y - size.y/2, position.z + size.z/2),
		]), ""))
		sides.append(Side.new(VPlane.new([
			Vector3(position.x - size.x/2, position.y - size.y/2, position.z - size.z/2),
			Vector3(position.x + size.x/2, position.y - size.y/2, position.z - size.z/2),
			Vector3(position.x + size.x/2, position.y + size.y/2, position.z - size.z/2),
		]), ""))
		sides.append(Side.new(VPlane.new([
			Vector3(position.x - size.x/2, position.y + size.y/2, position.z + size.z/2),
			Vector3(position.x - size.x/2, position.y - size.y/2, position.z + size.z/2),
			Vector3(position.x - size.x/2, position.y - size.y/2, position.z - size.z/2),
		]), ""))
		sides.append(Side.new(VPlane.new([
			Vector3(position.x + size.x/2, position.y + size.y/2, position.z - size.z/2),
			Vector3(position.x + size.x/2, position.y - size.y/2, position.z - size.z/2),
			Vector3(position.x + size.x/2, position.y - size.y/2, position.z + size.z/2),
		]), ""))
		sides.append(Side.new(VPlane.new([
			Vector3(position.x + size.x/2, position.y + size.y/2, position.z + size.z/2),
			Vector3(position.x - size.x/2, position.y + size.y/2, position.z + size.z/2),
			Vector3(position.x - size.x/2, position.y + size.y/2, position.z - size.z/2),
		]), ""))
		sides.append(Side.new(VPlane.new([
			Vector3(position.x + size.x/2, position.y - size.y/2, position.z - size.z/2),
			Vector3(position.x - size.x/2, position.y - size.y/2, position.z - size.z/2),
			Vector3(position.x - size.x/2, position.y - size.y/2, position.z + size.z/2),
		]), ""))
		self.sides = sides

class Side extends BaseEntity:
	var plane: VPlane
	var material: String
#	var uaxis: UVAxis
	var lightmapscale: int
	var smoothing_groups: int
	func _init(plane: VPlane, material: String):
		self.plane = plane
		self.material = material
		self.lightmapscale = 16
		self.smoothing_groups = 0

class VPlane:
	var vertices: Array
	func _init(vertices):
		self.vertices = vertices

func _ready():
	Logger.verbose(CubeSolid.new(Vector3(0, 0, 0), Vector3(10, 10, 10)))
