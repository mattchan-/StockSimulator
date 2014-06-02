# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

showDividendHistory = ->
  if gon.symbol && gon.date_acquired && gon.today
    $.ajax
      type: "GET"
      url: 'https://query.yahooapis.com/v1/public/yql'
      data:
        q: "use 'store://bg2cgClQyQC1c5gJE3UXUn' as yahoo.finance.dividendhistory; select * from yahoo.finance.dividendhistory where symbol = '" + gon.symbol + "' and startDate = '" + gon.date_acquired + "' and endDate = '2013-12-31'"
        format: "json"
        env: "store://datatables.org/alltableswithkeys"
      dataType: "jsonp"
      success: (data) ->
        console.log data
        if data.query.results != null
          $.each data.query.results.quote, ->
            $('#dividendHistory').append "<tr><td>" + @Date + "</td><td>" + parseFloat(@Dividends) + "</td></tr>"
        else
          $('table#dividendHistory').replaceWith "<p>No dividends have been paid out during your holding period.</p>"
  else
    $("table#dividendHistory").replaceWith "<p>An error has occurred.</p>"

$('.positions.show').ready showDividendHistory