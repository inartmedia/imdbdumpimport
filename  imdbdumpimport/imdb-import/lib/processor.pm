package processor;

use strict;
use warnings;

use file;
use db;

our @EXPORT_OK = ('process','init');
our $init = 0;

sub init {
	db::connect_to_database(@_);
	$init = 1;
}

sub process{
	my $i = 0;
	my ($file,$ctx,$handler) =  @_;
	$handler->set_context($ctx);
	file::open_file($file);
	LABEL:while(my $line = file::next() ){
		$i++;
		chomp($line);
		my %objects = $handler->parse($line);
		if ($handler->is_store_ready()){
			$handler->store(%objects);	
		}
		last if ($handler->how_many_lines>0 && $i > $handler->how_many_lines);
	}
	
	$handler->print_info;
	
	file::close_file();
}

sub destroy {
	if ($init ==0 ){
		return;
	}
	db::disconnect_from_database();
	file::close_file();
	$init = 0;
}
1;