### Convert text input to mp3 via Google Cloud TTS

Creator's primary use case is creation of Anki vocab cards. Cards have native languagage, target lanugage, and audio fields. Current workflow:

**Prerequisites**: Need a google cloud project with billing enabled, and valid service account key. Fill in all the environment variables and rename env.template to .env.

1. **Create a pipe delmited file of vocab words.** For example:

      le poisson| fish  
      le porc| pork  
      le potage| soup  

2. **Execute the following IRB**:
- load 'ruby_wrapper_google_tts.rb'
- x = RubyGoogleTTS.new
- x.create_anki_vocab_txt

   ** Assumes macOS, Ruby 2.6+, and installed Gems  
   ** Similar functionality exists to create cloze cards. Use, "create_anki_cloze_txt".

   This will 
   - Create an MP3 audio file for each item in the first column in the /output directory.
   - Create an, 'import_vocab.csv' file in the /anki directory.

3. **Manually copy audio files from the output directory into anki collections folder** (On macOS this is currently ~/Library/Application Support/Anki2/User/collection.media).
4. **Import CSV into Anki mapping CSV columns to card fields** (File --> Import).

