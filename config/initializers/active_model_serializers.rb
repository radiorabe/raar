# frozen_string_literal: true

ActiveModelSerializers.config.adapter = :json_api
ActiveModelSerializers.config.jsonapi_include_toplevel_object = true

# Use unaltered keys for easier round-trip documents and
# attributes accessible as methods in Javascript.
ActiveModelSerializers.config.key_transform = :unaltered
