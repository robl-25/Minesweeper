require 'matrix'

# Class to validate operations
class Validator
  def self.check_arg(arg)
    message_error = 'Expected Integer, got #{arg.class}'
    raise TypeError, message_error unless arg.is_a?(Integer)
    raise ArgumentError, 'Argument cannot be negative' if arg < 0
  end

  def self.valid_position?(x, y, width, height)
    check_arg(y)
    check_arg(x)
    y >= 0 && y < width && x >= 0 && x < height
  end

  def self.check_mines(width, height, num_mines)
    check_arg(num_mines)
    message_error = 'Argument can\'t be greater or equal than the number fields'
    raise ArgumentError, message_error if num_mines >= width * height
  end
end

# Management the game minefield
class Minesweeper
  attr_accessor :field, :width, :height, :num_mines, :click_mine
  def initialize(width, height, num_mines)
    Validator.check_arg(width)
    Validator.check_arg(height)
    Validator.check_mines(width, height, num_mines)
    @width = width
    @height = height
    @num_mines = num_mines
    @click_mine = false
    @field = (1..@height).map { |_| (1..@width).map { |_| '0' } }
    populate_mines
    populate_neighbors
  end

  def populate_mines
    (1..@num_mines).each do |_|
      x = rand(@height)
      y = rand(@width)
      while @field[x][y] == 'b'
        x = rand(@height)
        y = rand(@width)
      end
      @field[x][y] = 'b'
    end
  end

  def combines(x, y, aux_height, aux_width)
    combinations = aux_height.product aux_width
    combinations.delete_at(combinations.index([x, y]))
    combinations
  end

  def neighbors(x, y)
    aux_height = [[x - 1, 0].max, x, [x + 1, @height - 1].min].uniq
    aux_width = [[y - 1, 0].max, y, [y + 1, @width - 1].min].uniq
    combines(x, y, aux_height, aux_width)
  end

  def populate_neighbors
    (0...@height).each do |x|
      (0...@width).each do |y|
        next if @field[x][y] == 'b'
        combinations = neighbors(x, y)
        count_mines = combinations.count { |a, b| @field[a][b] == 'b' }
        @field[x][y] = count_mines.to_s
      end
    end
  end

  def still_playing?
    !@click_mine && @field.flatten.any? { |x| !visited?(x) && x != 'b' }
  end

  def victory?
    !@click_mine && !still_playing?
  end

  def discovering_neighbors(x, y)
    @field[x][y] = "##{@field[x][y]}"
    if @field[x][y][1] == '0'
      combinations = neighbors(x, y)
      combinations.map { |a, b| discovering(a, b) }
    end
  end

  def discovering(x, y)
    if !visited?(@field[x][y]) && @field[x][y] != 'b' &&
       @field[x][y].index('f').nil?
      discovering_neighbors(x, y)
    end
  end

  def play(y, x)
    if Validator.valid_position?(x, y, @width, @height)
      if still_playing?
        if @field[x][y] == 'b'
          @click_mine = true
        elsif !visited?(@field[x][y])
          discovering(x, y)
          true
        end
      end
    end
  end

  def visited?(x)
    !x.index('#').nil?
  end

  def mark_element(x, y)
    element = @field[x][y]
    @field[x][y] = element.index('f').nil? ? "#f#{element}" : element[2]
  end

  def flag(y, x)
    if Validator.valid_position?(x, y, @width, @height)
      if !visited?(@field[x][y]) || !@field[x][y].index('f').nil?
        mark_element(x, y)
        true
      end
    end
  end

  def board_state(options = {})
    [@field, options[:xray], !still_playing?]
  end
end

# Simple printing of the mined field
class SimplePrinter
  def custom_print(list)
    field = list[0]
    xray = list[1]
    finish_game = list[2]
    field.each do |x|
      x.each do |y|
        print_element(y, xray, finish_game)
      end
      print "\n"
    end
  end

  def print_element(y, xray, finish_game)
    if y[0] == '#'
      print y[1]
    elsif y == 'b' && xray && finish_game
      print y
    else
      print '.'
    end
  end
end

# Cut printing of the mined field
class PrettyPrinter
  def custom_print(list)
    field = list[0]
    xray = list[1]
    finish_game = list[2]
    print_edge(field)
    print_matrix(field, xray, finish_game)
    print_edge(field)
  end

  def print_edge(field)
    print '+ '
    print '-' * field[0].size * 2 + ' +'
    print "\n"
  end

  def print_matrix(field, xray, finish_game)
    field.each do |x|
      print '| '
      x.each do |y|
        print_element(y, xray, finish_game)
      end
      print " |\n"
    end
  end

  def print_element(y, xray, finish_game)
    if y[0] == '#'
      print "#{y[1]} "
    elsif y == 'b' && xray && finish_game
      print "#{y} "
    else
      print '. '
    end
  end
end
