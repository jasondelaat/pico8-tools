-- Example: 2D and 3D points

point=object:create()
function point:init(x, y)
   self.x=x
   self.y=y
end
function point:show()
   print('('..self.x..','..self.y..')')
end
p1=point:new(1, 2)
p1:show() -- (1, 2)

point3D=point:create() -- inherit from point
function point3D:init(x, y, z)
   self.proto.init(self, x, y) -- call prototype methods
   self.z=z
end
function point3D:show()
   print('('..self.x..','..self.y..','..self.z..')')
end
p2=point3D:new(1, 2, 3)
p2:show() -- (1, 2, 3)
