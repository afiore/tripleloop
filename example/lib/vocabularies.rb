require 'rdf'

module RDF
  class DOI  < RDF::Vocabulary("http://dx.doi.org/");end
  class NPG  < RDF::Vocabulary("http://ns.nature.com/terms/");end
  class NPGO < RDF::Vocabulary("http://ns.nature.com/ontology/");end
  class NPGS < RDF::Vocabulary("http://ns.nature.com/subjects/");end
  class NPGP < RDF::Vocabulary("http://ns.nature.com/products/");end
  class NPGT < RDF::Vocabulary("http://ns.nature.com/techniques/");end
  class NPGG < RDF::Vocabulary("http://ns.nature.com/graphs/");end
end
