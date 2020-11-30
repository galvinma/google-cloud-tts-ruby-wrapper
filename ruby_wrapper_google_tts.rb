require "google/cloud/text_to_speech"
require "highline/import"
require "dotenv/load"
require 'securerandom'

Dotenv.load

class RubyWrapperGoogleTTS
  attr_accessor :raw_vocab
  attr_accessor :raw_cloze

  def initialize
    @client = Google::Cloud::TextToSpeech.text_to_speech
  end

  # Creates a pipe delmited file for anki import
  # Expects a list of words in input_vocab.txt
  #
  # ex.
  # le pain grillé, toast
  # le pain au chocolat, pain au chocolat
  # le pâté, pâté
  #
  # Will create an anki import txt with rows native, target, audio
  # Place audio manually in media.collections
  def create_anki_vocab_txt
    return unless "input/input_vocab.txt"
    target_list = parse_raw_input(File.read("input/input_vocab.txt"))
    return unless target_list

    File.open("anki/import_vocab.txt", "w") do |writer|
      target_list.each do |row|
        target = row[0]
        native = row[1]
        audio_file = convert(target)

        # Check for syntax errors
        if target.empty? || native.empty? || audio_file.empty?
          puts("WARNING: Unable to handle the following row:")
          puts(row)
          next
        end

        # Write the txt row
        anki_audio_syntax = "[sound:#{audio_file}]" # [sound:fr-FR_je t'aime aussi.mp3]
        writer << native + ";" + target + ";" + anki_audio_syntax + "\n"
      end
    end
  end

  # Creates a txt file for anki import
  # Expects a list of words in input_cloze.txt
  #
  # {{c1::Je suis}} très heureux.,I am very happy
  # {{c1::Tu es}} une belle femme.,You are a beautiful woman.
  # {{c1::Il est}} sympa.,He is nice.
  def create_anki_cloze_txt
    return unless "input/input_cloze.txt"
    target_list = parse_raw_input(File.read("input/input_cloze.txt"))
    return unless target_list
    File.open("anki/import_cloze.txt", "w") do |writer|
      target_list.each do |row|
        target = row[0]
        target_stripped = strip_close_definition(target)
        native = row[1]
        audio_file = convert(target_stripped)

        # Check for syntax errors
        if target.empty? || native.empty? || audio_file.empty?
          puts("WARNING: Unable to handle the following row:")
          puts(row)
          next
        end

        # Write the txt row
        anki_audio_syntax = "[sound:#{audio_file}]" # [sound:fr-FR_je t'aime aussi.mp3]
        writer << native + ";" + target + ";" + anki_audio_syntax + "\n"
      end
    end
  end

  def parse_raw_input(input)
    input.split("\n").map { |row| row.split("|") }
  end

  def strip_close_definition(str)
    str = str.gsub("c1", "")
      .gsub("c2", "")
      .gsub("c3", "")
      .gsub(/({|}|:)+/, "")
  end

  # Parses a pipe delimted list
  # Each target phrase is on a newline.
  # ex. C'est un jeu très intéressant.|It's a very interesting game.
  def parse_raw_list
    @input_list = @raw_list.gsub(/[\r\n]+/, "").split("|").map { |x| x.to_s.strip }
  end

  # Accepts a list of phrases and calls convert function
  def bulk_convert_list
    parse_raw_list

    @input_list.each do |phrase|
      convert(phrase)
    end
  end

  # Accepts a phrase and writes an MP3 audio output
  def convert(input_text = nil)
    # Get text input
    if input_text == nil
      input_text = ask "Input text: "
    end

    hash = {
      text: input_text,
    }

    voice = {
      language_code: ENV["LANGUAGE_CODE"].to_s,
      ssml_gender: ENV["SSML_GENDER"].to_s,
    }

    audio_config = {
      audio_encoding: "MP3",
      speaking_rate: ENV["SPEAKING_RATE"].to_f,
    }

    response = @client.synthesize_speech(
      input: hash,
      voice: voice,
      audio_config: audio_config,
    )

    # Write the file
    filename = "#{SecureRandom.uuid}.mp3"
    output_path = "output/#{filename}"
    File.open output_path, "wb" do |file|
      file.write response.audio_content
      puts "Audio content written to #{output_path}"
    end

    filename
  end
end
