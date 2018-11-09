# Calculate various acoustic variables
# Built on Michael Wagner's script. Modifications by Michelle Oraa Ali. 

echo Measure

# This script measures various acoustic variables in our annotated files
# You have to *select* all sound files that you want to be included before
# running the script. All soundfiles without corresponding TextGrid files 
#  in the object list are ignored.


## The following procedure cuts apart the file name at underscores and hyphens
## and returns a tab-delimited variable with the pieces
procedure cutname thename$
   remain$ = thename$
   return$ = ""

# cut name into columns
# assumed structure: newonly1_pc_1_item1-1-a.wav
# will cut of beginning, 'pc', and last tab (which is linger internal and irrelevant)

repeat

     seper = index (remain$, "_")
     seperh = index (remain$, "-")

     if seper = 0 
         seper = seperh
     elsif seperh <> 0  and seperh < seper
            seper = seperh
     endif

     if seper = 0
         return$ = return$ + remain$ +  "'seperator$'"
         remain$ = ""
     else
        seper = seper - 1
        return$ = return$ + left$(remain$, seper) +  "'seperator$'"
      
     	len = length(remain$)
     	len = len - seper -1
        remain$ = right$(remain$, len)
     endif

until remain$ = ""  

# now tab delimited columns from name are in variable return$
	   
endproc


form Calculate Results for Production Experiments
	sentence Name_Format participant_presentationnum_verb_condition_item_targword_question_yesno_list_version_index
	sentence Result_filename measure
	sentence extension .wav
	sentence Sound_directory /Users/INSERT_PATH_HERE/
	natural phoneTier 1
	natural wordTier 2
	natural woiTier 3
	sentence seperator ,
endform

# set the woiTier to 2 since we are not getting this

output$ = "" 
output$ > 'result_filename$'.txt

# This creates the column labels:

call cutname 'name_Format$'
output$ = return$ + "word" +  "'seperator$'"  + "wordlabel" +  "'seperator$'"
		    ...+ "phonelength"
                     ...+  "'seperator$'" + "duration" +  "'seperator$'" + "silence" +  "'seperator$'" + "durasil" + "'seperator$'" +  "begin"
                     ...+  "'seperator$'" + "meanpit" +  "'seperator$'" + "maxpitch" +  "'seperator$'" + "maxPitTime"
                     ...+  "'seperator$'" + "minpitch" +  "'seperator$'" + "minPitTime" 
		     ...+  "'seperator$'" + "firstpitch" +  "'seperator$'" + "secondpitch" +  "'seperator$'" + "thirdpitch"
		     ...+  "'seperator$'" + "fourthpitch" +  "'seperator$'" + "meanIntensity" +  "'seperator$'" + "maxIntensity"
                     ...+ newline$

# This starts up the output file by saving the column labels:
 output$ >> 'result_filename$'.txt

# This keeps track of how many files were considered for measurements:
filesconsidered = 0

Create Strings as file list... list 'sound_directory$'*'extension$'
n = Get number of strings

# Now we'll cycle through all files and do the measurements

for i to n
   select Strings list
   filename$ = Get string... i
   Read from file... 'sound_directory$''filename$'

   length = length(filename$)
   length2 = length(extension$)
   length = length - length2
   dummy$ = left$(filename$, length)

     call cutname 'dummy$'
 
    grid$ = sound_directory$ +dummy$+".TextGrid"
 
    if fileReadable (grid$)
      Read from file... 'grid$'
  
     filesconsidered = filesconsidered + 1
   
           
# Get pitch of soundfile 

     select Sound 'dummy$'
     To Pitch (ac)... 0 75 15 no 0.02 0.45 0.01 0.35 0.14 350.0
     select Sound 'dummy$'
     To Intensity... 100 0.0 yes
    
     select TextGrid 'dummy$'
     numbInt = Get number of intervals... woiTier
     numbIntWord = Get number of intervals... wordTier
    
