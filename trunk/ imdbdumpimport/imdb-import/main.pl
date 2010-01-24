
use warnings;
BEGIN {
	unshift (@INC, ".");
}

use Getopt::Std;
use lib::processor;
#imports for imdb handlers.
use imdb::actors;
use imdb::movies;

sub process_main{

	# Parse the command line options.
	our ($opt_c, $opt_u, $opt_p,$opt_d, $opt_e);
	getopt("cupde");
	print "d=$opt_d,u=$opt_u,p=$opt_p,e=$opt_e,c=$opt_c \n";
	
	if (!$opt_d){
		$opt_d = "../data";
	}
	
	if (!$opt_e){
		$opt_e = 'movies,actors,languages,genres,ratings,actresses';
	}
	
	# TODO :- fail gracefully if all required options are not provided.
	
	processor::init($opt_c, $opt_u, $opt_p);
	
	my @imports =  split(/,/,$opt_e);
	
	foreach my $imp (@imports){
		my $file = "$opt_d/$imp.list";
		processor::process($file,$imp,$imp->new());
	}
	
	processor::destroy();
	
}

process_main;



