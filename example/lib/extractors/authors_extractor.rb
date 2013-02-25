require 'addressable/template'

class AuthorsExtractor < Tripleloop::Extractor
  bind(:doi)      { |doc| RDF::DOI.send(doc['doi']) }
  bind(:graph)    { |_|   RDF::NPGG.authors }

  map('authors') { |authors|
    article_authors = authors.map {|a|
      [doi, RDF::NPG.hasAuthor, author_uri(a['full']), graph]
    }

    affiliations = authors.reduce([]) { |accu, author|
      accu + author.fetch('affiliations', []).map { |affiliation|
        [author_uri(author['full']),
         RDF::NPG.affiliatedTo,
         institution_uri(affiliation),
         graph]
      }
    }

    article_authors + affiliations
  }


private
  def author_uri(full_name)
    uri = "http://ns.nature.com/institutions/{name}"
    RDF::URI.new template_uri(uri).expand(:name => full_name)
  end

  def institution_uri(institution)
    uri = "http://ns.nature.com/institutions/{name}"
    RDF::URI.new template_uri(uri).expand(:name => institution)
  end

  def template_uri(uri)
    @uri_templates ||= {}
    @uri_templates[uri] ||= Addressable::Template.new(uri)
  end
end
