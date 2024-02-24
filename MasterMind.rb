
module MasterMind
  COLORS = %w[Red Magenta Orange Yellow Blue Sky Green Lime]
            # 0   1       2      3      4    5    6    7
  KEYS_COLORS = %w[:White :Black]
  ROWS = 12 # 12
  COLS = 5
  class Game
    def initialize
      @decoder_board = Array.new(ROWS) {Array.new(COLS)}
      @decoder_board = @decoder_board.each do |row|
        row.map.with_index do |_value, i|
          row[i] = "[" + (i + 1).to_s + "]"
        end
      end

      @keys_board = Array.new(ROWS) {Array.new(COLS)}
      @password = Array.new(COLS)
      @round = 0
      @decoder = ComputerDecoder.new(self)
      @coder = ComputerCoder.new(self)
    end
    attr_reader :decoder_board, :keys_board, :round

    def play
      @password = @coder.set_code!
      loop do
        @decoder.select_decode!
        place_keys
        if decoder_won?
          puts "Decoder WINS !!"
          puts "Password was: #{@password}"
          break
        elsif board_full?
          puts "Coder WINS !"
          puts "Password was: #{@password}"
          break
        end
        print_boards
        @round += 1
      end
    end

    def print_boards
      # print decoder and keys boards here
      board_col_separator = " ---- "
      @decoder_board.each_with_index do |e, i|
        p "#{e} #{board_col_separator} #{@keys_board[i]}".to_s.gsub('"', '')
      end
    end

    def decoder_won?
      # check if this round decoder won
      @decoder_board[@round] == @password ? true : false
    end

    def board_full?
      COLORS.include?(decoder_board[ROWS-1][COLS-1])
    end

    # private
    def place_keys
      p @password
      @password.each_with_index do |e, i|
        @keys_board[@round][i] = "White" if @password.include?(@decoder_board[@round][i])
        @keys_board[@round][i] = "Black" if e == @decoder_board[@round][i]
      end
    end
  end

  class Player
    def initialize(game)
      @game = game
    end
  end

  class HumanDecoder < Player
    def select_decode!
      column = 0
      COLS.times do
        loop do
          puts "\n Select a color from the list by number: "
          COLORS.each_with_index { |e,i| puts "#{i} => #{e}" }
          selection = gets.to_i
          unless @game.decoder_board[@game.round].include?(COLORS[selection]) || !selection.between?(0, COLORS.length-1)
            @game.decoder_board[@game.round][column] = COLORS[selection]
            break
          end
          puts "Color #{COLORS[selection]} is not available. Try again."
        end
        column += 1
        @game.print_boards
      end
    end
  end

  class ComputerCoder < Player
    DEBUG = false # edit this line if necessary
    def set_code!
      password = COLORS.sample(5)
      log_debug "Computer has set password: #{password}"
      password
    end

    def log_debug(message)
      puts "#{self}: #{message}" if DEBUG
    end
  end
  class HumanCoder < Player
    DEBUG = false # edit this line if necessary
    def set_code!
      password = select_password!
      log_debug "Human has set password: #{password}"
      password
    end

    def select_password!
      column = 0
      password = Array.new(COLS)
      COLS.times do
        loop do
          puts "\n Select a color from the list by number: "
          COLORS.each_with_index { |e,i| puts "#{i} => #{e}" }
          selection = gets.to_i
          unless password.include?(COLORS[selection]) || !selection.between?(0, COLORS.length-1)
            password[column] = COLORS[selection]
            break
          end
          puts "Color #{COLORS[selection]} is not available. Try again."
        end
        column += 1
      end
      password
    end

    def log_debug(message)
      puts "#{self}: #{message}" if DEBUG
    end
  end

  class ComputerDecoder < Player
    DEBUG = true # edit this line if necessary

    def log_debug(message)
      puts "#{self}: #{message}" if DEBUG
    end

    def select_decode!
      if @game.round == 0
        select_first_decode!
      else
        calculate_decodes!
      end

      puts "\npress Enter to continue"
      gets
    end

    def select_first_decode!
      @game.decoder_board[0] = ["Sky", "Yellow", "Magenta", "Orange", "Green"]
    end

    def calculate_decodes!
      # CHECKING BLACKs
      unless @game.round > ROWS
        @game.keys_board[@game.round-1].each_with_index do |e, i|
          if e == "Black"
            @game.decoder_board[@game.round][i] = @game.decoder_board[@game.round-1][i]
          end
        end
      end

      # CHECKING WHITEs
      readable_indexes = []
      @game.keys_board[@game.round-1].each_with_index do |e, i|
        readable_indexes.push(i) if e == "White"
      end

      writable_indexes = []
      unless @game.round > ROWS
        @game.decoder_board[@game.round].each_with_index do |e, i|
          writable_indexes.push(i) unless COLORS.include?(e)
        end
      end

      readable_indexes.each do |read_index|
        # remove current read_index from writable_indexes and get random one
        writable_indexes_session = writable_indexes
        recover_removed_index = nil
        writable_indexes_session.each_with_index do |e, i|
          if writable_indexes_session.include?(read_index)
            writable_indexes_session.delete(e) if e == read_index
            recover_removed_index = e
          end
        end
        write_index = writable_indexes_session.sample

        # write decoder board
        if @game.decoder_board[@game.round-1][read_index]
          @game.decoder_board[@game.round][write_index] = @game.decoder_board[@game.round-1][read_index]
          log_debug "board has been updated"
          # remove written index
          writable_indexes.each do |e|
            writable_indexes.delete(e) if e == write_index
          end
        end
        # recovering index removed
        writable_indexes_session.push(recover_removed_index) unless recover_removed_index.nil?
      end

      # CHECKING NILs
      # find nil indexes
      readable_indexes = []
      @game.keys_board[@game.round-1].each_with_index do |e, i|
        readable_indexes.push(i) if e.nil?
      end
      # find writable indexes
      writable_indexes = []
      unless @game.round > ROWS
        @game.decoder_board[@game.round].each_with_index do |e, i|
          writable_indexes.push(i) unless COLORS.include?(e)
        end
      end
      # find available COLORS
      available_colors = COLORS - @game.decoder_board[@game.round]
      log_debug available_colors
      # get colors to Nil
      readable_indexes.each do |read_index|
        if @game.decoder_board[@game.round-1][read_index]
          write_index = writable_indexes.sample
          @game.decoder_board[@game.round][write_index] = available_colors.sample
          log_debug "board has been updated"
        end
      end

    end
  end
end

include MasterMind

Game.new.play