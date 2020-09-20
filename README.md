### Convert text input to mp3 via Google Cloud TTS

Creator's primary use case is creation of Anki vocab cards. Cards have native languagage, target lanugage, and audio fields. Current workflow:

1. Create a CSV file of vocab words. For example:

   le poisson, fish  
   le porc, pork  
   le potage, soup  

2. Execute the following IRB**:
   - load 'convert.rb'
   - x = RubyGoogleTTS.new
   - x.create_anki_csv
 
   ** Assumes macOS, Ruby 2.6+, and installed Gems

   This will 
   - Create an MP3 audio file for each item in the first column in the /output directory.
   - Create an, 'anki_import.csv' file in the /anki directory.


3. Manually copy audio files from the output directory into anki collections folder (On macOS this is currently ~/Library/Application Support/Anki2/User/collection.media).
4. Import CSV in anki mapping CSV columns to card fields.

