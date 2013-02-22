require 'set'

module Tripleloop
  class DocumentProcessor

    def initialize(document)
      @document = Tripleloop::Util.with_nested_fetch(document)
    end

    def self.extractors(*args)
      options = args.last.respond_to?(:fetch) ? args.pop : {}
      @extractors ||= {}

      args.each do |ext|
        @extractors[ext] = options
      end
    end

    def extracted_statements
      @extracted_statements ||= Hash[extractor_instances.map { |extractor|
        [extractor.name.to_sym, extractor.extract]
      }]
    end

  private
    attr_reader :document

    def extractor_instances
      extractors = self.class.instance_variable_get(:@extractors)

      @extractor_instances ||= extractors.map { |ext, opts|
        klass   = extractor_class(ext)
        context = get_context(opts[:context])
        klass.new(context)
      }
    end

    def extractor_class(extractor, scope=Kernel)
      class_name = Tripleloop::Util::String.classify("#{extractor}_extractor")
      scope.const_get(class_name)
    rescue NameError
      raise ArgumentError, "Cannot find an extractor with class name '#{class_name}'"
    end

    def get_context(context)
      context ? document.get_in(*context) : document
    end
  end
end
