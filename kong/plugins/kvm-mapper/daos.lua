local typedefs = require "kong.db.schema.typedefs"

return {
  {
    name = "kvm_mappings",
    primary_key = { "id" },
    cache_key = { "key" },
    endpoint_key = "key",
    generate_admin_api = true,
    admin_api_name = "kvm-mapper",
    fields = {
      { id = typedefs.uuid},
      { created_at = typedefs.auto_timestamp_s },
      { value = { type = "string", required = true, encrypted = true }, },
      { key = { type = "string", required = true, unique = true }, },
    },
  },
}

