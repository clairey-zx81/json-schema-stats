\echo '# tight schemas'

SELECT
  origin,
  COUNT(*) AS "#",
  percent(COUNT(*) FILTER (WHERE vmt), COUNT(*)) AS "%"
FROM SchemaStats
JOIN SourceOrigin USING (source)
GROUP BY GROUPING SETS ((1), ())
ORDER BY 1;
