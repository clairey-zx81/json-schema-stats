\echo '# type errors'
SELECT
  origin,
  COUNT(*) AS "#",
  COUNT(DISTINCT ssid) AS "# schema"
FROM AllErrors
WHERE category = 'type error'
GROUP BY GROUPING SETS ((1), ())
ORDER BY 3 DESC, 1;

\echo '# type errors details'
\x on
SELECT
  origin,
  chemin,
  ssid,
  error,
  path
FROM AllErrors
WHERE origin <> 'corpus'
  AND category = 'type error'
ORDER BY 1, 2, 4;

\x auto

\echo '# missing type declaration'
SELECT
  origin,
  COUNT(*) AS "# occs",
  COUNT(DISTINCT ssid) AS "# schema"
FROM AllErrors
WHERE category = 'missing type declaration'
GROUP BY GROUPING SETS ((1), ())
ORDER BY 3 DESC, 1;

\echo '# type details with missing type declaration'
\x on
SELECT
  origin,
  chemin,
  ssid,
  error,
  path
FROM AllErrors
WHERE origin = 'store' -- <> 'corpus'
  AND category = 'missing type declaration'
ORDER BY 1, 2, 4;

\x auto


\echo '# type inconsistency'
SELECT
  origin,
  COUNT(*) AS "# occs",
  COUNT(DISTINCT ssid) AS "# schema"
FROM AllErrors
WHERE category = 'type inconsistency'
GROUP BY GROUPING SETS ((1), ())
ORDER BY 3 DESC, 1;

\echo '# type details with type inconsistency'
\x on
SELECT
  origin,
  chemin,
  ssid,
  error,
  path
FROM AllErrors
WHERE origin = 'store' -- <> 'corpus'
  AND category = 'type inconsistency'
ORDER BY 1, 2, 4;

