class LineAnalyzer
  attr_reader :highest_wf_count, :highest_wf_words, :content, :line_number

  def initialize (content, line_number)
    @content = content
    @line_number = line_number

    calculate_word_frequency(content)
  end

  def calculate_word_frequency(content)
    word_frequency = Hash.new 0

    content.split.each do |word|
      word_frequency[word.downcase] +=1
    end

    @highest_wf_count = word_frequency.values.max
    @highest_wf_words = word_frequency.select { |k, v| v == @highest_wf_count}.keys

  end

end
 
class Solution
  attr_reader :analyzers, :highest_count_across_lines, :highest_count_words_across_lines

  def initialize()
    @analyzers = []
  end

  def analyze_file()
    lines = File.foreach('test.txt')
    lines.each_with_index {|content, line_number| @analyzers << LineAnalyzer.new(content, line_number) }
  end

  def calculate_line_with_highest_frequency()
    @highest_count_across_lines = 0
    @highest_count_words_across_lines = []
    
    @analyzers.each do |x| 
      if x.highest_wf_count > @highest_count_across_lines
        @highest_count_across_lines = x.highest_wf_count
      end
    end

    @analyzers.select do |x|
      if x.highest_wf_count == @highest_count_across_lines
        @highest_count_words_across_lines << x
      end
     end
   end     

  def print_highest_word_frequency_across_lines()
    puts "The following words have the highest word frequency per line:"
    @highest_count_words_across_lines.each{ |x| puts "#{x.highest_wf_words} (appears in line #{x.line_number})" }
  end

end