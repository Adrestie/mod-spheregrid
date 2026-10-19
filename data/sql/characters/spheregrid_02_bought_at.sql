-- mod-spheregrid — when each cell was bought.
--
-- The player window opens on the last cell bought. The module buys with a
-- REPLACE INTO naming its columns, so a fresh row each time: the database
-- dates it itself (DEFAULT CURRENT_TIMESTAMP(6)), and the UPDATEs that socket,
-- pin or reset leave the date alone. No change to the module's C++.
--
-- For a database created before the column was in spheregrid_01_schema.sql.
-- Idempotent: MySQL has no ADD COLUMN IF NOT EXISTS, so the column is looked
-- for first. Rows already there all get the moment this runs.

SET @spheregrid_has_bought_at = (
  SELECT COUNT(*) FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'mod_spheregrid_character_node'
    AND COLUMN_NAME = 'bought_at');

SET @spheregrid_sql = IF(@spheregrid_has_bought_at = 0,
  'ALTER TABLE `mod_spheregrid_character_node` ADD COLUMN `bought_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) COMMENT ''set by the database on every purchase (a REPLACE): the window opens on the last one'' AFTER `active`',
  'DO 0');

PREPARE spheregrid_stmt FROM @spheregrid_sql;
EXECUTE spheregrid_stmt;
DEALLOCATE PREPARE spheregrid_stmt;
