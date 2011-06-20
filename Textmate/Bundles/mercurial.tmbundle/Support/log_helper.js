
function didFinishCommand ()
{
   TextMate.isBusy = false;
}

// filename is already shell-escaped, URL is %-escaped
function export_file ( url, rev, filename )
{
   TextMate.isBusy = true;
   TextMate.system("\"${TM_HG:=hg}\" cat -r" + rev + " '" + url + "' &>/tmp/" + filename + " && open -a TextMate /tmp/" + filename, didFinishCommand);
}

function diff_and_open_tm( workpath, hg, url, rev, filename )
{
	TextMate.isBusy = true;
	TextMate.system('cd '+workpath+';"'+hg+'" diff -r "'+(rev-1)+'" -r "'+rev+'" '+url+' &> '+filename+'; open -a TextMate '+filename, didFinishCommand );
}

function ext_diff( workpath, hg, url, rev, difftool )
{
	TextMate.isBusy = true;
	TextMate.system('cd '+workpath+';"'+hg+'" '+difftool+ ' -r "'+(rev-1)+'" -r "'+rev+'" '+url, didFinishCommand );
}


/* show: files + hide-button,  hide: show-button.. */
function show_files( base_id )
{
   document.getElementById( base_id ).style.display = 'block';
   document.getElementById( base_id+'_show' ).style.display = 'none';   
   document.getElementById( base_id+'_hide' ).style.display = 'inline';
}

/* hide: files + hide-button,  show: show-button.. */
function hide_files( base_id )
{
   document.getElementById( base_id ).style.display = 'none';
   document.getElementById( base_id+'_show' ).style.display = 'inline';   
   document.getElementById( base_id+'_hide' ).style.display = 'none';
}

