module PositionsHelper
  def updown(number)
    if number.to_f < 0
      "down"
    elsif number.to_f > 0
      "up"
    else
      ""
    end
  end
end
