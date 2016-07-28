#!/usr/bin/perl

use Config;
use threads;
use threads::shared;

$Config{useithreads} or die
      "Recompilez Perl avec les threads activ�s pour faire tourner ce programme.";
	  
$NBTHREADS=$ARGV[0];
	  
my @file	  : shared;
	  
if(!defined($NBTHREADS) ){die("use <nbthreads> [mots a garder]\n");}

%nombre=(
'cent'=>100,
'cents'=>100,
'cinq'=>5,
'cinquante'=>50,
'deux'=>2,
'dix'=>10,
'douze'=>12,
'huit'=>8,
'huiti�me'=>8,
'ii'=>2,
'mil'=>1000,
'mille'=>1000,
'millions'=>1000000,
'million'=>1000000,
'milliard'=>1000000000,
'milliards'=>1000000000,
'neuf'=>9,
'nonante'=>90,
'onze'=>11,
'quarante'=>40,
'quatorze'=>14,
'quatre'=>4,
'quinze'=>15,
'seize'=>16,
'sept'=>7,
'six'=>6,
'soixante'=>60,
'treize'=>13,
'trente'=>30,
'trois'=>3,
'un'=>1,
'une'=>1,
'vi'=>6,
'vingt'=>20,
'z�ro'=>0
);



%fonction=(
'adjoint'=>1,
'administrateur'=>1,
'altesse'=>1,
'ambassadeur'=>1,
'b�tonnier'=>1,
'censeur'=>1,
'chambellan'=>1,
'chancelier'=>1,
'chanceli�re'=>1,
'chef'=>1,
'chefs'=>1,
'cheikh'=>1,
'commissaire'=>1,
'conseiller'=>1,
'conseill�re'=>1,
'contr�leur'=>1,
'coordinateur'=>1,
'coordonnateur'=>1,
'copr�sident'=>1,
'dala�'=>1,
'directeur'=>1,
'directrice'=>1,
'dirigeant'=>1,
'd�l�gu�'=>1,
'd�put�'=>1,
'd�put�-maire'=>1,
'd�put�e'=>1,
'd�put�s'=>1,
'emir'=>1,
'empereur'=>1,
'eurod�put�'=>1,
'ex-pr�sident'=>1,
'garde'=>1,
'gouverneur'=>1,
'inspecteur'=>1,
'juge'=>1,
'leader'=>1,
'lord'=>1,
'lords'=>1,
'maire'=>1,
'majest�'=>1,
'major'=>1,
'ministre'=>1,
'ministres'=>1,
'pdg'=>1,
'porte-parole'=>1,
'prince'=>1,
'princesse'=>1,
'procureur'=>1,
'professeur'=>1,
'proviseur'=>1,
'(sous\-?)?pr�fet'=>1,
'pr�sident'=>1,
'pr�sidente'=>1,
'pr�sidents'=>1,
'questeur'=>1,
'rabbin'=>1,
'recteur'=>1,
'responsable'=>1,
'secr�taire'=>1,
's�nateur'=>1,
'vice-ministre'=>1,
'vice-pr�sident'=>1,
'vice-pr�sidente'=>1,
'�v�que'=>1,
'wali'=>1
);

$sousunites="(deci|milli|deca|centi|kilo|m�ga|d�ca|hecto|giga|pico|fento|nano)\\-?";

