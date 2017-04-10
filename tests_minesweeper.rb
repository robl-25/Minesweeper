require_relative 'minesweeper'
require 'test/unit'

# Minesweeper tests
class TestMinesweeper < Test::Unit::TestCase
  def initialize_invalid_arguments_test
    assert_raise(ArgumentError) { Minesweeper.new(10, 10, 101) }
    assert_raise(ArgumentError) { Minesweeper.new(10, 10, 100) }
    assert_raise(ArgumentError) { Minesweeper.new(10, -10, 10) }
    assert_raise(ArgumentError) { Minesweeper.new(-10, 10, 10) }
    assert_raise(TypeError) { Minesweeper.new('red', 10, 101) }
    assert_raise(TypeError) { Minesweeper.new(10, 'trte', 101) }
    assert_raise(TypeError) { Minesweeper.new(10, 10, 'jhg') }
  end

  def verify_neighbors_and_count_mines(game, count_mines)
    game.field.each do |x|
      x.each do |y|
        (y == 'b') ? count_mines += 1 : assert_equal('1', y)
      end
    end
    count_mines
  end

  def test_initialize
    initialize_invalid_arguments_test

    game = Minesweeper.new(2, 2, 1)
    count_mines = verify_neighbors_and_count_mines(game, 0)
    assert_equal(1, count_mines)
  end

  def test_still_playing?
    game = Minesweeper.new(2, 4, 3)
    game.click_mine = true
    assert_equal(false, game.still_playing?)

    game = Minesweeper.new(2, 4, 3)
    game.field = game.field.map { |x| x.map { |y| (y != 'b') ? "##{y}" : 'b' } }
    assert_equal(false, game.still_playing?)

    game = Minesweeper.new(2, 4, 3)
    assert_equal(true, game.still_playing?)
  end

  def verify_neighbors_test(game)
    (0...5).each do |x|
      (0...5).each do |y|
        next if x == 1 && y == 1
        content = ((0...3).cover?(x) && (0...3).cover?(y)) ? '1' : '0'
        assert_equal(content, game.field[x][y])
      end
    end
  end

  def test_populate_neighbors
    game = Minesweeper.new(5, 5, 0)
    game.field[1][1] = 'b'
    game.populate_neighbors
    verify_neighbors_test(game)
  end

  def invalid_arguments_test(game, method)
    assert_raise(ArgumentError) { game.send(method, -1, 2) }
    assert_raise(ArgumentError) { game.send(method, -1, 2) }
    assert_raise(TypeError) { game.send(method, 'gfgd', 2) }
    assert_raise(TypeError) { game.send(method, 2, 'ert') }
  end

  def invalid_moviments_test(game)
    assert_equal(nil, game.play(3, 2))
    assert_equal(nil, game.play(2, 9))

    game = Minesweeper.new(2, 2, 1)
    game.field = game.field.map { |x| x.map { |y| (y != 'b') ? "##{y}" : 'b' } }
    assert_equal(nil, game.play(0, 0))
  end

  def valid_moviments_test
    game = Minesweeper.new(5, 5, 0)
    game.field[1][1] = 'b'
    game.populate_neighbors
    game.play(0, 1)
    assert_equal('#1', game.field[1][0])
  end

  def test_play
    game = Minesweeper.new(2, 4, 3)
    invalid_arguments_test(game, :play)
    invalid_moviments_test(game)
    valid_moviments_test

    game = Minesweeper.new(5, 5, 0)
    assert_equal(true, game.play(0, 0))
    assert_equal(nil, game.play(1, 1))
  end

  def include_falg_test(game)
    assert_equal(true, game.flag(0, 0))
    assert_equal('f', game.field[0][0][1])
  end

  def test_flag
    game = Minesweeper.new(2, 4, 3)
    invalid_arguments_test(game, :flag)
    include_falg_test(game)
    assert_equal(true, game.flag(0, 0))
    assert_equal(true, game.field[0][0].index('f').nil?)
  end

  def test_victory?
    game = Minesweeper.new(5, 5, 0)
    game.field[1][1] = 'b'
    game.populate_neighbors
    game.play(1, 1)
    assert_equal(false, game.victory?)

    game = Minesweeper.new(5, 5, 0)
    game.field[0][0] = 'b'
    game.populate_neighbors
    game.play(4, 4)
    assert_equal(true, game.victory?)
  end
end
