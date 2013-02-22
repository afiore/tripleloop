require 'spec_helper'

describe Tripleloop::DocumentProcessor do
  class FooExtractor < Tripleloop::Extractor
    map(:attrs, :foo) { |foo| [:subject, foo, :object ] }
  end
  class BarExtractor < Tripleloop::Extractor
    map(:attrs, :bar) { |bar| [:subject, bar, :object ] }
  end
  class BazExtractor < Tripleloop::Extractor
    map(:baz) { |baz| [:subject, baz, :object ] }
  end

  class SampleProcessor < Tripleloop::DocumentProcessor
    extractors :foo, :bar
    extractors :baz, :context => [:attrs, :nested]
  end

  class ProcessorWithMissingExtractor < Tripleloop::DocumentProcessor
    extractors :foo, :missing
  end

  let(:document) {{
    :attrs => {
      :foo => "foo-value",
      :bar => "bar-value",
      :nested => {
        :baz => "baz-value"
      }
    }
  }}

  describe "#extracted_statements" do
    context "when some of the registered extractors cannot be found" do
      it "raises an ExtractorNotFound error" do
        expect {
          ProcessorWithMissingExtractor.new(document).extracted_statements
        }.to raise_error(ArgumentError)
      end
    end

    context "when all the registered extractors can be found" do
      subject { SampleProcessor.new(document) }

      it "returns a hash mapping extractor names to extracted statements" do
        subject.extracted_statements.should eq({
          :foo => [[:subject, "foo-value", :object]],
          :bar => [[:subject, "bar-value", :object]],
          :baz => [[:subject, "baz-value", :object]]
        })
      end

      it "runs the extractors only once" do
        [FooExtractor, BarExtractor, BazExtractor].each_with_index do |klass, i|
          extractor = double('extractor', :name => "extractor_#{i}")
          klass.stub(:new) { extractor }
          extractor.should_receive(:extract).once.and_return { :extracted }
        end

        subject.extracted_statements.should eq({
          :extractor_0 => :extracted,
          :extractor_1 => :extracted,
          :extractor_2 => :extracted
        })
      end
    end
  end
end
