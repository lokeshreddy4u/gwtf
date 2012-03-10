module Gwtf
  class Item
    attr_accessor :file

    def initialize(file=nil)
      @item = default_item
      @file = file

      load_item if file
    end

    def open?
      @item["status"] == "open"
    end

    def closed?
      !open?
    end

    def load_item
      raise "A file to read from has not been specified" unless @file

      read_item = JSON.parse(File.read(@file))

      @item.merge!(read_item)
    end

    def backup_dir
      File.join(File.dirname(file), "backups")
    end

    def save(backup=true)
      raise "No item_id set, cannot save item" unless @item["item_id"]

      if backup && File.exist?(@file)
        backup_name = File.basename(@file) + "-" + Time.now.to_f.to_s

        FileUtils.mv(@file, File.join(backup_dir, backup_name))
      end

      File.open(@file, "w") do |f|
        f.print to_json
      end

      @file
    end

    def default_item
      {"description" => nil,
       "subject" => nil,
       "created_at" => Time.now,
       "edited_at" => nil,
       "closed_at" => nil,
       "status" => "open",
       "item_id" => nil,
       "work_log" => []}
    end

    def to_hash
      @item
    end

    def record_work(text, elapsed=0)
      update_property(:edited_at, Time.now)

      @item["work_log"] << {"text" => text, "time" => Time.now, "elapsed" => elapsed}
    end

    def open
      update_property(:closed_at, nil)
      update_property(:status, "open")
    end

    def close
      update_property(:closed_at, Time.now)
      update_property(:status, "closed")
    end

    def to_json
      JSON.pretty_generate(@item)
    end

    def to_yaml
      @item.to_yaml
    end

    def update_property(property, value)
      property = property.to_s

      raise "No such property: #{property}" unless @item.include?(property)

      @item["edited_at"] = Time.now
      @item[property] = value
    end

    def [](property)
      property = property.to_s

      raise "No such property: #{property}" unless @item.include?(property)

      @item[property]
    end

    def []=(property, value)
      update_property(property, value)
    end

    # simple read from the class:
    #
    #   >> i.description
    #   => "Sample Item"
    #
    # method like writes:
    #
    #   >> i.description "This is a test"
    #   => "This is a test"
    #
    # assignment
    #
    #   >> i.description = "This is a test"
    #   => "This is a test"
    #
    # boolean
    #
    #   >> i.description?
    #   => false
    #   >> i.description "foo"
    #   => foo
    #   >> i.has_description?
    #   => true
    #   >> i.has_description
    #   => true
    def method_missing(method, *args)
      method = method.to_s

      if @item.include?(method)
        if args.empty?
          return @item[method]
        else
          return update_property(method, args.first)
        end

      elsif method =~ /^has_(.+?)\?*$/
        return !@item[$1].nil?

      elsif method =~ /^(.+)\?$/
        return !@item[$1].nil?

      elsif method =~ /^(.+)=$/
        property = $1
        return update_property(property, args.first) if @item.include?(property)
      end

      raise NameError, "undefined local variable or method `#{method}'"
    end
  end
end