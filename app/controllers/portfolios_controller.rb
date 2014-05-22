class PortfoliosController < ApplicationController
  def new
    @portfolio = Portfolio.new
  end

  def create
    @portfolio = Portfolio.new(portfolio_params)
    if @portfolio.save
      flash[:success] = "Portfolio Saved"
      redirect_to root_path
    else
      render 'new'
    end
  end

  def edit
  end

  def update
  end

  def index
    @portfolios = Portfolio.all
  end

  def show
    @portfolio = Portfolio.find(params[:id])
    @new_position = @portfolio.positions.build
    gon.tickers = @portfolio.positions.pluck(:ticker)
  end

  def destroy
  end

  def create_position
    @portfolio = Portfolio.find(params[:id])
    @position = @portfolio.positions.build(portfolio_params)
    if @position.save
      flash[:success] = "Position Saved"
      redirect_to portfolio_path(@portfolio)
    else
      redirect_to :back
    end
  end

  private
    def portfolio_params
      params.require(:portfolio).permit(:name, position_attributes: [:portfolio_id, :ticker, :quantity, :cost_basis])
    end
end
