return {
  postgres = {
    up = "",
    teardown = function(connector)
      local drop_query = string.format([[
        DROP INDEX IF EXISTS "kvm_mappings_value_idx" CASCADE;
      ]])

      local _
      _, err = connector:query(drop_query)
      if err then
        return nil, err
      end

      return true
    end,
  },
  cassandra = {
    up = "",
    teardown = function(connector)
      local drop_query = string.format([[
        DROP INDEX IF EXISTS ON kvm_mappings_value_idx;
      ]])

      local _
      _, err = connector:query(drop_query)
      if err then
        return nil, err
      end

      return true
    end,
  },
}
