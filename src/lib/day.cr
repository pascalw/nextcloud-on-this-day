class Day
  private DAY_REGEX  = /(\d{2})-(\d{2})/
  private MONTH_DAYS = {
     1 => 31,
     2 => 29,
     3 => 31,
     4 => 30,
     5 => 31,
     6 => 30,
     7 => 31,
     8 => 31,
     9 => 30,
    10 => 31,
    11 => 30,
    12 => 31,
  }

  def self.from_time(time : Time)
    self.new(time.day, time.month)
  end

  def self.parse(value : String)
    matches = DAY_REGEX.match(value).not_nil!

    day = matches[1].to_i
    month = matches[2].to_i

    self.new(day, month)
  end

  getter day : Int32
  getter month : Int32

  def initialize(@day : Int32, @month : Int32)
    raise ArgumentError.new("Invalid date: #{self.to_s}") if @month > 12
    raise ArgumentError.new("Invalid date: #{self.to_s}") if @day > MONTH_DAYS[@month]
  end

  def next
    if @day + 1 > MONTH_DAYS[@month]
      month = @month + 1 > 12 ? 1 : @month + 1
      self.class.new(1, month)
    else
      self.class.new(@day + 1, @month)
    end
  end

  def prev
    if @day - 1 == 0
      month = @month - 1 == 0 ? 12 : @month - 1
      self.class.new(MONTH_DAYS[month], month)
    else
      self.class.new(@day - 1, @month)
    end
  end

  def day_str : String
    @day < 10 ? "0#{@day}" : @day.to_s
  end

  def month_str : String
    @month < 10 ? "0#{@month}" : @month.to_s
  end

  def ==(other)
    self.month == other.month &&
      self.day == other.day
  end

  def to_s
    "#{day_str}-#{month_str}"
  end
end
