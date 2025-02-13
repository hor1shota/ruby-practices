# frozen_string_literal: true

require 'minitest/autorun'

class BowlingTest < Minitest::Test
  def run_bowling(input)
    `./bowling.rb #{input}`.strip.to_i
  end

  def test_case_one
    assert_equal 139, run_bowling('6,3,9,0,0,3,8,2,7,3,X,9,1,8,0,X,6,4,5')
  end

  def test_case_two
    assert_equal 164, run_bowling('6,3,9,0,0,3,8,2,7,3,X,9,1,8,0,X,X,X,X')
  end

  def test_case_three
    assert_equal 107, run_bowling('0,10,1,5,0,0,0,0,X,X,X,5,1,8,1,0,4')
  end

  def test_case_four
    assert_equal 134, run_bowling('6,3,9,0,0,3,8,2,7,3,X,9,1,8,0,X,X,0,0')
  end

  def test_case_five
    assert_equal 144, run_bowling('6,3,9,0,0,3,8,2,7,3,X,9,1,8,0,X,X,1,8')
  end

  def test_perfect_game
    assert_equal 300, run_bowling('X,X,X,X,X,X,X,X,X,X,X,X')
  end

  def test_near_perfect_game
    assert_equal 292, run_bowling('X,X,X,X,X,X,X,X,X,X,X,2')
  end

  def test_low_score_game
    assert_equal 50, run_bowling('X,0,0,X,0,0,X,0,0,X,0,0,X,0,0')
  end
end
