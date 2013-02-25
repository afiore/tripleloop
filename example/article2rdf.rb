project_dir = File.dirname(File.dirname(__FILE__))
base_dir = File.dirname(__FILE__)
$LOAD_PATH << "#{base_dir}/lib"
$LOAD_PATH << "#{base_dir}/lib/extractors"
$LOAD_PATH << "#{project_dir}/lib/tripleloop"

require 'tripleloop'
require 'vocabularies'
require 'article_core'
require 'authors_extractor'
require 'article_processor'
require 'json'
require 'pry'

articles = [JSON.parse(File.read("article.json"))]
rdf_data = ArticleProcessor.batch_process(articles)
Tripleloop::RDFWriter.new(rdf_data).write
