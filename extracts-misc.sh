#! /bin/bash
#
# extraits intéressants pour un article
#

source extracts.sh

#
# VRAC
#
extract \
  "bad mix in table-schema" \
  ".properties.foreignKeys.items.oneOf[0].properties.fields.items" \
  ../YAC/corpus/Misc/VRAC/table-schema.BROKEN.json
