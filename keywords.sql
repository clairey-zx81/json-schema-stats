\echo '# all keywords…'
DROP TABLE IF EXISTS KeyWords;

CREATE TABLE KeyWords AS
SELECT
  entry.key AS "keyword",
  SUM(entry.value::INTEGER) FILTER (WHERE entry.value ~ '^[0-9]+$') AS "#",
  COUNT(DISTINCT ss.ssid) AS "# schemas",
  percent(COUNT(DISTINCT ss.ssid), (SELECT COUNT(*) FROM SchemaStats)) AS "%"
FROM SchemaStats AS ss,
  LATERAL jsonb_each_text(ss.js_stats) AS entry
GROUP BY GROUPING SETS ((1), ());

\echo '# keywords...'
SELECT COUNT(*) AS "# keywords"
FROM KeyWords;

SELECT *
FROM KeyWords
ORDER BY 3 DESC, 2 DESC, 1
LIMIT 30;

\echo '# type counts schemas'
SELECT
  tc.kw,
  COUNT(js_stats-> tc.kw) AS "# schema",
  percent(COUNT(js_stats-> tc.kw), COUNT(DISTINCT ssid)) AS "%",
  SUM((js_stats-> tc.kw)::INT) AS "# occs"
FROM SchemaStats
CROSS JOIN (VALUES
  ('type'),
  ('type-list'),
  ('type-list-one'),
  ('type-list-empty'),
  ('type=null'),
  ('type=boolean'),
  ('type=integer'),
  ('type=number'),
  ('type=string'),
  ('type=object'),
  ('type=array')) AS tc(kw)
GROUP BY 1
ORDER BY 1;

\echo '# large sizes'
SELECT
  -- sizes
  MAX((js_stats->'type=array')::INT) AS "max #arrays",
  MAX((js_stats->'type=object')::INT) AS "max #objects"
FROM SchemaStats;

\echo '# combinations'
SELECT
  -- len(*Of) == 1
  SUM((js_stats->'oneOf')::INT) AS "# oneOf",
  COUNT(*) FILTER(WHERE js_stats->'oneOf' IS NOT NULL) AS "# oneOff schemas",
  SUM((js_stats->'oneOf-one')::INT) AS "# oneOf-one",
  COUNT(*) FILTER(WHERE js_stats->'oneOf-one' IS NOT NULL) AS "# one-1 schemas",
  SUM((js_stats->'allOf')::INT) AS "# allOf",
  COUNT(*) FILTER(WHERE js_stats->'allOf' IS NOT NULL) AS "# allOf schemas",
  SUM((js_stats->'allOf-one')::INT) AS "# allOf-one",
  COUNT(*) FILTER(WHERE js_stats->'allOf-one' IS NOT NULL) AS "# all-1 schemas",
  SUM((js_stats->'anyOf')::INT) AS "# anyOf",
  COUNT(*) FILTER(WHERE js_stats->'anyOf' IS NOT NULL) AS "# any schemas",
  SUM((js_stats->'anyOf-one')::INT) AS "# anyOf-one",
  COUNT(*) FILTER(WHERE js_stats->'anyOf-one' IS NOT NULL) AS "# any-1 schemas",
  SUM((js_stats->'oneOf')::INT) + SUM((js_stats->'allOf')::INT) + SUM((js_stats->'anyOf')::INT) AS "# combiners",
  SUM((js_stats->'oneOf-one')::INT) + SUM((js_stats->'allOf-one')::INT) + SUM((js_stats->'anyOf-one')::INT) AS "# *-one",
  COUNT(DISTINCT ssid)
    FILTER (WHERE js_stats->'oneOf-one' IS NOT NULL
               OR js_stats->'allOf-one' IS NOT NULL
               OR js_stats->'anyOf-one' IS NOT NULL) AS "# *-1 schemas"
FROM SchemaStats;

