#!/usr/bin/perl

# Tokenize a text for the French language
#
package basicTokenizerFr;

use strict;
use Cwd 'abs_path';
use File::Basename;
use lib dirname( abs_path(__FILE__) )."/.";
use CorpusNormalisationFr;
require Encode;
use utf8;
# use locale;
use POSIX qw(locale_h);
setlocale(LC_CTYPE, "UTF8");
setlocale(LC_COLLATE, "UTF8");

#
# constants
#

my $dirRessources = dirname( abs_path(__FILE__) )."/../rsrc/fr";


# file with a list of abbreviations
my $fileAbbr = "$dirRessources/abbrev.lst";

my $quotes = "[\"«»]";
my $paren = "[\\(\\)\\{\\}\\[\\]]";
my $operators  = "[+=÷×\/]";
my $plusminus = "±";
my $punct1 = "[,;:\?\!¡¿]";
my $punct2 = "[\-_]";
my $punct = "[,;:\?\!\_\.\-¡¿]";
my $webdomain = "com|net|org|co\.uk|fr|gov|de|ch|es|it|info";


# Separate strings at the beginning of words
my $beginString='[dcjlmnstDCJLMNST]\'|[Qq]u\'|[Jj]usqu\'|[Ll]orsqu\'|[Pp]uisqu\'|[[Pp]resqu\'|[Qq]uelqu\'|[Qq]uoiqu\'';


# Separate strings at the end of words
my $endString='-t-elles?|-t-ils?|-t-on|-t-en|-ce|-elles?|-ils?|-je|-la|-les?|-leur|-lui|-mêmes?|-m\'|-moi|-nous|-on|-toi|-tu|-t\'|-vous|-en|-y|-ci|-là';
# exceptions where the words musn't be split
my $endExcept = '-t-elles?|-t-ils?|-t-on|-t-en|[rR]endez-vous|[eE]ntre-lui|[cC]hez-[mt]oi|[cC]hez-nous';


my %abbr = ();
my %begExcept = ();
# for latin-9 (ISO 8859-15)
our $alphanum = "[0-9a-zA-ZÀ-ÖØ-öø-ÿŠšŽžŒœŸ]";
our $letter = "[a-zA-ZÀ-ÖØ-öø-ÿŠšŽžŒœŸ]"; 
our $upper = "[A-ZÀ-ÖØ-ÞŠŽŒŸ]";
our $downer = "[a-zà-öø-ÿŠŽŒŸ]";



# ---------------------- #
#     sub downcase()
# for ISO 8859-15 (latin-9)
# ---------------------- #
sub downcase {
  my $w = shift;

  $w =~ tr/ABCDEFGHIJKLMNOPQRSTUVWXYZÀÁÂÃÄÅÆÈÉÊËÌÍÎÏÒÓÔÕÖØÙÚÛÜÝŸÇÐÑÞŠŽŒ/abcdefghijklmnopqrstuvwxyzàáâãäåæèéêëìíîïòóôõöøùúûüýÿçðñþšžœ/;

  return $w;
}


# ---------------------- #
#     sub upcase()
# for ISO 8859-15 (latin-9)
# ---------------------- #
sub upcase {
  my $w = shift;

  $w =~ tr/abcdefghijklmnopqrstuvwxyzàáâãäåæèéêëìíîïòóôõöøùúûüýÿçðñþšžœ/ABCDEFGHIJKLMNOPQRSTUVWXYZÀÁÂÃÄÅÆÈÉÊËÌÍÎÏÒÓÔÕÖØÙÚÛÜÝŸÇÐÑÞŠŽŒ/;

  return $w;
}




# ---------------------- #
#     sub initAbbr()
# ---------------------- #
sub initAbbr {
  open(ABBR, "<$fileAbbr")
    or die "couldn't open $fileAbbr\n";
  while (<ABBR>) {
    chomp;
    s/\#.*$//; # remove comments
    s/\s+$//; # remove trailing blanks
    $abbr{$_} = 1;
  }

  close(ABBR);
}



