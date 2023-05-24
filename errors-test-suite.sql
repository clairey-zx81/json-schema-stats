-- look for errors in the JSON Schema test suite!
-- strict vs fuzzy?
-- version incompatibilities?

CREATE OR REPLACE FUNCTION TSVersion(chemin TEXT)
RETURNS INTEGER IMMUTABLE STRICT AS $$
  SELECT CASE
    WHEN chemin LIKE '%/draft3_%' THEN 3
    WHEN chemin LIKE '%/draft4_%' THEN 4
    WHEN chemin LIKE '%/draft6_%' THEN 6
    WHEN chemin LIKE '%/draft7_%' THEN 7
    WHEN chemin LIKE '%/draft2019-09_%' THEN 8
    WHEN chemin LIKE '%/draft2020-12_%' THEN 9
    WHEN chemin LIKE '%/draft-next_%' THEN 10
    ELSE 9  -- assume latest???
  END; 
$$ LANGUAGE SQL;

\echo '# for information, missing types in test suite'
SELECT
  TSVersion(ss.chemin) AS "ts_version",
  COUNT(*)
FROM AllErrors AS ss
WHERE category = 'missing type'
  AND source IN ('test-suite-extracts', 'JSON-Schema-Test-Suite')
GROUP BY 1;

DROP VIEW IF EXISTS TestSuiteStats CASCADE;
CREATE VIEW TestSuiteStats AS
SELECT
  *,
  TSVersion(ss.chemin) AS "ts_version"
FROM AllErrors AS ss
WHERE category <> 'missing type'
  AND source IN ('test-suite-extracts', 'JSON-Schema-Test-Suite');

\echo '# test cases with errors (real or not, ignoring missing type) per version'
SELECT ts_version, COUNT(*)
FROM TestSuiteStats AS ss
GROUP BY GROUPING SETS ((1), ())
ORDER BY 1;

\echo '# test cases error *candidates*'
-- TODO filter out some errors!
SELECT chemin, category, error, path
FROM AllErrors
WHERE source IN ('test-suite-extracts', 'JSON-Schema-Test-Suite')
  AND NOT (category = 'unexpected $schema version' AND error ~ 'localhost:1234'
        OR category = 'invalid regex' AND error ~ E'p\{'
        OR category = 'invalid regex' AND error ~ E'\c[A-Z]'
        OR category = 'non integer value' AND error ~ 'm(in|ax).* number'
        OR category = 'missing type'
  )
ORDER BY 1, 2, 3, 4;

-- strict validation incompatibility
\echo '# strict validation incompatibility'
SELECT
  TSVersion(chemin) AS "version",
  chemin,
  CASE TSVersion(chemin)
    WHEN 3 THEN vm3
    WHEN 4 THEN vm4
    WHEN 6 THEN vm6
    WHEN 7 THEN vm7
    WHEN 8 THEN vm8
    WHEN 9 THEN vm9
    WHEN 10 THEN vmn
    ELSE NULL
  END AS "strict",
  CASE TSVersion(chemin)
    WHEN 3 THEN vm3n
    ELSE NULL
  END AS "nesting",
  CASE TSVersion(chemin)
    WHEN 3 THEN vm3f
    WHEN 4 THEN vm4f
    WHEN 6 THEN vm6f
    WHEN 7 THEN vm7f
    WHEN 8 THEN vm8f
    WHEN 9 THEN vm9f
    WHEN 10 THEN vmnf
    ELSE NULL
  END AS "fuzzy"
FROM SchemaStats
WHERE source IN ('test-suite-extracts', 'JSON-Schema-Test-Suite')
  AND (TSVersion(chemin) = 3 AND NOT vm3
    OR TSVersion(chemin) = 4 AND NOT vm4
    OR TSVersion(chemin) = 6 AND NOT vm6
    OR TSVersion(chemin) = 7 AND NOT vm7
    OR TSVersion(chemin) = 8 AND NOT vm8
    OR TSVersion(chemin) = 9 AND NOT vm9
    OR TSVersion(chemin) = 10 AND NOT vmn)
ORDER BY 1, 2;
