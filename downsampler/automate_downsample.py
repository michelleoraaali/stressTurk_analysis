from downsampler import downsampleWav
import os

# Listing all files in current directory.
listofFiles = os.listdir('./')

for thisFile in listofFiles:
	if thisFile[-4:] == '.wav':
		downsampleWav(thisFile, 'downsampled_files/' + thisFile)