# ---------------------- #
#      sub tok()
# ---------------------- #
# parameter:
# - string to tokenize
sub tok {

  my $intok = shift;
  my $res = "";

  ##  if your data comes in Latin-1, then uncomment:
  $intok =~ s/α/alpha/g;
  $intok =~ s/β/beta/g;
  $intok =~ s/γ/gamma/g;
  $intok =~ s/δ/delta/g;
  $intok =~ s/Δ/delta/g;
  $intok =~ s/μ/micro/g;
  $intok =~ s/ρ/rho/g;
  $intok =~ s/λ/lambda/g;
  $intok =~ s/Λ/lambda/g;
  #$intok = Encode::decode( 'utf8', $intok );
  $intok =~ s/\xe4/ae/g;  ##  treat characters ä ñ ö ü ÿ
  $intok =~ s/\xf1/ny/g;  ##  this was wrong in previous version of this doc
  $intok =~ s/\xf6/oe/g;
  $intok =~ s/\xfc/ue/g;
  $intok =~ s/\xff/yu/g;
  $intok =~ s/\x{00df}/ss/g;  ##  German beta “ß” -> “ss”
  $intok =~ s/\x{00c6}/AE/g;  ##  Æ
  $intok =~ s/\x{00e6}/ae/g;  ##  æ
  $intok =~ s/\x{0132}/IJ/g;  ##  Ĳ
  $intok =~ s/\x{0133}/ij/g;  ##  ĳ
  $intok =~ s/\x{0152}/Oe/g;  ##  Œ
  $intok =~ s/\x{0153}/oe/g;  ##  œ
  $intok =~ s/\x{0259}/e/g;  ## ə
  $intok =~ s/\x{018f}/e/g;  ## Ə
  $intok =~ s/\x{2019}/'/g;  ## ’
  $intok =~ s/\x{2026}/.../g;  ## …
  $intok =~ tr/\x{00d0}\x{0110}\x{00f0}\x{0111}\x{0126}\x{0127}/DDddHh/; # ÐĐðđĦħ
  $intok =~ tr/\x{0131}\x{0138}\x{013f}\x{0141}\x{0140}\x{0142}/ikLLll/; # ıĸĿŁŀł
  $intok =~ tr/\x{014a}\x{0149}\x{014b}\x{00d8}\x{00f8}\x{017f}/NnnOos/; # ŊŉŋØøſ
  $intok =~ tr/\x{00de}\x{0166}\x{00fe}\x{0167}/TTtt/;                   # ÞŦþŧ
  $intok =~ s/ﾣ//g; # ﾣ

  
  $intok =~ s/\|/ /g;
  $intok =~ s/^\d+([\.:\-\/\\]\d+)+: ?//gm; #skip time stamp at beginning of lines
  
  #Remove HTML tags
  $intok =~ s/( |^)<[^>]+?('s|'| |\n|$)/$1$2/gm;
  $intok =~ s/( |^)([^< ]+?)>( |\n|$)/$1$2$3/gm;
  $intok =~ s/<\/?[^>]+>/ /g;
  $intok =~ s/[<>]{2,}/ /g;
  
  #Space single quotes
  $intok =~ s/(^| )'(.*?[^s])'( |\n|$)/$1 ' $2 ' $3/g;

  # treat independently each line of the token
  my @lin = split(/\n/, $intok);
  foreach my $str (@lin) {
      while ($str =~ /([0-9]),([0-9]{3})\b/) {
	  $str = $`.$1.$2.$'; #'
      }
      
      
      #process parentheses ( X )
      # if X contains a number and no letter-> remove
      # if |X| <= 2 -> remove
      # otherwise, keep it    
      sub proc_par {
	  my $x = shift;
	  if ($x =~ /\d/ && $x !~ /\w/) { return ""; }
	  elsif (length($x) <= 2) { return ""; }
	  return "($x)";
      }
      $str =~ s/\(at\)/ @ /g;
      $str =~ s/\(([^\)]+)\)/" ".proc_par($1)." "/ge;
      
      #split items
      $str =~ s/ ?(?:■|•) ?/\n- /g;
      
      #remove long (5+) sequence of single letters and number
      $str =~ s/ (?:(?:[a-zA-Z]|-?[0-9][0-9\.]*) ){5,}/\n/g;

      # remove / at the end of Web addresses to avoid that this script
      # joins the address with the following word
      # e.g. www.nodo50.org/mareanegra/ sans oublier
      $str =~ s/(http:\/\/|www\.)(\S+)\/( |$punct1|\.|$quotes|$)/$1$2$3/g;
      
      


      # put spaces around punctuation marks
      $str =~ s/($plusminus|$paren|$quotes|$operators|$punct1)/ $1 /g;
      $str =~ s/--+/ -- /g;

      # remove blank between Canal and +
      $str =~ s/Canal(\s+)\+/Canal+/g;


      # correct numeric sequences

      # large numbers can have ., e.g. : 100.000
      while($str =~ s/([0-9]),([0-9]{3})([^0-9])/$1$2$3/) { }

      $str =~ s/([0-9]+)($operators)/$1 $2/og;
      $str =~ s/($operators)([0-9]+)/$1 $2/og;
#   $str =~ s/([0-9]+) +\-/$1-/g;
#    $str =~ s/\- +([0-9]+)/-$1/g;
      while($str =~ s/([0-9]+) +([\.,]) +([0-9]+)/$1$2$3/g) { } # decimal numbers

      # split numbers around , for lists and years
      # e.g. 8,11,12 et 13 juillet> 8, 11 , 12 et 13 juillet
      #... JO de 1992,1996 et 2004 ... -> JO de 1992 , 1996 et 2004 
      $str =~ s/(^|\b)([0-9]+),([0-9]+),([0-9]+)((?:,[0-9]+)*) +(et|ou) ([0-9])/$1.$2." , ".$3." , ".$4.treatLstNb($5)." ".$6." ".$7/ge;
      $str =~ s/(^|\b)([0-9]+),([0-9]+),([0-9]+)((?:,[0-9]+)*)/$1.$2." , ".$3." , ".$4.treatLstNb($5)/ge;      
      while($str =~ s/(^|\b)([0-9]+),([0-9]+)(\b|$)/$1.&checkYrs($2,$3).$4/ge) { }
      $str =~ s/¶¶¶/,/g;

      # minutes, seconds or inches
      $str =~ s/([0-9]) +(\'|\'\') */$1$2 /g;
      $str =~ s/([0-9]) +(\'|\'\') +([0-9]{1,2})/$1$2$3/g;
      
      # for acronyms with several ., put an extra . at the end of the
      # word if it is the end of a sentence
      $str =~ s/(${upper})\.(${upper})\.(${upper})\. +(${upper})/$1.$2.$3. . $4/g;

      # delete spaces between http and www for Web addresses
      $str =~ s/http +: +\/ +\//http:\/\//g;


      # delete spaces around / for Web addresses
      while ($str =~ s/(http:\/\/|www\.)(\S+) +\/ +(\S)/$1$2\/$3/) { }
      while ($str =~ s/(http:\/\/|www\.)(\S+) +\/(\S)/$1$2\/$3/) { }
      while ($str =~ s/(http:\/\/|www\.)(\S+)\/ +(\S)/$1$2\/$3/) { }
      
      
      # Delete ending "/" and "\"
#   $str =~ s/(?<!http:\/)[\/\\]( |\n|$)/$1/gim;
      # NB: ? remains with spaces around them for Web adresses but they
      # are rare
      # treat ' and -
      my @lstr = split(/ +/, $str);
      foreach my $w (@lstr) {
	  # Web address and e-mails address
	  if ($w =~ /^http:\/\/\S+$/) {
	      if ($w =~ /\.$/) {
		  $w = $`." .";
	      }
	      $res .= $w." ";
	  } elsif ($w =~ /^www\.\S+$/) {
	      if ($w =~ /\.$/) {
		  $w = $`." .";
	      }
	      $res .= $w." " ;
	  } elsif ($w =~ /^\S+@\S+\.\S+$/) {
	      if ($w =~ /\.$/) {
		  $w = $`." .";
	      }
	      $res .= $w." " ;

	      # other words
	  }
	  else {
	      $res .= &treatDot($w)." ";
	  }
      }
      

      $res .= "\n";
  }

  # remove leading and trailing blanks for each line
  $res =~ s/(^|\n) +/$1/g;
  $res =~ s/ +($|\n)/$1/g;

  # remove void lines
  $res =~ s/\n+/\n/g;
  $res =~ s/^\n+//;

  # keep only 1 consecutive blank
  $res =~ s/ +/ /g;

  #remove long sequences of numbers
  #while ($res =~ s/ (-?[^A-Za-z][0-9\.]* )(-?[0-9\.]+ ){2,}(-?[^A-Za-z][0-9\.]*)/\n/g) {}
  #$res =~ s/[^[:alnum:]\.,;:\?!\-\+\*'"\$£¥%\x{20AC}&#=@°\(\)\/<>²³\n]/ /g;
  $res =~ s/ \.( \.){2,}/ .../g;
  $res =~ s/ +/ /g;
  $res =~ s/ $//g;
  $res =~ s/^ //g;	    

        print STDERR $res."\n";
  
  #downcase sequence of 4+ uppercase words
  $res =~ s/(^| )([A-Z][A-Z0-9'-]*) ((?:[A-Z0-9][A-Z0-9'-]* ?,? ){1,})([A-Z][A-Z0-9'-]+)/$1.ucfirst(lc($2)).lc(" $3 $4")/gem;
	    
  $res =~ s/\n\n+/\n/gm;
  #$res = Encode::encode_utf8($res);
  
  return $res;
}


# ---------------------- #
#   sub checkYrs
# ---------------------- #
# Check that a token with a comma contains a year
# parameter:
# - token to process
sub checkYrs {
  my $a = shift;
  my $b = shift;
  if ($a =~ /^(17|18|19|20)[0-9]{2}$/ || $b =~ /^(17|18|19|20)[0-9]{2}$/) {
    return "$a , $b";
  }
  else {
    return "$a¶¶¶$b"; # to avoid an infinite loop when calling this function
  } 
}


# ---------------------- #
#   sub treatLstNb
# ---------------------- #
# Put blank between , for list of numbers
# parameter:
# - token to process
sub treatLstNb {
  my $itok = shift;
  while ($itok =~ s/,([0-9]+)/ , $1/g) {}
  return $itok;
}



# ---------------------- #
#     sub treatDot()
# ---------------------- #
# parameter:
# - word to process
sub treatDot {
  my $w = shift;
  
  # $w is segmented by . except
  # ...
  # in a number
  # in acronyms
  # in a known abbreviation
  # in an ending abbreviation
  # an isolated capital letter
  # a sequence of capital letters
  if ($w =~ s/(${alphanum}*)(\.{3})\.*/$1 $2/og) { }
  if ($w =~ s/(\.{3})\.*(${alphanum}*)/$1 $2/og) { }
  if ($w =~ /[0-9]\.$/) { $w =~ s/\.$/ ./g; }
  if ($w =~ /^\./) { $w =~ s/^\./. /g; }
  elsif ($w =~ /(?:${alphanum}*)\.(?:$webdomain)/i) { }
  elsif ($w =~ /[0-9]\.[0-9]/) { }
  elsif (defined $abbr{$w}) {}
  elsif ($w =~ /(${upper})\.(${upper})\.(${upper})\.?$/o) { 
    # normalize acronyms with . e.g., O.N.U.=>ONU (at least 3 letters as there can be first names with 2 capital letters, e.g. J.C. Tricher)
    $w =~ s/\.//g;
  }
  elsif ($w =~ /^(${upper})\.\-(${upper})\.*$/o) {}
  elsif ($w =~ /^(${upper})\.$/o) {}
  elsif ($w =~ /^(${upper})\.(${upper})\.$/o) {}
  else {
    $w =~ s/(${alphanum}*)(\.)(${alphanum}*)/$1 $2 $3/og;
  }

  return $w;
  
}

1;
