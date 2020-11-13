class ItemsController < ApplicationController
  before_action :set_current_user_items,only:[:i_transaction,:i_exhibiting,:i_soldout]
  before_action :set_user,only:[:i_transaction,:i_exhibiting,:i_soldout]

  def index
    @items = Item.all.limit(5)
  end

  def show
  end


  def new
    if user_signed_in?
      @item = Item.new
      # @item.item_pictures.build
      @category_parent_array = Category.where(ancestry: nil)
    else
      redirect_to root_path, notice: 'ログインもしくはサインインしてください'
    end
  end

  def create
    @item = Item.new(@item_params)
    # if @item.save
      render :sell
    # else
    #   render :new
    # end
  end

  def i_exhibiting #出品中のアクション
  end

  def i_transaction  #取引中のアクション
  end

  def i_soldout    #売却済みのアクション
  end

  require 'payjp'

  def buy
    #商品送付先情報の変数設定
    @destination = Destination.find_by(id: current_user.id)
    #商品情報の変数設定
    @item = Item.find(params[:id])

    card = Creditcard.where(user_id: current_user.id).first
    #Cardテーブルは前回記事で作成、テーブルからpayjpの顧客IDを検索
    if card.blank?
      #登録された情報がない場合にカード登録画面に移動
    else
      Payjp.api_key = ENV["PAYJP_ACCESS_KEY"]
      #保管した顧客IDでpayjpから情報取得
      customer = Payjp::Customer.retrieve(card.customer_id)
      #保管したカードIDでpayjpから情報取得、カード情報表示のためインスタンス変数に代入
      @default_card_information = customer.cards.retrieve(card.card_id)
    end
  end
  
  def pay
    card = Creditcard.where(user_id: current_user.id).first
    Payjp.api_key = ENV['PAYJP_ACCESS_KEY']
    Payjp::Charge.create(
    :amount => 13500, #支払金額を入力（itemテーブル等に紐づけても良い）
    :customer => card.customer_id, #顧客ID
    :currency => 'jpy', #日本円
    )
  redirect_to action: 'done' #完了画面に移動
  end

  def done
  end

  private

  def set_items
    @item = Item.find(params[:id])
  end

  def item_params
    params.require(:item).permit(:name, :text, :category_id, :status_id, :postage_id, :prefecture_id, :days_id, :price, :images[])
  end

  def set_current_user_items
    if user_signed_in? 
      @items = current_user.items.includes(:seller,:buyer,:auction,:item_images)
    else
      redirect_to root_path
    end
  end

  def set_user
  end
end