\echo '# enum'
SELECT
  SUM((js_stats->'enum')::INT) AS "count enum",
  SUM((js_stats->'enum-one')::INT) AS "count enum-one",
  COUNT(DISTINCT ssid) FILTER (WHERE js_stats->'enum' IS NOT NULL) AS "# schemas"
FROM SchemaStats;

\echo '# keyword occurences'
DROP TABLE IF EXISTS OfficialKeywords;
CREATE TABLE OfficialKeywords(word TEXT PRIMARY KEY);
INSERT INTO OfficialKeywords(word) VALUES
  ('type'),
  -- metadata
  ('$schema'),
  ('$vocabulary'),
  ('$id'),
  ('$ref'),
  ('$anchor'),
  ('$dynamicAnchor'),
  ('$dynamicRef'),
  ('$comment'),
  ('title'),
  ('description'),
  ('default'),
  ('examples'),
  ('deprecated'),
  ('readOnly'),
  ('writeOnly'),
  ('id'),
  -- alone
  ('enum'),
  ('const'),
  -- number
  ('minimum'),
  ('maximum'),
  ('exclusiveMinimum'),
  ('exclusiveMaximum'),
  ('multipleOf'),
  -- string
  ('minLength'),
  ('maxLength'),
  ('pattern'),
  ('contentMediaType'),
  ('contentEncoding'),
  ('contentSchema'),
  ('format'),
  -- array
  ('items'),
  ('prefixItems'),
  ('additionalItems'),
  ('minItems'),
  ('maxItems'),
  ('uniqueItems'),
  ('contains'),
  ('minContains'),
  ('maxContains'),
  ('unevaluatedItems'),
  -- object
  ('properties'),
  ('minProperties'),
  ('maxProperties'),
  ('patternProperties'),
  ('required'),
  ('dependentRequired'),
  ('propertyNames'),
  ('additionalProperties'),
  ('unevaluatedProperties'),
  -- combi
  ('allOf'),
  ('anyOf'),
  ('oneOf'),
  ('not'),
  ('if'),
  ('then'),
  ('else'),
  -- misc
  ('dependentSchemas'),
  ('$defs'),
  ('definitions')
;

\echo '# Per keyword'
DROP TABLE IF EXISTS PerKeyWords;

CREATE TABLE PerKeyWords AS
SELECT
  word,
  COUNT(CASE WHEN js_stats->word IS NOT NULL THEN 1 ELSE NULL END) AS "# schema",
  SUM((js_stats->>word)::INT) AS "# occ",
  PERCENT(COUNT(CASE WHEN js_stats->word IS NOT NULL THEN 1 ELSE NULL END), COUNT(DISTINCT ssid)) AS "%"
FROM SchemaStats
CROSS JOIN OfficialKeywords
GROUP BY 1;

INSERT INTO PerKeyWords
SELECT
  'id/$id',
  COUNT(CASE WHEN js_stats->'id' IS NOT NULL OR js_stats->'$id' IS NOT NULL THEN 1 ELSE NULL END),
  SUM((js_stats->>'id')::INT) + SUM((js_stats->>'$id')::INT),
  PERCENT(COUNT(CASE WHEN js_stats->'id' IS NOT NULL OR js_stats->'$id' IS NOT NULL THEN 1 ELSE NULL END), COUNT(DISTINCT ssid))
FROM SchemaStats;

INSERT INTO PerKeyWords
SELECT
  'definitions/$defs',
  COUNT(CASE WHEN js_stats->'definitions' IS NOT NULL OR js_stats->'$defs' IS NOT NULL THEN 1 ELSE NULL END),
  SUM((js_stats->>'definitions')::INT) + SUM((js_stats->>'$defs')::INT),
  PERCENT(COUNT(CASE WHEN js_stats->'definitions' IS NOT NULL OR js_stats->'$defs' IS NOT NULL THEN 1 ELSE NULL END), COUNT(DISTINCT ssid))
FROM SchemaStats;

