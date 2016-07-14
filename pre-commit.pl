#!/usr/bin/perl
# Should be put into <repository>/

# TODO: masks to ignore
# TODO: ignore files that were indexed but deleted
# TODO: learn to /bin/bash correctly and put it back, lol

EL();

my @diffFiles = GetFiles();
my $filecount = @diffFiles;
if ( $filecount == 0 )
{
	print "* Nothing to check\n";
	EL();
	exit 0;
}

print "* $filecount files to check\n";

ES();

my @unicodedFiles = ();
my $unicodedCount = 0;
my $i = 0;
foreach $file (@diffFiles)
{
	$i += 1;
	print "[$i/$filecount] --- Checking: $file";
	ConvertFile($file);
}

ES();

print "Unicode check finished: $i files checked\n";
if ( $i != $filecount )
{
	print " ! ERROR: couldn't parse all $filecount files!\n";
	EL();
	exit 1;
}

if ( $unicodedCount == 0 )
{
	print " * Everything OK\n";
	EL();
	exit 0;
}

print " * Of them $unicodedCount were encoded to UTF-8:\n";
for $f (@unicodedFiles)
{
	print "   - $f\n";
}

ES();

print " * Check these files and then 'git add' them again\n";
EL();
exit 1;



###############################################################################


# get the files to encode
sub GetFiles
{
	# turn off escaping non-ascii characters so тест.файл won't turn to "\321\202\320\265\321\201\321\202.\321\204\320\260\320\271\320\273"
	my $QP = `git config --get core.quotepath`;
	`git config core.quotepath off`;

	# get files to process
	my @diffFiles = `git diff --cached --name-only --diff-filter=ACMR`;
	`git config core.quotepath $QP`;
	return @diffFiles;
}

# encode the file if needed
sub ConvertFile
{
	my ($f) = @_;
	
	# since git diff returns one file per line ending with \n
	$f =~ s/\n//;
	my $utf = '~'.$f.'.utf8';
	
	# if we can successfully convert from Utf8 to Utf8 - it's already encoded correctly, won't mess around
	`iconv -s -f utf-8 -t utf-8 $f > /dev/null`;
	if ( not $? )
	{
		print "  * Conversion not needed\n";
		return;
	}
	
	# otherwise, let's try to convert it
	`touch $utf`;
	`iconv -s -f cp1251 -t utf-8 $f > $utf`;
	if ( not $? )
	{
		`rm $f`;
		`mv $utf $f`;
		$unicodedCount += 1;
		push @unicodedFiles, $f;
		print "  + Converted\n";
		return;
	}
	
	print "  - Couldn't convert! Probably a binary file\n";
	`rm $utf`;
}

sub EL
{
	print "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-\n";
}
sub ES
{
	print "- - - - - - - - - - - - - - - - - - - - - - - - - - -\n";
}
