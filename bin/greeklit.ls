#!/usr/bin/env livescript

# Sort of “leet speak” stuff, but for russian letters.
#
# greeklit 'привет'
# # => 'nρuвеm' is copied to clipboard.
#
# Could be freely distributed under the terms of MIT License.
# Copyright (c) 2012 Paul Miller (paulmillr.com)

prelude = require 'prelude-ls'
prelude.installPrelude(global)

chars =
  'а': 'α'
  'б': '6'
  'в': null
  'г': 'r'
  'д': 'g'
  'е': 'е'
  'ж': null
  'з': 'ʒ'
  'и': 'u'
  'к': null
  'л': 'ʌ'
  'м': 'ʍ'
  'н': null
  'о': 'о'
  'п': 'n'
  'р': 'ρ'
  'с': 'с'
  'т': 'm'
  'у': 'у'
  'ф': null
  'х': null
  'ш': 'ɯ'
  'щ': 'ϣ'
  'ч': null
  'э': null
  'ю': null
  'я': null

replace = (list-of-chars) ->
  list-of-chars |> map ((char) -> chars[char] ? char)

read-stdin = ->
  process.open-stdin!
  process.stdin.on 'data', (buffer) ->
    process.stdout.write "#{replace buffer.to-string!}"

text = process.argv[2]
if text?
  process.stdout.write "#{replace text}\n"
else
  read-stdin!
