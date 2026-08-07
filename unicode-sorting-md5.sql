-- The checksum approach was inspired by Joe Conway:
-- https://joeconway.com/presentations/

\timing
-- On aarch64, Debian 7/8 PostgreSQL packages require work_mem no higher than 2097151kB.
SET work_mem = '2097151kB';

WITH t AS (
  SELECT d1 AS strings
  FROM unicode_data
  ORDER BY d1 COLLATE @LOCALE@
)
SELECT md5(string_agg(t.strings, NULL))
FROM t;
