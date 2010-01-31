use strict;
use warnings;
BEGIN {
	unshift (@INC,".");
}
use lib::processor("init","process","destroy");
#imports for imdb handlers.
use imdb::actors;
use imdb::actresses;
use imdb::movies;
use Getopt::Std;


sub process_main{

	# Parse the command line options.
	our ($opt_c, $opt_u, $opt_p,$opt_d, $opt_e);
	getopt("cupde");

	if (!$opt_c){
		$opt_c = "DBI:mysql:imdb2:localhost";
		$opt_u = "imdb2";
		$opt_p = "imdb2";
	}
	if (!$opt_d){
		$opt_d = "data";
	}
	
	if (!$opt_e){
		$opt_e = 'movies,actors,languages,genres,ratings,actresses';
	}
	print "d=$opt_d,u=$opt_u,p=$opt_p,e=$opt_e,c=$opt_c \n";
	
	# TODO :- fail gracefully if all required options are not provided.
	
	lib::processor::init($opt_c, $opt_u, $opt_p);
	
	my @imports =  split(/,/,$opt_e);
	
	foreach my $imp (@imports){
		my $file = "$opt_d/$imp.list";
		lib::processor::process($file,$imp,"imdb::$imp"->new());
	}
	
	lib::processor::destroy();
	
}

process_main;
1;



