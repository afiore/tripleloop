require 'spec_helper'

describe Tripleloop::Util do
  subject { Tripleloop::Util }

  describe ".withNestedFetch" do
    context "when supplied argument is an array" do
      it "extends it with the NestedFetch module" do
        subject.withNestedFetch({}).should respond_to(:get_in)
      end
    end

    context "when supplied argument is an hash" do
      it "extends it with the NestedFetch module" do
        subject.withNestedFetch([]).should respond_to(:get_in)
      end
    end

    context "when supplied argument is not enumerable" do
      it "returns the supplied argument" do
        subject.withNestedFetch(Object.new).should_not respond_to(:get_in)
      end
    end
  end

  describe Tripleloop::Util::NestedFetch do
    describe "#get_in" do
      context "when object is a hash" do
        subject { Tripleloop::Util.withNestedFetch({
          :path => {
            :to => {
              :value => :ok
            }
          }
        })}

        it "returns the value corresponding to the supplied path" do
          subject.get_in(:path, :to, :value).should eq(:ok)
        end

        it "returns nothing when the corresponding value cannot be found" do
          subject.get_in(:wrong, :path).should be_nil
        end
      end

      context "when object is an array" do
        subject { Tripleloop::Util.withNestedFetch([
          [0,1,2,[
            [:ok]
          ]]
        ])}

        it "returns the value corresponding to the supplied path" do
          subject.get_in(0,3,0,0).should eq(:ok)
        end

        it "returns nothing when no corresponding value can be found" do
          subject.get_in(0,3,1).should be_nil
        end
      end
    end
  end
end
