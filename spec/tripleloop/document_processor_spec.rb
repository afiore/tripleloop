require 'spec_helper'

describe Tripleloop::DocumentProcessor do
  module Example
    class FooExtractor < Tripleloop::Extractor
      map(:attrs, :foo) { |foo| [:subject, foo, :object ] }
    end

    class BarExtractor < Tripleloop::Extractor
      map(:attrs, :bar) { |bar| [:subject, bar, :object ] }
    end

    class BazExtractor < Tripleloop::Extractor
      map(:baz) { |baz|
        baz.map { |v| [:subject, v, :object ] }
      }
    end

    class SampleProcessor < Tripleloop::DocumentProcessor
      extractors :foo, :bar
      extractors :baz, :context => [:attrs, :nested]
    end

    class ProcessorWithMissingExtractor < Tripleloop::DocumentProcessor
      extractors :foo, :missing
    end
  end

  let(:document) {{
    :attrs => {
      :foo => "foo-value",
      :bar => "bar-value",
      :nested => {
        :baz => ["baz a", "baz b"]
      }
    }
  }}

  describe "#extracted_statements" do
    context "when some of the registered extractors cannot be found" do
      it "raises an ExtractorNotFound error" do
        expect {
          Example::ProcessorWithMissingExtractor.new(document).extracted_statements
        }.to raise_error(Example::SampleProcessor::ExtractorNotFoundError, /Example::MissingExtractor/)
      end
    end

    context "when all the registered extractors can be found" do
      subject { Example::SampleProcessor.new(document) }

      it "returns a hash mapping extractor names to extracted statements" do
        subject.extracted_statements.should eq({
          :foo => [[:subject, "foo-value", :object]],
          :bar => [[:subject, "bar-value", :object]],
          :baz => [[:subject, "baz a", :object],
                   [:subject, "baz b", :object]]
        })
      end

      it "runs the extractors only once" do
        [Example::FooExtractor, Example::BarExtractor, Example::BazExtractor].each_with_index do |klass, i|
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

  describe ".batch_process" do
    let(:documents) {
      3.times.map { |n| {
        :attrs => {
          :foo => "foo-value #{n}",
          :bar => "bar-value #{n}",
          :nested => {
            :baz => ["baz a #{n}", "baz b #{n}"]
          }
        }}
      }
    }

    subject { Example::SampleProcessor.batch_process(documents) }

    it "returns a hash of combined statements, grouped by extractor name" do
      subject.should eq({
        :foo => [
          [:subject, "foo-value 0", :object],
          [:subject, "foo-value 1", :object],
          [:subject, "foo-value 2", :object]
        ],
        :bar => [
          [:subject, "bar-value 0", :object],
          [:subject, "bar-value 1", :object],
          [:subject, "bar-value 2", :object]
        ],
        :baz => [
          [:subject, "baz a 0", :object],
          [:subject, "baz b 0", :object],
          [:subject, "baz a 1", :object],
          [:subject, "baz b 1", :object],
          [:subject, "baz a 2", :object],
          [:subject, "baz b 2", :object],
        ]
      })
    end
  end
end
