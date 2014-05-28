class PositionsController < ApplicationController
  def create
    @portfolio = Portfolio.find(params[:portfolio_id])
    @position = @portfolio.positions.build(position_params)
    if @position.save
      flash[:success] = "Position Saved"
      redirect_to portfolio_path(@portfolio)
    else
      redirect_to :back
    end
  end

  def show
    @position = Position.find(params[:id])
    gon.ticker = @position.ticker
  end

  def edit
  end

  def update
  end

  def destroy
  end

  private
    def position_params
      params.require(:position).permit(:portfolio_id, :ticker, :quantity, :cost_basis, :date_acquired)
    end
end
