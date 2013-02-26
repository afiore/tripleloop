require 'addressable/template'

class AuthorsExtractor < Tripleloop::Extractor
  bind(:doi)      { |doc| RDF::DOI.send(doc['doi']) }
  bind(:graph)    { RDF::NPGG.authors }

  map('authors') { |authors_data|
    article_authors(authors_data) + affiliations(authors_data)
  }

private
  def article_authors(authors)
    Array(authors).map {|a|
      [doi, RDF::NPG.hasAuthor, author_uri(a['full']), graph]
    }
  end

  def affiliations(authors)
    Array(authors).reduce([]) { |accu, author|
      accu + author.fetch('affiliations', []).map { |affiliation|
        [author_uri(author['full']), RDF::NPG.affiliatedTo, institution_uri(affiliation), graph]
      }
    }
  end

  def author_uri(full_name)
    RDF::URI.new "http://ns.nature.com/authors/#{to_slug(full_name)}"
  end

  def institution_uri(institution)
    RDF::URI.new "http://ns.nature.com/institutions/#{to_slug(institution)}"
  end

  def to_slug(name)
    name.to_slug.normalize
  end
end
