class Item < ApplicationRecord
  has_many :order_items
  has_many :orders, through: :order_items
  belongs_to :user
  validates_presence_of :name, :description
  validates :current_price, numericality: { greater_than: 0 }
  validates :inventory, numericality: { greater_than: -1 }

  def not_ordered?
    order_items.first == nil
  end

  def self.active_items_by_merchant
        select('users.name as merchant_name, items.*')
            .joins(:user)
            .where('users.role': 1, active:true, "users.active": true)
            .entries
  end

  def self.items_sold(limit = 5, order = 'asc')
       Item.select("items.*, sum(order_items.order_quantity) as items_qty")
       .joins(:order_items)
       .where('order_items.fulfilled = true')
       .group(:id)
       .order("items_qty #{order}")
       .limit(limit)
  end

  def self.merchant_items_sold(limit = 5, order = 'desc', merchant_id)
    joins(:order_items)
    .select('items.*, sum(order_items.order_quantity)as total_sold')
    .group(:id)
    .where("items.user_id = #{merchant_id}")
    .order("total_sold #{order}")
    .limit(limit)
  end

  def self.percent_sold(merchant_id)
      joins(:order_items)
      .select('items.*, coalesce(sum(order_items.order_quantity),0)as total_sold')
      .where("items.user_id = #{merchant_id}")
      .group('items.*')
      # .limit(1)
  end

  def in_stock?(order_item)
    order_item = OrderItem.find(order_item.id)
    if self.inventory >= order_item.order_quantity
      true
    else
      false
    end
  end


end
