#!/usr/bin/perl
#
# Normalization script
#
# Gwenole Lecorve
# June, 2011
#

use Cwd 'abs_path';
use File::Basename;
use lib dirname( abs_path(__FILE__) )."/../../lib";
use CorpusNormalisationFr;
use Getopt::Long;
use File::Basename;
# use utf8;
# use POSIX qw(strftime locale_h);
# use locale;
# setlocale(LC_CTYPE, "UTF8");
# setlocale(LC_COLLATE, "UTF8");
use strict;

my $RSRC = dirname( abs_path(__FILE__) )."/../../rsrc/fr";
my $WIKTIONARY_WORD_POS = "$RSRC/word_pos.lst";
my $LEXIQUE_FILE = "$RSRC/lexicon_fr";

my $HELP=0;
my $VERBOSE=0;
my $ESTER=0;
my $KEEP_PARA = 0;
my $KEEP_PUNC = 0;

$|++; #autoflush

#
# Process command line
#
Getopt::Long::config("no_ignore_case");
GetOptions(
	"ester|e" => \$ESTER,
	"help|h" => \$HELP,
	"keep-par|P" => \$KEEP_PARA,
	"keep-punc|p" => \$KEEP_PUNC,
	"verbose|v" => \$VERBOSE,
)
or usage();

(@ARGV == 1) or usage();
if ($HELP == 1) { usage(); }



# open the input file
my $f = shift;
my $TEXT = "";
open(INPUT, "< $f") or die("Unable to open file $f.\n");
while(<INPUT>) {
	$TEXT .= $_;
}
close(INPUT);

my $weak_punc = '(?:,|;|:|\(|\)|¡|¿)';



load_pos($WIKTIONARY_WORD_POS);
load_lexicon($LEXIQUE_FILE);
my $STEP = 0;

	tag_ne(\$TEXT);
$VERBOSE && print STDERR ".";
	apply_rules(\$TEXT, "$RSRC/case-special.rules");

$VERBOSE && print STDERR ".\n";

#395/371

#############################################################
$VERBOSE && print STDERR `date "+%d/%m/%y %H:%M:%S"`." -- Hyphenation and processing of apostrophes for all the words";
	apply_rules(\$TEXT, "$RSRC/hyphenation-remove.rules", "$RSRC/hyphenation-add.rules", "$RSRC/hyphenation-general.rules", "$RSRC/hyphenation-latin_locutions.rules");	
$VERBOSE && print STDERR ".";
	hyphenate(\$TEXT);
$VERBOSE && print STDERR ".";
	apostrophes(\$TEXT);
	apply_rules(\$TEXT, "$RSRC/apostrophes.rules");
$VERBOSE && print STDERR ".";
	apply_rules(\$TEXT, "$RSRC/case-accent.rules");
$VERBOSE && print STDERR ".\n";



#############################################################
$VERBOSE && print STDERR `date "+%d/%m/%y %H:%M:%S"`." -- Processing uppercase words.";
	apply_rules(\$TEXT, "$RSRC/roman_numbers.rules");
	roman_numbers(\$TEXT);
$VERBOSE && print STDERR ".";
	acronyms(\$TEXT);
	apply_rules(\$TEXT, "$RSRC/acronyms.rules");
$VERBOSE && print STDERR ".\n";


$TEXT =~ s/ +/ /gm;
$TEXT =~ s/^ //gm;
$TEXT =~ s/ $//gm;


#############################################################
$VERBOSE && print STDERR `date "+%d/%m/%y %H:%M:%S"`." -- Conversion of digits into letters.";
	numbers(\$TEXT);

$VERBOSE && print STDERR ".\n";


#$VERBOSE && print STDERR `date "+%d/%m/%y %H:%M:%S"`." -- Modification de la casse.\n";
#	apply_rules(\$TEXT, "$RSRC/majuscule_unigrammes.rules");
#	apply_rules(\$TEXT, "$RSRC/majuscule_bigrammes.rules");
$VERBOSE && print STDERR ".\n";

#############################################################
#   $TEXT =~ s/_/ /gm; #remove previous multiwords
#	apply_rules(\$TEXT, "$RSRC/multiwords.rules");
#$VERBOSE && print STDERR ".\n";




#############################################################
# Remove weak punctuation signs
#############################################################
	if ($KEEP_PUNC == 0) {
		$TEXT =~ s/$weak_punc/ /gm;
	}
	
	
#############################################################
# One sentence per line + removal of all punctuation signs
#############################################################
$VERBOSE && print STDERR `date "+%d/%m/%y %H:%M:%S"`." -- Final processings.";

	$TEXT = remove_diacritics($TEXT);


$VERBOSE && print STDERR ".";
	apply_rules(\$TEXT, "$RSRC/final.rules");
$VERBOSE && print STDERR ".";
	end(\$TEXT);
$VERBOSE && print STDERR ".";

$TEXT =~ s/(^| )['\-](?= |\n|$)/$1/mg;
$VERBOSE && print STDERR `date "+%d/%m/%y %H:%M:%S"`." -- Splitting into sentences (1 per line).\n";
	if ($KEEP_PUNC == 0) {
		$TEXT =~ s/$weak_punc/ /mgo;
		if ($ESTER == 1 || $KEEP_PARA == 1) {
			$TEXT =~ s/( )(\.|\.\.\.|\?|!)( |$)/$3/mg;
		}
		else {
			$TEXT =~ s/( )(\.|\.\.\.|\?|!)( |$)/\n/mg;
		}
		$TEXT =~ s/(\.\.+|\?+|!+)/ /mg;
		$TEXT =~ s/^\.+//mg;
		$TEXT =~ s/ \.+$//mg;
	}
	else {
		if ($ESTER == 1 || $KEEP_PARA == 1) {
			$TEXT =~ s/( )(\.|\.\.\.|\?|!)( |$)/$1$2$3/mg;
		}
		else {
			$TEXT =~ s/( )(\.|\.\.\.|\?|!)( |$)/$1$2\n/mg;
		}
		$TEXT =~ s/^\.+//mg;
	}


	$TEXT =~ s/( | )+/ /mg;
	if ($KEEP_PARA == 0 ) {
	$TEXT =~ s/(\r+)//gm;
	$TEXT =~ s/(\n)+ /$1/gm;
	$TEXT =~ s/(\n)+/$1/gm;
	}
	$TEXT =~ s/ $//g;
$VERBOSE && print STDERR ".";


$VERBOSE && print STDERR "\n--\n";
print STDERR "\n";
#extra return character if needed
if ($TEXT !~ /\n$/) {
	$TEXT .= "\n";
}
print $TEXT;
print STDERR "\n";


#############################################################
# USAGE
#############################################################



sub usage {
	warn <<EOF;
Usage:
    normalize-text.pl [options] <input>

Synopsis:
    Normalize the content of the input file.
    The result is returned in STDOUT.

Options:
    -h, --help
                 Print this help ;-)
    -v, --verbose
                 Verbose
EOF
	exit 0;
}

#e#o#f#


