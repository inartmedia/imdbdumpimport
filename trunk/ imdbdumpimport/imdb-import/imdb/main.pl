use strict;
use warnings;
BEGIN {
	unshift (@INC, "../lib");
}

use actors;
use movies;

use processor;

sub process{
	processor::init("DBI:mysql:imdb2:localhost", "imdb2", "imdb2");
	
	#processor::process("../data/movies.list",'movie',movies::new());
	
	processor::process("../data/actors.list",'actor',actors::new());
	processor::destroy();
	
}

process;



