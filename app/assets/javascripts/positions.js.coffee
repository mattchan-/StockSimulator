# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sept", "Oct", "Nov", "Dec"]
formattedDate = (date) ->
  "#{months[date.getMonth()]} #{date.getDate()}, #{date.getFullYear()}"

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

$('.positions.show').ready ->
  # define chart size
  margin = { top: 20, right: 80, bottom: 30, left: 50 }
  width = 960 - margin.left - margin.right
  height = 500 - margin.top - margin.bottom

  zoomed = ->
    x.domain()

  zoom = d3.behavior.zoom()
      .scaleExtent([1, 10])
      .on("zoom", zoomed)

  parseDate = d3.time.format("%Y-%m-%d").parse
  bisectDate = d3.bisector( (d) -> d.date ).left

  x = d3.time.scale().range([0, width])
  y = d3.scale.linear().range([height, 0])

  # define axes
  xAxis = d3.svg.axis()
    .scale(x)
    .orient("bottom")
    .innerTickSize(-height)

  yAxisLeft = d3.svg.axis()
    .scale(y)
    .orient("left")
    .innerTickSize(-width)

  yAxisRight = d3.svg.axis()
    .scale(y)
    .orient("right")

  # line functions
  line_y0 = d3.svg.line()
    .x( (d) -> x(d.date))
    .y( (d) -> y(d.value))

  line_y1 = d3.svg.line()
    .x( (d) -> x(d.date))
    .y( (d) -> y(d.plus_div))

  line_y2 = d3.svg.line()
    .x( (d) -> x(d.date))
    .y( (d) -> y(d.div_reinvested))

  #set svg for chart
  svg = d3.select('.chart').append("svg")
      .attr("width", width + margin.left + margin.right)
      .attr("height", height + margin.top + margin.bottom)
    .append("g")
    .attr("transform", "translate(" + margin.left + "," + margin.top + ")")
      .call(zoom);

  container = svg.append("svg")
      .attr("class", "data_container")
      .attr("height", height)
      .attr("width", width)
      .attr("viewBox", "0 0 "+width+" "+height)

  legend = $('.legend')
  updateLegend = (data) ->
    legend.empty()
    legend.append("<div>#{formattedDate(data.date)}</div>")
    legend.append("<div>Price: #{data.value.toFixed(2)}</div>")
    legend.append("<div>With Dividends Unreinvested: #{data.plus_div.toFixed(2)}</div>")
    legend.append("<div>With Dividends Reinvested: #{data.div_reinvested.toFixed(2)}</div>")

  focus =
    markers: []
    addMarker: (chart, _class) ->
      @markers.push(
        chart.append("circle")
            .attr("class", _class)
            .style("display", "none")
            .attr("r", 4.5)
      )
      return
    show: ->
      @markers.forEach (f) ->
        f.style "display", null
      return
    hide: ->
      @markers.forEach (f) ->
        f.style "display", "none"
      return

  $.ajax
    type: "GET"
    url: '/positions/' + $('input[name=id]').val() + '/monthly_graph_data.json'
    dataType: "JSON"
    success: (data) ->
      # tidy up the data
      data.forEach (d) ->
        d.date = parseDate(d.date)
        d.value = +d.value
        d.plus_div = +d.plus_div
        d.div_reinvested = +d.div_reinvested
        return

      mMove = ->
        x0 = x.invert(d3.mouse(this)[0])
        i = bisectDate(data, x0)
        d0 = data[i - 1]
        d1 = data[i]
        d = (if x0 - d0.date > d1.date - x0 then d1 else d0)
        updateLegend(d)
        focus.markers[0].attr("transform", "translate(" + x(d.date) + "," + y(d.value) + ")")
        focus.markers[1].attr("transform", "translate(" + x(d.date) + "," + y(d.plus_div) + ")")
        focus.markers[2].attr("transform", "translate(" + x(d.date) + "," + y(d.div_reinvested) + ")")

      svg.append("rect")
          .attr("class", "overlay")
          .attr("width", width)
          .attr("height", height)
          .on "mouseover", ->
            focus.show()
          .on "mouseout", ->
            focus.hide()
          .on "mousemove", mMove

      last_data = data[data.length - 1]
      updateLegend(last_data)

      # use the data to scale the chart
      ymin = d3.min(data, (d) -> d.value)
      ymax = d3.max(data, (d) -> d.div_reinvested)

      xmin = d3.min(data, (d) -> d.date)
      xmax = d3.max(data, (d) -> d.date)
      x.domain([xmin, xmax])
      y.domain([ymin - ymax * .1, ymax * 1.1])

      downx = Math.NaN
      downscalex = undefined

      # show x axis
      xg = svg.append("g")
          .attr("class", "x axis")
          .attr("transform", "translate(0," + height + ")")
          .call(xAxis)
          .on "mousedown", (d) ->
            p = d3.mouse(svg[0][0])
            downx = x.invert(p[0])
            downscalex = x

      d3.select("body").on("mousemove", (d) ->
        unless isNaN(downx)
          p = d3.mouse(svg[0][0])
          rupx = p[0]
          unless rupx < 0
            scaling = width * (downx - downscalex.domain()[0]) / rupx
            x.domain [
              downscalex.domain()[0]
              Math.min(scaling + +downscalex.domain()[0], xmax)
            ]
          draw()
        return
      ).on "mouseup", (d) ->
        downx = Math.NaN
        return

      # xAxis.append("svg:line")
      #     .attr("x1", 0).attr("x2", 0)
      #     .attr("y1", 0).attr("y2", 30)
      #     .attr("class", "left_bound")
      # xAxis.append("svg:line")
      #     .attr("x1", width).attr("x2", width)
      #     .attr("y1", 0).attr("y2", 30)
      #     .attr("class", "right_bound")

      # show left y axis
      svg.append("g")
          .attr("class", "y axis")
          .call(yAxisLeft)
        .append("text")
          .attr("transform", "rotate(-90)")
          .attr("y", 6)
          .attr("dy", ".71em")
          .style("text-anchor", "end")
          .text("Price ($)")

      # show right y axis
      svg.append("g")
          .attr("class", "y axis")
          .attr("transform", "translate(" + width + ",0)")
          .call(yAxisRight.tickFormat((d) -> d3.round(d/data[0].value * 100, 0) + "%"))

      draw = ->
        d3.select('.line0').remove()
        d3.select('.line1').remove()
        d3.select('.line2').remove()
        #draw no_div line

        container.append("path")
            .attr("class", "line line0")
            .attr("d", line_y0(data))

        #draw w_div line
        container.append("path")
            .attr("class", "line line1")
            .attr("d", line_y1(data))

        container.append("path")
            .attr("class", "line line2")
            .attr("d", line_y2(data))

        xg.call(xAxis)
        d3.selectAll("g.x g.tick")
            .style("cursor", "ew-resize")

      draw()

      focus.addMarker(container, "focus0")
      focus.addMarker(container, "focus1")
      focus.addMarker(container, "focus2")