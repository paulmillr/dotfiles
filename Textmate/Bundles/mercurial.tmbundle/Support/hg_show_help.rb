# encoding: utf-8

$bundle        = ENV['TM_BUNDLE_SUPPORT']

require $bundle+'/hg_helper.rb'
include HGHelper

make_head( 'Hg Bundle Help', "Mercurial",
            [ $bundle+'/Stylesheets/hg_style.css',
              $bundle+'/Stylesheets/hg_help_style.css'] )

body = <<-HTML

<p>This document describes the commands of the TextMate <a href="http://www.selenic.com/mercurial/">Mercurial</a> bundle and how you can <a href="#conf">fine-tune</a> their behavior. For general Mercurial help and tutorial, you should read the Mercurial man pages (<a href="man:hg.1">hg(1)</a>, <a href="man:hgrc.5">hgrc(5)</a>, <a href="man:hgmerge.1">hgmerge(1)</a>, <a href="man:hgignore.5">hgignore(5)</a>), read the <a href="http://hgbook.red-bean.com/" title="Distributed revision control with Mercurial">hgbook</a> or check the <a href="http://www.selenic.com/mercurial/">wiki</a>.</p>

<p><strong>NB: <a href="http://www.selenic.com/mercurial/release/">Mercurial 0.9.1 or greater</a> is required.</strong> (Tested up to 1.0.1).</p>

<h2><a name="commands">Commands</a></h2>
 
 <dl>

	 <dt><a name="add">Add</a></dt>
	 <dd>
		<div class="target">selected project files/folders or the active file if it doesn't belong to a project</div>
		<div class="connect">No</div>
		<div class="description">
                Schedules the targets for addition to the repository.
		</div>
	 </dd>
	
	 <dt><a name="AddRemove">AddRemove</a></dt>
	 <dd>
		<div class="target">selected project files/folders or the active file if it doesn't belong to a project</div>
		<div class="connect">No</div>
		<div class="description">
                Schedules the targets for adding and removing files to the repository.
		</div>
	 </dd>
	
	 <dt><a name="Annotate">Annotate</a></dt>
	 <dd>
		<div class="target">active file</div>
		<div class="connect">No</div>
		<div class="description">
                Displays a line-by-line history of the file, showing you who wrote which line in what revision.	 Click a line to jump to it in an editor window.  Hover over a revision number or author name to see when the corresponding line was last changed.<!--  The date format is <a href="#tm_hg_date_format">adjustable</a>. -->
		</div>
	 </dd>
	
	
	<dt><a name="commit">Commit</a></dt>
	<dd>
	   <div class="target">selected project files/folders or the active file if it doesn't belong to a project</div>
	   <div class="connect">No</div>
	   <div class="description">
			Commits your changed files to the repository. A dialog asks you for the description of
			your changes; you may also choose to exclude files from the commit by unchecking them.
			If no files are selected or active, this command does nothing. If the target files
			have no local changes, nothing happens.
	   </div>
	</dd>

	<dt><a name="diff_between">Diff Revisions&hellip;</a></dt>
	<dd>
	   <div class="target">active file</div>
	   <div class="connect">No</div>
	   <div class="description">
		  Displays the differences between two specific revisions of the active file. You will be presented with a list of revisions; please select two.
	   </div>
	</dd>

	<dt><a name="diff_tip">Diff With Newest (tip)</a></dt>
	<dd>
	   <div class="target">active file</div>
	   <div class="connect">Yes</div>
	   <div class="description">
		Displays the differences between the active file and the newest available revision of the file in the repository.
		Equivalent to <code>hg diff -r tip</code>.
	   </div>
	</dd>
	
	<dt><a name="diff_base">Diff With Working Copy</a></dt>
	<dd>
	   <div class="target">active file</div>
	   <div class="connect">No</div>
	   <div class="description">
		  Displays the differences between the active file and an unaltered, pristine copy of the file at the same revision.
	   </div>
	</dd>

	<dt><a name="diff_with">Diff With Revision&hellip;</a></dt>
	<dd>
	   <div class="target">active file</div>
	   <div class="connect">No</div>
	   <div class="description">
		  Displays the differences between the active file and a different revision of the same file. This command presents you with a list of revisions to choose from.
	   </div>
	</dd>
	
	<dt><a name="init">Init</a></dt>
	<dd>
	   <div class="target">Project folder</div>
	   <div class="connect">No</div>
	   <div class="description">
		  create a new repository in the project directory
	   </div>
	</dd>
	
	<dt><a name="log">Log</a></dt>
	<dd>
	   <div class="target">selected project files/folders or the active file if it doesn't belong to a project</div>
	   <div class="connect">No</div>
	   <div class="description">
		   Displays the basic commit message history for the selected files.
		  <br />
		   <strong>NB: Mercurial 0.8.1 is needed for the logs commands to work properly.</strong>
	   </div>
	</dd>
	
	<dt><a name="logv">Log -v</a></dt>
	<dd>
	   <div class="target">selected project files/folders or the active file if it doesn't belong to a project</div>
	   <div class="connect">No</div>
	   <div class="description">
		   Displays the commit message history for the selected files.
		   Includes links to files associated with the changeset and the complete commit message.
		   Some parameters are configurable via shell variables; see the <a href="#tm_hg_log">Configuration Options</a> section below.<br />
		   <strong>NB: Mercurial 0.8.1 is needed for the logs commands to work properly.</strong>
	   </div>
	</dd>
	
	<dt><a name="pull">Pull from default repo.</a></dt>
	<dd>
	   <div class="target">Project directory or parent directory if it's a single file.</div>
	   <div class="connect">Yes</div>
	   <div class="description">
		   Pull changes from default repository.
	   </div>
	</dd>
	
	<dt><a name="push">Push to default repo.</a></dt>
	<dd>
	   <div class="target">Project directory or parent directory if it's a single file.</div>
	   <div class="connect">Yes</div>
	   <div class="description">
		   Commit changes to default repository.
	   </div>
	</dd>
	
	
	<dt><a name="revert">Revert</a></dt>
	<dd>
	   <div class="target">active file</div>
	   <div class="connect">No</div>
	   <div class="description">
		   Reverts the file to the Working Copy revision. Any modifications to the file will be lost.
	   </div>
	</dd>
	
	</dd>
	<dt><a name="revert_to">Revert to Revision&hellip;</a></dt>
	<dd>
	   <div class="target">selected files or active file</div>
	   <div class="connect">No</div>
	   <div class="description">
		   Reverts the file(s) to a different revision of the same file(s). This command presents you with a list of revisions to choose from.
	   </div>
	</dd>
	
	<dt><a name="status">Status</a></dt>
	<dd>
	   <div class="target">selected project files/folders or the active file if it doesn't belong to a project</div>
	   <div class="connect">No</div>
	   <div class="description">
		  Displays a list of files with changes in your working copy, along with the type of change for each file, and depending on the type of change: a link to diff with previous revision, a link to revert the changes, a link to add or remove files.
	   </div>
	</dd>
     
     <dt><a name="update">Update</a></dt>
	<dd>
	   <div class="target">Project directory or parent directory if it's a single file.</div>
	   <div class="connect">No</div>
	   <div class="description">
		   Update Working copy to tip.
		   Warns you if there is a conflict.
	   </div>
	</dd>

				
	<dt><a name="update">Update to Newest</a></dt>
	<dd>
	   <div class="target">selected project files/folders or the active file if it doesn't belong to a project</div>
	   <div class="connect">No</div>
	   <div class="description">
       Update Working copy to tip.
		   Warns you if there is a conflict.			   </div>
	</dd>
	
	
	<dt><a name="diff_prev">View Revision&hellip;</a></dt>
	<dd>
	   <div class="target">active file</div>
	   <div class="connect">No</div>
	   <div class="description">
		  Displays a different revision of the active file. This command presents you with a list of revisions to choose from.
	   </div>
	</dd>
	
 </dl>

