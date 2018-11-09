import os
# for fname in os.listdir("."):
	# os.rename(fname, fname.replace("?", ""))
# 	if ".wav" in fname:
# 		split_fname = fname.split("_")
# 		new_fname = "stressTurk_" + "" + split_fname[0] + "_" + split_fname[1] + "_" + "_".join( split_fname[2:] )
# 		os.rename( fname, new_fname )
# 	if ".TextGrid" in fname:
# 		split_fname = fname.split("_")
# 		new_fname = "stressTurk_" + "" + split_fname[0] + "_" + split_fname[1] + "_" + "_".join( split_fname[2:] )
# 		os.rename( fname, new_fname)

path = os.getcwd()
filenames = os.listdir(path)

for filename in filenames:
    os.rename(filename, filename.replace(" ", ""))

for filename in filenames:
    os.rename(filename, filename.replace("?", ""))


# for filename in filenames:
#     os.rename(filename, filename.replace("stressTurk__", "stressTurk_"))

# for filename in filenames:
#     os.rename(filename, filename.replace("TextGrid\r","TextGrid"))