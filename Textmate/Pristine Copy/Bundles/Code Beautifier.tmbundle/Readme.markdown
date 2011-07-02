# Code Beautifier Textmate Bundle

Textmate's indent functionality does a reasonable job of formatting your code BUT there is a great deal of room for improvement.

Code Beautifier only supports Ruby at present but does improve upon Textmate's indent functionality, in particular it is better at indenting multiline statements and cleans up white space.

## Installation

If you have git installed your machine then run this:

    cd ~/Library/Application\ Support/TextMate/Bundles
    git clone git://github.com/mocoso/code-beautifier.tmbundle.git Code\ Beautifier.tmbundle

Otherwise download the [zip][] or [tarball][] and unpack it in ~/Library/Application\ Support/TextMate/Bundles.

  [zip]:http://github.com/mocoso/code-beautifier.tmbundle/zipball/master
  [tarball]:http://github.com/mocoso/code-beautifier.tmbundle/tarball/master

Then select 'Bundles > Bundle Editor > Reload Bundles' from Textmate's menus

## Dependencies

The 'Beautify all changed' command relies on

 - Your project using Git for source control
 - The Grit gem being installed

        sudo gem sources -a http://gems.github.com/
        sudo gem install mojombo-grit

## KNOWN ISSUES

 - Does recognize strings with custom delimiters
 - Does not handle multiline blocks within implied brackets
 - Does not indent continuing line statements within brackets correctly

## Credits

This was based on the [ruby beautifier script][rbs] by Paul Lutus and [Beautiful Ruby in Textmate][brit] by Tim Burks

  [rbs]:http://www.arachnoid.com/ruby/rubyBeautifier.html
  [brit]:http://blog.neontology.com/posts/2006/05/10/beautiful-ruby-in-textmate
