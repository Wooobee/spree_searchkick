Spree::Product.class_eval do
  searchkick word_middle: [:mastersku, :sku, :name, :description, :brand, :manufacturersku], language: "German"

  def search_data
    json = {
      id: id,
      name: name,
      sku: variants.map { |v| v.sku },
      images: images.map { |i| i.attachment.url(:small, false) },
      mastersku: master.sku,
      description: description,
      active: available?,
      created_at: created_at,
      updated_at: updated_at,
      price: price,
      currency: currency,
      conversions: orders.complete.count,
      taxon_ids: taxon_and_ancestors.map(&:id),
      taxon_names: taxon_and_ancestors.map(&:name),
      brand: property('Brand')

    }

    Spree::Property.all.each do |prop|
      json.merge!(Hash[prop.name.downcase, property(prop.name)])
    end

    Spree::Taxonomy.all.each do |taxonomy|
      json.merge!(Hash["#{taxonomy.name.downcase}_ids", taxon_by_taxonomy(taxonomy.id).map(&:id)])
    end

    if variants.length > 0
      json['manufacturersku'] = options_list[0]['manufacturersku'] 
    end
    json
  end


  def options_list
    variants.map do |v|
      bla = {}
      v.option_values.each do |p|
        bla[p.option_type.name] = p.name;
      end
      bla
    end
  end

  def taxon_by_taxonomy(taxonomy_id)
    taxons.joins(:taxonomy).where(spree_taxonomies: {id: taxonomy_id})
  end

  def taxon_and_ancestors
      taxons.map(&:self_and_ancestors).flatten.uniq
  end

  def self.autocomplete(keywords)
    if keywords
      Spree::Product.search(keywords, word_middle: true, limit: 10).map do |product| { name: product.name, image: product.images.first ? product.images.first.attachment.url : "/assets/noimage/small.png", taxons: product.taxon_and_ancestors.map(&:name).slice(0,3).join(' / '), brand: product.property('Brand')}
      end
      #Spree::Product.search(keywords, word_middle: true, limit: 10).map(&:description).map(&:strip).uniq
    else
      Spree::Product.search("*").map do |product| { name: product.name, image: product.images.first ? product.images.first.attachment.url : "/assets/noimage/small.png", taxons: ['Test', 'Ja'].slice(0,3).join(' / '), brand: product.property('Brand')}
        end
    end
  end
end