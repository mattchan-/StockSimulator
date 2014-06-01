# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

YAHOO = Finance: SymbolSuggest: {}


showPositions = ->
  yql_url = "https://query.yahooapis.com/v1/public/yql"
  query = "SELECT * FROM yahoo.finance.quotes WHERE symbol in ('"
  if gon.symbols
    generate_query = (rest..., last) ->
      for r in rest
        query += r + "', '"
      if last?
        query += last + "')"
    generate_query.apply(null, gon.symbols)
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
        if !data.error
          $.each gon.symbols, (index, symbol) ->
            quote = data.query.results.quote
            quote = [quote]  unless $.isArray(quote)
            alert quote[index]["symbol"]
          
  else
    $("table#quotes").replaceWith "<div>An error has occurred.</div>"

$ ->
  $('#datepicker').datepicker(
    autoclose: true
    orientation: 'top left'
  )

$ ->
  $('#check_symbol').blur ->
    if !$(this).val()
      $('#symbol_error_message').text("")
    else
      yql_url = "https://query.yahooapis.com/v1/public/yql"
      query = "SELECT * FROM yahoo.finance.quotes WHERE symbol in ('"
      query += $('#check_symbol').val() + "')"
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
            $('#symbol_error_message').text("")
          else
            $('#symbol_error_message').text("Invalid symbol")
            return
  
$('.portfolios.show').ready showPositions