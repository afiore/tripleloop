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
      returned = block.call(fragment)

      if nested_triples?(returned)

        returned.each do |val|
          ensure_triple_or_quad(val)
        end
        memo.concat(returned)

      else
        ensure_triple_or_quad(returned)
        memo << returned
      end
    end
  end

private

  def nested_triples?(value)
    value.all? { |object| object.is_a?(Array) }
  end

  def ensure_triple_or_quad(value)
    message = "Cannot build a triple or a quad with #{value}."
    raise BrokenMappingError, message unless is_triple_or_quad?(value)
  end

  def is_triple_or_quad?(value)
    [3,4].include? value.length
  end

  class BrokenMappingError < StandardError; end
  attr_reader :context
end
