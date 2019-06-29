require "digest"    # for hash checksum digest function SHA256
require "pp"        # for pp => pretty printer
require 'active_support/inflector'

class Block

  attr_reader :index
  attr_reader :timestamp
  attr_reader :data
  attr_reader :previous_hash
  attr_reader :hash

  def initialize(index, data, previous_hash)
    @index         = index
    @timestamp     = Time.now
    @data          = data
    @previous_hash = previous_hash
    @hash          = calc_hash
  end

  def calc_hash
    sha = Digest::SHA256.new
    sha.update( @data.to_s + @previous_hash )
    sha.hexdigest
    #pp sha
  end


  def self.first( data="Genesis" )    # create genesis (big bang! first) block
    ## uses index zero (0) and arbitrary previous_hash ("0")
    Block.new( 0, data, "0" )
  end

  def self.next( previous, data )
    Block.new( previous.index+1, data, previous.hash )
  end

end  # class Block

def pluralize(number, text)
  return text.pluralize if number != 1
  text
end

def create_puzzle
    a = 1 + rand(9)
    b = 1 + rand(9)
    sign_index = rand(4)
    sign_list = ["+", "-", "/", "*"]
    
    return [a.to_s, sign_list[sign_index], b.to_s]
end

def solve_puzzle(equation, attempt)
    a = equation[0].to_i
    b = equation[2].to_i
    sym = equation[1]
    result = 0
    
    if sym == "+"
        result = a + b
    elsif sym == "-"
        result = a - b
    elsif sym == "/"
        result = a / b
    elsif sym == "*"
        result = a * b
    end
    
    if attempt != result
        pp "#{attempt.to_s} IS INCORRECT. TRY AGAIN..."
        # pp "#{a.to_s}#{sym}#{b.to_s}"
        return false
    else 
        return [equation, result, attempt]
    end
end

b0 = Block.first( "Genesis" )

#blocks = [b0, b1, b2, b3]

blocked = [b0]
wrong_numbers = []

10.times do |i|
    solution = 0
    attempts = 0
    equation = create_puzzle
    while !solve_puzzle(equation, solution)
        wrong_numbers << solution
        # pp wrong_numbers
        attempts +=1
        while wrong_numbers.include? solution
            solution = -100 + rand(200)
        end
        # sleep 0.5
    end
    wrong_numbers = []
    solved = solve_puzzle(equation, solution)
    blocked[i+1] = Block.next(blocked[i], solved)
    time_taken = blocked[i+1].timestamp - blocked[i].timestamp - 1
    pp "=========== CONGRATULATIONS! YOU HAVE SOLVED THE EQUATION. ==========="
    pp "It took #{time_taken} seconds and #{attempts} attempts to mine this block."
    pp "#{blocked[i+1]} has been added to the chain of #{i} #{pluralize(i, "block")}!"
    #sleep 1
end

def check_reverse_sha(previous_block, current_block)
    blocked.reverse_each.with_index do |block|
        pp block.hash
    end
end

pp blocked

blocked.reverse_each.with_index do |block, i|
    check_sha = Digest::SHA256.new
    check_sha.update(blocked[i+1].hash.to_s + blocked[i].data.to_s)
    pp blocked[i].hash
    pp check_sha.hexdigest
    if check_sha == blocked[i].previous_hash
        pp "This is a secure block."
    end
    
end
# pp rand(6)

#####
## let's get started
##   build a blockchain a block at a time

# b0 = Block.first( "Genesis" )
# b1 = Block.next( b0, "Transaction Data..." )
# b2 = Block.next( b1, "Transaction Data......" )
# b3 = Block.next( b2, "More Transaction Data..." )

# blockchain = [b0, b1, b2, b3]

# pp blockchain