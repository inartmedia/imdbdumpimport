package lib::processor;

use strict;
use warnings;
BEGIN {
	unshift (@INC, "../");
	unshift (@INC, "../imdb");
}

use lib::file('open_file','close_file','next_line');
use lib::db;
use imdb::cache;
use lib::IMDBUtil;
use Exporter;
our @ISA= ('Exporter');
our @EXPORT_OK = ('process','init','destroy');
our $init = 0;

sub init {
	lib::db::connect_to_database(@_);
	$init = 1;
	imdb::cache::load();
	
}

sub process{
	my $i = 0;
	my $s = 0;
	my ($file,$ctx,$handler) =  @_;
	$handler->set_context($ctx);
	open_file($file);
	while(my $line = next_line){
		$i++;
		chomp($line);
		my %objects = $handler->parse($line,$i);
		if ($handler->is_store_ready()){
			$handler->store(\%objects);	
			$s++;
		}
		# commit every now and then
		if ($s%200 == 0){
			lib::db::commit();
		}
		if ($i % 10000 == 0){
			debug($file." : processed $i lines");
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
	lib::db::commit();
	lib::db::disconnect_from_database();
	close_file();
	$init = 0;
}
1;