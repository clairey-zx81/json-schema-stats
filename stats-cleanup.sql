-- cleanup duplicates

\echo '# count case before cleaning by Corpus sources'
DROP VIEW IF EXISTS CorpusSourcesCounts;
CREATE VIEW CorpusSourcesCounts AS
SELECT origin,
  CASE
    WHEN soid BETWEEN 4 AND 8 THEN 'divers' 
    WHEN soid BETWEEN 9 AND 10 THEN 'test-suite'
    WHEN soid BETWEEN 11 AND 12 THEN 'spec'
    WHEN soid BETWEEN 15 AND 19 THEN 'misc'
    ELSE source
  END AS "source", 
  COUNT(*) AS "cnt"
FROM schemastats
JOIN SourceOrigin USING(source)
GROUP BY 1, 2;

DROP TABLE IF EXISTS CSCResults;
CREATE TABLE CSCResults(
  origin TEXT NOT NULL,
  source TEXT NOT NULL,
  files INTEGER,
  schemas INTEGER DEFAULT NULL,
  PRIMARY KEY(origin, source)
);

INSERT INTO CSCResults(origin, source, files)
SELECT origin, source, cnt
FROM CorpusSourcesCounts;

SELECT
  origin,
  source,
  COUNT(*) AS "# files",
  COUNT(DISTINCT rhash) AS "raw ≠",
  COUNT(DISTINCT nhash) AS "norm ≠",
  percent(COUNT(DISTINCT rhash), (SELECT COUNT(*) FROM SchemaStats)) AS "raw %",
  percent(COUNT(DISTINCT nhash), (SELECT COUNT(*) FROM SchemaStats)) AS "norm %"
FROM SchemaStats
JOIN SourceOrigin USING(source)
GROUP BY GROUPING SETS ((1), (2), ())
ORDER BY 2 DESC, 1;

\echo '# count case repeats'
SELECT
  origin,
  COUNT(*) AS "# files",
  COUNT(DISTINCT rhash) AS "raw ≠",
  COUNT(DISTINCT nhash) AS "norm ≠",
  percent(COUNT(DISTINCT rhash), (SELECT COUNT(*) FROM SchemaStats)) AS "raw %",
  percent(COUNT(DISTINCT nhash), (SELECT COUNT(*) FROM SchemaStats)) AS "norm %"
FROM SchemaStats
JOIN SourceOrigin USING(source)
GROUP BY GROUPING SETS ((1), ())
ORDER BY 2 DESC, 1;

\echo '# JSC-related stats repeats'
WITH
  JSC_SchemaStats AS (
    SELECT *
    FROM SchemaStats
    WHERE source IN ('json-schema-corpus', 'JSC_extracts')
  ),
  Total(cnt) AS (
    SELECT COUNT(*) FROM JSC_SchemaStats
  )
SELECT
  COUNT(*) AS "# files",
  COUNT(DISTINCT rhash) AS "raw ≠",
  COUNT(DISTINCT nhash) AS "norm ≠",
  percent(COUNT(DISTINCT rhash), (SELECT cnt FROM Total)) AS "raw %",
  percent(COUNT(DISTINCT nhash), (SELECT cnt FROM Total)) AS "norm %"
FROM JSC_SchemaStats;

\echo '# cleanup repeats!'
WITH
  duplicated(nhash) AS (
    SELECT nhash
    FROM SchemaStats
    GROUP BY nhash
    HAVING COUNT(nhash) > 1
  ),
  firstid(nhash, ssid) AS (
    SELECT nhash, MIN(ssid)
    FROM SchemaStats
    WHERE nhash IN (SELECT nhash FROM duplicated)
    GROUP BY nhash
  )
DELETE FROM SchemaStats
WHERE nhash IN (SELECT nhash FROM duplicated)
  AND ssid NOT IN (SELECT ssid FROM firstid);

\echo '# no more repeats'
SELECT COUNT(*), COUNT(DISTINCT nhash) AS "norm ≠"
FROM SchemaStats;

\echo '# files without repeats'
SELECT
  origin,
  COUNT(*) AS "# files",
  percent(COUNT(*), (SELECT COUNT(*) FROM SchemaStats)) AS "%"
FROM SchemaStats
JOIN SourceOrigin USING(source)
GROUP BY GROUPING SETS ((1), ())
ORDER BY 2 DESC, 1;

--
-- REMOVE NON JSON SCHEMAS
--

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

\echo '# 10 smallest unclear schemas'
DROP VIEW IF EXISTS TopTenSmallInvalidSchemaStatsUnclear;
CREATE VIEW TopTenSmallInvalidSchemaStatsUnclear AS
SELECT ssid, chemin, json_length
FROM InvalidSchemaStatsUnclear
ORDER BY json_length ASC
LIMIT 10;

-- should be empty!
SELECT * FROM TopTenSmallInvalidSchemaStatsUnclear;

