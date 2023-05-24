#! /bin/bash

source extracts.sh

# NOTE this same statusCode fantasy appears in multiple places and files
# json-schema-corpus/json_schema_corpus/pp_9873.json
# json-schema-corpus/json_schema_corpus/pp_9874.json
# json-schema-corpus/json_schema_corpus/pp_9875.json
# json-schema-corpus/json_schema_corpus/pp_9877.json
# and others (not statusCode)
# json-schema-corpus/json_schema_corpus/pp_70331.json
extract \
  'draft 4, min/max for minimum/maximum ("integer": true, min=100, max=599)' \
  '.properties.experienceEndpoints.properties.items.items.properties.unauthorizedReply.oneOf[0].properties.statusCode' \
  ../YAC/corpus/JSC/json-schema-corpus/json_schema_corpus/pp_9882.json

# Similar cases
# json-schema-corpus/json_schema_corpus/pp_9804.json
# json-schema-corpus/json_schema_corpus/pp_9805.json
# json-schema-corpus/json_schema_corpus/pp_9808.json
extract \
  'min/max for minItems/maxItems' \
  '.properties.toEmail' \
  ../YAC/corpus/JSC/json-schema-corpus/json_schema_corpus/pp_9806.json

# IDEM
# json-schema-corpus/json_schema_corpus/pp_9794.json
extract \
  'min/max for minLength/maxLength' \
  '.properties.subject' \
  ../YAC/corpus/JSC/json-schema-corpus/json_schema_corpus/pp_9806.json

extract \
  'min/maxValue for minimum/maximum' \
  '.definitions.perlin.properties.OctaveCount' \
  ../YAC/corpus/JSC/json-schema-corpus/json_schema_corpus/pp_74559.json

extract \
  'min/maxitems instead of min/maxItems, repeated 20 times in same file' \
  .properties.links \
  ../YAC/corpus/JSC/json-schema-corpus/json_schema_corpus/pp_80286.json
