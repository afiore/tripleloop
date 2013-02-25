class Tripleloop::RDFWriter
  def initialize(data, opts={})
    @data    = data
    @options = opts
  end

  def statements
    @statements ||= Hash[@data.map { |extractor_name, statements|
      [extractor_name,
       statements.map { |s| as_statement(s) }]
    }]
  end

  def write
    FileUtils.mkdir_p(datasets_path)

    statements.each do |extractor, extracted_statements|
      build_writer(extractor, extracted_statements) do |writer|
        extracted_statements.each do |statement|
          writer << statement
        end
      end
    end
  end

private
  attr_reader :options

  def datasets_path(filename=nil)
    path = Pathname.new(options.fetch(:path, "datasets"))
    filename ? path.join(filename) : path
  end

  def build_writer(extractor, statements, &block)
    statements_format = format(statements)
    ext               = extensions[statements_format]
    folder_path       = options.fetch(:dataset_path, datasets_path)
    path              = folder_path.join("#{extractor}.#{ext}")

    FileUtils.mkdir_p(folder_path)
    RDF::Writer.for(statements_format).open(path, &block)
  end

  def format(statements)
    statements.all?(&:has_context?) ? :nquads : :ntriples
  end

  def extensions
    {
      :ntriples => "nt",
      :nquads => "nq"
    }
  end

  def as_statement(args)
    statement_args = Hash[
      [:subject, :predicate, :object, :context].zip(args)
    ]
    RDF::Statement.new(statement_args)
  end
end
