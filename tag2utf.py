#!/usr/bin/python	
import os.path
import re
import os
import sys
import copy

helptext = """
Tool for encoding tags of mp3 files in the russian 1-byte charsets to unicode

Usage: tag2utf [DIRECTORIES]
(By default files will be searched in the current dirrectory)
Modes:
--restore  : programm will try to restore tags, that was broken by not right user choise

--help, --version, --usage  - view this text

Version 0.12
Author: Kopats Andrei
	hlamer@tut.by
Bugfix: Yarmak Vladislav
	chayt@smtp.ru

This program is distributed under the terms of the GPL License.

TODO:
	undo changes,
	Charsets will be in the config file or command line, for encoding not only from cp1251 and koi8-r
	GUI
If you need to encode tags from different charset using this version, you can modify script, it's very easy to do.
"""		

charsets = {'cp1251':'c','koi8-r':'k' }
#modify it if you want decode tags from other encodings

"""
Default mode - just to convert tags, that have 1-byte encoding now
Backup mode used for restore wrongly converted tags (and optionaly decode to right charset. """
restoreMode = False

try:
	import eyeD3
except:
	print 'You need to install python-eyed3 package.'
	sys.exit() 

mp3FileName = re.compile ('.*(mp3|MP3)$')


def recodingNeed (strs):
	"""recoding needed if tags have symbols with 256>ords >127 
	"""
#	needed = False
	for string in strs:
		for i in range (len(string)):
			if 256>ord (string[i])>127:
				return True  #nonunicode nonascii
	return False

def passDir (rootdir):
	tags = []
	songs = []
	titles = []
	artists = []
	albums = []
	for song in os.listdir(rootdir) :
		if (	os.path.isfile(os.path.join(rootdir,song)) 
			and mp3FileName.match (song)):
			filename = os.path.join(rootdir,song)
			tag = eyeD3.Tag()
			try:
				if not tag.link(filename):
					continue  #somthing wrong whith this file
			except:
				print '\n',filename,':error, may be tag is corrupted.\n '
				continue
			if recodingNeed ([tag.getTitle(),tag.getArtist(),tag.getAlbum()]) or restoreMode:
				if not os.access(filename,os.W_OK):
					print 'Warning! Have not access for writing file '\
					,filename , ' Sciped!'
					continue
				tags.append (tag)
				songs.append (song)
				if not restoreMode : #normal mode
					titles.append (getTagStr (tag.getTitle()))
					artists.append (getTagStr (tag.getArtist()))
					albums.append (getTagStr (tag.getAlbum()))
				else: #restore mode
					titles.append (tag.getTitle())
					artists.append (tag.getArtist())
					albums.append (tag.getAlbum())
	if len (tags) > 0:
		print len(tags),' file(s) finded in the ',rootdir
		askUser (tags,songs,titles,artists,albums)
	
def getTagStr (tagUnicStr): 
	#gets the 1byte 8bits string, as writed in the tag, from the unicode, returned by tag.get*
	ls = []
	for i in range (0,len(tagUnicStr)):
		if (ord (tagUnicStr[i]) in range(256)):
			ls.append (chr (ord (tagUnicStr[i])))
		else:
			ls.append(tagUnicStr[i])
	Str8 = ''.join(ls)	
	return Str8

def updateTags (tags,titles,artists,albums,charset, wrongCharset = ''):
	for i in range (len(tags)):
		tags[i].setVersion (eyeD3.ID3_V2_4)
		tags[i].setTextEncoding (eyeD3.UTF_8_ENCODING)
		if not ( restoreMode and wrongCharset != ''): #normal mode
			if (recodingNeed(artists[i])):
				tags[i].setArtist(artists[i].decode(charset))
			else:
				tags[i].setArtist(artists[i])
			if (recodingNeed(albums[i])):
				tags[i].setAlbum(albums[i].decode(charset))
			else:
				tags[i].setAlbum(albums[i])
			if (recodingNeed(titles[i])):
				tags[i].setTitle(titles[i].decode(charset))
			else:
				tags[i].setTitle(titles[i])
		else: #restore mode
			tags[i].setArtist(artists[i].encode(wrongCharset).decode(charset))
			tags[i].setAlbum (albums[i].encode(wrongCharset).decode(charset))
			tags[i].setTitle (titles[i].encode(wrongCharset).decode(charset))
		tags[i].update()

