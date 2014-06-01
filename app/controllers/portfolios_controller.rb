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
    @position = @portfolio.positions.build
    gon.symbols = @portfolio.positions.pluck(:symbol)
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
      params.require(:portfolio).permit(:name, position_attributes: [:portfolio_id, :symbol, :shares, :cost_per_share, :date_acquired])
    end
end
