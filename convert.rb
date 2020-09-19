require "google/cloud/text_to_speech"
require "highline/import"
require "dotenv/load"

Dotenv.load

# Get text input
input_text = ask "Input text: "

# Instantiates a client
client = Google::Cloud::TextToSpeech.text_to_speech

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

response = client.synthesize_speech(
  input: hash,
  voice: voice,
  audio_config: audio_config,
)

# Write the file
output_path = "output/#{ENV["LANGUAGE_CODE"].to_s}_#{input_text}.mp3"
File.open output_path, "wb" do |file|
  file.write response.audio_content
  puts "Audio content written to #{output_path}.mp3'"
end

# Play the file (macOS)
fork { exec "afplay", output_path }
