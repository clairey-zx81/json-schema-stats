\echo '# bad mix'

SELECT
  origin,
  COUNT(*) AS "#",
  COUNT(DISTINCT ssid) AS "# schema"
FROM AllErrors
-- WHERE category = 'bad mix'
GROUP BY GROUPING SETS ((1), ())
ORDER BY 3 DESC, 1;

\echo '# bad mix details'
SELECT
  origin,
  chemin,
  error,
  path
FROM AllErrors
--WHERE 
--  category = 'bad mix'
  -- TODO also filter if format among others? remove format? check for format strings?
--  AND NOT error LIKE '% [''unknown'']'
ORDER BY 1, 2, 3;
