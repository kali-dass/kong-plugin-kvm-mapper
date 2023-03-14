local typedefs = require "kong.db.schema.typedefs"

local schema = {
  name = "kvm-mapper",
  fields = {
    { consumer = typedefs.no_consumer },  -- this plugin cannot be configured on a consumer (typical for auth plugins)
    { protocols = typedefs.protocols_http },
    { config = {
        type = "record",
        fields = {
          {
            kvm_keys = {
              type = "array",
              elements = { type = "string", },
              required = true,
            },
          },
        },
      },
    },
  },
}

return schema
