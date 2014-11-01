--[[
    GM-Libraries :: SVG HTML Source
        by MiBShidobu
]]--

--[[
    Name: GenerateHTMLSource(string Source)
    Desc: Returns HTML code containing the source SVG, Source.
    State: LOCAL/CLIENT
]]--

return function (str)
    return [[<html>
    <head>
        <meta charset="utf-8">

        <style type="text/css">
            html, body, img {
                width: 100%;
                height: 100%;
                margin: 0px;
                padding: 0px;
            }

            body {
                min-width: 100%;
                min-height: 100%;
                overflow: hidden;
            }
        </style>

        <script type="text/javascript">
            var source = (function () {/*]]..string.Trim(string.Replace(string.Replace(str, "*/", ""), "/*", ""))..[[*/}).toString().match(/[^]*\/\*([^]*)\*\/\}$/)[1];

            function error(str) {
                document.write("<h2>" + str + "</h2>");
            }

            function hookRun() {
                svg.hook();
            }

            function getXMLError(element, opened)
            {
                var message = "";
                var name = element.nodeName;

                if (name == "h3") {
                    if (!opened) {
                        return "";
                    }

                    opened = false;
                } else if (name == "#text") {
                    message = message + element.nodeValue + "\n";
                }

                for (var index=0; index<element.childNodes.length; index++)
                {
                    message = message + getXMLError(element.childNodes[index], false);
                }

                return message;
            }

            function validateXML(doc)
            {
                if (doc.getElementsByTagName("parsererror").length > 0) {
                    return {
                        success: false,
                        message: getXMLError(doc.getElementsByTagName("parsererror")[0], true).replace(/^\s+|\s+$/g, "")
                    };
                }

                return {
                    success: true,
                    message: undefined
                };
            }

            function loadSVG (str) {
                try {
                    var parser = new DOMParser();
                    var doc = parser.parseFromString(str, "image/svg+xml");
                    var validation = validateXML(doc);
                    if (!validation.success) {
                        error(validation.message);
                        return;
                    }

                    return doc;

                } catch (err) {
                    error(err.message);
                }
            }

            function loadScript() { // So many work arounds...
                var doc = loadSVG(source);
                if (doc !== undefined) {
                    var svg = doc.querySelector("svg");
                    svg.setAttribute("preserveAspectRatio", "none");
                    svg.setAttribute("viewBox", "0 0 " + svg.getAttribute("width") + " " + svg.getAttribute("height"));

                    var img = document.createElement("img");
                    var src = new XMLSerializer().serializeToString(doc);
                    img.setAttribute("src", "data:image/svg+xml," + src);

                    img.onload = function () {
                        setTimeout(function () {
                            hookRun();
                        }, 100);
                    };
                    document.body.appendChild(img);

                } else {
                    hookRun();
                }                
            }
        </script>
    </head>

    <body onload="loadScript();"></body>
</html>]]
end