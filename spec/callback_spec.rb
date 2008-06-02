require File.dirname(__FILE__) + '/spec_helper'

class TestCallbacks
  include Callbacks
  attr_reader :str
  
  before :world, :hello
  after :world, :thanks
  
  def hello
    string << "hello "
  end
  def world
    string << "world"
  end
  def thanks
    string << ", thank you"
  end
  after :pop, :boom
  def pop
    string << "pop"
  end
  def boom
    string << " goes boom"
  end    
  def string
    @str ||= String.new
  end
end
describe "Callbacks" do
  before(:each) do
    @klass = TestCallbacks.new
  end
  it "should retain it's class identifier" do
    @klass.class.should == TestCallbacks
  end
  it "should callback the method before the method runs" do
    @klass.world.should == "hello world, thank you"
  end
  it "should callback the method before the method runs" do
    @klass.pop.should == "pop goes boom"
  end
end
class TestMultipleCallbacks
  include Callbacks
  attr_reader :str
  def hi
    string << "hi, "
  end
  def hello
    string << "hello "
  end
  def world
    string << "world"
  end
  def string
    @str ||= String.new
  end
  before :world, :hi, :hello
end
describe "Multiple callbacks" do
  before(:each) do
    @klass = TestMultipleCallbacks.new
  end
  it "should be able to have multiple callbacks on the same call" do
    @klass.world.should == "hi, hello world"
  end
end
class OutsideClass
  def self.hello
    puts "hello"
  end
end
class TestOutsideClass
  include Callbacks
  before :world, {:hello => "OutsideClass"}
  def world
    "world"
  end
end
describe "Options" do
  before(:each) do
    @c = TestOutsideClass.new
  end
  it "should be able to pass external class options to the callback" do
    OutsideClass.should_receive(:hello).and_return "hello"
    @c.world
  end
end
class BlockClass
  include Callbacks
  before :world do
    string << "hello "
  end
  def world
    string << "world"
  end
  def string
    @string ||= ""
  end
end
describe "Block callbacks" do
  it "should call the block on the callback" do
    BlockClass.new.world.should == "hello world"
  end
end