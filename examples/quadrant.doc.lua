--[[
    The quadrant object library is a helper library for manipulating map coordinates into bigger quadrant or 'chunks' of the map.
    Thinking of it as Minecraft's chunk system where the map is split up into bigger sections called 'chunks' will help you get the idea.
    This can be used for many proposes, if you need a full example check out my addon called Agressive Chunk Spawner. (github.com/MiBShidobu/ACS)
]]--

-- So let's get started, for most examples we'll use the quadrant at Vector(0, 0, 0).
local quadrant = QuadrantPosition(Vector(0, 0, 0))

-- Quadrants divide up the map into 1200s1200x1200 sections, so 600 to each side(this can be edited in the file).
-- To put simply, just follow the math: Quadrant(floor(X / 1200, Y / 1200, Z / 1200)). So a Vector of 0, 0, 0 will
-- litterally be a Quadrant of 0, 0, 0. Meaning we can easily just use that aswell directly!
local quadrant = Quadrant(0, 0, 0)

-- QuadrantPosition is basically a helper function that does that math for us, without us manually typing any numbers.

-- There is one other way to get a quadrant too. When we tostring any quadrant, ala
local mystr = tostring(quadrant)

-- Or when print does it automatically for us
print(quadrant)

-- We can actually parse that string into a quadrant again!
local quadrant = QuadrantString(mystr)

-- We can even pull the quadrant's XYZ aswell.
print(quadrant.x, quadrant.y, quadrant.z) prints '0 0 0'

-- So, I never leave you without an easy access to get a quadrant. So let's look into other functions.

-- If we ever need to check if a variable is a quadrant
local boolean = IsQuadrant("hello, i r string") -- would return false

-- When you ever need to know the dimensions of quadrants, never hardcode it, as someone could edit the quadrant.lua
-- file. Always call the helper functions to cache it instead.
local radius = GetQuadrantRadius()
local diameter = GetQuadrantDiameter()

-- So let's get onto the object its self. To make it easily adaptable to, quadrant provide persistenting indexing just like entities.

-- So this
quadrant.myvariable = "hi"

-- Will be the same as a new instance of it is called
local quadrant2 = Quadrant(0, 0, 0)
print(quadrant2.myvariable) -- prints 'hi'

-- And more helper functionality too.
local mins, maxs = quadrant:GetMins(), quadrant:GetMaxs() -- Practically just -Vector(QuadrantRadius(), QuadrantRadius(), QuadrantRadius()) and Vector(QuadrantRadius(), QuadrantRadius(), QuadrantRadius()), but without the mess.

local position = quadrant:GetPos() -- Returns the center point in the quadrant.

-- With its own localization functions too.
local position = quadrant:LocalToWorld(Vector(25, 0, 0)) -- Returns the local vector as a world vector 25 units north of the quadrant.

print(quadrant:WorldToLocal(position)) -- prints '25, 0, 0', hence it converted it back to a localized vector.

-- Maybe IsEmpty would be a more apt name for it, but it returns if there is any brushwork inside the quadrant at all. Which if it was in the air, not touching a mountain or anything, it would return true.
local boolean = quadrant:IsAirborne()

--[[
    Now relating to quadrants, is the district api. It divides quadrants up into a 2x2 district of quadrants, mainly for naming for readbility for end-users.
    I should note, the district functions rely only on a 2D plane of quadrants. Z coordinate doesn't affect which district the quadrant/map coordinate is in.
]]--

local dx, dy = quadrant:GetDistrict() -- Returns the X and Y coordinates of the district. Like quadrants, has similar math: dx, dy = floor(quadrant.x, quadrant.y)

local wx, wy = quadrant:GetDistrictPos() -- Like GetPos for quadrants, returns the district's center point of origin.

local super = quadrant:GetName() -- Quadrants are named depending which section of the district they are, getting a letter from the greek alphabet.
--[[
    upper left: Nu
    upper right: Tsu
    lower left: Psi
    lower right: Theta
]]--

local district = quadrant:GetDistrictName() -- Generates(caches it for later calls) and returns a name for the district the quadrant is in. The names are not pre defined in anyway, and in fact
-- are completely random. Comprised of two syllables, the name ranges from 4-6 characters. With each map also getting a uniqued set of names for their district, although with some repeats, just not in the same places.