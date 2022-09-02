-- Get location path
local hash = 'sha1'
local box_root = ngx.var.box_prefix .. ngx.var.box_name .. '/'
local posix = require "posix"
local glob = posix.glob (box_root .. '*.box')


if not glob then
    ngx.status = ngx.HTTP_NOT_FOUND
    return ngx.exit (ngx.HTTP_NOT_FOUND)
end


function get_hash (filepath)
    -- Calc hashum of given filepath
    local command = string.format ('%ssum %s | cut -d " " -f1', hash, filepath)
    local hashsum = assert (io.popen (command, 'r'))
    local result = string.gsub (hashsum:read ('*a'), '\n', '')
    hashsum:close ()
    return result
end


local function make_provider (filepath)
    -- Make vagrant provider from given file
    local box_provider, box_version = string.match (filepath, '.*/(%a+)-(.+).box')
    local box_url = string.format ("http://%s/%s", ngx.var.host, "%s/%s-%s.box")
    return {
        name = box_provider, -- virtualbox or docker
        url = string.format (box_url, ngx.var.box_name, box_provider, box_version),
        checksum_type = hash,
        checksum = get_hash(filepath)
    }, box_version
end


local versions = {}
-- Discover the boxes
for _, box in ipairs (glob) do
    local provider, version = make_provider (box)
    if version then
        if versions[version] == nil then
            versions[version] = {
                version = version,
                providers = {provider}
            }
        else
            table.insert (versions[version]['providers'], provider)
        end
    end
end


-- Make result response
local vagrant = {
    name = ngx.var.box_name,
    description = string.format ("Boxes for %s proj", ngx.var.box_name),
    versions = {}
}
for _, version in pairs (versions) do
    table.insert (vagrant['versions'], version)
end

-- Return response
ngx.header.content_type = "application/json; charset=utf-8"
local json = require "json"
ngx.say (json.encode (vagrant))
