require "sqlite3"
require "crecto"

require "./photo"
require "../lib/day"

module Repo
  extend Crecto::Repo
  Query = Crecto::Repo::Query

  config do |conf|
    conf.adapter = Crecto::Adapters::SQLite3
    conf.uri = ENV["DB_URL"]
  end

  def self.find_photos(day : Day)
    day_str = "#{day.day_str}#{day.month_str}"

    query = Query.where(day: day_str).order_by("year DESC")
    self.all(Photo, query)
  end
end
