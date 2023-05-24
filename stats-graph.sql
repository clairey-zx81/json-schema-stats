-- Taille fichier en log2
\copy (SELECT ROUND(log(json_length) / log(2.0)), count(*) FROM schemastats GROUP BY 1 ORDER BY 1) TO 'graph-size.csv' WITH (FORMAT csv)

-- Nb /versions OLD
\copy (SELECT version, count(*) FROM schemastats GROUP BY 1 ORDER BY 1) TO 'graph-version.csv' WITH (FORMAT csv)

-- Nb /version with none, last and others
\copy (SELECT CASE version WHEN 0 THEN 'none' WHEN 11 THEN 'last' ELSE 'v1-v10' END, count(*) FROM schemastats GROUP BY 1 ORDER BY 1 DESC) TO 'graph-version-simple.csv' WITH (FORMAT csv)

-- Nb /versions 1-10
\copy (SELECT CASE WHEN version BETWEEN 8 AND 10 THEN 'v8-v10' ELSE 'v'||version END, count(*) FROM schemastats WHERE version BETWEEN 3 AND 10 AND version <> 5 GROUP BY 1 ORDER BY 1) TO 'graph-version-numbers.csv' WITH (FORMAT csv)

-- Per keywords
\copy (SELECT word, "%" FROM PerKeyWords WHERE word NOT IN ('definitions','$defs','id','$id') AND "%" < 1.0 ORDER BY 2 DESC, 1) TO 'graph-kw-petit.csv' WITH (FORMAT csv)
\copy (SELECT word, "%" FROM PerKeyWords WHERE word NOT IN ('definitions','$defs','id','$id') AND "%" >= 1.0 ORDER BY 2 DESC, 1) TO 'graph-kw-grand.csv' WITH (FORMAT csv)
