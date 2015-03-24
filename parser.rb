class Parser

  def initialize(file)
    @string = open(file)
    @headers = nil
    @content =nil
    @hashes = []
  end

  # Opens file and saves it to the instance of string. Called in intialize
  def open(file)
    @string = File.open(file, "r") do |f|
      f.read
    end
  end

  # Removes whitespace and CR/LF and replaces them with tags
  def tokenize
    @string = @string.strip + "<"
    @string = @string.gsub(/\n\n\s*\[/,"\<\s\>\s\[")
    @string = @string.gsub(/\n\s\s(?!\s)/,"\s\<\s\>")
    @string = @string.gsub(/\n\s\s\s/, "")
    @string = @string.gsub(/\n\s/, "")
  end


  # Grabs the sections headers and saves them to the instance variable of
  # headers as an array. Calls header_is_unique? to ensure uniqueness
  def grab_headers
    @headers = @string.scan(/\[(.*?)\]/).map do |section|
      section.map do |header|
        header.strip
      end
    end
    @headers = @headers.flatten
    header_is_unique?(@headers)
  end

  # Checks if headers are unique
  def header_is_unique?(headers)
    if headers.uniq.length == headers.length
      return headers
    else
      raise "There are duplicates in the headers"
    end
  end

  # Grabs all the key value pairs grouped by section and saves them to the
  # instance of content as nested arrays
  def grab_keys_and_values
    @content = @string.split(/\s(?=\[)/)
    @content = @content.map do |section|
      s = section.scan(/\>(.*?)\</)
      s.flatten!
    end
  end

  # Splits the key value pairs on the semi-colon.
  # Checks for key uniqueness with it's own section
  def split_keys_and_values
    @content = @content.map do |section|
      section.map do |pair|
        pair.split(/\:/)
      end
    end
    keys_unique?
  end


  # Checks if keys in a given sections are unique, for all sections
  def keys_unique?
    @content.each do |section|
      k = []
      section.each do |pair|
        k << pair[0].strip
      end
      if k.uniq.length != k.length
        raise "There are duplicates in the keys"
      end
    end
  end

  # For each sections converts all the split key value pairs into a hash
  # Saves hashes in an array to the instance of hashes
  def to_hash
    @content.map do |section|
      h = {}
      section.map do |key, value|
        convert(h, key, value)
      end
        @hashes << h
    end
    return @hashes
  end


  # Checks if a value is an integer, float or string. If an integer or float
  # it is converted to said class. If it is a string it is stripped of extra
  # whitespace. Then sends value to the hash
  def convert(hash, key, value)
    if is_integer?(value) == true
      value = value.to_i
    end
    if is_float?(value) == true
      value = value.to_f
    end
    if value.is_a? String
      value = value.strip
    end
    hash[key.strip] = value
  end

  # Checks if a string value is actually an integer
  def is_integer?(string)
    /\A[-+]?\d+\z/ === string
  end

  # Checks if a string value is actually a float
  def is_float?(string)
    if string !~ /^\s*[+-]?((\d+_?)*\d+(\.(\d+_?)*\d+)?|\.(\d+_?)*\d+)(\s*|([eE][+-]?(\d+_?)*\d+)\s*)$/
      return false
    else
      return true
    end
  end

  # Extracts all the headers and key value paurs and saves them to instance variables
  def extract
    tokenize
    grab_headers
    grab_keys_and_values
    split_keys_and_values
    to_hash
  end



  # Methods to access instance variable ----------------


  def show_content
    p @content
  end

  def show_string
    p @string
  end

  def show_headers
    p @headers
  end

  def show_hashes
    p @hashes
  end

  # End methods to access instance variables -----------------


  # Search Methods --------------------------------------

  # Searches headers for a match given a string and returns the header's section index. Raises Error
  # if no match
  def search_headers(header)
    @headers.each do |section_name|
      if section_name == header
        section_index = @headers.index(section_name)
        return section_index
      end
    end
    if defined?(section_index) == nil
      raise "Section does not Exist!"
    end
  end

  # Given a section's index and key name, returns a value.
  # If no key name raises an Error
  def search_keys(section_index, key_name)
    @hashes[section_index].each do |key, value|
      if key == key_name
        return value
      end
    end
    raise "Key Does not Exist!"
  end

  # Searches for a value given a header and key name
  def search(header, key_name)
    section_index = search_headers(header)
    search_keys(section_index, key_name)
  end

  # End Search Methods --------------------------



  # Edit and Write Methods ---------------------------


  # Searches for a value given header and key names, updates
  # corresponding value with a new value.
  def update_value(header, key_name, new_value)
    section_index = search_headers(header)
    @hashes[section_index].each do |key, value|
      if key == key_name
        @hashes[section_index][key] = new_value
        return "Successfully updated!"
      end
    end
    raise "Key Does not Exist!"
  end

  # Turns a section back into a string
  def recompile_section(section_counter)
    header = "[" + @headers[section_counter] +"]" + "\n"
    pairs = @hashes[section_counter].map do |k,v|
      if v.to_s.length > 50
        counter = find_break(v.to_s)
        v = v.to_s.insert(counter, "\n ")
        k.to_s + ": " + v
      else
        k.to_s + ": " + v.to_s
      end
    end
    section = header + pairs.join("\n") + "\n\n"
    @string = @string + section
  end

  # Strings over 50 characters get a new line. This checks the
  # index for the new line is between words
  def find_break(string)
    index = 50
    until string[index] == " " do
      index -= 1
    end
    return index
  end

  # recompiles all the sections and joins all the section strings
  def recompile
    @string = ""
    section_count = @headers.length
    counter = 0
    until counter > section_count - 1 do
      recompile_section(counter)
      counter += 1
    end
  end

  # Creates a new file
  def create_file(name)
    File.new(name, "w+")
  end

  # Opens a file and writes it to disk
  def write_file(name)
    File.open(name, 'w') { |file| file.write(@string) }
  end

end

# Test Code

test = Parser.new("test.config")
test.extract
p test.search("header", "project") == "Programming Test"
p test.search("header", "budget") == 4.5
p test.search("header", "accessed") == 205
p test.search("meta data", "description") == "This is a tediously long description of the programming test that you are taking. Tedious isn't the right word, but it's the first word that comes to mind."
p test.update_value("meta data", "description", "This is short. Much better.")
p test.search("meta data", "description") == "This is short. Much better."
p test.update_value("meta data", "description", "Now I will make this long again so that when I write this to disk it will span multiple lines and display the proper indentation on the lines after the first line and this is a great run on sentence.")


# Uncomment to write new file with changes to disk
test.recompile
test.create_file("new.config")
test.write_file("new.config")
p "File created"





