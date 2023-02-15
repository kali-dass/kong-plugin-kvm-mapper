return {
  postgres = {
    up = [[
      CREATE TABLE IF NOT EXISTS "kvm_mappings" (
        "id"           UUID                         PRIMARY KEY,
        "created_at"   TIMESTAMP WITH TIME ZONE     DEFAULT (CURRENT_TIMESTAMP(0) AT TIME ZONE 'UTC'),
        "value"        TEXT,
        "key"          TEXT                         UNIQUE
      );

      DO $$
      BEGIN
        CREATE INDEX IF NOT EXISTS "kvm_mappings_value_idx" ON "kvm_mappings" ("value");
      EXCEPTION WHEN UNDEFINED_COLUMN THEN
        -- Do nothing, accept existing state
      END$$;
    ]],
  },

  cassandra = {
    up = [[
      CREATE TABLE IF NOT EXISTS kvm_mappings(
        id          uuid PRIMARY KEY,
        created_at  timestamp,
        value       text,
        key         text
      );
      CREATE INDEX IF NOT EXISTS ON kvm_mappings(key);
      CREATE INDEX IF NOT EXISTS ON kvm_mappings(value);
    ]],
  },
}
