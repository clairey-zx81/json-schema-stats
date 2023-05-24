-- Errors typos keywords

\echo '# Count per source'
SELECT
  source,
  COUNT(*) FILTER (WHERE js_stats->'<typos>' IS NOT NULL) AS "# typos",
  COUNT(DISTINCT ssid) AS "# schema"
FROM schemastats
GROUP BY 1
ORDER BY 1;

\echo '# per keyword'
SELECT
  keyword,
  COUNT(*) AS "# cases",
  COUNT(DISTINCT ssid) AS "# schemas"
FROM schemastats
CROSS JOIN LATERAL jsonb_array_elements_text(js_stats->'<typos-keywords>') AS keyword
WHERE js_stats->'<typos>' IS NOT NULL
GROUP BY GROUPING SETS ((1), ())
HAVING COUNT(*) >= 5
ORDER BY 2 DESC, 1;

\echo '# Detailed count per source'
SELECT
  source,
  js_stats->'<typos-keywords>' AS "bad keywords",
  COUNT(*) AS "# schema"
FROM schemastats
WHERE js_stats->'<typos>' IS NOT NULL
GROUP BY 1,2
ORDER BY 3 DESC, 1, 2;

\echo '# All bad keywords'
SELECT
  js_stats->'<typos-keywords>' AS "bad keywords",
  chemin AS "where"
FROM schemastats
WHERE js_stats->'<typos>' IS NOT NULL
ORDER BY 2, 1;

\echo '# With path'
SELECT
  chemin,
  js_stats->'<typos-keywords-where>' AS "where"
FROM schemastats
WHERE source IN ('schemastore','schemastore-analysis')
  AND js_stats->'<typos>' IS NOT NULL
ORDER BY 1; 
