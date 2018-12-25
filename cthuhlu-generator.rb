# require Random

# FORMAT:
# 'TITLE'
# Item description of about 160 characters generated from a mix of menu descriptions and lovecraft text.
# Calories: N Cost: $N

wordcounts = []


title_assets = "assets/titles/steen_titles.txt"
body_assets = "assets/menu_items/steen_bodies.txt"

def trainer(asset_file)
  words_hash = {}
  line_words_array = []
  words_popularity_hash = {}
  opener_words_array = []
  all_words_array = []
  probabilities_hash = {}

  File.open(asset_file, 'r') do |file|
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

  return words_hash, opener_words_array, probabilities_hash
end

def wacky_writer(words_hash, opener_words_array, probabilities_hash, word_count_average, word_count_deviation)
  # Picks an opener from the opening words
  random_word = opener_words_array.sample
  randomizer_words_array = []
  wacky_text = ""

  # word_count_average = wordcounts.reduce(:+).to_f / wordcounts.size

  # Generates a word count based on the average word count of the documents, then adds or subtracts within a range of -10% and +10%
  word_count = (word_count_average + rand(-word_count_deviation..word_count_deviation)).to_i
  # puts word_count

  # print "#{random_word.strip.capitalize} "
  wacky_text << "#{random_word.strip.capitalize} "
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
      # print "#{random_word.chomp(')').chomp('(').strip} "
      wacky_text << "#{random_word.chomp(')').chomp('(').strip} "
      randomizer_words_array = []
    else
      random_word = opener_words_array.sample
      # print "#{random_word.strip.capitalize} "
      wacky_text << "#{random_word.strip.capitalize} "
    end
  end
  return wacky_text
end

words_hash, opener_words_array, probabilities_hash = trainer(title_assets)

title = wacky_writer(words_hash, opener_words_array, probabilities_hash, 3, 4)

puts "'#{title.upcase.strip}'"

calories = Random.rand(2000)
price = Random.rand(100)+Random.rand.round(2)

puts "Price: $#{price} Calories: #{calories}"