package lib::processor;

use strict;
use warnings;
BEGIN {
	unshift (@INC, "../");
	unshift (@INC, "../imdb");
}

use lib::file('open_file','close_file','next_line');
use lib::db;
use lib::Log; 
use imdb::cache;
use lib::IMDBUtil;
use Exporter;
our @ISA= ('Exporter');
our @EXPORT_OK = ('process','init','destroy');
our $init = 0;

sub init {
	my ($db,$log,$unp) = ("lib::MySQLDB","log/logfile.log","log/unprocessed.log");
	lib::db::init($db);
	lib::Log::init($log,$unp);
	lib::db::connect_to_database(@_);
	$init = 1;
	
}

sub process{
	my $i = 0;
	my $s = 0;
	my ($file,$ctx,$handler) =  @_;
	$handler->set_context($ctx);
	open_file($file);
	my @fsplit = split(/\//,$file);
	my $file_name = $fsplit[$#fsplit];
	while(my $line = next_line){
		$i++;
		chomp($line);
		my %objects = $handler->parse($line,$i);
		if ($handler->is_store_ready(\%objects)){
			$handler->store(\%objects,$i);	
			$s++;
		}
		# commit every now and then
		if ($s%200 == 0){
			lib::db::commit();
		}
		if ($i % 10000 == 0){
		#	debug($file_name." : processed $i lines");
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
	lib::Log::destroy();
	close_file();
	$init = 0;
}
1;