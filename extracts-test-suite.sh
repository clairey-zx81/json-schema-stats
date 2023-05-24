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
  ../YAC/corpus/Ref/test-suite-extracts/draft3_ref_007.json

extract \
  "draft4: '\$comment' is draft 7 or later" \
  ".allOf[0]" \
  ../YAC/corpus/Ref/test-suite-extracts/draft4_ref_006.json

extract \
  "draft4: 'const' is draft 6 or later" \
  ".definitions.zzz_id_in_const" \
  ../YAC/corpus/Ref/test-suite-extracts/draft4_id_000.json

extract \
  "draft6: '\$comment' is draft 7 or later" \
  ".allOf[0]" \
  ../YAC/corpus/Ref/test-suite-extracts/draft6_ref_006.json

# idem
# $.$comment: Ref/test-suite-extracts/draft6_ref_019.json
# $.$comment: Ref/test-suite-extracts/draft6_ref_020.json
# $.$comment: Ref/test-suite-extracts/draft6_ref_021.json
# $.$comment: Ref/test-suite-extracts/draft6_ref_022.json
# $.$comment: Ref/test-suite-extracts/draft6_ref_023.json
