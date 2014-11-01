--[[
    GM-Libraries :: SVG Library Script
        by MiBShidobu

    Notes:
            When getting an SVG render, they return a blank material to you that is updated in a queue. Typically takes about ~0.1s
        per SVG, maybe a bit longer for the way more complex ones(not tested). I also stopped working on my manual SVG parser and renderer,
        due after doing some tests with Awesomium's HTML panels. Speeds and me not having to support the entire SVG 1.1 spec manually
        was a big bonus. So people maybe concerned about this due to the multi-process nature, but testing on my dual-core Pentium B940,
        and 3.5GB RAM laptop, I saw little to no impact in both CPU and RAM usage. With RAM only being ~5KB. Not only that, but the library
        only ever uses one active HTML panel and that is open only while a queue is active. Compared to having a JIT DHTML panel, rather
        than a just having a one made at first load, the JIT variant adds ~1 load time. Once it starts processing, it's about ~0.1 inbetween
        each SVG. So take that how you will though.
]]--

if SVG and SVGRaw and IsSVGReady then
    return -- We only need to load once, if we load again might leave behind stray Awesomium processes.
end

local GenerateHTMLSource = CompileFile("includes/modules/svg.html.lua")() -- Get the source generation function... sorry I like to modulate my code.

local HOOK_THINK = nil
local g_CurrentSVG = nil
local g_RenderSVG = nil

local g_SVGCache = {}
local g_SVGRender = {}

local g_SVGRenderPanel = nil

--[[
    Name: QuickFind(string String, string Search)
    Desc: Returns true if sub-string Search exists in String.
    State: LOCAL/CLIENT
]]--

local function QuickFind(str, search)
    return string.find(string.lower(str), search, 0, false) and true or false
end

--[[
    Name: IsSVGReady(number ID)
    Desc: Returns if the SVG of ID is ready.
    State: CLIENT
]]--

function IsSVGReady(checksum)
    return g_SVGCache[checksum] and true or false
end

--[[
    Name: SVGRaw(string SVG Source, number Width, number Height, string Parameters)
    Desc: Returns an IMaterial of a rendered SVG string and the SVG's id. Taking Width and Height as the output rendered size.
        Parameter is similar to _G.Material's pngParameters, currently supports: smooth, alphatest, nocull, vertexlitgeneric, unlitgeneric.
        Support for the other pngParameters will be added when methods are found to replicate them.

        Note: Returned IMaterials are blank, they'll be autoupdated with their relavent content when processed. They can be drawn still regardless. If you
        need to keep track of when they're processed, use the SVGMaterialReady hook and id to check.

    State: CLIENT
]]--

function SVGRaw(str, width, height, parameters)
    local checksum = util.CRC("svg_"..width..str..parameters..height.."_svg")
    if g_SVGCache[checksum] then
        return g_SVGCache[checksum], checksum

    else
        local target = GetRenderTarget("svg_render_"..checksum, width, height, true)
        local material = CreateMaterial("svg_material_"..checksum, QuickFind(parameters, "vertexlitgeneric") and "VertexLitGeneric" or "UnlitGeneric", {
            ["$alpha"] = QuickFind(parameters, "alphatest") and "0" or "1",
            ["$alphatest"] = QuickFind(parameters, "alphatest") and "1" or "0",
            ["$nocull"] = QuickFind(parameters, "nocull") and "1" or "0",
            ["$translucent"] = QuickFind(parameters, "alphatest") and "0" or "1",
            ["$basetexture"] = target:GetName()
        })

        table.insert(g_SVGRender, {
            Checksum = checksum,
            Width = width,
            Height = height,
            String = str,
            Material = material,
            Target = target,
            Parameters = parameters
        })

        if not hook.GetTable()["Think"]["svg_think_stack"] then
            g_SVGRenderPanel = vgui.Create("DHTML")
            g_SVGRenderPanel:SetPos(0, 0)
            g_SVGRenderPanel:SetSize(0, 0)
            g_SVGRenderPanel:SetPaintedManually(true)
            g_SVGRenderPanel:ParentToHUD()

            g_SVGRenderPanel:SetScrollbars(false)
            g_SVGRenderPanel:AddFunction("svg", "hook", function ()
                hook.Run("SVGRendered")
            end)

            hook.Add("Think", "svg_think_stack", HOOK_THINK)
        end

        g_SVGCache[checksum] = material
        return material, checksum
    end
end

--[[
    Name: SVG(string SVG Source, number Width, number Height, string Parameters)
    Desc: Returns an IMaterial of a rendered SVG file path and the SVG's id. Check SVGRaw for additional information.
    State: CLIENT
]]--

function SVG(name, width, height, parameters)
    if file.Exists(name, "GAME") then
        return SVGRaw(file.Read(name, "GAME"), width, height, parameters)

    else
        error("invalid file path")
    end
end

--[[
    Name: HOOK_THINK()
    Desc: Called when processing current queue of SVGs.
    State: LOCAL/CLIENT
]]--

function HOOK_THINK()
    if not g_CurrentSVG and not g_RenderSVG and not gui.IsGameUIVisible() then
        g_CurrentSVG = table.remove(g_SVGRender, 1)

        g_SVGRenderPanel:SetSize(g_CurrentSVG.Width, g_CurrentSVG.Height)
        g_SVGRenderPanel:Clear()

        g_SVGRenderPanel:SetHTML(GenerateHTMLSource(g_CurrentSVG.String))
    end
end

--[[
    Name: HOOK_HUDPAINT()
    Desc: Called when needing to render a SVG to a material.
    State: LOCAL/CLIENT
]]--

local function HOOK_HUDPAINT()
    g_SVGRenderPanel:PaintManual()
    g_SVGRenderPanel:UpdateHTMLTexture()

    local smooth = QuickFind(g_RenderSVG.Parameters, "smooth")
    render.PushRenderTarget(g_RenderSVG.Target)
        render.Clear(0, 0, 0, 0, true, true)
        cam.Start2D()
            if smooth then
                render.PushFilterMag(TEXFILTER.ANISOTROPIC)
            end

            local material = g_SVGRenderPanel:GetHTMLMaterial()
            surface.SetMaterial(material)
            surface.SetDrawColor(Color(255, 255, 255, 255))
            surface.DrawTexturedRect(0, 0, material:Width(), material:Height(), g_RenderSVG)

            if smooth then
                render.PopFilterMag()
            end
        cam.End2D()
    render.PopRenderTarget()

    hook.Run("SVGMaterialReady", g_RenderSVG.Material, g_RenderSVG.Checksum, g_RenderSVG.String)

    g_RenderSVG = nil
    hook.Remove("HUDPaint", "svg_hudpaint_render")
    if #g_SVGRender == 0 then
        g_SVGRenderPanel:Remove()
        hook.Remove("Think", "svg_think_stack")
    end
end

hook.Add("SVGRendered", "svg_rendered", function ()
    if g_CurrentSVG then
        g_RenderSVG = g_CurrentSVG
        g_CurrentSVG = nil

        hook.Add("HUDPaint", "svg_hudpaint_render", HOOK_HUDPAINT)
    end
end)