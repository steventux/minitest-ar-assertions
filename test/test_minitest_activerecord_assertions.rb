require 'helper'
require 'active_support/core_ext/module/delegation'

class UnvalidatedThing < ActiveRecord::Base
end

class UnassociatedThing < ActiveRecord::Base
end

class User < ActiveRecord::Base
  has_many :likes, :as => :likeable
  validates_presence_of :email
  validates_uniqueness_of :username, :email
  validates_inclusion_of :can_like, :in => [true, false]
end

class Like < ActiveRecord::Base
  belongs_to :likeable, :polymorphic => true
  belongs_to :user
  validates_numericality_of :user_id
  validates_presence_of :email
  validates_uniqueness_of :username, :email
end

describe "assert_association assertion" do
  it "should fail for models with no associations" do
    assert_raises MiniTest::Assertion do
      assert_association UnvalidatedThing, :belongs_to, :user
    end
  end
  
  it "should pass for models with has_many associations" do
    assert assert_association(User, :has_many, :likes)
  end
  
  it "should pass for models with belongs_to associations" do
    assert assert_association(Like, :belongs_to, :user)
  end
  
  it "should pass for models with polymorphic belongs_to associations" do
    assert assert_association(Like, :belongs_to, :likeable, :polymorphic => true)
  end
end

describe "assert_validates_presence_of assertion" do
  it "should fail for models with no validations" do
    assert_raises MiniTest::Assertion do
      assert_validates_presence_of UnvalidatedThing, :email
    end
  end
  
  it "should pass for models with validates_presence_of validations" do
    assert assert_validates_presence_of(User, :email)
  end
end

describe "assert_validates_uniqueness_of assertion" do
  it "should fail for models with no validations" do
    assert_raises MiniTest::Assertion do
      assert_validates_uniqueness_of UnvalidatedThing, :username, :email
    end
  end
  
  it "should pass for models with validates_uniqueness_of validations" do
    assert assert_validates_uniqueness_of(User, :username, :email)
  end
end

describe "assert_validates_numericality_of assertion" do
  it "should fail for models with no validations" do
    assert_raises MiniTest::Assertion do
      assert_validates_numericality_of UnvalidatedThing, :user_id
    end
  end
  
  it "should pass for models with validates_numericality_of validations" do
    assert assert_validates_numericality_of(Like, :user_id)
  end
end

describe "assert_validates_inclusion_of assertion" do
  it "should fail for models with no validations" do 
    assert_raises MiniTest::Assertion do
      assert_validates_inclusion_of UnvalidatedThing, :can_like, :in => [true, false]
    end
  end

  it "should pass for models with validates_inclusion_of validations" do
    assert assert_validates_inclusion_of(User, :can_like)
    assert assert_validates_inclusion_of(User, :can_like, :in => [true, false])
    assert_raises MiniTest::Assertion do
      assert_validates_inclusion_of(User, :can_like, :in => [true, true])
    end
  end
end