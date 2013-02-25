require 'spec_helper'
require 'fakefs/spec_helpers'

describe Tripleloop::RDFWriter do
  class ExampleNs < RDF::Vocabulary("http://example.com/resources/"); end
  class SampleGraph < RDF::Vocabulary("http://example.com/graphs/"); end

  let(:triples) {[
    [ExampleNs.my_resource, RDF::DC11.title, "My test resource"],
    [ExampleNs.my_resource, RDF::DC11.author, "sample author"]
  ]}

  let(:triples_as_rdf) {[
    RDF::Statement(:subject => ExampleNs.my_resource,
                       :predicate => RDF::DC11.title, 
                       :object => "My test resource"),

    RDF::Statement(:subject => ExampleNs.my_resource,
                   :predicate => RDF::DC11.author,
                   :object => "sample author")
  ]}

  let(:quads) {[
    [ExampleNs.my_resource, RDF::DOAP.homepage, ExampleNs.my_resource, SampleGraph.projects],
    [ExampleNs.my_resource, RDF::DOAP.mailing_list, RDF::URI("mailto://example-list@mailman.example.com"), SampleGraph.projects]
  ]}

  let(:quads_as_rdf) {[
    RDF::Statement(:subject => ExampleNs.my_resource,
                   :predicate => RDF::DOAP.homepage, 
                   :object => ExampleNs.my_resource,
                   :context => SampleGraph.projects),

    RDF::Statement(:subject => ExampleNs.my_resource,
                   :predicate => RDF::DOAP.mailing_list,
                   :object => RDF::URI("mailto://example-list@mailman.example.com"),
                   :context => SampleGraph.projects)
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
      rdf_writer.statements[:triples].should eq(triples_as_rdf)
    end

    it "returns 4 items long arrays as RDF quads" do
      rdf_writer.statements[:quads].should eq(quads_as_rdf)
      rdf_writer.statements[:quads].each do |statement|
        statement.context.should eq(SampleGraph.projects)
      end
    end
  end

  describe "#write" do
    include FakeFS::SpecHelpers

    before do
      FakeFS.activate!
      rdf_writer.write
    end

    context "when a dataset path is not supplied in the options" do
      it "saves files in the standard 'datasets' folder" do
        File.directory?("datasets").should be_true
      end
    end

    context "when a dataset path is supplied" do
      let(:options) {{
        :dataset_path => Pathname.new("test-path")
      }}

      it "exports quads as .nq file" do
        File.read("test-path/quads.nq").split(/\s*\.\n/).should eq([
          "<#{ExampleNs.my_resource}> <#{RDF::DOAP.homepage}> <#{ExampleNs.my_resource}> <#{SampleGraph.projects}>",
          "<#{ExampleNs.my_resource}> <#{RDF::DOAP.mailing_list}> <mailto://example-list@mailman.example.com> <#{SampleGraph.projects}>",
        ])
      end

      it "exports triples as .n3 files" do
        File.read("test-path/triples.nt").split(/\s*\.\n/).should eq([
          "<#{ExampleNs.my_resource}> <#{RDF::DC11.title}> \"My test resource\"",
          "<#{ExampleNs.my_resource}> <#{RDF::DC11.author}> \"sample author\"",
        ])
      end
    end

    after do
      FakeFS.deactivate!
    end
  end
end
