require "google/cloud/text_to_speech"
require "highline/import"
require "dotenv/load"

Dotenv.load

# Get text input
input_text = ask "Input text: "

# Instantiates a client
client = Google::Cloud::TextToSpeech.text_to_speech
hash = { text: input_text }

# Note: the voice can also be specified by name.
# Names of voices can be retrieved with client.list_voices
voice = {
  language_code: ENV["LANGUAGE_CODE"].to_s,
  ssml_gender: ENV["SSML_GENDER"].to_s,
}

audio_config = {
  audio_encoding: "MP3",
  speaking_rate: ENV["SPEAKING_RATE"].to_f,
}

response = client.synthesize_speech(
  input: hash,
  voice: voice,
  audio_config: audio_config,
)

# The response's audio_content is binary.
File.open "output/#{ENV["LANGUAGE_CODE"].to_s}_#{input_text}.mp3", "wb" do |file|
  # Write the response to the output file.
  file.write response.audio_content
end

puts "Audio content written to file 'output/#{ENV["LANGUAGE_CODE"].to_s}_#{input_text}.mp3'"
