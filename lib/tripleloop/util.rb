module Tripleloop
  module Util
    module NestedFetch
      def get_in(*keys)
        return self if keys.empty?
        value = Util.withNestedFetch(self[keys.shift])

        if value.respond_to?(:get_in) && !keys.empty?
          value.get_in(*keys)
        else
          value
        end
      end
    end

  module_function
    def withNestedFetch(object)
      object.is_a?(Enumerable) ? object.extend(NestedFetch) : object
    end
  end
end
