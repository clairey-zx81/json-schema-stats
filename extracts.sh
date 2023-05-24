#! /bin/bash
#
# extraits intéressants pour un article
#

COUNT=1

function extract()
{
  local comment=$1 path=$2 file=$3
  echo
  echo "// $COUNT file: $file"
  echo "// path: $path"
  echo "// $comment"
  jq "$path" "$file"

  COUNT=$(($COUNT + 1))
}
