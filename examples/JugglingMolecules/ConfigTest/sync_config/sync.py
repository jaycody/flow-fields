#!/usr/bin/python

"""
	Combine unique PS##.tsv config files from 2 different directories into an output directory.
	Removes all duplicates from output directory.
	Any files in dir1 & dir2 with the same name but different contents will be moved as minimally as possible.
"""

import os
import sys
import hashlib
import re

configPrefix = r"PS"
configExtension = r".tsv"
configRE = re.compile(configPrefix + r"(\d+)" + configExtension)

# NOTE: have a trailing slash on the names below!
config1Path = "/www/videoAlchemy/spiro/_exhibitions/20130922-EarthTones/JugglingMolecules/config/"
config2Path = "/www/videoAlchemy/spiro/_exhibitions/20131005-IsaWedding/JugglingMolecules/config/"
outputPath  = "/www/videoAlchemy/spiro/JugglingMolecules/config/"




def hashConfigsForPath(path, hashMap=None):
	''' Given a path, return a dict of all .tsv files in that '''

	print "--------------------------------------"
	print "Loading files from "+path
	print "--------------------------------------"

	if hashMap == None:
		hashMap = dict()

	fileNames = os.listdir(path)
	for fileName in fileNames:
		if not fileName.startswith(configPrefix): continue

		# read the contents of the file
		filePath = path + fileName
		file = open(filePath, "r")
		fileContents = file.read()

		# figure out md5 hash sum for the file's contents
		hash = hashlib.md5(fileContents).hexdigest()

		# if we don't have it in our hashMap already, add it
		if not (hash in hashMap):
			print filePath +" is unique"
			config = dict()
			config['name'] = fileName
			config['contents'] = fileContents
			config['hash'] = hash

			hashMap[hash] = config
		else:
			print filePath +" is A DUPLICATE"

	return hashMap


def configIndex(configName):
	''' Return the index number of a config object '''
	match = configRE.match(configName)
	if match == None:	return None
	return int(match.group(1))


def configNameForIndex(index):
	''' Given an index, return the corresponding config name '''
	return configPrefix + ("%02d" % index) + configExtension


def main(argv):
	print "Sync started"

	# get a hashMap with all of the file data from the first path
	hashMap = hashConfigsForPath(config1Path)

	# get a hashMap with all of the file data from the second path
	hashMap = hashConfigsForPath(config2Path, hashMap)

	print "--------------------------------------"
	print "resolving names"
	print "--------------------------------------"

	# convert to another list by config name
	# maintains a list of duplicate names to process next
	# WHAT TO DO WITH DUPE NAMES???
	nameMap = dict()
	dupeMap = dict()
	for (hash, config) in hashMap.items():
		name = config['name']
		if not (name in nameMap):
			print "adding "+name
			nameMap[name] = config
		else:
			print "found duplicate name "+name
			dupeMap[name] = config

	# process duplicates AFTER others, to minimize unnecessary movement
	for (fileName, config) in dupeMap.items():
		index = configIndex(fileName)
		if index == None: continue
		while True:
#TODO: wrap around if we get to 99
#TODO: what if there's no space at all for the dupes?
			index += 1
			newFileName = configNameForIndex(index)
			if not (newFileName in nameMap):
				print "adding dupe "+fileName+" as "+newFileName
				nameMap[newFileName] = config
				break;

	print "--------------------------------------"
	print "outputting to "+outputPath
	print "--------------------------------------"

	# create output directory if necessary
	if not os.path.exists(outputPath):
		print "creating output directory "+outputPath
		os.makedirs(outputPath)
	# or clear all of old config files if folder exists already
	else:
		fileNames = os.listdir(outputPath)
		for fileName in fileNames:
		if fileName.startswith(configPrefix):
				path = outputPath + fileName
				print "removing old file "+path
				os.remove(path)


	# output all configs from nameMap
	fileNames = nameMap.keys()
	fileNames.sort()
	for fileName in fileNames:
#TODO: rename to compact the space?
		filePath = outputPath + fileName
		print "outputting to "+filePath
		file = open(filePath, "w+")
		config = nameMap[fileName]
		file.write(config['contents'])
		file.close()

	print "Sync finished!"




# actually run the "main()" function when executing the file
if __name__ == "__main__":
	main(sys.argv[1:])
