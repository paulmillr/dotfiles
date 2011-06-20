Scala TextMate Bundle
=====================

Using it
--------

**NOTICE:** If you want fancy IDE features (code-completion, refactoring, navigation, type-checking, inspection, etc. ) use my [ENSIME.tmbundle](https://github.com/mads379/ensime.tmbundle "ENSIME.tmbundle") alongside this one.

**Snippets** 

As any good textmate bundle this one comes with a bunch of snippets that will make you more productive. To make it easier for you to remember all of the tab-completions the bundle strives to use the keywords as tab-triggers. As an example: If you wanted to create a new class you would simply write "class" and hit tab. If you wanted to create a case class you would type "case class" and hit tab and so on. 

This of course means that the tab-triggers aren't as short as they could have been. If you're programming Scala every day you would probably prefer that you would only have to type "cc" and hit tab and it would expand into a case class. Now, Textmate doesn't allow a snippet to have multiple tab trigger (i.e. both "case class" and "cc") and having duplicated snippets would be a mess to maintain. So to fix this most of the snippets have a shorter version with expand to the "larger" version which in turn can expand to the full source. Here's and example

cc &lt;tab&gt; => case class &lt;tab&gt; => proper source for a case class

This means you have to hit tab twice but I think that's a fair tradeoff.

**Playing with the code**

The bundle offers several ways to play around with Scala code in your document - Hit ⌘R and see the options possible

- **Scala REPL**: This will start the Scala REPL in a new tab in the a frontmost terminal window or create a new window if one doesn't exist. 
- **Scala REPL: Preload file** This will start the Scala REPL like above but it will preload the current file
- **Scala REPL: Paste selection** This will paste the current selection in TextMate to active Terminal tab.

**Other cool stuff**

- **Align Assignments**: This will align anything according to =>,=,->,<-. As an example, the following: 

	<pre>case foo => bar
case blah if ding => baz</pre> 
	
	turns into 
	
	<pre>case foo          => bar
case blah if ding => baz</pre> 
	
	The current line decides the pattern. i.e. if the current line is the first one the following: 
	
	<pre>def foo(body: => Unit) = 55
def baz(somethingelse: => Unit) = 55
val x = 22</pre>
			
	Turns into
			
	<pre>def foo(body:          => Unit) = 55
def baz(somethingelse: => Unit) = 55
val x = 22</pre>
			
	and if you select the last line it turn into
	
	<pre>def foo(body: => Unit)          = 55
def baz(somethingelse: => Unit) = 55
val x                           = 22</pre>

- **Comments**
  - Javadoc for line (⌘⇧D): Will analyze the the current line and add the appropriate documentation for the line (i.e. correct @param etc.)
  - New javadoc line (⇧⏎ in comment scope): Will create a new correctly indented comment line.

Installation
------------

**Stable**: To install latest stable version simply grab it from the downloads page, unzip it and follow the instructions in the INSTALLATION_GUIDE.txt file. 

**Cutting-edge**: To install the cutting-edge version of the bundle simply run the following in your terminal:

<pre><code>git clone git://github.com/mads379/scala.tmbundle.git
open scala.tmbundle
</code></pre>

In both cases add the shell variable <code>SCALA\_HOME</code> in TextMate -> Preferences... -> Advanced -> Shell Variables to the root of your scala installation. If you installed scala using MacPorts, it probably is <code>/opt/local/share/scala-2.8</code>

About
-----

**If you're on a slightly older system Dan Oxlade is currently maintaining a 32bit compatible version of the bundle. Get it from his fork [here](http://github.com/oxlade39/scala.tmbundle "here")**

I wasn't happy with the official [TextMate](http://macromates.com/) bundle so I started my own bundle. It has since been hugely improved by [Paul Phillips](http://github.com/paulp) and is now vastly better than the original one.
