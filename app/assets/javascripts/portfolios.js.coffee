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
  )

$.fn.addPosition = ->
  @submit ->
    $.post @action, $(this).serialize(), null, "script"
    false
  return this

toggleSpinner = -> $('#spinner').toggle()

$ ->
  $('#new_position').addPosition()

$.fn.editPortfolio = ->
  @submit ->
    $.post @action, $(this).serialize(), null, "script"
    false
  return this

$ ->
  $('#name').click ->
    @.contentEditable = true

  $('#name').blur ->
    $('#portfolio_name').val($('#name').text())
    $('form.edit_portfolio').submit()

$ ->
  $(document)
    .on('ajaxSend', toggleSpinner)
    .on('ajaxComplete', toggleSpinner)