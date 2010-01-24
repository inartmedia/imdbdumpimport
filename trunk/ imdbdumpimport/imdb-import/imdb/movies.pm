package movies;

use constant TYPE => 'movie';

BEGIN {
	unshift( @INC, "../lib" );
}
use processor;
use IMDBUtil;

our $i = 0;
our $j =0;
our $s = 0;

sub new {
	my $obj = {"l"=>"f"};
	bless $obj, 'movies';
	return $obj;
}
sub is_store_ready{
	return 1;
}

sub parse {
	shift;
	my $line = shift;
	my %ret = ( type => TYPE );
	
	if ($line =~ m/\{\{(SUSPENDED|SUSPENSION|SUSPENDE)\}\}/){
		#print $line ." SuSpEnDeD\n";
		$s++;
	}
	elsif ( $line =~ m/^(.+)\([\d|?]{4}(\/.+)?\)\s+\(([T]{0,1}V[G]{0,1})\)\s+([\d|?]{4}(-[\d|?]{4})?)(\s+\(.+\))?$/ ) {
		#print $1." - ".$2." - ".$3. "\n";
	}
	elsif ( $line =~ m/^(.+)\([\d|?]{4}(\/.+)?\)\s+([\d|?]{4}(-[\d|?]{4})?)(\s+\(.+\))?$/ ){
		
	}
	elsif ($line =~ m/^\"(.+)\"\s+\([\d|?]{4}(\/.+)?\)\s+\{(.+)\}\s+([\d|?]{4}(-[\d|?]{4})?)(\s+\(.+\))?$/){
		
	}
	elsif ($line =~ m/^\"(.+)\"\s+\([\d|?]{4}(\/.+)?\)\s+\{(.+)\}\s+$/){
		
	}
	elsif ($line =~ m/^\"(.+)\"\s+\([\d|?]{4}(\/.+)?\)(\s+(\S+))?$/){
	}
	else {
		debug($line);	
		$j++;
	}

	$i++;
	if ( $i > 10000000 ) {
		print "$i not-accepted:$j ; suspended: $s\n";
		processor::destroy;
		die;
	}

	return %ret;
}

sub store {

}


sub set_context {
	print "MOVIE\n";
}

# debugging helper methods, to be deleted once everything is finished.
sub how_many_lines {
	return 10000;
}

sub print_info {
	print "processed: $i, unprocessed: $j \n";
}
1;
