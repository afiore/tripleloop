class Tripleloop::Extractor
  def initialize(context)
    @context = context
  end

  def name
    class_name = self.class.name.split('::').last
    Tripleloop::Util::String.snake_case(class_name).
      gsub(/_extractor$/,'')
  end


  def self.map(*fragment, &block)
    @fragment_map ||= {}
    @fragment_map.merge!(fragment => block)
  end

  def self.fragment_map
    @fragment_map || {}
  end

  def extract
    self.class.fragment_map.reduce([]) do |memo, (path, block)|
      fragment = Tripleloop::Util.with_nested_fetch(context).get_in(*path)
      value = block.call(fragment)

      if value.all? { |object| object.is_a?(Array) }
        memo.concat(value)
      else
        memo << value
      end
    end
  end

private
  attr_reader :context
end
