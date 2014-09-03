class PositionsController < ApplicationController
  def new
    @portfolio = Portfolio.find(params[:portfolio_id])
    @position = @portfolio.positions.build
  end

  def create
    @portfolio = Portfolio.find(params[:portfolio_id])
    @position = @portfolio.positions.build.localized(position_params)
    if @position.save
      flash.now[:success] = "Position Saved"
    end
    respond_to do |format|
      format.html { redirect_to portfolio_path @portfolio }
      format.js
    end
  end

  def show
    @position = Position.find(params[:id])
    gon.symbol = @position.symbol
    gon.date_acquired = @position.date_acquired.strftime("%Y-%m-%d")
    gon.today = Date.today.strftime("%Y-%m-%d")
  end

  def edit
    @position = Position.find(params[:id])
  end

  def update
    @position = Position.find(params[:id])
    if @position.update(position_params)
      flash.now[:success] = "Position Updated"
      redirect_to @position.portfolio
    else
      render 'edit'
    end
  end

  def destroy
    @position = Position.find(params[:id])
    @portfolio = @position.portfolio

    @position.destroy
    redirect_to portfolio_path @portfolio
  end

  def monthly_graph_data
    @position = Position.find(params[:id])
    # startMonth = Position.find(141).date_acquired.month
    # startYear = Position.find(141).date_acquired.year
    # endMonth = Date.today.month
    # endYear = Date.today.year

    # month = startMonth
    # a = []
    # for year in (startYear..endYear)
    #   if year == endYear
    #     while month <= endMonth
    #       a.push(CompanyData.select("id", "date", "value").where("symbol = ? AND category = ? AND strftime('%m', date) + 0 = ? AND strftime('%Y', date) + 0 = ?", @position.symbol, "close", month, year).order("date ASC").first)
    #       month += 1
    #     end
    #   else
    #     while month <= 12
    #       a.push(CompanyData.select("id", "date", "value").where("symbol = ? AND category = ? AND strftime('%m', date) + 0 = ? AND strftime('%Y', date) + 0 = ?", @position.symbol, "close", month, year).order("date ASC").first)
    #       month += 1
    #     end
    #     month = 1
    #   end
    # end
    # @data = a
    raw_data = CompanyData.select("date, value, category").where("symbol = ? AND category IN (?, ?) AND date > ?", @position.symbol, "close", "dividend", @position.date_acquired).order("date ASC")

    month = raw_data.first.date.month
    div_adjustment = 0
    last_div = 0
    share_factor = 1
    @data = []
    raw_data.each do |d|
      if d.category == "dividend"
        div_adjustment += d.value
        share_factor *= (1 + d.value/@data.last[:value])
      elsif d.date.month == month
        @data.push({ date: d.date, value: d.value, plus_div: d.value + div_adjustment, div_reinvested: d.value * share_factor })
        month == 12 ? month = 1 : month += 1
      end
    end
    respond_to do |format|
      format.json { render json: @data }
    end
  end

  private
    def position_params
      params.require(:position).permit(:portfolio_id, :symbol, :shares, :cost_per_share, :date_acquired)
    end
end
