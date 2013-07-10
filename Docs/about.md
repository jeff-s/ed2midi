In its day, Electric Duet was a technological marvel, allowing two-voice music to be played on Apple \]\[ hardware capable of generating only square waves with 1-bit resolution.  **ed2midi** tries to convert those old music files into a midi format, usable on a variety of software systems today.

**ed2midi** is *not* full-featured.  Its purpose is to get the audio out of these `M.*` files and into a usable file format.  There are no options for tempo, voices, or transposing. All of this and more can be accomplished with other midi software.

Getting your Electric Duet files in to a system capable of running **ed2midi** can be quite a feat.  There are numerous Apple \]\[ resources on the world-wide internet, so get to Google-ing.

# file format #

Electric Duet files are a collection of 3-byte records.

If the first byte is $00, then it's a voice.  See below.

Otherwise, the first byte is the duration, measured in some number of machine cycles.  Bigger values mean longer values.  $20 is translated as a quarter note.  $40 is half note, etc. In-between values are allowed for ritardando and accelerandos, or if you need a string of eight-note quintuplets; **ed2midi** will dumbly quantize to "normal" note lengths, or unceremoniously fail if given an odd-ball duration.

The second and third bytes are the note values for track one and track two, respectively. $36 corresponds to middle C.  Doubling the value lowers the note one octave; halving goes up an octave.  (See the Excel file for mapping Electric Duet values to MIDI note values.)

In-between values are allowed, so if 12-tone chromatic music isn't your thang, Electric Duet will let you find something between C and C&#9839; or between A and B&#9837;.  **ed2midi** tries to round to the nearest note neighbor, but will more likely just fail unceremoniously if given an odd-ball note value.

(This is used to great effect in some of the Electric Duet sample songs.  With one track playing a pure note, and the other track playing an off-by-one value, a "heterodyning" effect could be heard.  This will be lost in **ed2midi**.)

## voices ##

Electric Duet allows different "instruments" (which Electric Duet calls "voices"). $00 being the "pure" square waves we know and love, and increasing values becoming buzzier (for lack of a better word).  These values don't correspond to any real-world instruments; instead they tweak the sound-generating algorithm in some mysterious way.  In my experience, values above $08 didn't seem to make a difference.

**ed2midi** takes these voice numbers, and maps them directly to MIDI program changes, with the Electric Duet voice number mapping directly to MIDI standard instruments ($00=Acoustic Grand Piano, $01=Bright Acoustic Piano, $02=Electric Grand Piano, etc.)  Remember, **ed2midi** isn't full-featured; if you don't like these mappings, you can change them in your MIDI editor.

If the first byte of the record is $00, it is a voice change (and not the aforementioned duration).  The second byte is the voice for track 1, and the third byte is the voice for track 2.

## DOS 3.3 ##

Depending on how you get your files off of your Apple \]\[ media, your Electric Duet music files may have a four-byte prefix.  This is added by DOS 3.3 for all binary files: the first two bytes are the load address (little-endian, natch), and the next two bytes are the length.  (Some Apple \]\[ disk reading software strips these off; others don't.)  All Electric Duet files are saved with a load address of $4000, so if the first two bytes are $00, $40, **ed2midi** skips the first four bytes entirely.  (An Electric Duet file beginning with $00, $40 isn't strictly illegal, but *is* highly unlikely.)

