#This script prompts the user to input file, finds pitch, finds intensity, compares the two, exports the times of emphasis

clearinfo; #clears the info window;
#Create the demo window and welcome the user;
demo Erase all
demo White
demo Select inner viewport: 0, 100, 0, 100
demo Axes: 0, 100, 0, 100
demo Paint rectangle: "purple", 0, 100, 0, 100
demo 24
demo Text: 50, "centre", 50, "half", "Welcome to Emp: Emphasis Locator. Select a .WAV file to begin"
demoWaitForInput ( )
#Prompts the user to open a file;
name$ = chooseReadFile$: "Open a sound file"
while name$ <> ""
#Reads the file
if name$ <> ""
    sound = Read from file: name$
endif
#Converts the sound file to pitch and finds values for the new file;
To Pitch: 0, 75, 600
#Interpolate
time = 0.2
end = Get end time
timeStep= Get time step
mean = Get mean: 0.0, 0.0, "Hertz"
quantile1= Get quantile: 0.0,0.0,0.95,"Hertz" #used to eliminate upper outliers
quantile2= Get quantile: 0.0,0.0,0.2,"Hertz" #used to break the while loop
quantile3= Get quantile: 0.0,0.0,0.005,"Hertz" #used to eliminate lower outliers
min = mean
maxTime = 0
minTime = 0
max = mean
sD= Get standard deviation: 0.0, 0.0, "Hertz" #to determine if a quantile can be used for threshold;
absMin = Get minimum: time, end, "Hertz", "Parabolic"
absMax = Get maximum: time, end, "Hertz", "Parabolic"
absMinTime = Get time of minimum: time, end, "Hertz", "Parabolic"
absMaxTime = Get time of maximum: time, end, "Hertz", "Parabolic"
if sD < 55
   threshold = sD
else
   threshold = Get quantile: 0.0,0.0,0.16,"Hertz"
endif
piTimes = undefined
piMinTimes = undefined
j=0 #counters for array indexing
k=0
#runs through the section incremented by timesteps
while time < end
	value= Get value at time: time, "Hertz", "Nearest"
		if value = undefined #early values are often undefined
			time = time + timeStep;
		elsif value>quantile1 or value<quantile3 #these values aren't significant
			time = time + timeStep;
		elsif max-min > threshold #Emphasis is determined here
			if abs(minTime-time) > 0.05 #The time section must be long enough
				j=j+1
				k=k+1
				repeat #pushes the time along until it reaches a new low
					time=time + timeStep
					value= Get value at time: time, "Hertz", "Nearest"
						if value = undefined
							time = time + timeStep;
						elsif value > max
							max=value
						elsif value < min 
							min = value;
						elsif value=min
							min=value
						endif
				until value < quantile2
				piMinTimes[j] = minTime
				piTimes[k] = time
				max = mean
				min = mean
			endif
		max = mean
		min = mean
	elsif value > max #resets the max
		max=value
		maxTime= time
	elsif value < min #resets the min
		min = value;
		minTime= time
	elsif value=min
		min=value
	endif	
	time = time + timeStep;
endwhile
Remove
#Reopens the same file;
sound = Read from file: name$
#Converts the sound file to intensity and finds values for the new file;
To Intensity: 75, 0, "yes"
time = 0.2
end = Get end time
timeStep= Get time step
mean = Get mean: 0.0, 0.0, "dB"
min = mean
maxTime = 0
minTime = 0
max = mean
absMin = Get minimum: time, end, "cubic"
absMax = Get maximum: time, end, "cubic"
absMinTime = Get time of minimum: time, end, "cubic"
absMaxTime = Get time of maximum: time, end, "cubic"
threshold = abs(absMin - absMax) * (3/4)
inTimes = undefined
inMinTimes = undefined
x=0 #new counters for array indexing
y=0
#runs through the section incremented by timesteps
while time < end
	value= Get value at time: time, "cubic";
		if value = undefined
			time = time + timeStep;
	elsif max-min > threshold #Determines if the contrast hits threshold
			if abs(minTime-time) > 0.05
				x=x+1
				y=y+1
				repeat
					time=time + timeStep
					value= Get value at time: time, "cubic";
						if value = undefined
							time = time + timeStep;
						elsif value > max
							max=value
						elsif value < min 
							min = value;
						elsif value=min
							min=value
						endif
				until value < mean #loops until a new low is found
				inMinTimes[x] = minTime
				inTimes[y] = time
				max = mean
				min = mean
			endif
		max = mean
		min = mean
	elsif value > max
		max=value
		maxTime= time
	elsif value < min 
		min = value;
		minTime= time
	elsif value=min
		min=value
	endif	
	time = time + timeStep;
endwhile
Remove
#this creates a table,  but will only be made in Praat
#for m from 1 to j
#	appendInfoLine: piMinTimes [m], tab$, piTimes [m]
#endfor
#appendInfoLine: "Intensity values: "
#for n from 1 to x
#	appendInfoLine: inMinTimes [n], tab$, inTimes [n]
#endfor
p=0 #counter to determine if an error occured
alli = 60 #allignment variable
#This creates the results page
demo Erase all
demo White
demo Select inner viewport: 0, 100, 0, 100
demo Axes: 0, 100, 0, 100
demo Paint rectangle: "Purple", 0, 100, 0, 100
#combines intensity and pitch values to see if they overlap
for m from 1 to j
	for n from 1 to x
		if piMinTimes[m]< inMinTimes[n] and inMinTimes[n]<piTimes[m] 
			p=p+1
			if inTimes[n]>piTimes[m]
				alli= alli-7
				demo Text: 50, "centre", alli, "half", "Emphasis from " + fixed$(inMinTimes[n],2) + "sec to " + fixed$(inTimes[n],2) + "sec"
				m=m+1
			else
				alli= alli-7
				demo Text: 50, "centre", alli, "half", "Emphasis from " + fixed$(inMinTimes[n],2) + "sec to " + fixed$(piTimes[m],2) + "sec"
				m=m+1
			endif
		else
		endif
	endfor
endfor
#checks for errors
if p = 0 and j = 0
	demo Text: 50, "centre", 50, "half", "NO EMPHASIS VALUES because of PITCH ERROR"
elsif p = 0
	demo Text: 50, "centre", 50, "half", "NO EMPHASIS VALUES"
endif
#repeats the entire program
name$ = ""
demoWaitForInput ( )
demo Erase all
demo White
demo Select inner viewport: 0, 100, 0, 100
demo Axes: 0, 100, 0, 100
demo Paint rectangle: "purple", 0, 100, 0, 100
demo 24
	demo Text: 50, "centre", 50, "half", "To run another file, click again"
demoWaitForInput ( )
name$ = chooseReadFile$: "Open a sound file"
endwhile