\echo '# draft incompatibility'

SELECT
  origin,
  COUNT(*) AS "#",
  COUNT(DISTINCT ssid) AS "# schema"
FROM AllErrors
WHERE category LIKE '%incompatibility%'
GROUP BY GROUPING SETS ((1), ())
ORDER BY 3 DESC, 1;

\echo '# missing type details'
SELECT
  origin,
  chemin,
  error,
  path
FROM AllErrors
WHERE origin <> 'corpus'
  AND category LIKE '%incompatibility%'
ORDER BY 1, 2, 3;
