class Satoshi

  # Says how many digits after the decimal point
  # a denomination has.
  UNIT_DENOMINATIONS = {
    btc:     8,
    mbtc:    5,
    satoshi: 0
  }

  attr_reader :value, :from_unit, :to_unit

  def initialize(n=nil, from_unit: 'btc', to_unit: 'btc', unit: nil)
    n = 0 if n.nil?
    if unit
      @from_unit = @to_unit = unit.downcase.to_sym
    else
      @from_unit = from_unit.downcase.to_sym
      @to_unit   = to_unit.downcase.to_sym
    end
    @value = convert_to_satoshi(n) if n
  end

  def to_btc(as: :number)
    to_denomination(UNIT_DENOMINATIONS[:btc], as: as)
  end

  def to_mbtc(as: :number)
    to_denomination(UNIT_DENOMINATIONS[:mbtc], as: as)
  end

  def to_unit(as: :number)
    to_denomination(UNIT_DENOMINATIONS[@to_unit], as: as)
  end

  def to_i
    return 0 if @value.nil?
    @value
  end
  alias :satoshi_value :to_i 

  def value=(n)
    n = 0 if n.nil?
    @value = convert_to_satoshi(n)
  end

  def satoshi_value=(v)
    @value = v
  end

  def >(i)
    self.to_i > i
  end

  def <(i)
    self.to_i < i
  end

  def >=(i)
    self.to_i >= i
  end

  def <=(i)
    self.to_i <= i
  end

  def ==(i)
    self.to_i == i
  end

  def +(i)
    self.to_i + i
  end

  def -(i)
    self.to_i - i
  end

  def *(i)
    self.to_i * i
  end

  def coerce(other)
    if other.kind_of?(Integer)
      [other, self.to_i]
    else
      raise TypeError, message: "Satoshi cannot be coerced into anything but Integer"
    end
  end

  private
  
    def to_denomination(digits_after_delimiter, as: :number)
      sign  = @value < 0 ? -1 : 1
      val   = @value.abs
      return val if digits_after_delimiter <= 0
      leading_zeros = "0"*(18-val.to_s.length)
      result = leading_zeros + val.to_s
      result.reverse!
      result = result.slice(0..digits_after_delimiter-1) + '.' + result.slice(digits_after_delimiter..17)
      result.reverse!
      result = result.sub(/\A0*/, '').sub(/0*\Z/, '') # remove zeros on both sides
      if as == :number
        result.to_f*sign 
      else
        result = "0#{result}" if result =~ /\A\./
        sign == -1 ? "-#{result}" : result
      end
    end

    def convert_to_satoshi(n)
      n = ("%.#{UNIT_DENOMINATIONS[@from_unit]}f" % n) # otherwise we might see a scientific notation
      n = n.split('.') 
      n[1] ||= '' # in the case where there's no decimal part
      n[1] += "0"*(UNIT_DENOMINATIONS[@from_unit]-n[1].length) if n[1] 
      n.join.to_i
    end

end
