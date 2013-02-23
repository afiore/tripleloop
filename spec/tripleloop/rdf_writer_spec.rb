require 'spec_helper'

describe Tripleloop::RDFWriter do

  class ExampleNs < RDF::Vocabulary("http://example.com/resources/"); end
  class SampleGraph < RDF::Vocabulary("http://example.com/graphs/"); end

  let(:triples) {[
    [ExampleNs.my_resource, RDF::DC11.title, "My test resource"],
    [ExampleNs.my_resource, RDF::DC11.author, "sample author"]
  ]}

  let(:quads) {[
    [ExampleNs.my_resource, RDF::DOAP.homepage, ExampleNs.my_resource, SampleGraph.projects],
    [ExampleNs.my_resource, RDF::DOAP.mailing_list, RDF::URI("mailto://example-list@mailman.example.com"), SampleGraph.projects]
  ]}

  let(:statements) {{
    :triples => triples,
    :quads => quads
  }}

  let(:options) {{}}

  let(:rdf_writer) {
    Tripleloop::RDFWriter.new(statements, options)
  }

  describe "#statements" do
    it "returns 3 items long arrays as RDF triples" do
      expected_triples = [
        RDF::Statement(:subject => ExampleNs.my_resource,
                       :predicate => RDF::DC11.title, 
                       :object => "My test resource"),

        RDF::Statement(:subject => ExampleNs.my_resource,
                       :predicate => RDF::DC11.author,
                       :object => "sample author")
      ]

      rdf_writer.statements[:triples].should eq(expected_triples)
    end

    it "returns 4 items long arrays as RDF quads" do
      expected_quads = [
        RDF::Statement(:subject => ExampleNs.my_resource,
                       :predicate => RDF::DOAP.homepage, 
                       :object => ExampleNs.my_resource,
                       :graph => SampleGraph.project),

        RDF::Statement(:subject => ExampleNs.my_resource,
                       :predicate => RDF::DOAP.mailing_list,
                       :object => RDF::URI("mailto://example-list@mailman.example.com"),
                       :graph => SampleGraph.project)
      ]
      rdf_writer.statements[:quads].should eq(expected_quads)
    end
  end

  describe "#write" do
    context "when a format is not specified" do
      it "exports quads as .nq file"
      it "exports triples as .n3 files"
    end

    context "when a format is specified" do
      it "delegates the ::RDF::Writer"
    end
  end
end
