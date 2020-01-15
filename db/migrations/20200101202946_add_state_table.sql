-- +micrate Up
CREATE TABLE state (
    last_mtime INTEGER
);

-- +micrate Down
DROP TABLE state;