<h2><a name="conf">Configuration Options</a></h2>
 
 <p>These shell variables allow you to tweak the behavior of the certain commands if need be. The default values should make sense for normal use. Learn <a href="help:anchor='static_variables'%20bookID='TextMate%20Help'">how to set these variables</a>.</p>
 
 <dl>
	<dt><a name="tm_hg">$TM_HG</a></dt>
	<dd>
	   <div class="default"><code>hg</code></div>
	   <div class="description">the path to your hg executable.</div>
	</dd>
	
	<dt><a name="tm_hg_close">$TM_HG_CLOSE</a></dt>
	<dd>
	   <div class="default"><code>false</code></div>
	   <div class="description">With this option you can adjust whether the windows of <a href="#Annotate">Annotate</a> close if you click on a link which opens a file in TM.  Set it to <code>1</code> or <code>true</code> if windows should close or to something else if they should not.</div>
	</dd>

   <dt><a name="tm_hg_log">$TM_HG_LOG_LIMIT</a></dt>
   <dd>
      <div class="default"><code>10</code></div>
      <div class="description">The number of messages to show. <code>0</code> means no limit.</div>
   </dd>
   
   <dt><a name="tm_hg_ext_diff">$TM_HG_EXT_DIFF</a></dt>
   <dd>
      <div class="default"><code>None</code></div>
      <div class="description">Specify the external GUI diff tool to use. If this variable is not set, the bundle will use <code>hg diff</code>, output a .diff file and open it in TM. <br />
         <strong>To use <a href="http://changesapp.com/" title="Changes">Changes.app</a>:</strong> Follow <a href="http://wiki.changesapp.com/index.php/SCM_Integration_Scripts#Mercurial_.28Hg.29_Integration">these instructions</a> to setup Changes integration in Mercurial, then set <code>TM_HG_EXT_DIFF</code> to <code>chdiff</code>.<br />
        <strong> To use FileMerge.app:</strong> Follow <a href="http://www.selenic.com/mercurial/wiki/index.cgi/TipsAndTricks#head-eb500c4bf0eed0b501bb7a5266fd3c4729105fca">these instructions</a> to setup FileMerge integration in Mercurial, then set <code>TM_HG_EXT_DIFF</code> to <code>opendiff</code>.
      </div>
   </dd>
 </dl>


<h2><a name="authors">Authors</a></h2>
 
 <ul>
	<li>Chris Thomas & Torsten Becker for the svn bundle which is the inspiration for the hg bundle</li>
	<li>Ollivier Robert did the first version of this bundle</li>
	<li>Frédéric "FredB" Ballériaux rewrited it to its current state</li>
 </ul>
HTML

puts body

make_foot()

