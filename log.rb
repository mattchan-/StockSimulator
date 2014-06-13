require 'logger'

log = Logger.new('log.txt')

log.debug "Log file created"

success = 0
failed = 0

Company.all.each do |c|
  if c.get_price
    success += 1
  else
    log.debug "#{c.symbol} failed to retrieve price"
    c.destroy
    failed += 1
  end
end

log.debug "#{success} prices successfully retrieved"
log.debug "#{failed} prices unsuccessful"