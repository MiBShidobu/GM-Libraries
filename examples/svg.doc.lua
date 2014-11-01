--[[
    The svg library allows you to render the Scaleable Vector Graphics files at any given size, via Awesomium. To see notes on the
    process behind rendering, check lua/includes/modules/svg.lua. This is just explaining how to use the functions.
]]--

-- SVG renders act like any other IMaterial maded via Material.
local mymaterial = SVG("materials/mysvg.svg", 512, 512)

--[[
    The last two arguments here, are the output width and height. Because we have to use Source's native material engine,
    we need to have the output SVG rendered as a Raster image. So we give it a width and height. You can have multiple variants
    of the same SVG at different sizes though. Just don't try to have too many now, might crash the client.
]]--

-- Not only that, but they support most of the pngParameters that Material supports.
local mymaterial = SVG("materials/mysvg.svg", 512, 512, "smooth") -- They support the following: smooth, alphatest, nocull, vertexlitgeneric, unlitgeneric

-- SVGs can also be loaded via raw strings too.
local mymaterial =  SVGRaw([[<svg>svg data...</svg>]], 512, 512, "smooth") -- With pngParameters too!

-- Like said before, SVG renders can be used like any IMaterial returned via Material and CreateMaterial.
hook.Add("HUDPaint", "example_paint", function ()
    surface.SetMaterial(mymaterial)
    surface.SetDrawColor(Color(255, 255, 255, 255))
    surface.DrawTexturedRect(0, 0, 512, 512)
end)

--[[
    Returned IMaterial objects via SVG and SVGRaw are pure black until they're finished rendering. You normally shouldn't have to worry
    about this though, since you can just render the blank material and it'll auto update when it's finished. Typically wait time is ~0.1,
    maybe a bit more or less, depending on the complexity of the SVG. If you actually wanna know when it's finished for whatever reason,
    we got a hook for that. SVGMaterialReady, and it takes three arguments.
]]--

hook.Add("SVGMaterialReady", "myid", function (mymaterial, myid, source) -- IMaterial Material, Number ID, String SVG
    -- your code here!
end)

--[[
    Material of course, is just the IMaterial object you receive when you call SVG and SVGRaw. SVG is the source code of your SVG, and ID is the CRC32 checksum
    assigned to your particular instance of the SVG. You get it, if you want it, when you call SVG and SVGRaw:
]]--

local mymaterial, myid = SVG(...)

--[[
    Do note however, if your SVG is already rendered and cached. SVGMaterialReady will not be called, it's only called whenever the SVG is first rendered.
    If you want check right away if it is rendered you can call IsSVGReady and it'll return a Boolean:
]]--

local isready = IsSVGReady(myid)
