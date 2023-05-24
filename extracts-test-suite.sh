#! /bin/bash
#
# extraits intéressants pour un article
#

source extracts.sh

#
# JSON Schema Test Suite
#

extract \
  "draft3: '\$comment' is draft 7 or later" \
  ".definitions.base_foo" \
  ../gits/JSON-schema-test-suite/draft3_ref_007.json

extract \
  "draft4: '\$comment' is draft 7 or later" \
  ".allOf[0]" \
  ../gits/JSON-schema-test-suite/draft4_ref_006.json

extract \
  "draft4: 'const' is draft 6 or later" \
  ".definitions.zzz_id_in_const" \
  ../gits/JSON-schema-test-suite/draft4_id_000.json

extract \
  "draft6: '\$comment' is draft 7 or later" \
  ".allOf[0]" \
  ../gits/JSON-schema-test-suite/draft6_ref_006.json

# idem
# $.$comment: ../gits/JSON-schema-test-suite/draft6_ref_019.json
# $.$comment: ../gits/JSON-schema-test-suite/draft6_ref_020.json
# $.$comment: ../gits/JSON-schema-test-suite/draft6_ref_021.json
# $.$comment: ../gits/JSON-schema-test-suite/draft6_ref_022.json
# $.$comment: ../gits/JSON-schema-test-suite/draft6_ref_023.json
