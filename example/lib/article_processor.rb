class ArticleProcessor < Tripleloop::DocumentProcessor
  extractors :article_core, :authors
end
