package lib::processor;

use strict;
use warnings;
BEGIN {
	unshift (@INC, "../");
	unshift (@INC, "../imdb");
}
use lib::file('open_file','close_file','next_line');
use lib::db;
use Exporter;
our @ISA= ('Exporter');
our @EXPORT_OK = ('process','init','destroy');
our $init = 0;

sub init {
	lib::db::connect_to_database(@_);
	$init = 1;
}

sub process{
	my $i = 0;
	my ($file,$ctx,$handler) =  @_;
	$handler->set_context($ctx);
	open_file($file);
	while(my $line = next_line){
		$i++;
		chomp($line);
		my %objects = $handler->parse($line);
		if ($handler->is_store_ready()){
			$handler->store(%objects);	
		}
		last if ($handler->how_many_lines>0 && $i > $handler->how_many_lines);
	}
	
	$handler->print_info;
	
	close_file();
}

sub destroy {
	if ($init ==0 ){
		return;
	}
	lib::db::disconnect_from_database();
	close_file();
	$init = 0;
}
1;