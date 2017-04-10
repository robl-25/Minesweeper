require_relative 'minesweeper'

width = 10
height = 20
num_mines = 10
game = Minesweeper.new(width, height, num_mines)

while game.still_playing?
  valid_move = game.play(rand(width), rand(height))
  valid_flag = game.flag(rand(width), rand(height))
  if valid_move || valid_flag
    printer = (rand > 0.5) ? SimplePrinter.new : PrettyPrinter.new
    printer.custom_print(game.board_state)
  end
end

puts 'Fim do jogo!'
if game.victory?
  puts 'Você venceu!'
else
  puts 'Você perdeu! As minas eram:'
  PrettyPrinter.new.custom_print(game.board_state(xray: true))
end