SELECT *
FROM PerKeyWords
ORDER BY 2 DESC;

\echo '# schemas without type hints?'
SELECT
  origin,
  COUNT(*)
FROM SchemaStats
JOIN SourceOrigin USING(source)
WHERE js_stats->'type' IS NULL
  AND js_stats->'enum' IS NULL
  AND js_stats->'const' IS NULL
  AND js_stats->'$ref' IS NULL
GROUP BY GROUPING SETS ((1), ())
ORDER BY 1;

\echo '# to check'
SELECT
  origin,
  source,
  chemin
FROM SchemaStats
JOIN SourceOrigin USING(source)
WHERE js_stats->'type' IS NULL
  AND js_stats->'enum' IS NULL
  AND js_stats->'const' IS NULL
  AND js_stats->'$ref' IS NULL
  AND origin = 'store'
ORDER BY 1, 2;


\echo '# strings, array, object, null and bool'
SELECT
  'string' AS "type",
  MIN(nb_strings) AS "min",
  ROUND(AVG(nb_strings), 1) AS "avg",
  PERCENTILE_DISC(0.25) WITHIN GROUP(ORDER BY nb_strings) AS "1q",
  PERCENTILE_DISC(0.5) WITHIN GROUP(ORDER BY nb_strings) AS "med",
  PERCENTILE_DISC(0.75) WITHIN GROUP(ORDER BY nb_strings) AS "3q",
  MAX(nb_strings) AS "max",
  PERCENT(AVG(nb_strings)::INT, AVG(nb_strings+nb_nums+nb_ints+nb_array+nb_bools+nb_nulls+nb_object)::INT) AS "%"
  FROM SchemaStats
UNION
SELECT
  'num',
  MIN(nb_nums) AS "min",
  ROUND(AVG(nb_nums),1) AS "avg",
  PERCENTILE_DISC(0.25) WITHIN GROUP(ORDER BY nb_nums) AS "1q",
  PERCENTILE_DISC(0.5) WITHIN GROUP(ORDER BY nb_nums),
  PERCENTILE_DISC(0.75) WITHIN GROUP(ORDER BY nb_nums) AS "3q",
  MAX(nb_nums) AS "max",
  PERCENT(AVG(nb_nums)::INT, AVG(nb_strings+nb_nums+nb_ints+nb_array+nb_bools+nb_nulls+nb_object)::INT) AS "%"
  FROM SchemaStats
UNION
SELECT
  'int',
  MIN(nb_ints) AS "min",
  ROUND(AVG(nb_ints),1) AS "avg",
  PERCENTILE_DISC(0.25) WITHIN GROUP(ORDER BY nb_ints) AS "1q",
  PERCENTILE_DISC(0.5) WITHIN GROUP(ORDER BY nb_ints),
  PERCENTILE_DISC(0.75) WITHIN GROUP(ORDER BY nb_ints) AS "3q",
  MAX(nb_ints) AS "max",
  PERCENT(AVG(nb_ints)::INT, AVG(nb_strings+nb_nums+nb_ints+nb_array+nb_bools+nb_nulls+nb_object)::INT) AS "%"
  FROM SchemaStats
UNION
SELECT
  'array',
  MIN(nb_array) AS "min",
  ROUND(AVG(nb_array),1) AS "avg",
  PERCENTILE_DISC(0.25) WITHIN GROUP(ORDER BY nb_array) AS "1q",
  PERCENTILE_DISC(0.5) WITHIN GROUP(ORDER BY nb_array),
  PERCENTILE_DISC(0.75) WITHIN GROUP(ORDER BY nb_array) AS "3q",
  MAX(nb_array) AS "max",
  PERCENT(AVG(nb_array)::INT, AVG(nb_strings+nb_nums+nb_ints+nb_array+nb_bools+nb_nulls+nb_object)::INT) AS "%"
  FROM SchemaStats
