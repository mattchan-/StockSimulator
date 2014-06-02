# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

YAHOO = Finance: SymbolSuggest: {}

$.ajaxSetup beforeSend: (xhr) ->
  xhr.setRequestHeader "Accept", "text/javascript"
  return

$ ->
  $('#position_date_acquired').datepicker(
    autoclose: true
    orientation: 'top left'
  )

$.fn.addPosition = ->
  @submit ->
    $.post @action, $(this).serialize(), null, "script"
    false
  return this

$ ->
  $('#new_position').addPosition()

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
  
