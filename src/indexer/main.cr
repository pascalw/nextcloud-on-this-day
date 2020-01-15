require "pg"
require "db"

require "micrate"
require "./indexer"

module Indexer::Main
  extend self

  def run
    state_db = DB.open(ENV["DB_URL"])
    Micrate.up(state_db)

    nextcloud_db = DB.open(ENV["NEXTCLOUD_DB_URL"])

    begin
      Indexer.index(nextcloud_db, state_db, Path.new(ENV["NEXTCLOUD_DATA_DIR"]))
    ensure
      state_db.close
      nextcloud_db.close
    end
  end
end
