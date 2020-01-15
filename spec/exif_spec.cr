require "spec"
require "../src/exif"

private EUROPE_AMSTERDAM = Time::Location.load("Europe/Amsterdam")

describe "Exif" do
  it "reads DateTimeOriginal" do
    exif_date_time = Exif.read_datetime_original(Path.new(__DIR__, "fixtures", "20191028_111529.jpg"))
    exif_date_time.should eq({"2019:10:28 11:15:30", Time.local(2019, 10, 28, 11, 15, 30, location: EUROPE_AMSTERDAM)})
  end
end
