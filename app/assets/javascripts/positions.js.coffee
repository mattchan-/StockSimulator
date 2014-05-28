# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
  showDividendHistory = ->
    if gon.ticker
      $.ajax
        type: "GET"
        url: 'https://query.yahooapis.com/v1/public/yql'
        data:
          q: "use 'store://bg2cgClQyQC1c5gJE3UXUn' as yahoo.finance.dividendhistory; select * from yahoo.finance.dividendhistory where symbol = '" + gon.ticker + "' and startDate = '1962-01-01' and endDate = '2013-12-31'"
          format: "json"
          env: "store://datatables.org/alltableswithkeys"
        dataType: "jsonp"
        success: (data) ->
          console.log data
          if data.query.results != null
            $.each data.query.results.quote, ->
              $('#dividendHistory').append "<tr><td>" + @Date + "</td><td>" + parseFloat(@Dividends) + "</td></tr>"
          else
            $('table#dividendHistory').replaceWith "Dividend data is unavailable for the specified date range."
    else
      $("table#dividendHistory").replaceWith "<p>An error has occurred.</p>"

  $('.positions.show').ready ->
    showDividendHistory()