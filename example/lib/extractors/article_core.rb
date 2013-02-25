class ArticleCoreExtractor < Tripleloop::Extractor
  bind(:doi)            { |doc| RDF::DOI.send(doc['doi']) }

  map('title')          { |title|   [doi, RDF::DC11.title, title, RDF::NPGG.articles] }
  map('product')        { |product| [doi, RDF::NPG.product, RDF::NPGP.nature, RDF::NPGG.articles] }
  map('published_date') { |date |   [doi, RDF::DC11.date, Date.parse(date), RDF::NPGG.articles] }
end
