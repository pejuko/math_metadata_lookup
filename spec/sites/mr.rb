# -*-: coding: utf-8
require './lib/math_metadata_lookup'

describe MathMetadata::MR do
  l = MathMetadata::Lookup.new :sites => [:mr], :verbose => false

  describe "#article" do
    it "should find one article " do
      result = l.article :title => "Sobolev embeddings with variable exponent. II"
      result.should_not == nil
      result.size.should == 1
      result.num_results.should == 1
    end
  end

  describe "#reference" do
    it "should find one article" do
      result = l.reference :threshold => 0.4, :reference => "Kufner, A., John, O., and Fučík, S.: Function Spaces, Noordhoff, Leyden, and Academia, Prague, 1977"
      result.should_not == nil
      result.size.should == 1
      result.num_results.should == 1
      result.results[0][:id].should == "MR0482102"
    end
  end

  describe "#author" do
    it "should find one author" do
      result = l.author :name => "Vesely, Jiri"
      result.should_not == nil
      result.size.should == 1
      result.num_results.should == 1
      result.results[0][:id].should == "178155"
    end
  end
end
