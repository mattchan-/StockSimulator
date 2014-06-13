# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
  $("#check_symbol").autocomplete
    source: (request, response) ->
      YAHOO = window.YAHOO = Finance:
        SymbolSuggest: {}
      $.ajax
        type: "GET"
        url: "http://autoc.finance.yahoo.com/autoc"
        dataType: "jsonp"
        jsonp: "callback"
        jsonpCallback: "YAHOO.Finance.SymbolSuggest.ssCallback"
        data:
          query: request.term

        cache: true

      YAHOO.Finance.SymbolSuggest.ssCallback = (data) ->
        response $.map(data.ResultSet.Result, (item) ->
          label: item.symbol + " " + item.name
          value: item.symbol
        )
        return

      return

    minLength: 1
    select: (event, ui) ->
      $("#check_symbol").val ui.item.symbol
      return
  return