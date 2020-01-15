require "crecto"
require "../exif"

module Repo
  class Photo < Crecto::Model
    @taken_at : Time | Nil

    set_created_at_field nil
    set_updated_at_field nil

    schema "photos" do
      field :file_id, Int64, primary_key: true
      field :day, String
      field :year, Int32
      field :exif_created_at, String
    end

    def taken_at
      @taken_at ||= begin
        return nil unless self.exif_created_at

        begin
          Exif.parse_exif_timestamp(self.exif_created_at.as(String))
        rescue
          nil
        end
      end
    end

    def compare_taken_at(b : Photo)
      if self.taken_at.nil? || b.taken_at.nil?
        return -1
      end

      self.taken_at.as(Time) <=> b.taken_at.as(Time)
    end
  end
end
