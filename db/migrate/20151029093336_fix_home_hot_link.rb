class FixHomeHotLink < ActiveRecord::Migration
  def change
    black_list = %W[id created_at updated_at]
    Ddt::HomeHotLink.where(shop_type: :single).find_in_batches(batch_size: 2000) do |group|
      links = group.map do |link|
        attrs = link.attributes.select{|attr| !black_list.include?(attr)}
        attrs['shop_type'] = 'service'
        Ddt::HomeHotLink.new(attrs)
      end
      Ddt::HomeHotLink.import(links)
      puts "---------home hot link migrate single------------"
    end

    Ddt::HomeHotLink.where(shop_type: :multiple).find_in_batches(batch_size: 2000) do |group|
      links = group.map do |link|
        attrs = link.attributes.select{|attr| !black_list.include?(attr)}
        attrs['shop_type'] = 'chain'
        Ddt::HomeHotLink.new(attrs)
      end
      Ddt::HomeHotLink.import(links)
      puts "---------home hot link migrate multiple------------"
    end

  end
end
