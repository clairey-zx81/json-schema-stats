--
-- Schema for storing statistics about collected JSON Schemas
-- 

DROP TABLE IF EXISTS SchemaStats;

CREATE TABLE SchemaStats(
  ssid SERIAL8 PRIMARY KEY,
  chemin TEXT UNIQUE NOT NULL,
  source TEXT NOT NULL,
  -- model validations draft, nesting, fuzzy…
  -- TODO hyper?
  vm1 BOOLEAN NOT NULL,
  vm1n BOOLEAN NOT NULL,
  vm2 BOOLEAN NOT NULL,
  vm2n BOOLEAN NOT NULL,
  vm3 BOOLEAN NOT NULL,
  vm3n BOOLEAN NOT NULL,
  vm3f BOOLEAN NOT NULL,
  vm4 BOOLEAN NOT NULL,
  vm4n BOOLEAN NOT NULL,
  vm4f BOOLEAN NOT NULL,
  vm6 BOOLEAN NOT NULL,
  vm6f BOOLEAN NOT NULL,
  vm7 BOOLEAN NOT NULL,
  vm7f BOOLEAN NOT NULL,
  vm8 BOOLEAN NOT NULL,
  vm8f BOOLEAN NOT NULL,
  vm9 BOOLEAN NOT NULL,
  vm9f BOOLEAN NOT NULL,
  vmn BOOLEAN NOT NULL,
  vmnf BOOLEAN NOT NULL,
  vmt BOOLEAN NOT NULL,
  -- advertised version if any, -1 if incompatible versions
  version INTEGER NOT NULL CHECK(version BETWEEN -1 AND 11),
  -- file and json normal hashes for deduplication
  rhash TEXT NOT NULL,
  nhash TEXT NOT NULL,
  -- max depth
  depth INTEGER NOT NULL,
  -- all encountered data in the schema (raw)
  nb_nulls INTEGER NOT NULL,
  nb_bools INTEGER NOT NULL,
  nb_ints INTEGER NOT NULL,
  nb_nums INTEGER NOT NULL,
  nb_strings INTEGER NOT NULL,
  nb_array INTEGER NOT NULL,
  nb_object INTEGER NOT NULL,
  nb_items INTEGER NOT NULL,
  nb_props INTEGER NOT NULL,
  nb_strlens INTEGER NOT NULL,
  -- json normal schema length
  json_length INTEGER NOT NULL,
  -- detailed stats of JSON Schema keyword usage
  js_stats JSONB NOT NULL
);

-- create a table regrouping all sources in 5 origins
DROP TABLE IF EXISTS SourceOrigin;

CREATE TABLE SourceOrigin(
  soid SERIAL8 PRIMARY KEY,
  source TEXT NOT NULL,
  origin TEXT NOT NULL
);

INSERT INTO SourceOrigin (source,origin)
VALUES
  ('json-schema-corpus','corpus'),
  ('JSC_extracts','corpus'),
  ('data.opendatasoft.com','opendatasoft'),
  ('public.opendatasoft.com','opendatasoft'),
  ('examples.opendatasoft.com','opendatasoft'),
  ('data.sncf.com','opendatasoft'),
  ('opendata.agenceore.fr','opendatasoft'),
  ('data.laregion.fr','opendatasoft'),
  ('test-suite-extracts','reference'),
  ('JSON-Schema-Test-Suite','reference'),
  ('json-schema-spec','reference'),
  ('schemas','reference'),
  ('schemastore','store'),
  ('schemastore-analysis','store'),
  ('VRAC','misc'),
  ('openAPI','misc'),
  ('schema.data.gouv.fr','misc'),
  ('apidae','misc'),
  ('sp-simulateurs','misc'),
  ('kubernetes', 'misc'),
  ('washington-post', 'misc')
;


-- create a copy for moved out json stuff
CREATE TABLE InvalidSchema (LIKE SchemaStats INCLUDING ALL);

-- tell whether a schema is valid in any way
CREATE OR REPLACE FUNCTION mvalid(ss SchemaStats) RETURNS BOOLEAN
IMMUTABLE STRICT AS $$
  SELECT ss.vm1 OR ss.vm1n
      OR ss.vm2 OR ss.vm2n
      OR ss.vm3 OR ss.vm3n OR ss.vm3f
      OR ss.vm4 OR ss.vm4n OR ss.vm4f
      OR ss.vm6 OR ss.vm6f
      OR ss.vm7 OR ss.vm7f
      OR ss.vm8 OR ss.vm8f
      OR ss.vm9 OR ss.vm9f
      OR ss.vmn OR ss.vmnf;
$$ LANGUAGE SQL;

-- tell whether a schema is valid only because of fuzzyness
CREATE OR REPLACE FUNCTION fvalidOnly(ss SchemaStats) RETURNS BOOLEAN
IMMUTABLE STRICT AS $$
  SELECT (ss.vm3f OR ss.vm4f OR ss.vm6f OR ss.vm7f OR ss.vm8f OR ss.vm9f OR ss.vmnf) AND
    NOT (ss.vm1 OR ss.vm1n OR ss.vm2 OR ss.vm2n OR ss.vm3 OR ss.vm3n OR
         ss.vm4 OR ss.vm4n OR ss.vm6 OR ss.vm7 OR ss.vm8 OR ss.vm9 OR ss.vmn);
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION percent(cnt INT8, total INT8) RETURNS NUMERIC
IMMUTABLE STRICT AS $$
  SELECT ROUND(100.0 * cnt / total, 2);
$$ LANGUAGE SQL;
