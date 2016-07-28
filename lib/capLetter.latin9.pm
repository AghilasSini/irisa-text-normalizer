# library to upcase, downcase or remove diacritics of letters
#

package capLetter;

use strict;


# for latin-9 (ISO 8859-15)
our $alphanum = "[0-9a-zA-Z�-��-��-��������]";
our $letter = "[a-zA-Z�-��-��-��������]"; 
our $upper = "[A-Z�-��-ަ���]";
our $downer = "[a-z�-��-�����]";



# ---------------------- #
#     sub downcase()
# for ISO 8859-15 (latin-9)
# ---------------------- #
sub downcase() {
  my $w = shift;

  $w =~ tr/ABCDEFGHIJKLMNOPQRSTUVWXYZ�������������������������ݾ���ަ��/abcdefghijklmnopqrstuvwxyz����������������������������������/;

  return $w;
}


# ---------------------- #
#     sub upcase()
# for ISO 8859-15 (latin-9)
# ---------------------- #
sub upcase() {
  my $w = shift;

  $w =~ tr/abcdefghijklmnopqrstuvwxyz����������������������������������/ABCDEFGHIJKLMNOPQRSTUVWXYZ�������������������������ݾ���ަ��/;

  return $w;
}


# ---------------------- #
#     sub rmDiacritics()
# for ISO 8859-15 (latin-9)
# ---------------------- #
sub rmDiacritics() {
  my $w = shift;

  $w =~ tr/�������������������������������������������������ݾѦ�/aaaaaaeeeeiiiiooooouuuuyynszAAAAAAEEEEIIIIOOOOOUUUUYYNSZ/;

  return $w;
}

return 1;
