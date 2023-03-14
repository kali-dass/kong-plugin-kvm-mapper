local kong = kong
local error = error

local KvmMapper = {
  -- set the plugin priority, to be run after OIDC plugin
  PRIORITY = 999,
  VERSION = "0.1",
}

local function load_key_values(key)

  local key_value, err = kong.db.kvm_mappings:select_by_key(key)

  -- return error when unable to get data from db
  if err then
    return nil, { message = "Error getting kvm key value:".. err }
  end

  -- if value not found return nil
  -- else return value of key
  if not key_value then
    return nil, nil
  else
    return key_value, nil
  end

end

-- set the kvm to header
local function set_kvm_header(key, value)
  local set_header = kong.service.request.set_header

  -- set header
  set_header("X-KVM-"..key, value)

end

-- load kvm values for the keys to headers
local function load_kvm_values_to_header(keys)
  -- cache
  local cache = kong.cache

  -- loop over each key
  for i = 1, #keys do
    local key = keys[i]

    -- create kvm cache key
    local kvm_cache_key = kong.db.kvm_mappings:cache_key(key)

    -- load from cache or load from db (and cache it)
    local kvm, err = cache:get(kvm_cache_key, nil, load_key_values, key)

    -- return error if fault in cache or gettin from db
    if err then
      return kong.response.exit(500, "Plugin error : ".. err)
    end

    -- if value not found leave the warning message
    -- else set value of key to header
    if not kvm then
      kong.log.warn("Could not find value for kvm key : " .. key)
    else
      set_kvm_header(key, kvm.value)
    end
  end
end

-- runs in the 'access_by_lua_block'
function KvmMapper:access(plugin_conf)

  -- check kvm_keys are missing
  if not plugin_conf.kvm_keys then
    return kong.response.error(500, "Invalid plugin configuration")
  end

  -- load kvm values
  local kvm_value, err = load_kvm_values_to_header(plugin_conf.kvm_keys)

  -- on error return 500
  if err then
    return kong.response.exit(500, "Plugin error : ".. err)
  end

end

-- return our plugin object
return KvmMapper
