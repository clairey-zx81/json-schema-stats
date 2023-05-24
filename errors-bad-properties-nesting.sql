-- Errors bad properties nesting

-- TODO check manually and possibly remove more keywords…

DROP VIEW IF EXISTS BadPropertiesNesting;

CREATE VIEW BadPropertiesNesting AS
SELECT ssid, source, chemin, json_length,
  js_stats->'<bad-properties-nesting>' AS "# nestings",
  js_stats->'<bad-properties-nesting-where>' AS "where"
FROM schemastats
WHERE (js_stats->'<bad-properties-nesting>')::INT > 0;

\echo '# Errors bad properties nesting'
SELECT source, COUNT(*)
FROM BadPropertiesNesting
GROUP BY GROUPING SETS ((1), ())
ORDER BY 2 DESC, 1;

\echo '# All files with bad properties nesting'
SELECT * FROM BadPropertiesNesting
ORDER BY 2;
