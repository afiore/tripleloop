class Tripleloop::Extractor
  def initialize(context)
    @context = context
    bind_variables!
  end

  def name
    class_name = self.class.name.split('::').last
    Tripleloop::Util::String.snake_case(class_name).gsub(/_extractor$/,'')
  end

  def self.map(*fragment, &block)
    @fragment_map ||= {}
    @fragment_map.merge!(fragment => block)
  end

  def self.bind(name, &block)
    @extractor_bindings ||= {}
    @extractor_bindings[name.to_sym] = block
  end

  def self.fragment_map
    @fragment_map || {}
  end

  def extract
    self.class.fragment_map.reduce([]) do |accu, (path, block)|
      if fragment = Tripleloop::Util.with_nested_fetch(context).get_in(*path)
        add_to_triples(accu, fragment, &block)
      else
        accu
      end
    end
  end

private
  def add_to_triples(triples, fragment, &block)
    returned = Array(instance_exec(fragment, &block))

    if nested_triples?(returned)
      returned.each do |value|
        ensure_triple_or_quad(value)
      end
      triples.concat(returned)
    else
      ensure_triple_or_quad(returned)
      triples << returned
    end
  end

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

  def bind_variables!
    klass = self.class
    extractor_bindings = klass.instance_variable_get(:@extractor_bindings) || {}
    extractor_bindings.each do |method, block|
      klass.send(:define_method, method) do
        block.call(context)
      end
    end
  end

  class BrokenMappingError < StandardError; end
  attr_reader :context
end
