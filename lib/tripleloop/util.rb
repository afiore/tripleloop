module Tripleloop
  module Util
    module NestedFetch
      def get_in(*keys)
        return self if keys.empty?
        value = Util.with_nested_fetch(self[keys.shift])

        if value.respond_to?(:get_in) && !keys.empty?
          value.get_in(*keys)
        else
          value
        end
      end
    end

    module String
      module_function

      def classify(string)
        string.split("_").reduce("") { |accu, chunk|
          accu << chunk.capitalize
        }
      end

      def snake_case(string)
        string.gsub(/(.)([A-Z])/,'\1_\2').downcase
      end
    end

  module_function
    def with_nested_fetch(object)
      object.is_a?(Enumerable) ? object.extend(NestedFetch) : object
    end
  end
end
