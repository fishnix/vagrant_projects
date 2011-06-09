if Chef::Config[:solo]
  class Chef
    module Mixin
      module Language
        
        def data_bag(bag)
          @solo_data_bags = {} if @solo_data_bags.nil?
          unless @solo_data_bags[bag]
            @solo_data_bags[bag] = {}
            Dir.glob(File.join(Chef::Config[:data_bag_path], bag,
                               "*.json")).each do |f|
              item = JSON.parse(IO.read(f))
              @solo_data_bags[bag][item['id']] = item
            end
          end
          @solo_data_bags[bag].keys
        end
        
        def data_bag_item(bag, item)
          data_bag(bag) unless ( !@solo_data_bags.nil? && @solo_data_bags[bag])
          @solo_data_bags[bag][item]
        end
        
      end
    end
  end
end