# counter counts the silent intervals separating words
      counter = 0
      difpitch = 0		

     for interval from 1 to numbInt

		duration = 0
		silence = 0
		durasil = 0
		pitch    = 0
		maxpitch = 0
		minpitch = 0
		cenpitch = 0   
		earpitch = 0
		power = 0
		energy = 0
		maximum = 0
		maxPitTime = 0
		minPitTime = 0
		finalpitch = 0
		initpitch = 0
		latepitch = 0
		meanIntensity = 0
		maxIntensity = 0
		maxIntTime = 0
		minIntensity = 0
		minIntTime = 0
		phonelength = 0

		# store beginning and end of current word
		
    		select TextGrid 'dummy$'
		label$ = Get label of interval... woiTier interval

		#only measure annotated words
		if label$ <> ""

               	wordonset = Get starting point... woiTier interval
          	wordoffset = Get end point... woiTier interval

		phoneinterval = Get interval at time... 'phoneTier' 'wordonset'
		phonelength = Get interval at time... 'phoneTier' 'wordoffset'
		phonelength = phonelength - phoneinterval

		# Get the duration of the current word
 
		duration = wordoffset - wordonset

		#  Get label from wordtier
		midd = wordonset + duration/2
		wordint = Get interval at time... wordTier midd
		wordlabel$ = Get label of interval... wordTier wordint

		# Is next interval a silence?
		intervalSil = wordint + 1

		# this 'if' will ignore final 'sil'---they shouldn't be counted. to include, <=
		if intervalSil < numbIntWord 
			labelsil$ = Get label of interval... 'wordTier' 'intervalSil'
			if labelsil$ = "sil"
              			silonset = Get starting point... 'wordTier' 'intervalSil'
          			siloffset = Get end point... 'wordTier' 'intervalSil'
				silence = siloffset - silonset
			endif
		endif

		durasil = duration + silence

		# Get power, energy and maximum

		select Intensity 'dummy$'
			meanIntensity = Get mean... 'wordonset' 'wordoffset'
			minIntensity = Get minimum... 'wordonset' 'wordoffset' Parabolic
			minIntTime = Get time of minimum... 'wordonset' 'wordoffset' Parabolic
			maxIntensity = Get maximum... 'wordonset' 'wordoffset' Parabolic
			maxIntTime = Get time of maximum... 'wordonset' 'wordoffset' Parabolic

			maxIntTime = (maxIntTime - wordonset) / duration
			minIntTime = (minIntTime - wordonset) / duration

	     	# Get pitch measures

             	select Pitch 'dummy$'

                meanpitch = Get mean... 'wordonset' 'wordoffset' Hertz
               	maxpitch = Get maximum... 'wordonset' 'wordoffset' Hertz Parabolic
                minpitch = Get minimum... 'wordonset' 'wordoffset' Hertz Parabolic
		maxPitTime = Get time of maximum... 'wordonset' 'wordoffset' Hertz Parabolic
		maxPitTime = maxPitTime - wordonset
		minPitTime = Get time of minimum... 'wordonset' 'wordoffset' Hertz Parabolic
		minPitTime = minPitTime - wordonset

             	first = wordonset +(duration/ 4)
             	second = wordonset +(duration/ 2)
             	third = wordonset +(duration* (3/4))

	     	firstpitch = Get mean... 'wordonset' 'first' Hertz
		secondpitch = Get mean... 'first' 'second' Hertz
		thirdpitch = Get mean... 'second' 'third' Hertz
		fourthpitch = Get mean... 'third' 'wordoffset' Hertz
			
		return2$ = replace$(return$,  "'seperator$'","_",0)

	 	output$ = return$  + "'label$'" + "'seperator$'" + "'wordlabel$'" +  "'seperator$'"          
		     				... + "'phonelength'" + "'seperator$'" + 
						... "'duration:3'" +  "'seperator$'" + 
		     				... "'silence:3'" +  "'seperator$'" + 
		     				... "'durasil:3'" +  "'seperator$'" +  "'wordonset'" + "'seperator$'" + 
						...  "'meanpitch:3'" +  "'seperator$'" + "'maxpitch:2'"
						... +  "'seperator$'" + "'maxPitTime:3'" +  "'seperator$'" + "'minpitch:2'"
						...+  "'seperator$'" + "'minPitTime:3'" +  "'seperator$'" 
                                                ...+ "'firstpitch:3'" +  "'seperator$'" +"'secondpitch:3'"
						...+  "'seperator$'" + "'thirdpitch:3'" +  "'seperator$'" + "'fourthpitch:3'"
						...+  "'seperator$'" + "'meanIntensity:3'" +  "'seperator$'" + "'maxIntensity:3'"
						...+ newline$
             
                  output$ >> 'result_filename$'.txt

	   endif       
	endfor
     
                select Pitch 'dummy$'
                Remove
		select Intensity 'dummy$'
                Remove
                select TextGrid 'dummy$'
                Remove
       endif       
	        select Sound 'dummy$'
                Remove
   endfor   
 
   printline Soundfiles selected: 'n'
   printline Files considered: 'filesconsidered'

	if seperator$=","
		system mv  'result_filename$'.txt 'result_filename$'.csv
	endif

select Strings list
Remove

