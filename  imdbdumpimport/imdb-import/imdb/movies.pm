package imdb::movies;
use strict;
use warnings;
use constant MOVIE => 'movie';
use constant SHOW  => 'show';

BEGIN {
	unshift( @INC, "../" );
}

use lib::IMDBUtil;
use lib::db;
use imdb::cache;

our $s   = 0;
our $idx = 0;

our $begun = 0;

sub new {
	my $class = shift;
	my $obj = { context => undef };
	bless $obj, $class;
	return $obj;
}

sub is_store_ready {
	return $begun;
}

sub parse {

	shift;
	my $line      = shift;
	my $line_id   = shift;
	my @line_frgs = split( /\t+/, $line );

	my %ret;
	if ( $#line_frgs + 1 >= 1 ) {
		%ret = lib::IMDBUtil::parse_movie_info( shift @line_frgs, $line_id );
		if ( $ret{type} ) {
			$begun = 1;
			if ( $ret{type} eq MOVIE ) {
				my $year_part = shift @line_frgs;
				my $year_end  = "";
				my $year_start;
				if (   $year_part
					&& $year_part =~ m/\s+([\d|?]{4})(-([\d|?]{4}))?/gc )
				{
					$year_start = t($1);

					if ( !$2 ) {
						$year_end = t($2);
					}
				}

				my $notes_part = shift @line_frgs;
				my $notes;
				if ( $notes_part && $notes_part =~ m/\s+\((.+)\)/ ) {
					$notes = t($1);
				}

				if (   $year_start
					&& $year_start ne '????'
					&& $ret{year} eq '????' )
				{
					$ret{year} = $year_start;
				}
				$ret{year_end} =
				  ( $year_end && $year_end ne "????" ? $year_end : "" );
				$ret{notes} = $notes;

			}
			else {

				my ( $ep_times, $notes );
				my ( $ep_times_part, $notes_part ) = @line_frgs;

				if (   $ep_times_part
					&& $ep_times_part =~ m/\s+([\d|?]{4}(-[\d|?]{4})?[,]?)+/gc )
				{
					$ep_times = t($1);

				}
				if ( $notes_part && $notes_part =~ m/\s+\((.+)\)/cg ) {
					$notes = t($1);
				}

				my $episode_hash = $ret{episode};
				if ($episode_hash) {
					$$episode_hash{years} = $ep_times;
					$$episode_hash{notes} = $notes;
				}

			}
		}
		else {
			$begun = 0;
		}
	}

	return %ret;
}

sub store {
	shift;
	my $mref = shift;
	my %obj  = %$mref;
	my $lid  = shift;

	my $type = $obj{type};

	if ( !$type ) {
		print "[$lid] HHHH ";
		print_r($mref);
		return;
	}

	if ( $type eq MOVIE ) {
		return;

		# save the movie
		my $msql =
"insert into movies (title,year,year_end,vtype,notes) values (?,?,?,?,?)";
		my @params = (
			$$mref{title}, $$mref{year}, $$mref{year_end},
			$$mref{vtype}, $$mref{notes}
		);

		my $id = lib::db::insert( $msql, @params );
		imdb::cache::add( $mref, $id );

	}
	else {

		# save the show
		# if the episode is not included, save the show
		my $sid = imdb::cache::get_show( $$mref{title}, $$mref{year} );
		if ( !$sid ) {
			my $ssql   = "insert into shows (title,year) values (?,?)";
			my @params = ( $$mref{title}, $$mref{year} );
			my $id     = lib::db::insert( $ssql, @params );

			# retain the reference for future use
			imdb::cache::add( $mref, $id );
		}
		else {
			my $episode = $$mref{episode};

			# save the episode, get the reference from $obj{show}
			my $esql =
"insert into show_episodes (sid,title,year,years_active,season,episode_no,notes) values (?,?,?,?,?,?,?)";

			my @eparams = (
				$sid, $$episode{title}, $$episode{year}, $$episode{years},
				$$episode{season}, $$episode{episode_num}, $$episode{notes}
			);
			my $eid = lib::db::insert( $esql, @eparams );
			$$episode{sid} = $sid;
			imdb::cache::add( $episode, $eid );
		}
	}
}

sub set_context {

}

# debugging helper methods, to be deleted once everything is finished.
sub how_many_lines {
	return -1;
}

sub print_info {
}
1;
