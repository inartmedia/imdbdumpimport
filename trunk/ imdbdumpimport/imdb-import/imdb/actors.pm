package actors;

BEGIN {
	unshift( @INC, "../" );
	
}

use Exporter;
our @ISA = qw(Exporter);

our @EXPORT_OK = qw(new is_parse_ready is_store_ready parse print_info set_context store);

use lib::IMDBUtil( 'trim', 'debug' );

our $context;
our %actor;
our @credits = 0;

our $is_store = 0;

# keep an indicator for last two lines.
# to detect begin of a parse.
our $line1 = "";
our $line2 = "";

#delete me later
my $i = 0;
my $u = 0;

sub new {

	# dummy object
	my $obj = { "l" => "f" };
	bless $obj, shift;
	return $obj;
}

sub is_parse_ready {

	my @line_fragments = split( /\t+/, $line1 );
	if ( ( my $size = @line_fragments ) != 2 ) {
		return 0;
	}
	if (   trim( $line_fragments[0] ) eq 'Name'
		&& trim( $line_fragments[1] ) eq 'Titles' )
	{
		return 1;
	}
	return 0;
}

sub is_store_ready {
	return $is_store;
}

sub parse {
	shift;
	my $line = shift;

	my %ret = ( type => $context );

	if ( !is_parse_ready() ) {
		$line1 = $line2;
		$line2 = $line;
		return %ret;
	}
	elsif ( %actor && trim($line) eq "" ) {
		$is_store       = 1;
		$ret{'actor'}   = \%actor;
		$ret{'credits'} = \@credits;
		return %ret;
	}

	my @frgs = split( /\t+/, $line );
	my $character_part;
	my $actor_str = "";
	if ( ( my $size = @frgs ) == 2 ) {
		$character_part = $frgs[1];
		$actor_str      = $frgs[0];
	}

	#parse the actor and store 'it'
	my @actornames = split( /,/, $actor_str );
	if ( scalar @actornames == 2 ) {
		$actor = {
			fullname => trim($actor_str),
			fname    => trim( $actornames[1] ),
			lname    => trim( $actornames[0] )
		};
	}

	#parse the credit and store it in @credits array;
	$i++;
	if ($character_part) {
		$character_part = trim($character_part);
		if ( $character_part =~
m/^(.+)\s+\([\d|?]{4}(\/.+)?\)(\s+\(([TVG]{1,2})\))?(\s+\[(.+)\])?(\s+\<(\d+)\>)?$/
		  )
		{
			
		}
		elsif ($character_part =~ m/^\"(.+)\"\s+\([\d|?]{4}(\/.+)?\)\s+\{(.+)\}(\s+\((.+)\))?\s+\[(.+)\](\s+\<(\d+)\>)?$/){
			
		}
		else {
			$u++;
			debug($character_part);
		}
	}
	return %ret;

}

sub store {

	# reset state
	$is_store = 0;
	undef($actor);
	undef($credits);
}

sub set_context {
	print "ACTOR\n";
	$context = shift;

}

# debugging helper methods, to be deleted once everything is finished.
sub how_many_lines {
	return 10;
}

sub print_info {
	print "processed: $i, unprocessed: $u \n";
}
1;
