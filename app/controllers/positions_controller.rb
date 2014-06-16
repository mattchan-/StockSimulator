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
    if @position.update_attributes(position_params)
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

  private
    def position_params
      params.require(:position).permit(:portfolio_id, :symbol, :shares, :cost_per_share, :date_acquired)
    end
end
