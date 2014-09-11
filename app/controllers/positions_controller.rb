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
    raw_data = CompanyData.select("date, value, category").where("symbol = ? AND category IN (?, ?) AND date > ?", @position.symbol, "close", "dividend", @position.date_acquired).order("date ASC")

    month = raw_data.first.date.month
    div_adjustment = 0
    last_div = 0
    share_factor = 1
    @data = []
    spacing = (raw_data.length.to_f / 1000).ceil
    raw_data.each_with_index do |d, idx|
      if d.category == "dividend"
        div_adjustment += d.value
        share_factor *= (1 + d.value/@data.last[:value])
      elsif idx % spacing == 0 # d.date.month == month
        @data.push({ date: d.date, value: d.value, plus_div: d.value + div_adjustment, div_reinvested: d.value * share_factor })
        # month == 12 ? month = 1 : month += 1
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
