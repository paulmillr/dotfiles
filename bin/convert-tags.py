#!/usr/bin/env python
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
--restore  : programm will try to restore tags, that was broken by not right user choice

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
If you need to encode tags from different charset using this version, you can modify script, it"s very easy to do.
"""
try:
    import eyeD3
except:
    print "You need to install python-eyed3 package."
    print "You can get eyed3 here: http://eyed3.nicfit.net/"
    sys.exit()

mp3_file_name = re.compile(".*(mp3|MP3)$")


def needs_recoding(strings):
    """Recoding is needed for non-ASCII files."""
    for string in strings:
        for char in string:
            if 127 < ord(char) < 256:
                return True
    return False


def pass_dir(rootdir):
    tags = []
    songs = []
    titles = []
    artists = []
    albums = []
    for song in os.listdir(rootdir):
        if (os.path.isfile(os.path.join(rootdir, song))
            and mp3_file_name.match(song)):
            filename = os.path.join(rootdir,song)
            tag = eyeD3.Tag()
            try:
                if not tag.link(filename):
                    # Something is wrong with the file.
                    continue
            except Exception as e:
                print "\n{}: error. Tag could be corrupted. {}\n".format(filename, e)
                continue
            if needs_recoding([tag.getTitle(), tag.getArtist(), tag.getAlbum()]):
                if not os.access(filename, os.W_OK):
                    print (
                        "Warning! Have not access for writing file {},"
                        "skipped"
                    ).format(filename)
                    continue
                tags.append(tag)
                songs.append(song)
                titles.append(get_tag_str(tag.getTitle()))
                artists.append(get_tag_str(tag.getArtist()))
                albums.append(get_tag_str(tag.getAlbum()))
    tags_length = len(tags)
    if tags_length > 0:
        print tags_length, " file(s) finded in the ", rootdir
        ask_user(tags, songs, titles, artists, albums)


def get_tag_str(string):
    """
       Gets the 1byte 8bits string, as writed in the tag,
       from the unicode, returned by tag.get*().
    """
    result = []
    for char in string:
        if 0 < ord(char) < 256:
            result.append(chr(ord(char)))
        else:
            result.append(char)
    return "".join(result)


def update_tags(tags, titles, artists, albums, charset, wrong_charset=""):
    for index, tag in enumerate(tags):
        tag.setVersion(eyeD3.ID3_V2_4)
        tag.setTextEncoding(eyeD3.UTF_8_ENCODING)
        if not wrong_charset:
            if needs_recoding(artists[index]):
                tag.setArtist(artists[index].decode(charset))
            else:
                tag.setArtist(artists[index])
            if needs_recoding(albums[index]):
                tag.setAlbum(albums[index].decode(charset))
            else:
                tag.setAlbum(albums[index])
            if needs_recoding(titles[index]):
                tag.setTitle(titles[index].decode(charset))
            else:
                tag.setTitle(titles[index])
        tag.update()


def ask_user(tags, songs, titles, artists, albums):
    charset = "cp1251"
    for index, song in enumerate(songs):
        outlst = [" "]
        if (needs_recoding(titles[index])):
            outlst.append(titles[index].decode(charset))
        else:
            outlst.append(titles[index])
        outlst.append(" ")
        if (needs_recoding(artists[index])):
            outlst.append(artists[index].decode(charset))
        else:
            outlst.append(artists[index])
        outlst.append(" ")
        if (needs_recoding(albums[index])):
            outlst.append(albums[index].decode(charset))
        else:
            outlst.append(albums[index])
        print "".join(outlst)
    update_tags(tags, titles, artists, albums, "cp1251")

def main():
    args_failed = False
    rootdirs = []
    argv = copy.copy(sys.argv)
    argv.__delitem__(0)
    for arg in argv:
        if arg in ("--usage", "--help", "--version"):
            print helptext
            sys.exit()
        elif os.path.isdir(arg):
            rootdirs.append(arg)
            # This is needed because paths may have start
            # in the working dir or in the root dir.
            item = os.path.join(os.getcwd(), arg)
        elif os.path.isdir(item):
            rootdirs.append(item)
        else:
            print (
                "Invalid argument {}: not a directory."
                "See '--usage'.".format(
                    sys.argv[i]
                )
            )
            sys.exit()
    if not rootdirs:
        rootdirs = [os.getcwd()]
        print "Starting search in the ", rootdirs

    for rootdir in rootdirs:
        for root, dirs, files in os.walk(rootdir):
            pass_dir(root)

if __name__ == "__main__":
    main()
