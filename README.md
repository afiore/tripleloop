# Tripleloop

A DSL for extracting data from hash-like objects into RDF statements (i.e. triples or quads).

## Usage

Start by creating some extractor classes. Each extractor maps one or several document fragments
to RDF statments.

    class ArticleCoreExtractor < Tripleloop::Extractor
      bind(:doi) { |doc| RDF::DOI.send(doc[:doi]) }

      map(:title)          { |title|   [doi, RDF::DC11.title, title, RDF::NPGG.articles] }
      map(:published_date) { |date |   [doi, RDF::DC11.date, Date.parse(date), RDF::NPGG.articles] }
      map(:product)        { |product| [doi, RDF::NPG.product, RDF::NPGP.nature, RDF::NPGG.articles] }
    end

    class SubjectsExtractor < Tripleloop::Extractor
      bind(:doi) { |doc| RDF::DOI.send(doc[:doi]) }

      map(:subjects) { |subjects|
        subjects.map { |s|
          [doi, RDF::NPG.hasSubject, RDF::NPGS.send(s) ]
        }
      }
    end

Once defined, extractors can be composed into a DocumentProcessor class.

   class NPGProcessor < Tripleloop::DocumentProcessor
     extractors :article_core, :subjects
   end

The processor can then be fed with a collection of hash like documents and return RDF data grouped by
extractor name.

    data = NPGProcessor.batch_process(documents)
    => { :article_core => [[<RDF::URI:0x00000002651ce0(http://dx.doi.org/10.1038/481241e)>, <RDF::URI:0x1b0c060(http://purl.org/dc/elements/1.1/title)>, "Developmental biology: Watching cells die in real time"],...], :subjects

Notice that the output retuned by the `batch_process` method is still a plain ruby data structure, and not an instance of RDF::Statement.
The actual job of instantiating RDF statements and writing them to disc is in fact responsability of the `Tripleloop::RDFWriter` class, which can be used as follows:

    Tripleloop::RDFWriter.new(data, :dataset_path => Pathname.new("my-datasets")).write

This will create the following two files:

   `my-dataset/article_core.nq`
   `my-dataset/subjects.nq`

When `#write` method is executed, `RDFWriter` will internally generate RDF triples, delegating the RDF serialisation job to RDF.rb's [`RDF::Writer`](http://rubydoc.info/github/ruby-rdf/rdf/master/RDF/Writer).
The only logic involved in the implementation of `Tripleloop::RDFWriter#write` concerns the assignment of the right RDF serialisation format and file extension. When all the RDF statements
generated by an extractor do specify also a graph (as in the example above), the writer will use the `RDF::NQuads::Writer`, falling back to RDF::NTriples otherwise.



