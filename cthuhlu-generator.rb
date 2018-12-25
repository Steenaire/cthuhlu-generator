# require Random

# FORMAT:
# 'TITLE'
# Item description of about 160 characters generated from a mix of menu descriptions and lovecraft text.
# Calories: N Cost: $N

calories = Random.rand(2000)
price = Random.rand(100)+Random.rand.round(2)

puts "Price: $#{price}"
puts "Calories: #{calories}"

all_words_array = []

probabilities_hash = {}

wordcounts = []

randomizer_words_array = []

def trainer
  words_hash = {}
  line_words_array = []
  words_popularity_hash = {}
  opener_words_array = []
  File.open("assets/titles/steen_titles.txt", 'r') do |file|
    file.each_line do |line|
      # puts line
      line_words_array = line.split(" ")
      if line_words_array.any?
        line_words_array.each_with_index do |word, word_index|
          if words_hash["#{word}"] && word_index < line_words_array.length-1
            words_popularity_hash["#{word}"] += 1
              words_hash["#{word}"] << line_words_array[word_index+1]
          elsif words_hash["#{word}"]
            words_popularity_hash["#{word}"] += 1
          elsif word_index < line_words_array.length-1
            words_hash["#{word}"] = [line_words_array[word_index+1]]
            words_popularity_hash["#{word}"] = 1
          end
          #Also stores opening words in their own special array, so the text can be opened appropriately
          opener_words_array << word if word_index == 0
          #I considered doing closing words the same way as opening words, but decided against it because it might be even weirder than Markov
          #closing_words_array << word if word_index == line_words_array.length-1
        end
      end
    end
  end
  return words_hash, opener_words_array
end

words_hash, opener_words_array = trainer

words_hash.each do |word, following_words|
  # file.write("#{word}\t#{following_words}\n")
  following_words.each do |following_word|
    # float_holder = 1.to_f/following_words.length.to_f
    if probabilities_hash["#{word}"]
      if probabilities_hash["#{word}"]["#{following_word}"]
        probabilities_hash["#{word}"]["#{following_word}"] += 1
      else
        probabilities_hash["#{word}"]["#{following_word}"] = 1
      end
    else
      probabilities_hash["#{word}"] = {"#{following_word}" => 1}
    end
  end
    all_words_array << word
end

# Picks an opener from the opening words
random_word = opener_words_array.sample

# word_count_average = wordcounts.reduce(:+).to_f / wordcounts.size
word_count_average = 3
word_count_deviation = Random.rand(4)

# Generates a word count based on the average word count of the documents, then adds or subtracts within a range of -10% and +10%
word_count = (word_count_average + rand(-word_count_deviation..word_count_deviation)).to_i
puts word_count

menu_item = File.open("menu_item.txt", 'w')

print "#{random_word.strip.capitalize} "
menu_item.write("#{random_word.strip.capitalize} ")
counter = 0
word_count.times do
  counter += 1

  if probabilities_hash[random_word]
    probabilities_hash[random_word].each do |following_word, probability|
      probability.times do
        randomizer_words_array << following_word
      end
    end
    if counter == word_count
      # If it is the last word, strip out all punctuation that may/may not be there, and add a period, just to be safe
      random_word = "#{randomizer_words_array.sample.gsub(/[^\w\s\d]/, '')}"
    else
      random_word = randomizer_words_array.sample
    end
    print "#{random_word.chomp(')').chomp('(').strip} "
    menu_item.write("#{random_word.chomp(')').chomp('(').strip} ")
    randomizer_words_array = []
  else
    random_word = opener_words_array.sample
    print "#{random_word.strip.capitalize} "
    menu_item.write("#{random_word.strip.capitalize} ")
  end
end

print ("\n")
menu_item.close