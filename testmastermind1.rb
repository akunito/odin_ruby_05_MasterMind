#variables
COLORS = %w[Red Magenta Orange Yellow Blue Sky Green Lime]
# 0   1       2      3      4    5    6    7
KEYS_COLORS = %w[:White :Black]
ROWS = 4 # 12
COLS = 5

@keys_board = Array.new(ROWS) {Array.new(COLS)}
@password = Array.new(COLS)
@decoder_board = Array.new(ROWS) {Array.new(COLS)}
@decoder_board = @decoder_board.each do |row|
  row.map.with_index do |_value, i|
    row[i] = "[" + (i + 1).to_s + "]"
  end
end

@password = ["Red", "Yellow", "Magenta", "Green", "Lime"]
@decoder_board[0] = %w[Sky Yellow Magenta Orange Green]

# functions
def print_boards
  # print decoder and keys boards here
  board_col_separator = " ---- "
  @decoder_board.each_with_index do |e, i|
    p "#{e} #{board_col_separator} #{@keys_board[i]}".to_s.gsub('"', '')
  end
end

def place_keys
  p @password
  @password.each_with_index do |e, i|
    @keys_board[@round][i] = "White" if @password.include?(@decoder_board[@round][i])
    @keys_board[@round][i] = "Black" if e == @decoder_board[@round][i]
  end
end

# main
@round = 0
place_keys
print_boards

p "--------"
readable_indexes = []
p readable_indexes.length