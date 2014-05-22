# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
  do showPositions = ->
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
          quote = data.query.results.quote
          quote = [quote]  unless $.isArray(quote)
          $.each quote, ->
            if @ErrorIndicationreturnedforsymbolchangedinvalid != null
              false
            else
              if @Change.charAt(0) == "+"
                chg = "\"up\">"
              else if @Change.charAt(0) == "-"
                chg = "\"down\">"
              $(".quotes").append "<tr><td>" + @symbol + "</td><td>" + @LastTradePriceOnly + "</td><td class=" + chg + @ChangeinPercent + "</td><td>" + @EarningsShare + "</td></tr>"
    else
      $("div.content").replaceWith "<p>An error has occurred.</p>"

  $('#show_add_position').click ->
    $('#addPosition').toggleClass('hidden')
    if $('#addPosition').hasClass('hidden') then $('#show_add_position').text('Add Position') else $('#show_add_position').text('Remove Position')
    false

  $('#datepicker').datepicker().on('changeDate', ->
    $(@).datepicker('hide')
  )

  $('#check_ticker').blur ->
    yql_url = "https://query.yahooapis.com/v1/public/yql"
    query = "SELECT * FROM yahoo.finance.quotes WHERE symbol in ('"
    query += $('#check_ticker').val() + "')"
    alert query
    $.ajax
      type: "GET"
      url: yql_url
      dataType: "jsonp"
      data:
        q: query
        format: "json"
        env: "store://datatables.org/alltableswithkeys"
      dataType: "jsonp"
      success: (data) ->
        console.log data
        quote = data.query.results.quote
        if quote.ErrorIndicationreturnedforsymbolchangedinvalid != null
          alert quote.ErrorIndicationreturnedforsymbolchangedinvalid
        else
          return