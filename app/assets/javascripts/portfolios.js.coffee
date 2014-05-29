# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

YAHOO = Finance: SymbolSuggest: {}


showPositions = ->
  yql_url = "https://query.yahooapis.com/v1/public/yql"
  query = "SELECT * FROM yahoo.finance.quotes WHERE symbol in ('"
  if gon.tickers
    generate_query = (rest..., last) ->
      for r in rest
        query += r + "', '"
      if last?
        query += last + "')"
    generate_query.apply(null, gon.tickers)
    $.ajax
      type: "GET"
      url: yql_url
      data:
        q: query
        format: "json"
        env: "store://datatables.org/alltableswithkeys"
      dataType: "jsonp"
      success: (data) ->
        console.log data
        quote = data.query.results.quote
        quote = [quote]  unless $.isArray(quote)
        $.each quote, (counter) ->
          if @ErrorIndicationreturnedforsymbolchangedinvalid == null
            if @Change.charAt(0) == "+"
              $('#change-' + counter).addClass("up")
            else if @Change.charAt(0) == "-"
              $('#change-' + counter).addClass("down")
            $('#price-' + counter).html(@LastTradePriceOnly)
            $('#name-' + counter).html(@Name)
            $('#change-' + counter).html(@ChangeinPercent)
            $('#EPS-' + counter).html(@EarningsShare)
  else
    $("table#quotes").replaceWith "<div>An error has occurred.</div>"

$ ->
  $('#datepicker').datepicker(autoclose: true)

$ ->
  $('#check_ticker').blur ->
    if !$(this).val()
      $('#ticker_error_message').text("")
    else
      yql_url = "https://query.yahooapis.com/v1/public/yql"
      query = "SELECT * FROM yahoo.finance.quotes WHERE symbol in ('"
      query += $('#check_ticker').val() + "')"
      $.ajax
        type: "GET"
        url: yql_url
        dataType: "jsonp"
        data:
          q: query
          format: "json"
          env: "store://datatables.org/alltableswithkeys"
        success: (data) ->
          if data.query.results.quote.ErrorIndicationreturnedforsymbolchangedinvalid == null
            $('#ticker_error_message').text("")
          else
            $('#ticker_error_message').text("Invalid Ticker")
            return
  
$('.portfolios.show').ready showPositions