%jour=('lundi',1,'mardi',2,'mercredi',3,'jeudi',4,'vendredi',5,'samedi',6,'dimanche',7);
%mois=('janvier',1,'f.vrier',2,'mars',3,'avril',4,'mai',5,'juin',6,'juillet',7,'ao[u�]t',8,'septembre',9,'octobre',10,'novembre',11,'d[e�]cembre',12);
%devise=('ecus?','1','wons?','1','yens?','1','euros?',1,'francs?',1,'dollars?',1,'centimes?',1,'dirhams',1,'sterling',1,'pesetas?',1,'marks?',1);
%ordinal=('(\\S+\\-)?millioni�mes',1,'cinquanti�mes?',1,'(\\S+\\-)?seizi�mes?',1,'(\\S+\\-)?uni�mes?',1,'quaranti�mes?',1,'centi�mes?',1,"(\\S+\\-)?cinqui�mes?"=>1,"(\\S+\\-)?deuxi�mes?"=>1,"(\\S+\\-)?septi�mes?"=>1,"dixi�mes?"=>1,"(\\S+\\-)?douzi�mes?"=>1,"(\\S+\\-)?neuvi�mes?"=>1,"(\\S+\\-)?onzi�mes?"=>1,"(\\S+\\-)?quatorzi�mes?"=>1,"(\\S+\\-)?quatri�mes?"=>1,"(\\S+\\-)?quinzi�mes?"=>1,"(\\S+\\-)?septi�mes?"=>1,"(\\S+\\-)?sixi�mes?"=>1,"(\\S+\\-)?treizi�mes?"=>1,"(\\S+\\-)?troisi�mes?"=>1,"(\\S+\\-)?vingti�mes?"=>1,"(\\S+\\-)?huiti�mes?"=>1,"seconds?"=>1);
%cardinal=('centaines?',1,'dizaines?',1,'vingtaines?',1,'quarantaines?',1,'cinquantaines?',1,'trentaines?',1,'quinzaines?',1,'douzaines?',1,'soixantaines?',1,'cinquantaines?',1);
%duree=('week','S','septennat','7AN','quinquennat','5AN','mill�naires?','TL','(demi\\-)?si�cles?','TL','d�cennies?','TL','an(n�e?)?s?','A','semestres?','C','trimestres?','C','mois','TC','semaines?','week','TC','TC','jour(n�e)?s?','TC','(demi\\-)?heures?','H','minutes?','M','secondes?','S');
%unites=('((deci|milli|deca|centi|kilo|m�ga|d�ca|hecto|giga|pico|fento|nano)\\-?)?volts?','V','miles?','D','centigrade','D','celsius','D','((deci|milli|deca|centi|kilo|m�ga|d�ca|hecto|giga|pico|fento|nano)\\-?)?m�tres?(-cube|-heure)?','D','degr�s?','T','kilos?','P','((deci|milli|deca|centi|kilo|m�ga|d�ca|hecto|giga|pico|fento|nano)\\-?)?tonnes?','P','((deci|milli|deca|centi|kilo|m�ga|d�ca|hecto|giga|pico|fento|nano)\\-?)?litres?','V','quinta(ux|l)','P','((deci|milli|deca|centi|kilo|m�ga|d�ca|hecto|giga|pico|fento|nano)\\-?)?grammes?','P','d�cibels?','S','((deci|milli|deca|centi|kilo|m�ga|d�ca|hecto|giga|pico|fento|nano)\\-?)?watt(heure)?s?','C','((deci|milli|deca|centi|kilo|m�ga|d�ca|hecto|giga|pico|fento|nano)\\-?)?hertz','F','((deci|milli|deca|centi|kilo|m�ga|d�ca|hecto|giga|pico|fento|nano)\\-?)?litres?','V','hectares?','S');
%tempsrelatif=('aujourd\'hui',1,'(apr�s\\-|surlen|len)?demain',1,'(avant\\-)?hier',1);
%moment=('(apr�s\\-)?midi',1,'matin(�e)?',1,'soir(�e)?',1,'(mi)?nuits?',1);
%fete=('rameaux',1,'no[�e]l',1,'p[a�]ques?',1,'pentec[�o]te',1,'[aA][�i]d',1,'al\-[Aa]dha',1);
%gentile=('\\S+aine?s?$',1,'\\S+aise?s?$',1,'\\S+[iy]en(ne)?s?$',1,'\\S+oise?s?$',1);
%sport=('((volley|hand|basket)\-?)?ball',1,'foot(ball)?',1,'boxe',1,'rugby',1,'basket',1,'tennis',1,'cyclisme',1,'judo',1);
# -ain(e)(s) ou -in(e)(s) surtout pour les villes et quartiers.
# -ais(e)(s) pour les villes (Bayonne : Bayonnais) mais aussi pour les pays (Ta�wan : Ta�wanais, France : Fran�ais)
# -ien(ne)(s), in(e) (s) ou -�en(ne)(s) surtout pour les pays (Italie : Italiens, Malaisie : Malaisiens), Mont�n�gro : Mont�negrins mais aussi Paris : Parisiens, Calais : Calaisiens, Arles : Arl�siens
# -ois(e)(s) 

if(defined($ARGV[1]))
{
	open(T,$ARGV[1]) || die("can't open $ARGV[0]\n");
	while(<T>)
	{
		chomp($_);
		s/(\S+).*/$1/;
		$motagarder{$_}++;
	}
	close(T);
}


