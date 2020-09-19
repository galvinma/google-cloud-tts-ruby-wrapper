require "google/cloud/text_to_speech"
require "dotenv/load"

Dotenv.load

# Instantiates a client
client = Google::Cloud::TextToSpeech.text_to_speech
input_text = gets.chomp
hash = { text: input_text }

# Note: the voice can also be specified by name.
# Names of voices can be retrieved with client.list_voices
voice = {
  language_code: ENV["LANGUAGE_CODE"].to_s,
  ssml_gender: ENV["SSML_GENDER"].to_s,
}

audio_config = { audio_encoding: "MP3" }

response = client.synthesize_speech(
  input: hash,
  voice: voice,
  audio_config: audio_config,
)

# The response's audio_content is binary.
File.open "#{input_text}.mp3", "wb" do |file|
  # Write the response to the output file.
  file.write response.audio_content
end

puts "Audio content written to file '#{input_text}'"