def askUser (tags,songs, titles,artists,albums):
	charsetListStr = ''
	if not restoreMode: #normal mode
		for charset in charsets.keys():
			print '\n'+'['+charsets[charset]+']'+'   If charset of tags is '+ charset+ ':'
			for i in range (len(songs)):
				sys.stdout.write(songs[i])
				outlst = [' ']
				if (recodingNeed(titles[i])):
					outlst.append(titles[i].decode(charset))
				else:
					outlst.append(titles[i])
				outlst.append(' ')
				if (recodingNeed(artists[i])):
					outlst.append(artists[i].decode(charset))
				else:
					outlst.append(artists[i])
				outlst.append(' ')
				if (recodingNeed(albums[i])):
					outlst.append(albums[i].decode(charset))
				else:
					outlst.append(albums[i])
				print "".join(outlst)
	else: #backup mode
		for wrongCharset in charsets.keys(): #charset, to which file was wrongly converted
			for tagCharset in charsets.keys(): #right charset of tag
				if wrongCharset == tagCharset:
					continue
				print '\n'+'['+charsets[wrongCharset]+charsets[tagCharset]+']', \
					'   If charset is '+ tagCharset+' (wrongly converted to '+ wrongCharset+ ')',':'
				for i in range (len(songs)):
					try:
						print 	songs[i],' ',\
							titles[i].encode(wrongCharset).decode(tagCharset),' ',\
							artists[i].encode(wrongCharset).decode(tagCharset),' ',\
							albums[i].encode(wrongCharset).decode(tagCharset)
					except:
						print "ERROR:Can't encode tags of "+songs[i]
				charsetListStr += "   '"+charsets[wrongCharset]+charsets[tagCharset]+"' - "+tagCharset+' converted to '+wrongCharset+'\n'

	print '\n',"Select charset:\n",charsetListStr, "'s' - skip this file(s)"
	if len(tags) >1:
		print "'m' - manual for every file"
	while 1:
	#get user choise end update the tags
		choise = raw_input()
		if not restoreMode : #normal mode
			if choise in charsets.values():
					charset = charsets.keys()[charsets.values().index(choise)]
					updateTags(tags,titles,artists,albums,charset)
					break
		else: #restore mode
			if 	(len (choise) == 2) and \
				(choise[0] in charsets.values()) and \
				(choise[1] in charsets.values()):
					charset = charsets.keys()[charsets.values().index(choise[1])]
					wrongCharset = charsets.keys()[charsets.values().index(choise[0])]
					updateTags(tags,titles,artists,albums,charset,wrongCharset)
					break
		if choise == 's':
			return
		if choise == 'm' and len(tags) >1:
			for i in range(len(tags)):
				askUser ([tags[i]],[songs[i]],[titles[i]],[artists[i]],[albums[i]])
				return
		#will be executed if no break or return before	
		print 'What?'


argsFailed = False ;
rootdirs = []
argv = copy.copy ( sys.argv)
argv.__delitem__(0)
for arg in argv:
	if (	arg == '--usage' or 
			arg == '--help' or
			arg == '--version'):
				print helptext
				sys.exit()
	elif arg == '--restore':
		restoreMode = True
	elif os.path.isdir(arg):
		rootdirs.append(arg)
	#this need because paths may have start in the working dir or in the root dir
	elif os.path.isdir (os.path.join (os.getcwd(),arg)):
		rootdirs.append (os.path.join (os.getcwd(),arg))
	else:
		print "Not right argument '",sys.argv[i],"' It's not a directory.\n Try ",sys.argv[0], " --usage" 
		argsFailed = True;
if argsFailed:
	sys.exit()
if rootdirs == []:
	rootdirs = [os.getcwd()]
	print 'Starting search in the ',os.getcwd()
for rootdir in rootdirs:
	for root, dirs, files in os.walk(rootdir):
		passDir (root)
