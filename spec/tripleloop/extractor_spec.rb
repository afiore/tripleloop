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

    context "when a block does not return a valid constructor argument for RDF::Statement" do
      it "raises an ArgumentError" do
        expect {
          BrokenExtractor.new(document).extract
        }.to raise_error(Tripleloop::Extractor::BrokenMappingError)
      end
    end
  end

  describe "#name" do
    it "returns the extractor name (in snake case)" do
      extractor.name.should eq("sample")
    end
  end
end
