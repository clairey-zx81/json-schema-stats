DROP VIEW IF EXISTS KeywordTypos CASCADE;
CREATE VIEW KeywordTypos AS
  SELECT
    *,
    typo->>0 AS "keyword",
    typo->>1 AS "path"
FROM SchemaStats
CROSS JOIN LATERAL jsonb_array_elements(js_stats->'<typos-keywords-where>') AS typo
WHERE js_stats->'<typos>' IS NOT NULL;

-- few
\echo '# example (vs examples), draft 6'
SELECT ssid, chemin, version, keyword, path
FROM KeywordTypos
WHERE keyword = 'example' 
  AND (version >= 6 OR 
       version = 0 AND js_stats->'<versions>' @> JSONB '6' )
ORDER BY 2, 5;

-- very few
\echo '# readonly (vs readOnly), draft 7'
SELECT ssid, chemin, version, keyword, path
FROM KeywordTypos
WHERE keyword = 'readonly' 
  AND (version >= 7 OR 
       version = 0 AND js_stats->'<versions>' @> JSONB '7' )
ORDER BY 2, 5;

-- 1357, many extensions really
\echo '# *type* (vs type)'
SELECT ssid, chemin, version, keyword, path
FROM KeywordTypos
WHERE keyword IN ('type:')
 -- ('@type', '$type', 'type:', 'typeof')
 -- typeof: extensions
ORDER BY 2, 5;

\echo '# defaults (vs default)'
SELECT ssid, chemin, version, keyword, path
FROM KeywordTypos
WHERE keyword IN ('defaults')
ORDER BY 2, 5;

\echo '# min max and variants'
SELECT ssid, chemin, version, keyword, path
FROM KeywordTypos
WHERE keyword IN ('min', 'max', 'minValue', 'maxValue', 'minSize', 'maxSize', 'minitems', 'maxitems')
ORDER BY 2, 5;

\echo '# Id'
SELECT ssid, chemin, version, keyword, path
FROM KeywordTypos
WHERE keyword IN ('Id', '$Id', 'id')
ORDER BY 2, 5;