-- count explicit JSON schema : source = opendata OR test-suite OR
-- vm1, vm2, vm3, vm4, vm6, vm7, vm8, vm9, vmn = True
-- sure json schema
\echo '# Sure JSON schema'
DROP VIEW IF EXISTS SureJsonSchema;
CREATE VIEW SureJsonSchema AS
SELECT *, 

  -- trusted sources
     source IN ('test-suite-extracts', 'JSON-Schema-Test-Suite',
                'data.opendatasoft.com', 'opendata.agenceore.fr',
                'public.opendatasoft.com', 'examples.opendatasoft.com',
                'data.laregion.fr', 'apidae', 'openapi-spec', 'data.sncf.com',
                'VRAC', 'JSC_extracts', 'schemastore-analysis', 'json-schema-spec')

  -- OR any *strict* validation
  OR vm1 OR vm2 OR vm3 OR vm4 OR vm6 OR vm7 OR vm8 OR vm9 OR vmn

  -- OR explicitely declared JSON schema
  OR (js_stats->'<explicit-schema>')::BOOLEAN

  -- OR some JSON schema property name found at root
  OR (js_stats->'<schema-prop>')::BOOLEAN

    AS "sure",

  -- filter out some stuff than cannot be a JSON Schema

     (js_stats->>'<$schema>' IS NOT NULL

 AND (js_stats->>'<$schema>' LIKE '%frictionlessdata.io/schemas/table-schema.json%'
   OR js_stats->>'<$schema>' LIKE '%opendataschema.frama.io/catalog/schema-catalog.json%'
   OR js_stats->>'<$schema>' LIKE '%schema.management.azure.com/schemas/%/deploymentTemplate.json%'))
   OR (js_stats->'<bad-root>')::BOOLEAN

    AS "sure_not"

FROM schemastats;

SELECT
  COUNT(*) FILTER(WHERE sure) AS "sure",
  COUNT(*) FILTER(WHERE NOT sure) AS "not sure",
  COUNT(*) FILTER(WHERE sure_not) AS "sure not",
  COUNT(*) FILTER(WHERE sure IS NULL) AS "NULL",
  COUNT(*) FILTER(WHERE sure AND sure_not) AS "contradiction",
  COUNT(*) AS "total"
FROM SureJsonSchema;

\echo '# not sure, but not sure not…'
SELECT origin, COUNT(*)
FROM SureJsonSchema
JOIN SourceOrigin USING(source)
WHERE NOT sure AND NOT sure_not
GROUP BY GROUPING SETS ((1), ())
ORDER BY 2 DESC, 1;

\echo '# removed invalid schemas'
INSERT INTO InvalidSchema
  SELECT *
  FROM schemastats
  WHERE ssid IN (SELECT ssid FROM SureJsonSchema WHERE sure_not OR NOT sure)
;
SELECT origin, COUNT(*) AS "# schema"
FROM InvalidSchema
JOIN SourceOrigin USING(source)
GROUP BY GROUPING SETS ((1), ())
ORDER BY 2 DESC, 1;

DELETE FROM SchemaStats
WHERE ssid IN (SELECT ssid FROM SureJsonSchema WHERE sure_not OR NOT sure);

\echo '# $schema *BUT* not really a schema!'
DROP VIEW FalsePositiveSchemas CASCADE;
CREATE VIEW FalsePositiveSchemas AS
  SELECT *
  FROM SchemaStats
  WHERE (js_stats->'<explicit-schema>')::BOOLEAN
    AND js_stats->'<unknown-keywords>' @> JSONB '["name", "groups"]'
;

SELECT COUNT(*) FROM FalsePositiveSchemas;

INSERT INTO InvalidSchema
  SELECT *
  FROM schemastats
  WHERE ssid IN (SELECT ssid FROM FalsePositiveSchemas)
;

DELETE FROM SchemaStats
WHERE ssid IN (SELECT ssid FROM FalsePositiveSchemas);

\echo '# schemas without repeats'
SELECT
  origin,
  COUNT(*) AS "# schemas",
  percent(COUNT(*), (SELECT COUNT(*) FROM SchemaStats)) AS "%"
FROM SchemaStats
JOIN SourceOrigin USING(source)
GROUP BY GROUPING SETS ((1), ())
ORDER BY 2 DESC, 1;

\echo '# check: MUST BE EMPTY'
SELECT ssid, chemin, json_length
FROM SureJsonSchema
WHERE NOT sure AND NOT sure_not
ORDER BY 2;

\echo '# count case after cleaning by Corpus sources'
UPDATE CSCResults AS res
  SET schemas = csc.cnt
  FROM CorpusSourcesCounts AS csc
  WHERE res.origin = csc.origin
    AND res.source = csc.source;

SELECT origin, source, files, schemas, percent(schemas, files) AS "%"
FROM cscresults
  UNION
SELECT NULL, NULL, SUM(files), SUM(schemas), percent(SUM(schemas), SUM(files)) AS "%"
FROM cscresults
GROUP BY 1, 2
ORDER BY 1, 4 DESC;

\echo '# min, avg, percentile, max on file size'
SELECT
  origin,
  MIN(json_length) AS "min",
  ROUND(AVG(json_length), 1) AS "avg",
  ROUND(STDDEV(json_length), 1) AS "sd",
  PERCENTILE_DISC(0.25) WITHIN GROUP(ORDER BY json_length) AS "q1",
  PERCENTILE_DISC(0.5) WITHIN GROUP(ORDER BY json_length) AS "med",
  PERCENTILE_DISC(0.75) WITHIN GROUP(ORDER BY json_length) AS "q3",
  MAX(json_length) AS "max",
  COUNT(*) AS "#"
FROM schemastats
JOIN SourceOrigin USING (source)
GROUP BY GROUPING SETS ((1), ())
ORDER BY 1;
