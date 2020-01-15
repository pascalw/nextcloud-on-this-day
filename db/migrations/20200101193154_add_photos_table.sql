-- +micrate Up
CREATE TABLE photos (
    file_id INTEGER PRIMARY KEY,
    day TEXT NOT NULL,
    year INTEGER NOT NULL,
    exif_created_at TEXT
);
CREATE INDEX idx_photos_day ON photos(day);

-- +micrate Down
DROP TABLE photos;
DROP INDEX idx_photos_day;
