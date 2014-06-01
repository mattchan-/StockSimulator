class PositionsController < ApplicationController
  def create
    @portfolio = Portfolio.find(params[:portfolio_id])
    @position = @portfolio.positions.build(position_params)
    @position.date_acquired = Date.strptime(params[:position][:date_acquired], '%m/%d/%Y')
    if @position.save
      flash[:success] = "Position Saved"
      redirect_to portfolio_path(@portfolio)
    else
      render template: "portfolios/show"
    end
  end

  def show
    @position = Position.find(params[:id])
    gon.symbol = @position.symbol
  end

  def edit
  end

  def update
  end

  def destroy
  end

  private
    def position_params
      params.require(:position).permit(:portfolio_id, :symbol, :shares, :cost_per_share, :date_acquired)
    end
end
