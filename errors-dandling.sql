\echo '# dangling $ref value'

SELECT
  origin,
  COUNT(*) AS "#",
  COUNT(DISTINCT ssid) AS "# schema"
FROM AllErrors
WHERE category LIKE 'dangling $ref value'
GROUP BY GROUPING SETS ((1), ())
ORDER BY 3 DESC, 1;

\echo '# dangling type details'
SELECT
  origin,
  chemin,
  error,
  path
FROM AllErrors
WHERE origin = 'store'
  AND category LIKE 'dangling $ref value'
ORDER BY 1, 2, 3;
