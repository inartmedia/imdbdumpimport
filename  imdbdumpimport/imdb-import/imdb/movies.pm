package imdb::movies;

use constant TYPE => 'movie';

BEGIN {
	unshift( @INC, "../" );
}
use Exporter;
our @ISA = qw(Exporter);

use lib::IMDBUtil;

our $i = 0;
our $j =0;
our $s = 0;

sub new {
	my $class = shift;
	my $obj = {context=>undef};
	bless $obj, $class;
	return $obj;
}
sub is_store_ready{
	return 1;
}

sub parse {
	shift;
	my $line = shift;
	my %ret = ( type => TYPE );
	
	if ( $line =~ m/^[^"](.+)\(([\d|?]{4})(\/[IVX]{1,5})?\)/g ) {
		
		#print $1."  ".$2;
		
		if ($line =~ m/\G\s+\(([TVG]{1,2})\)/gc){
		#	print " ($1) "
						
		}
		if ($line =~ m/\G\s+\{\{SUSPENDED\}\}/cg){
		#	print " [suspended] ";
		}
		#print "\n";
	}
	elsif ($line =~ m/^\"(.+)\"\s+\(([\d|?]{4})(\/[IVX]{1,5})?\)\s+(\{(.+)\})?/g){
		
		
	}
	else {
		debug($line);	
		$j++;
	}

	$i++;
	

	return %ret;
}

sub store {

}


sub set_context {
	print "MOVIE\n";
}

# debugging helper methods, to be deleted once everything is finished.
sub how_many_lines {
	return -1;
}

sub print_info {
	print "processed: $i, unprocessed: $j \n";
}
1;