$fichier[0]="$ENV{IRISA_NE}/data/listes/pays.liste";
$fichier[1]="$ENV{IRISA_NE}/data/listes/prenoms.liste";
$fichier[2]="$ENV{IRISA_NE}/data/listes/villesdefrance+capitale.liste";
$fichier[3]="$ENV{IRISA_NE}/data/listes/departements.liste";
$fichier[4]="$ENV{IRISA_NE}/data/listes/regions.liste";
$fichier[5]="$ENV{IRISA_NE}/data/listes/titres.liste";
$fichier[6]="$ENV{IRISA_NE}/data/listes/titres-monarchie.liste";
$fichier[7]="$ENV{IRISA_NE}/data/listes/titres-religieux.liste";
$fichier[8]="$ENV{IRISA_NE}/data/listes/grade-militaire.liste";

for($i=0;$i<=$#fichier;$i++)
{

open(FICHIER,$fichier[$i]) || die("can't open $fichier[$i]\n");
while(<FICHIER>)
{
	if(/(.+?)\s*$/)
	{
		$token=$1;
		$token=~s/�/�/;
		$token=~s/\s+/\-/g;
		#$pays=~s/\-/\\-/g;
		$token=lc($token);
		if($i==0){$PAYS{$token}++;}
		elsif($i==1){$PRENOMS{$token}++;}
		elsif($i==2){$VILLES{$token}++;}
		elsif($i==3){$DEPARTEMENTS{$token}++;}
		elsif($i==4){$REGIONS{$token}++;}
		elsif($i==5){$TITRES{$token}++;}
		elsif($i==6){$MONARCHIE{$token}++;}
		elsif($i==7){$RELIGIEUX{$token}++;}
		elsif($i==8){$GRADE{$token}++;}



		#print STDERR "($pays)\n";
	}
}
close(FICHIER);
}


open(GENTILE,"$ENV{IRISA_NE}/data/listes/gentile.liste") || die("can't open $ENV{IRISA_NE}/data/listes/gentile.liste\n");
while(<GENTILE>)
{
	if(/^(.+?)\s+(\S+)\s*$/)
	{
		$pays=$1;
		$gentile=$2;
		$pays=~s/\s+/\-/g;
		#$pays=~s/\-/\\-/g;
		$pays=~s/�/�/;
		$pays=lc($pays);
		$PAYS{$pays}++;
		$gentile=~s/\-/\\-/g;
		$gentile=~s/�/�/;
		$gentile=lc($gentile);
		$gentile=~s/ain$/aine?/;
		$gentile=~s/ais$/aise?/;
		$gentile=~s/ien$/ien(ne)?/;
		$gentile=~s/in$/ine?/;
		$gentile=~s/�en$/�en(ne)?/;
		$gentile=~s/ois$/oise?/;
		
		$gentile=~s/([ls])$/$1e?/;
		
		$gentile=~s/$/s?/;
		$GENTILE{$gentile}++;
		#print STDERR "($pays)\n";
		#print STDERR "($gentile)\n";
	}
}
close(GENTILE);

# -ain(e)(s) ou -in(e)(s) surtout pour les villes et quartiers.
# -ais(e)(s) pour les villes (Bayonne : Bayonnais) mais aussi pour les pays (Ta�wan : Ta�wanais, France : Fran�ais)
# -ien(ne)(s), in(e) (s) ou -�en(ne)(s) surtout pour les pays (Italie : Italiens, Malaisie : Malaisiens), Mont�n�gro : Mont�negrins mais aussi Paris : Parisiens, Calais : Calaisiens, Arles : Arl�siens
# -ois(e)(s) 
$i=0;
while(<STDIN>)
{
	$file[$i++]=$_;
}

if($NBTHREADS==0)
{$part=$#file+1;}
else{$part=int(($#file+1)/$NBTHREADS);}

for($i=0;$i<=$NBTHREADS;$i++)
{
	$deb=$part*$i;
	$fin=$part*$i+$part;
	if($fin > ($#file+1)){$fin=$#file+1;}
	#print STDERR "Process($deb,$fin)...\n";
	$thr{$i} = threads->new(\&process, $deb,$fin);
	
}

for($i=0;$i<=$NBTHREADS;$i++)
{
	#print STDERR "Wait process($i)...";
	$retour=$thr{$i}->join;
	#print STDERR " -> $retour\n";
}

for($i=0;$i<=$#file;$i++)
{
  print STDOUT $file[$i];
}
	

sub process()
{
    my $deb=$_[0];
	my $fin=$_[1];
	my $i;
	my $word="";
	my $pos="";
	my $demiword="";
	my $tagflag=0;
	
	
	for($i=$deb;$i<$fin;$i++)
	{
	
	if($file[$i] =~/(\S+)\s+(\S+)/)
    {
  	 $word=$1;
	 $pos=$2;
	
	if($file[$i] =~/\S+\s+\S+\s+\S+/){$tagflag=1;}else{$tagflag=0}
    
	$demiword=$word;
	$demiword=~s/\-.*//;

	if($pos eq "CAR" || exists($nombre{$word}) || exists($nombre{$demiword}))
	{
	  #print STDOUT "$word\n";
	  $numerique=&convert($word);
	  if($numerique>1){$pos=$numerique;}
	  if($numerique>1 && $numerique<10){$pos="CAR_UNITE";}
	  elsif($numerique<=31 && $numerique>=10){$pos="CAR_RANGE_DATE";}
	  elsif($numerique>31 && $numerique<100){$pos="CAR_GROS";}
	  elsif($numerique==100){$pos="CAR_CENT";}
	  elsif($numerique>100 && $numerique<1000){$pos="CAR_GROS";}
	  elsif($numerique==1000){$pos="CAR_MILLE";}
	  elsif($numerique>1000){$pos="CAR_ENORME";}
	 
	}
	
	if(exists($PRENOMS{$word}) && $pos =~/^(NP|<unk>)/) {$pos="PRENOM";}	#
	
	foreach $j (keys %GENTILE) #a faire avant pays car lorsque identique prefere pays (suisse)
	{
	   if($word=~/^$j$/) {$pos="GENTILE";}
	}
	
	
	if(exists($PAYS{$word})) {$pos="PAYS";} #pas besoin de tous les parcourir car mot est fig� par une expression r�guli�res
	if(exists($REGIONS{$word}) && $pos =~/^(NP|<unk>)/) {$pos="REGION";}# && 
	if(exists($DEPARTEMENTS{$word}) && $pos =~/^(NP|<unk>)/) {$pos="DEPARTEMENT";}# 
	if(exists($VILLES{$word})) {$pos="VILLE";}
	if(exists($TITRES{$word})) {$pos="TITRE";}
	if(exists($MONARCHIE{$word})) {$pos="MONARCHIE";}
	if(exists($RELIGIEUX{$word})) {$pos="RELIGIEUX";}
	if(exists($GRADE{$word})) {$pos="GRADE";}
		
		
	foreach $j (keys %moment)
	{
	   if($word=~/^$j$/) {$pos="MOMENT";}
	}
	foreach $j (keys %jour)
	{
	   if($word=~/^$j$/) {$pos="JOUR";}
	}
	foreach $m (keys %mois)
	{
	   if($word=~/^(mi\-)?$m$/) {$pos="MOIS";}
	}
	foreach $m (keys %ordinal)
	{
	   if($word=~/^$m$/) {$pos="ORDINAL";}
	}
	foreach $m (keys %cardinal)
	{
	   if($word=~/^$m$/) {$pos="CARDINAL";}
	}
	foreach $m (keys %devise)
	{
	   if($word=~/^$m$/) {$pos="DEVISE";}
	}
	foreach $m (keys %duree)
	{
	   if($word=~/^$m$/) {$pos="DUREE";}
	}
	foreach $m (keys %unites)
	{
	   if($word=~/^$m$/) {$pos="UNITES";}
	}
	foreach $m (keys %tempsrelatif)
	{
	   if($word=~/^$m$/) {$pos="TEMPSREL";}
	}	
	foreach $m (keys %fete)
	{
	   if($word=~/^$m$/) {$pos="FETE";}
	}
	foreach $m (keys %sport)
	{
	   if($word=~/^$m$/) {$pos="SPORT";}
	}	
	
	if($pos=~/<unk>/)
	{
		if($word=~/^([ae]l\-)|(abd)/){$pos="NEW_ARABE";}
		elsif($word=~/[o]\-/){$pos="NEW_COMPOSE1";}
		elsif($word=~/\-/){$pos="NEW_COMPOSE2";}
		
	}
	if(exists($motagarder{$word})){$pos=$word;}
	
	$file[$i]=~s/(\S+)\s+(\S+)/$1 $pos/;

	}
  }
  return "ok";
 
}

sub convert()
{
	my $lexical=$_[0];
	$lexical=~s/\-/ /g;
	$lexical=~s/et/ /g;
	$lexical=~s/\S+//;
	my $result=$nombre{$&};
	while($lexical=~s/\S+//)
	{
	  $actuel=$nombre{$&};
	  if($result>$actuel){$result=$result+$actuel;}
	  else{$result*=$actuel;}
	}
	return $result;
}