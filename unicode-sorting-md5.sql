-- The checksum approach was inspired by Joe Conway:
-- https://joeconway.com/presentations/

\timing
SET work_mem = '3GB';

WITH t AS (
  SELECT d1 AS strings
  FROM unicode_data
  ORDER BY d1 COLLATE @LOCALE@
)
SELECT md5(string_agg(t.strings, NULL))
FROM t;
