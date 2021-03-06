module Tripleloop
  class DocumentProcessor
    attr_reader :document

    def initialize(document)
      @document = Util.with_nested_fetch(document)
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

    def self.batch_process(documents)
      documents.map { |doc|
        self.new(doc).extracted_statements
      }.reduce(Hash.new([])) { |accu, statements|
        accu.merge(statements) { |k, olds, news|
          olds.concat(news)
        }
      }
    end

  private
    def extractor_instances
      extractors = self.class.instance_variable_get(:@extractors)

      @extractor_instances ||= extractors.map { |ext, opts|
        klass   = extractor_class(ext)
        context = get_context(opts[:context])
        klass.new(context)
      }
    end

    def extractor_class(extractor)
      class_name = Tripleloop::Util::String.classify("#{extractor}_extractor")
      scope.const_get(class_name)
    rescue NameError
      raise ExtractorNotFoundError, "Cannot find an extractor with class name '#{scope}::#{class_name}'"
    end

    def scope
      Tripleloop::Util.module(self)
    end

    def get_context(context)
      context ? document.get_in(*context) : document
    end

    class ExtractorNotFoundError < StandardError;end
  end
end
