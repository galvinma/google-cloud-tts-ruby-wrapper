require "google/cloud/text_to_speech"
require "highline/import"
require "dotenv/load"
require "csv"

Dotenv.load

class RubyGoogleTTS
  attr_accessor :raw_list
  attr_accessor :raw_csv

  def initialize
    @client = Google::Cloud::TextToSpeech.text_to_speech
    @raw_list = File.read("input/input.txt")
    @raw_csv = CSV.parse(File.read("input/input.csv"))
  end

  # Creates a csv file for anki import
  # Expects a list of words in input.csv
  #
  # ex.
  # le pain grillé, toast
  # le pain au chocolat, pain au chocolat
  # le pâté, pâté
  #
  # Will create an anki import csv with rows native, target, audio
  # Place audio manually in media.collections
  def create_anki_csv
    file = "anki/anki_import.csv"
    CSV.open(file, "w") do |writer|
      @raw_csv.each do |row|
        target = row[0]
        native = row[1]
        audio_file = convert(target)
        anki_audio_syntax = "[sound:#{audio_file}]" # [sound:fr-FR_je t'aime aussi.mp3]
        writer << [native, target, anki_audio_syntax]
      end
    end
  end

  # Parses a comma delimted list
  # Each target phrase is on a newline.
  # Each lines ends with a comma
  def parse_raw_list
    @input_list = @raw_list.gsub(/[\r\n]+/, "").split(",").map { |x| x.to_s.strip }
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
    output_path = "output/#{ENV["LANGUAGE_CODE"].to_s}_#{input_text}.mp3"
    filename = "#{ENV["LANGUAGE_CODE"].to_s}_#{input_text}.mp3"
    File.open output_path, "wb" do |file|
      file.write response.audio_content
      puts "Audio content written to #{output_path}.mp3'"
    end

    # Play the file (macOS)
    fork { exec "afplay", output_path }
    filename
  end
end
