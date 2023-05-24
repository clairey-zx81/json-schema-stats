--
-- VERSIONS
--
\echo '# advertised versions (0 for none, 11 for implicit latest)'
SELECT
  version,
  COUNT(*) AS "#",
  percent(COUNT(*), (SELECT COUNT(*) FROM SchemaStats)) AS "%",
  percent(COUNT(*) FILTER (WHERE version <> 0), (SELECT COUNT(*) FROM SchemaStats WHERE version <> 0)) AS "% adv"
FROM SchemaStats
GROUP BY GROUPING SETS ((1), ())
ORDER BY 1;

\echo '# guessed versions (from keywords, ignoring $schema)'
SELECT
  js_stats->'<versions>' AS "versions",
  COUNT(*) AS "#",
  percent(COUNT(*), (SELECT COUNT(*) FROM SchemaStats)) AS "%"
FROM SchemaStats
GROUP BY GROUPING SETS ((1), ())
ORDER BY 2 DESC, 1;

-- no compatible version found, and some errors
DROP VIEW IF EXISTS BadVersions CASCADE;
CREATE VIEW BadVersions AS
  SELECT *
  FROM SchemaStats
  WHERE js_stats->'<versions>' IS NULL
    AND js_stats->'<errors>' IS NOT NULL;

\echo '# bad versions (no compat but errors)'
SELECT COUNT(*) AS "#"
FROM BadVersions;

\echo '# bad version analysis (no compatible version found)'
DROP VIEW IF EXISTS BadVersionAnalysis;
CREATE VIEW BadVersionAnalysis AS
  SELECT
    *,
    regexp_substr(errors->>1, '\[.*\]') AS "error"
  FROM BadVersions,
    LATERAL jsonb_array_elements(js_stats->'<errors>') AS errors
  WHERE errors->>0 = 'incompatible version guesses';

SELECT
  error,
  COUNT(*) AS "#",
  percent(COUNT(*), (SELECT COUNT(*) FROM BadVersionAnalysis)) AS "%"
FROM BadVersionAnalysis AS bva
GROUP BY GROUPING SETS ((1), ())
HAVING COUNT(*) >= 10
ORDER BY 2 DESC, 1;

\echo '# bad versions (non corpus)'
SELECT ssid, chemin
FROM BadVersions
JOIN SourceOrigin USING (source)
WHERE origin <> 'corpus';

-- show compatibilities
CREATE OR REPLACE FUNCTION VersionCompatibility(ss SchemaStats)
RETURNS TEXT IMMUTABLE STRICT AS $$
DECLARE
  cmp BOOLEAN;
BEGIN
  -- TRUE: advertised is compatible
  -- FALSE: advertised is not compatible
  -- NULL: empty compatibility set
  cmp := ss.version::TEXT::JSONB <@ (ss.js_stats->'<versions>');
  IF cmp IS NULL THEN
    RETURN 'none';
  ELSIF cmp = TRUE THEN
    RETURN 'comp';
  ELSE
    RETURN 'incomp';
  END IF;
END;
$$ LANGUAGE plpgsql;

\echo '# compatibility when version is advertised'
SELECT
  ss.version,
  COUNT(*) FILTER(WHERE ss.VersionCompatibility = 'comp') AS "compat",
  COUNT(*) FILTER(WHERE ss.VersionCompatibility = 'incomp') AS "incomp",
  COUNT(*) FILTER(WHERE ss.VersionCompatibility = 'none') AS "none",
  COUNT(*) AS "# schema",
  percent(COUNT(*), (SELECT COUNT(*) FROM SchemaStats WHERE version >= 1)) AS "%"
FROM SchemaStats AS ss
WHERE version >= 1
GROUP BY GROUPING SETS ((1), ())
ORDER BY 1;

CREATE OR REPLACE VIEW LatestCompat AS
  SELECT *
  FROM SchemaStats
  WHERE version = 11
    AND js_stats->'<versions>' IS NOT NULL;

\echo '# latest version real compatibility'
SELECT
  js_stats->>'<versions>' AS versions,
  version::TEXT::JSONB <@ (js_stats->'<versions>') AS compatible,
  COUNT(*) AS "# schemas",
  percent(COUNT(*), (SELECT COUNT(*) FROM LatestCompat)) AS "%",
  ROUND(AVG(json_length), 1) AS "size"
FROM LatestCompat
GROUP BY GROUPING SETS ((1, 2), (2), ())
ORDER BY 2 DESC, 3 DESC, 1;

\echo '# latest version real compatibility per version'
SELECT
  v,
  COUNT(DISTINCT ssid) FILTER (WHERE v::TEXT::JSONB <@ (js_stats->'<versions>')) AS "# schemas",
  percent(COUNT(DISTINCT ssid) FILTER (WHERE v::TEXT::JSONB <@ (js_stats->'<versions>')),
    (SELECT COUNT(DISTINCT ssid) FROM LatestCompat)) AS "%"
FROM LatestCompat
CROSS JOIN generate_series(1, 10) AS v
GROUP BY GROUPING SETS ((1), ())
ORDER BY 1;

\echo '# multiple inconsistent versions'
SELECT
  ssid,
  chemin,
  js_stats->'<versions>' AS "versions"
FROM SchemaStats
WHERE version = -1
ORDER BY 1, 2;

-- 

CREATE OR REPLACE VIEW NoneCompat AS
  SELECT *
  FROM SchemaStats
  WHERE version = 0
    AND js_stats->'<versions>' IS NOT NULL;

\echo '# no version real compatibility'
SELECT
  js_stats->>'<versions>' AS versions,
  version::TEXT::JSONB <@ (js_stats->'<versions>') AS compatible,
  COUNT(*) AS "# schemas",
  percent(COUNT(*), (SELECT COUNT(*) FROM NoneCompat)) AS "%",
  ROUND(AVG(json_length), 1) AS "size"
FROM NoneCompat
GROUP BY GROUPING SETS ((1, 2), (2), ())
ORDER BY 2 DESC, 3 DESC, 1;

\echo '# no version real compatibility per version'
SELECT
  v,
  COUNT(DISTINCT ssid) FILTER (WHERE v::TEXT::JSONB <@ (js_stats->'<versions>')) AS "# schemas",
  percent(COUNT(DISTINCT ssid) FILTER (WHERE v::TEXT::JSONB <@ (js_stats->'<versions>')),
    (SELECT COUNT(DISTINCT ssid) FROM NoneCompat)) AS "%"
FROM NoneCompat
CROSS JOIN generate_series(1, 10) AS v
GROUP BY GROUPING SETS ((1), ())
ORDER BY 1;


\echo '# latest version (11)'
SELECT origin, source, COUNT(*) FROM schemastats JOIN sourceorigin USING(source) WHERE version = 11 GROUP BY 1, 2;


\echo '# schemas that pass a *tighter* JSON Schema spec'
SELECT
  origin,
  COUNT(*),
  percent(COUNT(*) FILTER (WHERE vmt), COUNT(*))
FROM SchemaStats
JOIN SourceOrigin USING (source)
GROUP BY GROUPING SETS ((1), ())
ORDER BY 1;
