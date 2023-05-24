#! /usr/bin/bash

source extracts.sh

extract \
  "HMMM... the string type on name is declared elsewhere" \
  '."$defs".parameter.dependentSchemas.schema."$defs"."styles-for-path".then.properties.name' \
  ../YAC/corpus/Misc/openAPI/schemas/v3.1/schema.json
