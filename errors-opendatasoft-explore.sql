-- Erreur de niveau d'accolade (VRAC/postes-public-des-bibliotheques-FIXED)
\echo '# Error opendatasoft'

SELECT
  source,
  js_stats->'<unknown-keywords>',
  COUNT(*) 
FROM schemastats
WHERE source IN ('data.laregion.fr', 'data.opendatasoft.com', 'data.sncf.com',
   'examples.opendatasoft.com', 'opendata.agenceore.fr', 'public.opendatasoft.com')
GROUP BY GROUPING SETS ((1, 2), (2), ())
ORDER BY 1, 2;
