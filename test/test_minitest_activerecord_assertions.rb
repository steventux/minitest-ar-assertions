require 'helper'
require 'active_support/core_ext/module/delegation'

class UnvalidatedThing
  include ActiveRecord::Reflection
  include ActiveRecord::Validations
    
end

class User < ActiveRecord::Base
  include ActiveRecord::Reflection
  include ActiveRecord::Validations
  
  has_many :likes, :as => :likeable
  validates_presence_of :email
  validates_uniqueness_of :username, :email
end



describe "validates_presence_of assertion" do
  it "should fail for models with no validations" do
    assert_raises MiniTest::Assertion do
      assert_validates_presence_of UnvalidatedThing, :email
    end
  end
  
  it "should pass for models with validates_presence_of validations" do
    assert assert_validates_presence_of User, :email
  end
end

describe "validates_uniqueness_of assertion" do
  it "should fail for models with no validations" do
    assert_raises MiniTest::Assertion do
      assert_validates_uniqueness_of UnvalidatedThing, :username, :email
    end
  end
  
  it "should pass for models with validates_uniqueness_of validations" do
    assert assert_validates_uniqueness_of User, :username, :email
  end
end
