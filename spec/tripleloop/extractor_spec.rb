require 'spec_helper'

describe Tripleloop::Extractor do
  class SampleExtractor < Tripleloop::Extractor
    map(:path, :to, :key) { |fragment|
      [fragment, :predicate, :object]
    }

    map(:path, :to, :enumerable) { |enumerable|
      enumerable.map { |item|
        [:subject, item, :object]
      }
    }

    map(:path, :to, :missing, :key) { nil }
  end

  class BrokenExtractor < Tripleloop::Extractor
    map(:path, :to, :key) { |fragment|
      [[:subject, fragment, :obj],
       [:subject, :obj]] # <= missing predicate
    }
  end

  let(:document) {{
    :path => {
      :to => {
        :key => :test_key,
        :enumerable => [ :foo, :bar, :baz]
      }
    }
  }}

  let(:extractor) {
    SampleExtractor.new(document)
  }

  describe "#extract" do
    let(:triples) { extractor.extract }

    it "maps a document fragment to a block" do
      triples.first.should eq([:test_key, :predicate, :object])
    end

    context "when a block returns multiple triples arguments" do
      it "concats the returned values to the extracted list" do
        triples[1..3].should eq([
          [:subject, :foo, :object],
          [:subject, :bar, :object],
          [:subject, :baz, :object]
        ])
      end
    end

    context "when a map block does not return a valid constructor argument for RDF::Statement" do
      it "raises an ArgumentError" do
        expect {
          BrokenExtractor.new(document).extract
        }.to raise_error(Tripleloop::Extractor::BrokenMappingError)
      end
    end

    context "when a map block returns a nil value" do
      it "ignores the nil value" do
        triples.should_not include(nil)
      end
    end

    context "when map points to a nil document fragment" do
      my_block = proc { raise "This should not be called" }

      klass = Class.new(SampleExtractor) do
        map(:path, :to, :nil, :key, &my_block)
        map(:path, :to, :key) { |v| [:s, :p, v] }
      end

      it "ignores the mapped block" do
        my_block.should_not_receive(:call)
        extractor = klass.new(document)
        extractor.extract.should eq([
          [:s, :p, :test_key]
        ])
      end
    end
  end

  describe ".define" do
    let(:document) {{
      :doi => "10.1038/481241e",
      :title => "Sample document"
    }}

    class ExtractorWithBinding < Tripleloop::Extractor
      bind(:doi) { |doc| doc[:doi] }

      map(:title) { |title|
        [doi, RDF::DC11.title, title]
      }
    end

    it "defines a binding which can be used from within a map block" do
      extractor = ExtractorWithBinding.new(document)
      extractor.extract.should eq([["10.1038/481241e", RDF::DC11.title, "Sample document"]])
    end
  end

  describe "#name" do
    it "returns the extractor name (in snake case)" do
      extractor.name.should eq("sample")
    end
  end
end
