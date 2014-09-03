class PortfoliosController < ApplicationController
  def new
    @portfolio = Portfolio.new
  end

  def create
    @portfolio = Portfolio.new(portfolio_params)
    if @portfolio.save
      flash[:success] = "Portfolio Saved"
      redirect_to @portfolio
    else
      render 'new'
    end
  end

  def edit
    @portfolio = Portfolio.find(params[:id])
  end

  def update
    @portfolio = Portfolio.find(params[:id])
    @portfolio.update(portfolio_params)
    flash.now[:success] = "Portfolio Name Updated"
    respond_to do |format|
      format.html { redirect_to @portfolio }
      format.js
    end
  end

  def index
    @portfolios = Portfolio.all
  end

  def show
    @portfolio = Portfolio.find(params[:id])
    @positions = @portfolio.positions.order(date_acquired: :asc)
    @position = Position.new
  end

  def destroy
    @portfolio = Portfolio.find(params[:id])
    flash[:success] = "Portfolio '" + @portfolio.name + "' deleted."
    @portfolio.destroy
    redirect_to root_path
  end

  private
    def portfolio_params
      params.require(:portfolio).permit(:name, position_attributes: [:portfolio_id, :symbol, :shares, :cost_per_share, :date_acquired])
    end
end
