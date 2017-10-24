# Configure
#  Items.config.folder = Rails.root.join('tmp', 'items')

class Items

  attr_accessor :id, :index, :items, :info

  def initialize(id, items, info: {})
    @id = id
    @index = 0
    @total = items.size
    @items = items
    @info = info
    save
  end

  def each(&block)
    @items[index..-1].each_with_index do |item, i|
      block.call(item)
      @index = i
      save
    end
  end

  def each_with_index(&block)
    @items[index..-1].each_with_index do |item, i|
      block.call(item, i)
      @index = i
      save
    end
  end

  def reset
    @index = 0
    save
  end

  def save
    File.open(Items.path(@id), 'w') {|f| f.write(YAML::dump(self)) }
  end

  class << self
    def config
      @@config ||= OpenStruct.new(folder: Rails.root.join('tmp', 'items'))
    end

    def get(id, info: {}, &block)
      obj = if exists?(id)
        load(id)
      else
        items = block.call
        Items.new(id, items, info: info)
      end
    end

    def load(id)
      YAML::load(File.read(path(id)))
    end

    def exists?(id)
      File.exists?(path(id, create_path: false))
    end

    def path(id, create_path: true)
      dirname = File.dirname(id).gsub(/^\./, '')
      filename = File.basename(id)
      path = File.join(config.folder, dirname, "#{sanitize_filename(filename)}.items")
      if create_path
        FileUtils.mkdir_p(File.dirname(path)) unless File.exists?(File.dirname(path))
      end
      path
    end

    # remove all cached items
    def cleanup
      FileUtils.rm_f Dir.glob(File.join(config.folder, '*.items'))
    end

    def list
      Dir.glob(File.join(config.folder, '*.items'))
    end

    def sanitize_filename(name)
       name.strip.gsub(/[^0-9A-Za-z.\-]/, '_').downcase
    end
  end
end
