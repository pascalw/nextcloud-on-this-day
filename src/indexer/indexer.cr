require "path"
require "db"
require "logger"

require "../exif"
require "../repo"
require "../repo/photo"

module Indexer
  extend self

  private LOGGER = Logger.new(STDOUT)

  struct File
    property path, file_id

    def initialize(@path : Path, @file_id : Int64); end
  end

  def index(nextcloud_db : DB::Database, state_db : DB::Database, files_root_path : Path)
    state_last_mtime = state_db.query_one?("select * from state limit 1;", &.read(Int64))
    nc_last_mtime = nextcloud_db.scalar("select of.mtime from oc_filecache of order by of.mtime DESC limit 1;").as(Int64)

    fetch_nextcloud_file_paths(nextcloud_db, state_last_mtime) do |file|
      photo = try_determine_photo_date(file, files_root_path)
      insert_photo(photo, file)
    end

    state_db.exec("DELETE FROM state;")
    state_db.exec("INSERT INTO state values(?);", nc_last_mtime)
  end

  private def try_determine_photo_date(file, root_path)
    file_path = root_path.join(file.path)
    exif_data = Exif.read_datetime_original(file_path)

    if exif_data
      photo_from_exif(file, exif_data)
    else
      LOGGER.warn "Failed to read EXIF timestamp: #{file.path}. Falling back to path based detection."
      photo_from_path(file)
    end
  end

  private def photo_from_exif(file, exif_data)
    date_time_str = exif_data[0]
    date_time = exif_data[1]

    photo = Repo::Photo.new
    photo.file_id = file.file_id
    photo.day = date_time.to_s("%d%m")
    photo.year = date_time.year
    photo.exif_created_at = date_time_str

    photo
  end

  private def photo_from_path(file)
    if file.path.to_s =~ /(\d{4})\/(\d{2})\/(\d{2})/
      year = $~[1]
      month = $~[2]
      day = $~[3]

      photo = Repo::Photo.new
      photo.file_id = file.file_id
      photo.day = "#{day}#{month}"
      photo.year = year.to_i32

      photo
    end
  end

  private def insert_photo(photo, file)
    if photo
      LOGGER.info "Determined day for #{file.path}: #{photo.day}, #{photo.year}"
      changeset = Repo.insert(photo)

      if changeset.errors.any?
        LOGGER.warn("Failed to insert photo: #{changeset.errors.to_s}")
      end
    else
      LOGGER.warn "Failed to detect timestamp: #{file.path}."
    end
  end

  private def fetch_nextcloud_file_paths(db, since_mtime, &block)
    if since_mtime
      query = "select fileid,path from oc_filecache of where of.mimetype = 10 and of.storage = 2 and of.mtime >= $1;"
      args = [since_mtime]
    else
      query = "select fileid,path from oc_filecache of where of.mimetype = 10 and of.storage = 2;"
      args = [] of DB::Any
    end

    db.query_each query, args: args do |rs|
      file_id = rs.read(Int64)
      path = rs.read(String)

      yield File.new(Path.new(path), file_id)
    end
  end
end
