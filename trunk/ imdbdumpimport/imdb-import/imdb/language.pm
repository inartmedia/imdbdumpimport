package imdb::language;

BEGIN {
	unshift( @INC, "../" );

}

use lib::IMDBUtil;
use imdb::cache;
our $i        = 0;
our $j        = 0;
our $is_ready = 0;

sub parse {
	shift;
	my @line_frgs = split( /\t+/, shift );
	my $line_id = shift;

	if ( !$is_ready ) {
		if ( $#line_frgs == 0 && $line_frgs[0] =~ m/LANGUAGE LIST/ )
		{
			$is_ready = 1;
		}
		return;
	}

	my %ret;
	if ( $#line_frgs + 1 >= 2 ) {
		%ret       = lib::IMDBUtil::parse_movie_info( shift @line_frgs );
		$lang_part = t( shift(@line_frgs) );
		my ( $lang, $lang_notes );
		if ( $lang_part && $lang_part =~ m/(\w+)\s+(\((.+)\))?/ ) {
			$lang       = t($1);
			$lang_notes = t($3);
		}

		$ret{language}       = $lang;
		$ret{language_notes} = $lang_notes;

	}

	return %ret;

}

sub store {
	shift;
}

sub new {
	my $class = shift;
	my $obj = { context => undef };
	bless $obj, $class;
	return $obj;
}

sub is_store_ready {
	shift;
	my $obj_ref = shift;
	if ($is_ready && $obj_ref) {
		if ( $$obj_ref{language} ) {
			return 1;
		}
	}

	return 0;
}

# debugging helper methods, to be deleted once everything is finished.
sub how_many_lines {
	return -1;
}

sub print_info {
	print "processed: $i, unprocessed: $j \n";
}

sub set_context {

}
1;
