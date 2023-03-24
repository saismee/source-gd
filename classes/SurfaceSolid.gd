class_name SurfaceSolid extends SourceGD.BaseSolid

func _init(position: Vector3, size: Vector3, indent: int, material: String) -> void:
	position = Vector3(position.z, position.y, position.x)
	self.sides = []
	self.sides.append(SourceGD.Side.new(SourceGD.VPlane.new([
		SourceGD.Vertex.new(Vector3(position.x - size.x/2 + indent, position.y + size.y/2, position.z + size.z/2 - indent)),
		SourceGD.Vertex.new(Vector3(position.x + size.x/2 - indent, position.y + size.y/2, position.z + size.z/2 - indent)),
		SourceGD.Vertex.new(Vector3(position.x + size.x/2 - indent, position.y + size.y/2, position.z - size.z/2 + indent)),
	]), material, SourceGD.uvaxes.z))
	self.sides.append(SourceGD.Side.new(SourceGD.VPlane.new([
		SourceGD.Vertex.new(Vector3(position.x - size.x/2, position.y - size.y/2, position.z - size.z/2)),
		SourceGD.Vertex.new(Vector3(position.x + size.x/2, position.y - size.y/2, position.z - size.z/2)),
		SourceGD.Vertex.new(Vector3(position.x + size.x/2, position.y - size.y/2, position.z + size.z/2)),
	]), material, SourceGD.uvaxes.z))
	self.sides.append(SourceGD.Side.new(SourceGD.VPlane.new([
		SourceGD.Vertex.new(Vector3(position.x - size.x/2 + indent, position.y + size.y/2, position.z + size.z/2 - indent)),
		SourceGD.Vertex.new(Vector3(position.x - size.x/2 + indent, position.y + size.y/2, position.z - size.z/2 + indent)),
		SourceGD.Vertex.new(Vector3(position.x - size.x/2, position.y - size.y/2, position.z - size.z/2)),
	]), material, SourceGD.uvaxes.x))
	self.sides.append(SourceGD.Side.new(SourceGD.VPlane.new([
		SourceGD.Vertex.new(Vector3(position.x + size.x/2, position.y - size.y/2, position.z + size.z/2)),
		SourceGD.Vertex.new(Vector3(position.x + size.x/2, position.y - size.y/2, position.z - size.z/2)),
		SourceGD.Vertex.new(Vector3(position.x + size.x/2 - indent, position.y + size.y/2, position.z - size.z/2 - indent)),
	]), material, SourceGD.uvaxes.x))
	self.sides.append(SourceGD.Side.new(SourceGD.VPlane.new([
		SourceGD.Vertex.new(Vector3(position.x + size.x/2 - indent, position.y + size.y/2, position.z + size.z/2 - indent)),
		SourceGD.Vertex.new(Vector3(position.x - size.x/2 + indent, position.y + size.y/2, position.z + size.z/2 - indent)),
		SourceGD.Vertex.new(Vector3(position.x - size.x/2, position.y - size.y/2, position.z + size.z/2)),
	]), material, SourceGD.uvaxes.y))
	self.sides.append(SourceGD.Side.new(SourceGD.VPlane.new([
		SourceGD.Vertex.new(Vector3(position.x + size.x/2, position.y - size.y/2, position.z - size.z/2)),
		SourceGD.Vertex.new(Vector3(position.x - size.x/2, position.y - size.y/2, position.z - size.z/2)),
		SourceGD.Vertex.new(Vector3(position.x - size.x/2 + indent, position.y + size.y/2, position.z - size.z/2 + indent)),
	]), material, SourceGD.uvaxes.y))