UNION
SELECT
  'object',
  MIN(nb_object) AS "min",
  ROUND(AVG(nb_object),1) AS "avg",
  PERCENTILE_DISC(0.25) WITHIN GROUP(ORDER BY nb_object) AS "1q",
  PERCENTILE_DISC(0.5) WITHIN GROUP(ORDER BY nb_object),
  PERCENTILE_DISC(0.75) WITHIN GROUP(ORDER BY nb_object) AS "3q",
  MAX(nb_object) AS "max",
  PERCENT(AVG(nb_object)::INT, AVG(nb_strings+nb_nums+nb_ints+nb_array+nb_bools+nb_nulls+nb_object)::INT) AS "%"
  FROM SchemaStats
UNION
SELECT
  'null',
  MIN(nb_nulls) AS "min",
  ROUND(AVG(nb_nulls),1) AS "avg",
  PERCENTILE_DISC(0.25) WITHIN GROUP(ORDER BY nb_nulls) AS "1q",
  PERCENTILE_DISC(0.5) WITHIN GROUP(ORDER BY nb_nulls),
  PERCENTILE_DISC(0.75) WITHIN GROUP(ORDER BY nb_nulls) AS "3q",
  MAX(nb_nulls) AS "max",
  PERCENT(AVG(nb_nulls)::INT, AVG(nb_strings+nb_nums+nb_ints+nb_array+nb_bools+nb_nulls+nb_object)::INT) AS "%"
  FROM SchemaStats
UNION
SELECT
  'bool',
  MIN(nb_bools) AS "min",
  ROUND(AVG(nb_bools),1) AS "avg",
  PERCENTILE_DISC(0.25) WITHIN GROUP(ORDER BY nb_bools) AS "1q",
  PERCENTILE_DISC(0.5) WITHIN GROUP(ORDER BY nb_bools),
  PERCENTILE_DISC(0.75) WITHIN GROUP(ORDER BY nb_bools) AS "3q",
  MAX(nb_bools) AS "max",
  PERCENT(AVG(nb_bools)::INT, AVG(nb_strings+nb_nums+nb_ints+nb_array+nb_bools+nb_nulls+nb_object)::INT) AS "%"
  FROM SchemaStats
UNION
SELECT
  'item',
  MIN(nb_items) AS "min",
  ROUND(AVG(nb_items),1) AS "avg",
  PERCENTILE_DISC(0.25) WITHIN GROUP(ORDER BY nb_items) AS "1q",
  PERCENTILE_DISC(0.5) WITHIN GROUP(ORDER BY nb_items),
  PERCENTILE_DISC(0.75) WITHIN GROUP(ORDER BY nb_items) AS "3q",
  MAX(nb_items) AS "max",
  PERCENT(AVG(nb_items)::INT, AVG(nb_strings+nb_nums+nb_ints+nb_array+nb_bools+nb_nulls+nb_object)::INT) AS "%"
  FROM SchemaStats
UNION
SELECT
  'prop',
  MIN(nb_props) AS "min",
  ROUND(AVG(nb_props),1) AS "avg",
  PERCENTILE_DISC(0.25) WITHIN GROUP(ORDER BY nb_props) AS "1q",
  PERCENTILE_DISC(0.5) WITHIN GROUP(ORDER BY nb_props),
  PERCENTILE_DISC(0.75) WITHIN GROUP(ORDER BY nb_props) AS "3q",
  MAX(nb_props) AS "max",
  PERCENT(AVG(nb_props)::INT, AVG(nb_strings+nb_nums+nb_ints+nb_array+nb_bools+nb_nulls+nb_object)::INT) AS "%"
  FROM SchemaStats ;

\echo '# schemas with unused definitions'
SELECT origin, COUNT(*) FILTER (WHERE js_stats->'<unused-defs>' IS NOT NULL)
FROM SchemaStats
JOIN SourceOrigin USING (source)
GROUP BY 1
ORDER BY 2 DESC;
