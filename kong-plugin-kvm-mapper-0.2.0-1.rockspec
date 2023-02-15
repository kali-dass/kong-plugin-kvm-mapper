local plugin_name = "kvm-mapper"
local package_name = "kong-plugin-" .. plugin_name
local package_version = "0.2.0"
local rockspec_revision = "1"

local github_account_name = "Kong"
local github_repo_name = "kong-plugin-kvm-mapper"
local git_checkout = package_version == "main" and "master" or package_version


package = package_name
version = package_version .. "-" .. rockspec_revision
supported_platforms = { "linux", "macosx" }
source = {
  url = "git://github.com/"..github_account_name.."/"..github_repo_name..".git",
  branch = git_checkout,
}


description = {
  summary = "Kong plugin for Key Values Mapping into database using Admin API and apply plugin with key to get key/values as headers into upstream.",
  homepage = "https://"..github_account_name..".github.io/"..github_repo_name,
  license = "Apache 2.0",
}


dependencies = {
    "lua >= 5.1"
}


build = {
  type = "builtin",
  modules = {
    ["kong.plugins."..plugin_name..".handler"] = "kong/plugins/"..plugin_name.."/handler.lua",
    ["kong.plugins."..plugin_name..".schema"] = "kong/plugins/"..plugin_name.."/schema.lua",
    ["kong.plugins."..plugin_name..".daos"] = "kong/plugins/"..plugin_name.."/daos.lua",
    ["kong.plugins."..plugin_name..".migrations.init"] = "kong/plugins/"..plugin_name.."/migrations/init.lua",
    ["kong.plugins."..plugin_name..".migrations.000_base_kvm-mapper"] = "kong/plugins/"..plugin_name.."/migrations/000_base_kvm-mapper.lua",
    ["kong.plugins."..plugin_name..".migrations.001_010_to_020"] = "kong/plugins/"..plugin_name.."/migrations/001_010_to_020.lua"
  }
}
