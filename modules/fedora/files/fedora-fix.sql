CREATE TABLE IF NOT EXISTS fcrepoRebuildStatus (
  rebuildDate bigint NOT NULL,
  complete boolean NOT NULL,
  UNIQUE KEY rebuildDate (rebuildDate),
  PRIMARY KEY rebuildDate (rebuildDate)
);
