class ArticleCoreExtractor < Tripleloop::Extractor
  bind(:doi)            { |doc| RDF::DOI.send(doc['doi']) }
  bind(:graph)          { RDF::NPGG.articles }

  map('title')          { |title|   [doi, RDF::DC11.title, title, graph] }
  map('product')        { |product| [doi, RDF::NPG.product, RDF::NPGP.nature, graph] }
  map('published_date') { |date |   [doi, RDF::DC11.date, Date.parse(date), graph] }
  map('subjects')       { |subjects|
    subjects.map { |s|
      [doi, RDF::NPG.hasSubject, RDF::NPGS.send(s['code'].to_s), graph]
    }
  }
  map('techniques')     { |techniques|
    techniques.map { |t|
      [doi, RDF::NPG.hasTechnique, RDF::NPGT.send(t['code'].to_s), graph]
    }
  }
end
