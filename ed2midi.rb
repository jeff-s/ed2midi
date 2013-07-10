#!/usr/bin/ruby

$LOAD_PATH[0, 0] = File.join(File.dirname(__FILE__), '..', 'lib')

def loadvalues(m,d)

    #
    # m [ elecduet note ] = midi note
    #
    m[255]=33
    m[240]=34
    m[228]=35
    m[216]=36
    m[204]=37
    m[192]=38
    m[180]=39
    m[172]=40
    m[160]=41
    m[152]=42
    m[144]=43
    m[136]=44

    m[128]=45
    m[120]=46
    m[114]=47
    m[108]=48
    m[102]=49
    m[96]=50
    m[90]=51
    m[86]=52
    m[80]=53
    m[76]=54
    m[72]=55
    m[68]=56

    m[64]=57
    m[60]=58
    m[57]=59
    m[54]=60
    m[51]=61
    m[48]=62
    m[45]=63
    m[43]=64
    m[40]=65
    m[38]=66
    m[36]=67
    m[34]=68

    m[32]=69
    m[30]=70
    m[28]=71
    m[27]=72
    m[25]=73
    m[24]=74
    m[22]=75
    m[21]=76
    m[20]=77
    m[19]=78
    m[18]=79
    m[17]=80

    m[16]=81
    m[15]=82
    m[14]=83
    m[13]=84
    m[12]=85
    m[12]=86
    m[11]=87
    m[10]=88
    m[10]=89
    m[9]=90
    m[9]=91
    m[8]=92

    m[0]=0 #rest

    #
    # d [ elec duet duration ] = midi duration
    #
    d[255]='dotted whole'
    d[254]='dotted whole'
    d[128]='whole'
    d[112]='whole'
    d[96]='dotted half'
    d[64]='half'
    d[56]='half'
    d[48]='dotted quarter'
    d[45]='quarter'
    d[44]='quarter'
    d[40]='quarter'
    d[32]='quarter'
    d[30]='dotted eighth'
    d[26]='dotted eighth'
    d[24]='dotted eighth'
    d[20]='eighth '
    d[18]='eighth'
    d[16]='eighth'
    d[15]='eighth'
    d[14]='eighth'
    d[12]='dotted sixteenth'
    d[11]='dotted sixteenth'
    d[10]='dotted sixteenth'
    d[9]='sixteenth'
    d[8]='sixteenth'
    d[7]='sixteenth '
    d[6]='dotted 32nd'
    d[5]='dotted 32nd'
    d[4]='32nd'
    d[3]='dotted 64th'
    d[2]='64th'
    
end

require 'rubygems'
require 'midilib/sequence'
require 'midilib/consts'
include MIDI

print "ed2midi - By Jeff, Oct 2011\n"
print "\n"

if ARGV.length != 1
  print "Converts Apple ][ Electric Duet files to a primitive MIDI format.\n\n"
  print "Syntax: ed2midi <electric_duet_filename>\n\n"
  print "writes output file in same directory with .midi extension.\n"
  exit
end

file_name=ARGV[0] #'/Users/jeff/JMS/MIDI/ED/M.SONATA'
out_file=file_name.gsub('M.','').gsub('.bin','').downcase+'.midi'
print "Creating #{out_file}...\n"

m=Hash.new
d=Hash.new
loadvalues(m,d)

seq = Sequence.new()

# Create a first track for the sequence. This holds tempo events and stuff
# like that.
track = Track.new(seq)
seq.tracks << track
track.events << Tempo.new(Tempo.bpm_to_mpq(120))
track.events << MetaEvent.new(META_SEQ_NAME, 'ed2midi')

# Create a track to hold the notes. Add it to the sequence.
track1 = Track.new(seq)
seq.tracks << track1
# Give the track a name and an instrument name (optional).
track1.name = 'Voice 1'
track1.instrument = GM_PATCH_NAMES[0]
# Add a volume controller event (optional).
track1.events << Controller.new(0, CC_VOLUME, 127)
track1.events << ProgramChange.new(0, 1, 0)

# Create a track to hold the notes. Add it to the sequence.
track2 = Track.new(seq)
seq.tracks << track2
# Give the track a name and an instrument name (optional).
track2.name = 'Voice 2'
track2.instrument = GM_PATCH_NAMES[0]
# Add a volume controller event (optional).
track2.events << Controller.new(0, CC_VOLUME, 127)
track2.events << ProgramChange.new(0, 1, 0)

buf = File.open(file_name,"rb") {|io| io.read}
starting=0
print "#{buf.length} bytes.\n"
if buf[0]==0 and buf[1]==40
  print "Raw file mode, skipping load address and length (first four bytes).\n"
  starting=4
end
p=starting
while p<(buf.length - starting) do
  dur=buf[p]
  e1=buf[p+1]
  e2=buf[p+2]
  m1=m[e1]
  m2=m[e2]
  if m1.nil? : m1=m[e1-1]||m[e1]||m[e1+1] end
  if m2.nil? : m2=m[e2-1]||m[e2]||m[e2+1] end

  v1=64
  v2=64
  if m1.nil? : m1=0; v1=0 end
  if m2.nil? : m2=0; v2=0 end
  
  if (dur>1)  
     print "#{p}: #{dur}=#{d[dur]}, #{e1}=#{m1}, #{e2}=#{m2}\n"
     track1.events << NoteOn.new( 0, m1, v1, 0)
     track1.events << NoteOff.new(0, m1, v1, seq.note_to_delta(d[dur]))
     track2.events << NoteOn.new( 0, m2, v2, 0)
     track2.events << NoteOff.new(0, m2, v2, seq.note_to_delta(d[dur]))
  end
  if (dur==1)
    print "Program change, v1=#{e1}, v2=#{e2}\n"
    track1.events << ProgramChange.new(0, e1, 0)
    track2.events << ProgramChange.new(0, e2, 0)
  end
  
  p+=3
end

File.open(out_file, 'wb') { | file | seq.write(file) }

exit

