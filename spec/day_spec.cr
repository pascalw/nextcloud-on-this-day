require "spec"
require "../src/lib/day"

describe "Day" do
  describe ".parse" do
    it "parses date string" do
      day = Day.parse("18-03")

      day.day.should eq(18)
      day.month.should eq(3)
    end

    it "raises on invalid date" do
      expect_raises(ArgumentError) do
        Day.parse("32-03")
      end

      expect_raises(ArgumentError) do
        Day.parse("30-02")
      end

      expect_raises(ArgumentError) do
        Day.parse("18-13")
      end
    end
  end

  describe ".from_time" do
    it "creates a day from a Time instance" do
      today = Time.local
      Day.from_time(today).should eq(Day.new(today.day, today.month))
    end
  end

  describe "#to_s" do
    it "zero pads to_s" do
      Day.parse("18-03").to_s.should eq("18-03")
    end
  end

  describe "#next" do
    it "provides the next day" do
      Day.new(18, 3).next.should eq(Day.new(19, 3))
    end

    it "advances to the next month" do
      Day.new(31, 1).next.should eq(Day.new(1, 2))
    end

    it "advances to january from december" do
      Day.new(31, 12).next.should eq(Day.new(1, 1))
    end
  end

  describe "#prev" do
    it "provides the previous day" do
      Day.new(18, 3).prev.should eq(Day.new(17, 3))
    end

    it "advances to the previous month" do
      Day.new(1, 3).prev.should eq(Day.new(29, 2))
    end

    it "advances to december from january" do
      Day.new(1, 1).prev.should eq(Day.new(31, 12))
    end
  end
end
