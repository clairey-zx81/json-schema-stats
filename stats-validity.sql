--
-- VALIDITY
--
-- general stats about possibly invalid schemas
-- to be investigated further…
--

\echo '# invalid schemas'
SELECT COUNT(*) AS "invalid schemas"
FROM SchemaStats AS ss
WHERE NOT ss.mvalid;

\echo '# fuzzy schemas'
SELECT COUNT(*) AS "fuzzy schemas"
FROM SchemaStats AS ss
WHERE ss.fvalidOnly;

\echo '# schemas with <errors>'
SELECT
  COUNT(*) AS "# schemas",
  SUM(jsonb_array_length(js_stats->'<errors>')) AS "# errors"
FROM SchemaStats
WHERE js_stats->'<errors>' IS NOT NULL;

DROP VIEW IF EXISTS AllErrors CASCADE;
CREATE VIEW AllErrors AS
SELECT
  ss.*,
  so.origin,
  error->>0 AS "category",
  error->>1 AS "error",
  error->>2 AS "path"
FROM SchemaStats AS ss
JOIN SourceOrigin AS so USING(source),
  LATERAL jsonb_array_elements(js_stats->'<errors>') AS error
WHERE js_stats->'<errors>' IS NOT NULL;

\echo '# errors per categories'
SELECT
  category,
  COUNT(*) AS "# errors",
  COUNT(DISTINCT ssid) AS "# schemas",
  percent(COUNT(DISTINCT ssid), (SELECT COUNT(*) FROM SchemaStats)) AS "%"
FROM AllErrors
GROUP BY GROUPING SETS ((1), ())
ORDER BY 3 DESC, 2 DESC, 1;

-- some errors are ignored because they may be false positive
DROP VIEW IF EXISTS SureErrors;

CREATE VIEW SureErrors AS
SELECT *
FROM AllErrors
WHERE category IN
  ('dangling $ref value', 'bad mix', 'draft incompatibility',
   'type error', 'invalid root schema type', 'unexpected type data',
   'invalid type value', 'incompatible version guesses', 'missing type declaration');

\echo '# sure errors'
SELECT
  category,
  COUNT(*) AS "# errors",
  COUNT(DISTINCT ssid) AS "# schemas",
  percent(COUNT(DISTINCT ssid), (SELECT COUNT(*) FROM SchemaStats)) AS "%"
FROM SureErrors
GROUP BY GROUPING SETS ((1), ())
ORDER BY 3 DESC, 2 DESC, 1;
 
SELECT
  origin,
  COUNT(*) AS "# errors",
  COUNT(DISTINCT ssid) AS "# schemas",
  percent(COUNT(DISTINCT ssid), (SELECT COUNT(*) FROM SchemaStats)) AS "%"
FROM SureErrors
GROUP BY GROUPING SETS ((1), ())
ORDER BY 3 DESC, 2 DESC, 1;

\echo '# errors detailed counts'
SELECT
  category,
  error,
  COUNT(*) AS "# errors",
  COUNT(DISTINCT ssid) AS "# schemas"
FROM AllErrors
GROUP BY 1, 2
HAVING COUNT(*) >= 10
ORDER BY 4 DESC, 3 DESC, 1, 2;

\echo '# schemas with <unknown>'
SELECT COUNT(*) AS "unknown"
FROM SchemaStats
WHERE js_stats->'<unknown>' IS NOT NULL;

\echo '# schemas with <typos>'
SELECT COUNT(*) AS "typos"
FROM SchemaStats
WHERE js_stats->'<typos>' IS NOT NULL;

\echo '# invalid schemas without <errors> or <unknown> or <typos>'
DROP VIEW IF EXISTS InvalidSchemaStatsUnclear CASCADE;
CREATE VIEW InvalidSchemaStatsUnclear AS
SELECT ss.*
FROM SchemaStats AS ss
WHERE NOT ss.mvalid
  AND js_stats->'<unknown>' IS NULL
  AND js_stats->'<typos>' IS NULL
  AND js_stats->'<errors>' IS NULL;

SELECT COUNT(*) AS "invalid without clear errors"
FROM InvalidSchemaStatsUnclear;

SELECT ssid, chemin
FROM InvalidSchemaStatsUnclear
ORDER BY 2;
