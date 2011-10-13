#!/bin/env lua

--- A GitHub specific manifest generator for the LuaDist deployment utility
local per = require "dist.persist"
local man = require "dist.manifest"
local fet = require "dist.fetch"

-- Collect URLs of repos for each module
local modules = io.open(".gitmodules", "r")
local repo = {}
for line in modules:lines() do
    url = line:match("%surl%s=%s([^%s]+)")
    if name and url then
        repo[name] = url
    end
    name = line:match("%spath%s=%s([^%s]+)")
end
modules:close()

-- Collect tags for each module
local manifest = {}
for name, url in pairs(repo) do
    local remote = io.popen("git ls-remote --tags "..url.. " | tail -r")
	local tags = {}
    for line in remote:lines() do
		table.insert(tags, line)
	end
	table.insert(tags, "0 refs/tags/master")

	-- Generate manifest entry for each tag if it contains valid dist.info
	for _,line in ipairs(tags) do
        local hash, tag = line:match("([^%s]+)%srefs/tags/([^%s%^]+)$")
        if hash and tag then
            -- Collect dist.info for each tag
            local url = "https://raw.github.com/LuaDist/"..name.."/"..tag.."/dist.info"
            local info = man.info(per.loadText(fet.get(url)) or "")
			
			-- Generate manifest entry for the dist
            if info then
            	-- If master, mark dist version as scm
				if tag == "master" then info.version = "scm" end
			
			    -- Small hack to generate correct filename
                -- I apologize to GitHub for (ab)using their automated zip feature.
                info.path = "https://nodeload.github.com/LuaDist/"..name.."/zipball/"..tag.."?/"..info.name.."-"..info.version..".dist"
                print(info.name, info.version, info.path)
                table.insert(manifest, info)
            end
        end
    end
    remote:close()
end

per.saveManifest("dist.manifest", manifest)
