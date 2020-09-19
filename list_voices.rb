require "google/cloud/text_to_speech"
require "dotenv/load"

Dotenv.load

client = Google::Cloud::TextToSpeech.text_to_speech

# Performs the list voices request
voices = client.list_voices({}).voices

voices.each do |voice|
  # Display the voice's name. Example: tpc-vocoded
  puts "Name: #{voice.name}"

  # Display the supported language codes for this voice. Example: "en-US"
  voice.language_codes.each do |language_code|
    puts "Supported language: #{language_code}"
  end

  # Display the SSML Voice Gender
  puts "SSML Voice Gender: #{voice.ssml_gender}"

  # Display the natural sample rate hertz for this voice. Example: 24000
  puts "Natural Sample Rate Hertz: #{voice.natural_sample_rate_hertz}\n"
end
