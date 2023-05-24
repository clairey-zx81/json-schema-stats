#! /bin/bash

source extracts.sh

extract \
  "OK because a property name cannot be anything but a string" \
  '.properties.patternProperties.propertyNames' \
  ../YAC/corpus/Ref/schemas/draft-2019-09-applicator.schema.json

# idem 2020-12 and next
