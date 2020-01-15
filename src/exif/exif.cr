require "path"
require "logger"
require "./libexif"

module Exif
  extend self

  private EUROPE_AMSTERDAM = Time::Location.load("Europe/Amsterdam")
  private LOGGER           = Logger.new(STDOUT)

  def parse_exif_timestamp(timestamp_str)
    Time.parse(timestamp_str, "%Y:%m:%d %H:%M:%S", EUROPE_AMSTERDAM)
  end

  def read_datetime_original(photo_file_path : Path)
    exif_data = LibExif.exif_data_new_from_file(photo_file_path.to_s)
    return nil unless exif_data

    begin
      exif_content = exif_data.value.ifd[LibExif::ExifIfd::EXIF_IFD_1.value]
      date_time_entry = LibExif.exif_content_get_entry(exif_content, LibExif::ExifTag::EXIF_TAG_DATE_TIME_ORIGINAL)

      buf = Slice(UInt8).new(20)
      exif_date_time_value = LibExif.exif_entry_get_value(date_time_entry, buf, buf.bytesize)

      if exif_date_time_value
        date_time_str = String.new(exif_date_time_value)
        date_time = parse_exif_timestamp(date_time_str)

        return {date_time_str, date_time}
      end
    rescue e
      LOGGER.warn("Failed to read EXIF for #{photo_file_path}: #{e}")
      nil
    ensure
      LibExif.exif_data_unref(exif_data)
    end
  end
end
