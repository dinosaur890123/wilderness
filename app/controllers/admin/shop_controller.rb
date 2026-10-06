module Admin
  class ShopController < BaseController
    before_action :set_item, only: %i[update destroy]

  def index
    render inertia: "admin/shop", props: {
      items: ShopItem.includes(:prices).order(:position, :id).map { |item| item_props(item) },
      regions: Region::ALL.map { |code, label| { code: code, label: label } },
      kinds: ShopItem::KINDS,
      totals: {
        items: ShopItem.count,
        stocked: ShopItem.where(stocked: true).count,
        sold_out: ShopItem.where(stock_remaining: 0).count
      },
      flash_notice: flash_notice
    }
  end

  def create
    item = ShopItem.new(item_params)
    if item.save
      sync_prices(item)
      AuditEvent.record!("shop_item.created", actor: current_user, subject: item, title: item.title)
      redirect_to admin_shop_path, notice: "#{item.title} is now available for all users"
    else
      redirect_to admin_shop_path, inertia: { errors: item.errors }
    end
  end

  def update
    if @item.update(item_params)
      sync_prices(@item)
      redirect_to admin_shop_path, notice: "#{@item.title} updated"
    else
      redirect_to admin_shop_path, inertia: { errors: @item.errors }
    end
  end

  def destroy
    title = @item.title
    @item.destroy!
    AuditEvent.record!("shop_item.deleted", actor: current_user, title: title)
    redirect_to admin_shop_path, notice: "#{title} deleted"
  end

  private
  def set_item
    @item = ShopItem.find(params[:id])
  end


  def item_params
    attrs = params.permit(:title, :description, :kind, :image_url, :stocked, :position, :stock_remaining).to_h
    attrs["stock_remaining"] = attrs["stock_remaining"].presence if attrs.key?("stock_remaining")
    attrs
  end

  def sync_prices(item)
    params.permit(prices: {}).fetch(:prices, {}).to_h.each do |region, logs|
      next unless Region.codes.include?(region)
      row = item.prices.find_or_initialize_by(region: region)
      if logs.to_s.strip.blank?
        row.destroy if row.persisted?
      else
        row.update!(logs: logs.to_i)
      end
    end
  end

  def item_props(item)
    {
      id: item.id,
      title: item.title,
      description: item.description,
      kind: item.kind,
      image_url: item.image_url,
      stocked: item.stocked,
      stock_remaining: item.stock_remaining,
      position: item.position,
      sold_out: item.sold_out?,
      default_price: item.price,
      prices: item.prices.to_h { |price| [ price.region, price.logs ] }
    }
  end
  end
end
