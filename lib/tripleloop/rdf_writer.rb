class Tripleloop::RDFWriter
  def initialize(statements, opts={})
    @statements = statements
  end

  def statements
    Hash[@statements.map { |extractor_name, statements|
      [extractor_name,
       statements.map { |s| build_statement(s) }]
    }]
  end

  def build_statement(args)
    RDF::Statement.new(
      Hash[[:subject, :predicate, :object, :graph].zip(args)]
    )
  end
end
