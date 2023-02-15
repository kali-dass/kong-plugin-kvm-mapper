local KvmMapper = {
  -- set the plugin priority, to be run after OIDC plugin
  PRIORITY = 999,
  VERSION = "0.1",
}

--[[
-- runs in the 'access_by_lua_block'
function KvmMapper:access(plugin_conf)
  kong.log.inspect(plugin_conf)
end
--]]

-- return our plugin object
return KvmMapper
