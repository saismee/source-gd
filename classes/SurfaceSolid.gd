class_name SurfaceSolid extends SourceGD.BaseSolid

func _init(position: Vector3, size: Vector3, material: String) -> void:
	position = Vector3(position.z, position.y, position.x)
	self.sides = []
	self.sides.append(Side.new(VPlane.new([
		Vertex.new(Vector3(position.x - size.x/2, position.y + size.y/2, position.z + size.z/2)),
		Vertex.new(Vector3(position.x + size.x/2, position.y + size.y/2, position.z + size.z/2)),
		Vertex.new(Vector3(position.x + size.x/2, position.y + size.y/2, position.z - size.z/2)),
	]), material, SourceGD.uvaxes.z))
	self.sides.append(Side.new(VPlane.new([
		Vertex.new(Vector3(position.x - size.x/2, position.y - size.y/2, position.z - size.z/2)),
		Vertex.new(Vector3(position.x + size.x/2, position.y - size.y/2, position.z - size.z/2)),
		Vertex.new(Vector3(position.x + size.x/2, position.y - size.y/2, position.z + size.z/2)),
	]), material, SourceGD.uvaxes.z))
	self.sides.append(Side.new(VPlane.new([
		Vertex.new(Vector3(position.x - size.x/2, position.y + size.y/2, position.z + size.z/2)),
		Vertex.new(Vector3(position.x - size.x/2, position.y + size.y/2, position.z - size.z/2)),
		Vertex.new(Vector3(position.x - size.x/2, position.y - size.y/2, position.z - size.z/2)),
	]), material, SourceGD.uvaxes.x))
	self.sides.append(Side.new(VPlane.new([
		Vertex.new(Vector3(position.x + size.x/2, position.y - size.y/2, position.z + size.z/2)),
		Vertex.new(Vector3(position.x + size.x/2, position.y - size.y/2, position.z - size.z/2)),
		Vertex.new(Vector3(position.x + size.x/2, position.y + size.y/2, position.z - size.z/2)),
	]), material, SourceGD.uvaxes.x))
	self.sides.append(Side.new(VPlane.new([
		Vertex.new(Vector3(position.x + size.x/2, position.y + size.y/2, position.z + size.z/2)),
		Vertex.new(Vector3(position.x - size.x/2, position.y + size.y/2, position.z + size.z/2)),
		Vertex.new(Vector3(position.x - size.x/2, position.y - size.y/2, position.z + size.z/2)),
	]), material, SourceGD.uvaxes.y))
	self.sides.append(Side.new(VPlane.new([
		Vertex.new(Vector3(position.x + size.x/2, position.y - size.y/2, position.z - size.z/2)),
		Vertex.new(Vector3(position.x - size.x/2, position.y - size.y/2, position.z - size.z/2)),
		Vertex.new(Vector3(position.x - size.x/2, position.y + size.y/2, position.z - size.z/2)),
	]), material, SourceGD.uvaxes.y))
