require "sqlite3"
require "crecto"

require "./photo"

module Repo
  extend Crecto::Repo
  Query = Crecto::Repo::Query

  config do |conf|
    conf.adapter = Crecto::Adapters::SQLite3
    conf.uri = ENV["DB_URL"]
  end

  def self.find_photos(day)
    query = Query.where(day: day).order_by("year DESC")
    self.all(Photo, query)
  end
end
