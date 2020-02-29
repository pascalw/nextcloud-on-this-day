require "kemal"
require "uri"

require "../repo"
require "../lib/day"

module Web::Helpers
  extend self

  private MONTH_NAMES = {
     1 => "januari",
     2 => "februari",
     3 => "maart",
     4 => "april",
     5 => "mei",
     6 => "juni",
     7 => "juli",
     8 => "augustus",
     9 => "september",
    10 => "oktober",
    11 => "november",
    12 => "december",
  }

  def nextcloud_photo_uri(nextcloud_uri : URI, file_id : Int64, size : {Int, Int})
    uri = nextcloud_uri.dup
    uri.path = "/index.php/core/preview"

    query_params = HTTP::Params.new({"fileId" => [file_id.to_s], "x" => [size[0].to_s], "y" => [size[1].to_s]})
    uri.query = query_params.to_s

    uri
  end

  def sort_by_taken_at(a : Repo::Photo, b : Repo::Photo)
    a.compare_taken_at(b)
  end

  def month_name(day)
    MONTH_NAMES[day.month]
  end

  def date_url(day : Day, absolute = false) : String
    "#{absolute ? ENV["SELF"] : ""}/#{day.to_s}"
  end
end

module Web::Main
  extend self

  EUROPE_AMSTERDAM = Time::Location.load("Europe/Amsterdam")

  def run
    nextcloud_uri = URI.parse(ENV["NEXTCLOUD_URI"])

    static_headers do |response, filepath, filestat|
      if filepath =~ /\.js$/
        next_year = filestat.modification_time.shift(years: 1)
        response.headers.add("Cache-Control", "public")
        response.headers.add("Expires", Time::Format::HTTP_DATE.format(next_year))
      end
    end

    get "/" do |env|
      today = Time.local EUROPE_AMSTERDAM
      day = Day.from_time(today)
      env.redirect Helpers.date_url(day)
    end

    get "/:date" do |env|
      date_str = env.params.url["date"]
      day = Day.parse(date_str)

      photos = Repo.find_photos(day)
      render "src/web/templates/photo_feed.ecr", "src/web/templates/layout.ecr"
    end

    get "/feed.xml" do |env|
      env.response.content_type = "text/xml"
      today = Time.local EUROPE_AMSTERDAM
      day = Day.from_time(today)

      <<-XML
      <?xml version="1.0" encoding="utf-8"?>
      <feed xmlns="http://www.w3.org/2005/Atom">
        <title>Nextcloud Today</title>
        <link href="#{ENV["SELF"]}" rel="self"/>
        <updated>#{today.at_beginning_of_day.to_rfc3339}</updated>
        <id>#{ENV["SELF"]}</id>
        <entry>
          <title>Op deze dag: #{day.to_s}</title>
          <link href="#{Helpers.date_url(day, absolute: true)}"/>
          <updated>#{today.at_beginning_of_day.to_rfc3339}</updated>
          <id>#{Helpers.date_url(day, absolute: true)}</id>
          <content type="html"></content>
        </entry>
      </feed>
      XML
    end

    Kemal.run
  end
end
