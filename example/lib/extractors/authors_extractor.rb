require 'addressable/template'

class AuthorsExtractor < Tripleloop::Extractor
  bind(:doi)      { |doc| RDF::DOI.send(doc['doi']) }
  bind(:graph)    { |_|   RDF::NPGG.authors }

  map('authors') { |authors_data|
    article_authors(authors_data) + affiliations(authors_data)
  }

private
  def article_authors(authors)
    authors.map {|a|
      [doi, RDF::NPG.hasAuthor, author_uri(a['full']), graph]
    }
  end

  def affiliations(authors)
    authors.reduce([]) { |accu, author|
      accu + author.fetch('affiliations', []).map { |affiliation|
        [author_uri(author['full']), RDF::NPG.affiliatedTo, institution_uri(affiliation), graph]
      }
    }
  end

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
