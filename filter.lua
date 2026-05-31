local dot_path = os.getenv("DOT") or "dot"

local function dot(code)
	return pandoc.pipe(dot_path, {"-Tsvg"}, code)
end

local meta_block = nil

function truncate_metainlines(block, max_len)
	if block == nil then
		return nil
	end
	local str = nil
	for k, v in pairs(block) do
		if v.text ~= nil then
			if str == nil then
				str = v.text
			elseif string.len(str .. " " .. v.text) <= max_len then
				str = str .. " " .. v.text
			else
				break
			end
		end
	end
	str = string.sub(str, 0, math.min(max_len, string.len(str)))
	return pandoc.MetaInlines(str)
end

function Pandoc(content)
	if meta_block ~= nil then
		for k, v in pairs(meta_block) do
			content.meta[k] = pandoc.MetaInlines(v)
		end
	end

	if content.meta["short-title"] == nil then
		content.meta["short-title"] = truncate_metainlines(content.meta["title"], 70)
	end

	return content
end

local figcount = 1

function Para(content)
	for k, v in pairs(content.content) do
		if v.attr ~= nil and v.attr.attributes["reference-type"] == "ref" then
			v.content[1].text = tostring(figcount)
			figcount = figcount + 1
		end
	end
	return content
end

local function figure_block(content, label, caption)
	if caption ~= nil then
		caption = "<figcaption>" .. caption .. "</figcaption>"
	else
		caption = ""
	end
	return pandoc.List({
		[1] = pandoc.RawBlock("html", "<figure id=" .. label .. ">"),
		[2] = content,
		[3] = pandoc.RawBlock("html", caption .. "</figure>")
	})
end

function Math(el)
	for text, annotation in el.text:gmatch("\\implruby{([^}]*)}{([^}]*)}") do
		return pandoc.RawInline(
			"html",
			"<ruby>" .. text .. "<rt>" .. annotation .. "</rt></ruby>")
	end
	for abbr, desc in el.text:gmatch("\\implabbr{([^}]*)}{([^}]*)}") do
		return pandoc.RawInline(
			"html",
			"<abbr title=\"" .. desc .. "\">" .. abbr .. "</abbr>")
	end
end

function CodeBlock(block, attr)
	if block.attributes.language == "page-meta" then
		meta_block = assert(load("return " .. block.text))()
		return {}
	elseif block.attributes.language == "dot-image" then
		local success, img = pcall(dot, block.text)

		if not success then
			io.stderr:write(tostring(block.text) .. "\n")
			io.stderr:write(tostring(img) .. "\n")
			error "dot to svg failed"
		end

		result = pandoc.RawBlock("html", img)
		if block.identifier ~= nil and block.identifier ~= "" then
			result = figure_block(result, block.identifier, block.attributes.caption)
		end
		return result
	elseif block.identifier ~= nil and block.identifier ~= "" then
		return figure_block(block, block.identifier, block.attributes.caption)
	end
end
