module PortfoliosHelper
  def updown(number)
    if number < 0
      "down"
    elsif number > 0
      "up"
    else
      ""
    end
  end
end
