local typedefs = require "kong.db.schema.typedefs"

local schema = {
  name = "kvm-mapper",
  fields = {
    { consumer  = typedefs.no_consumer },
    { service = typedefs.no_service },
    { route = typedefs.no_route },
    { protocols = typedefs.protocols_http },
    {
      config = {
        type   = "record",
        fields = {
        }
      }
    }
  }
}

return schema
