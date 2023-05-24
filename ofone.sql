\echo '# schemas with *Of with length one'
WITH OriginCount AS (
    SELECT origin, COUNT(*) AS cnt
    FROM SchemaStats
    JOIN SourceOrigin USING (source)
    GROUP BY 1
  )
SELECT
  origin,
  COUNT(*) AS "#",
  percent(COUNT(*), (SELECT cnt FROM OriginCount AS oc WHERE oc.origin = so.origin)) AS "%"
FROM SchemaStats
JOIN SourceOrigin AS so USING (source)
WHERE js_stats ? 'oneOf-one'
   OR js_stats ? 'anyOf-one'
   OR js_stats ? 'allOf-one'
GROUP BY GROUPING SETS ((1), ())
ORDER BY 1;

\echo '# small store examples'
SELECT
  ssid,
  chemin,
  json_length
FROM SchemaStats
JOIN SourceOrigin USING (source)
WHERE origin = 'store' AND
     (js_stats ? 'oneOf-one'
   OR js_stats ? 'anyOf-one'
   OR js_stats ? 'allOf-one')
ORDER BY 3 ASC, 1
LIMIT 20;
