local dot_path = os.getenv("DOT") or "dot"

local function dot(code)
	return pandoc.pipe(dot_path, {"-Tsvg"}, code)
end

function Meta(meta)
	local title = ""
	for k, v in pairs(meta.title) do
		if v.text ~= nil then
			title = title .. v.text
		else
			title = title .. " "
		end
	end
	local author = {}
	for i, a in pairs(meta.author) do
		author[i] = ""
		for k, v in pairs(a) do
			if v.text ~= nil then
				author[i] = author[i] .. v.text
			else
				author[i] = author[i] .. " "
			end
		end
		author[i] = pandoc.MetaString(author[i])
	end
	meta["og:type"] = pandoc.MetaString("article")
	meta["og:title"] = pandoc.MetaString(title)
	meta["og:author"] = pandoc.MetaList(author)
	return meta
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
	return pandoc.List({
		[1] = pandoc.RawBlock("html", "<figure id=" .. label .. ">"),
		[2] = content,
		[3] = pandoc.RawBlock("html", "<figcaption>" .. caption .. "</figcaption></figure>")
	})
end

function CodeBlock(block, attr)
	if block.classes[1] == "dot-image" then
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
