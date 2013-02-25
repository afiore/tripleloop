require 'spec_helper'

describe Tripleloop::Util do
  subject { Tripleloop::Util }

  describe ".with_nested_fetch" do
    context "when supplied argument is an array" do
      it "extends it with the NestedFetch module" do
        subject.with_nested_fetch({}).should respond_to(:get_in)
      end
    end

    context "when supplied argument is an hash" do
      it "extends it with the NestedFetch module" do
        subject.with_nested_fetch([]).should respond_to(:get_in)
      end
    end

    context "when supplied argument is not enumerable" do
      it "returns the supplied argument" do
        subject.with_nested_fetch(Object.new).should_not respond_to(:get_in)
      end
    end
  end

  describe ".module" do
    module Test
      module Foo
        class Bar; end
      end
      class Baz; end
    end

    context "when the supplied object's class is within a nested namespace" do
      it "returns the parent module as a constant" do
        subject.module(Test::Foo::Bar.new).should eq(Test::Foo)
        subject.module(Test::Baz.new).should eq(Test)
      end
    end

    context "when the supplied object class is not noested within a namespace" do
      it "returns the Kernel constant" do
        subject.module(Object.new).should eq(Kernel)
      end
    end
  end

  describe Tripleloop::Util::NestedFetch do
    describe "#get_in" do
      context "when object is a hash" do
        subject { Tripleloop::Util.with_nested_fetch({
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
        subject { Tripleloop::Util.with_nested_fetch([
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

  describe Tripleloop::Util::String do
    subject { Tripleloop::Util::String }

    describe ".classify" do
      it "turns 'snake case' into 'camel case'" do
        subject.classify("foo_bar_baz").should eq("FooBarBaz")
      end
    end
  end

  describe Tripleloop::Util::Hash do
    subject { Tripleloop::Util::Hash }

    describe ".symbolize_keys" do
      it "returns a copy of the supplied hash, with symbol instead than string keys" do
        subject.symbolize_keys({"foo" => 1, "bar" => 2}).should eq({
          :foo => 1,
          :bar => 2
        })

      end
    end
  end
end
