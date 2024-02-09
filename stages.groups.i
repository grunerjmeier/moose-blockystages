# Variables containing a set of block names representing groups


BoundarySurfaces = 'BoundingBox_Vol_XMax_0
                    BoundingBox_Vol_XMin_0
                    BoundingBox_Vol_YMax_0
                    BoundingBox_Vol_YMin_0
                    BoundingBox_Vol_ZMin_0'

BoundarySurfaces_XMax = 'BoundingBox_Vol_XMax_0'

BoundarySurfaces_XMin = 'BoundingBox_Vol_XMin_0'

BoundarySurfaces_YMax = 'BoundingBox_Vol_YMax_0'

BoundarySurfaces_YMin = 'BoundingBox_Vol_YMin_0'

BoundarySurfaces_ZMin = 'BoundingBox_Vol_ZMin_0'

# Fake users of the variables containing a set of block names representing groups

[Functions]
	[FakeUser_BoundarySurfaces]
		type = ParsedFunction
		expression = 'a'
		symbol_names = 'a'
		symbol_values = '1'
		control_tags = ${BoundarySurfaces}
	[]
	[FakeUser_BoundarySurfaces_XMax]
		type = ParsedFunction
		expression = 'a'
		symbol_names = 'a'
		symbol_values = '1'
		control_tags = ${BoundarySurfaces_XMax}
	[]
	[FakeUser_BoundarySurfaces_XMin]
		type = ParsedFunction
		expression = 'a'
		symbol_names = 'a'
		symbol_values = '1'
		control_tags = ${BoundarySurfaces_XMin}
	[]
	[FakeUser_BoundarySurfaces_YMax]
		type = ParsedFunction
		expression = 'a'
		symbol_names = 'a'
		symbol_values = '1'
		control_tags = ${BoundarySurfaces_YMax}
	[]
	[FakeUser_BoundarySurfaces_YMin]
		type = ParsedFunction
		expression = 'a'
		symbol_names = 'a'
		symbol_values = '1'
		control_tags = ${BoundarySurfaces_YMin}
	[]
	[FakeUser_BoundarySurfaces_ZMin]
		type = ParsedFunction
		expression = 'a'
		symbol_names = 'a'
		symbol_values = '1'
		control_tags = ${BoundarySurfaces_ZMin}
	[]
[]
