#!/usr/bin/perl
#########################################################################
#                                                                       #
# BlockPy - Convert Python source code with traditional blocks of code  #
#			to the format compatible with the Python interpreter        #
#                                                                       #
#########################################################################
use warnings;
use strict;
use Getopt::Long;
my $DEBUGGING    = 0;
my $input_file   = $ARGV[0]; 	# input file to parse/transpile
my $indent_type  = '';		    # 'tab' or null (if null, a space is used as indent char)
my $indent_num   = 4; 			# number of indent chars per indent level. Must be greater than 0
my $write_output = 0;			# write converted Python code to a file
my $output_file  = '';	        # file to write converted Python code to

#########################################################################
# Internal variables - Initially not intended to be user configurable   #
#                                                                       #
my $indent_level         = 0;  # default indentation (number of spaces)
my $indent_string        = ''; # internal var for adding indentation
#                                                                       #
#########################################################################

GetOptions (
		"f|file=s" 			=> \$input_file,
		"t|indent_type=s" 	=> \$indent_type,
		"n|indent_num=i" 	=> \$indent_num,
		"o|output=s"		=> \$write_output,
		"d|debug"  			=> \$DEBUGGING,
		"h|help"			=> sub{ &_help(); },
	)
	or _usage();

#########################################################################

if ($write_output){
	$output_file = $write_output;
	if ( -e $output_file ){
		print "WARNING: $output_file already exists.  Do you want to overwrite? (Y/N): ";
		my $confirm = <STDIN>;
		chomp($confirm);
		if ( $confirm =~ /y/i ) {
			unlink($output_file);
		} else {
			exit();
		}
	}
}

my $indent_char = ' ';
$indent_char    = "\t" if ($indent_type eq 'tab');
my @file_data   = _verify_input_file($input_file);

# transpile - convert to valid Python syntax
for my $line (@file_data) {
	chomp($line); # remove end-of-line newline character
	$line           = ltrim($line); # remove spaces and tabs at beginning of line

	my $eol_comment = ""; # placeholder for an end of line comment
	if ( $line =~ s/(?<eol_comment>#.*)// ) { # capture end of line comment
		$eol_comment = $+{eol_comment};
		print "* end-of-line comment found\n" if $DEBUGGING;
	}

	$line = trim($line);  # remove trailing spaces

	if ( $line =~ /\=.*?[\{\}]/ ) { # line contains an equal sign followed by an open or close curly brace.  Assuming a dict definition
		_print("$line"."$eol_comment\n");
	} elsif ( $line =~ s/\{$/\:/) {  # line ends with {
		# replace { with : and indent next line
		$line =~ s/\s+:/:/; # remove spaces before colon
		_print("$line"."$eol_comment\n");
		_indent();
		next();
	} elsif ($line =~ s/\}$//) {
		_unindent();
		_print("$line"."$eol_comment"); # no newline for end curly braces
		next();
	} else {
		_print("$line"."$eol_comment\n");
	}
}

#########################################################################
#                             Subroutines                               #
#########################################################################

sub trim {
	my $string = shift;
	$string =~ s/\s+$//;
	return($string);
}

sub ltrim {
	my $string = shift;
	$string =~ s/^[\s\t]+//;
	return($string);
}

sub _print {
	my $string = $indent_string . shift;
	if ($write_output) {
		_write($string);
	} else {
		print $string;
	}
}

sub _write {
	my $string = shift;
	print ("\n* sub->_write($string)\n\n") if $DEBUGGING;
	open('OUTPUT', '>>', $output_file) || print "ERROR: Can't write to $output_file.  $!\n" && exit();
	print OUTPUT $string;
	close('OUTPUT');
}

sub _indent { # increase $indent_level by $indent_num
	print ("\n* sub->_indent()\n\n") if $DEBUGGING;
	$indent_string = '';
	$indent_level++;
	for ( my $i=0; $i<$indent_level * $indent_num; $i++ ) {
		$indent_string .= $indent_char;
	}
}

sub _unindent { # decrease $indent_level by $indent_num
	print ("\n* sub->_unindent()\n\n") if $DEBUGGING;
	$indent_string = '';
	$indent_level--;
	for ( my $i=0; $i>$indent_level * $indent_num; $i-- ) {
		$indent_string .= $indent_char;
	}
}

sub _verify_input_file { # If file exists and is readable, slurp in the file contents and return as an array.
	my $filename = shift;
	unless ($filename){
		print "ERROR: Input file not provided\n";
		_usage();
	}

	print ("\n* sub->_verify_input_file($filename)\n\n") if $DEBUGGING;
	unless ( -e $filename ) {
		print "ERROR: $filename does not exist.\n";
		exit();
	}
	unless ( -r $filename ) {
		print "ERROR: Can't read $filename (check file permissions).\n";
		exit();
	}
	open('INPUT','<',$filename) || print "ERROR: Can't open $filename.  $!\n" && exit();
	my @FILEDATA = <INPUT>;
	close('INPUT');
	return(@FILEDATA);
}

sub _usage { #TODO:
	print ("\n* sub->_usage()\n\n") if $DEBUGGING;
	print "Usage: \n";
	print "	BlockPy -f <InputFile> -o <OutputFile>\n";
	print "\nOptions:\n";
	print "	-f , -file          :   Input file containing \"BlockPy\" compatible source code\n";
	print "	-t , -tab indent    :   Use tab as the indentation character ( default is space )\n"; 
	print "	-n , -indent_num    :   Number of indentation characters ( default is 4 )\n";
	print "	-o , -output        :   Output file to write converted Python code to ( default is to write to STDOUT only)\n";
	print "	-d , -debug         :   Display extended internal operational information\n";
	print "	-h , -help          :   Display this page (plus additional info)\n";
	exit() unless shift; # end script unless something is passed to _usage().  Only intended for use by the _help() subroutine

}

sub _help {
	print ("\n* sub->_help()\n\n") if $DEBUGGING;
	_usage(1);
	print "\n";
	print "********************************************************************************\n";
	print <<END_OF_DOC;

The purpose of BlockPy is to allow Python source code to be written in a more traditional format
(using curley braces to delimit blocks of code).

BlockPy also removes Python's indentation based syntax requirement.
Anything within a block code, (blocks of code are within curly braces {}) is not required to be indented.
BlockPy will automatically insert the proper indentation and produce Python code that is syntically correct.

END_OF_DOC
	print "\n";
	exit();
}
