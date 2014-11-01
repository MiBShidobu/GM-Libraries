-- Result: http://pasteboard.co/1ncB61KG.png
-- testsvg.txt and testsvg2.txt included within folder.

local width, height = 512, 512
local mat = SVG("data/testsvg.txt", width, height, "") -- supports smooth, alphatest, nocull, vertexlitgeneric, unlitgeneric
local mat2 = SVG("data/testsvg2.txt", width, height, "")

local mat3 = SVG("data/testsvg.txt", width / 2, height / 2, "")
local mat4 = SVG("data/testsvg2.txt", width / 2, height / 2, "")

hook.Add("HUDPaint", "test_svg", function ()
    surface.SetMaterial(mat)
    surface.SetDrawColor(Color(255, 255, 255, 255))
    surface.DrawTexturedRect(0, 0, width, height)

    surface.SetMaterial(mat2)
    surface.SetDrawColor(Color(255, 255, 255, 255))
    surface.DrawTexturedRect(width, 0, width, height)

    surface.SetMaterial(mat3)
    surface.SetDrawColor(Color(255, 255, 255, 255))
    surface.DrawTexturedRect(0, height, width / 2, height / 2)

    surface.SetMaterial(mat4)
    surface.SetDrawColor(Color(255, 255, 255, 255))
    surface.DrawTexturedRect(width / 2, height, width / 2, height / 2)
end)