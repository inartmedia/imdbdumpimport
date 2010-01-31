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

our $i   = 0;
our $j   = 0;
our $s   = 0;
our $idx = 0;

my $begun = 0;

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
	my $line    = shift;
	my $line_id = shift;
	my %ret;
	if ( $line !~ m/^["]/ ) {
		if ( $line =~ m/^(.+)\(([\d|?]{4})(\/[IVX]{1,5})?\)/g ) {

			my ( $title, $year_start, $year_end, $tv, $suspended, $notes );

			$title      = t($1);
			$year_start = t($2);
			$suspended  = 0;
			$notes      = "";
			$tv         = "";
			$year_end   = "";
			if ( $line =~ m/\G\s+\(([TVG]{1,2})\)/gc ) {

				#	print " ($1) "
				$tv = t($1);

			}
			if ( $line =~ m/\G\s+\{\{(SUSPENDE[D]?|SUSPENSION)\}\}/gc ) {

				#	print " [suspended] ";
				$suspended = 1;
			}
			if ( $line =~ m/\G\s+([\d|?]{4})(-([\d|?]{4}))?/gc ) {
				$year_start = t($1);
				if ( !$2 ) {
					$year_end = t($2);
				}
			}
			if ( $line =~ m/\G\s+\((.+)\)/gc ) {
				$notes = t($1);

			}
			if ( $line =~ m/\G(.+)/gc ) {
				my $rep = trim($1);
				if ( $rep ne "" ) {
					debug( $rep, $line_id );
				}

			}
			$ret{type}  = MOVIE;
			$ret{title} = $title;
			$ret{year} =
			  ( $year_start && $year_start ne "????" ? $year_start : "0" );
			$ret{year_end} =
			  ( $year_end && $year_end ne "????" ? $year_end : "" );
			$ret{vtype}     = $tv;
			$ret{suspended} = $suspended;
			$ret{notes}     = $notes;

			#$movies{$idx++} = \%ret;

		}
	}
	elsif (
		$line =~ m/^\"(.+)\"\s+\(([\d|?]{4})(\/[IVX]{1,5})?\)(\s+\{([^{]+)\})?/g )
	{
		my ( $show, $year, $episode, $notes, $ep_times, $ep_season, $ep_num,$suspended );
		$show    = t($1);
		$year    = t($2);
		$episode = t($5);
		if ($episode) {
			if ( $episode =~ m/(.+)?\(\#(\d+)\.(\d+)\)/ ) {
				if (t($1)){
					$episode   = t($1);
				}
				$ep_season = t($2);
				$ep_num    = t($3);
			}

		}
		
		if ( $line =~ m/\G\s+\{\{(SUSPENDE[D]?|SUSPENSION)\}\}/gc ) {

				#	print " [suspended] ";
				$suspended = 1;
			}

		if ( $line =~ m/\G\s+([\d|?]{4}(-[\d|?]{4})?[,]?)+/gc ) {
			$ep_times = t($1);

		}
		if ( $line =~ m/\G\s+\((.+)\)/cg ) {
			$notes = t($1);

		}

		if ( $line =~ m/\G(.+)/gc ) {
			my $rep = trim($1);
			if ( $rep ne "" ) {
				debug( $rep, $line_id );
			}
		}

		#my $show_ref = $shows{$show};
		$ret{type}  = SHOW;
		$ret{title} = $show;
		$ret{year}  = ( $year && $year ne "????" ? $year : "0" );
		if ($episode) {
			my %episode_hash = (
				title       => $episode,
				notes       => $notes,
				year        => ( $year ne "????" ? $year : "" ),
				years       => $ep_times,
				season      => $ep_season,
				episode_num => $ep_num
			);
			$ret{episode} = \%episode_hash;
		}

	}
	else {

		#debug($line);
		$j++;
	}

	$i++;

	if ( !$begun ) {
		if ( $ret{type} ) {
			$begun = 1;
		}
	}

	return %ret;
}

sub store {
	shift;
	my $mref = shift;
	my %obj  = %$mref;

	my $type = $obj{type};

	if ( !$type ) {
		print_r($mref);
		return;
	}

	if ( $type eq MOVIE ) {

		# save the movie
		my $msql =
"insert into movies (title,year,year_end,vtype,notes) values (?,?,?,?,?)";
		my @params = (
			$$mref{title}, $$mref{year}, $$mref{year_end},
			$$mref{vtype}, $$mref{notes}
		);

		#		my $id = lib::db::insert($msql,@params);
		#		imdb::cache::add($mref,$id);

	}
	else {

		# save the show
		# if the episode is not included, save the show
		my $sid = imdb::cache::get_show( $$mref{title}, $$mref{year} );
		if ( !$sid) {
			my $ssql   = "insert into shows (title,year) values (?,?)";
			my @params = ( $$mref{title}, $$mref{year} );
			my $id     = lib::db::insert( $ssql, @params );

			# retain the reference for future use
			imdb::cache::add( $mref, $id );
		}
		else {
			my $episode = $$mref{episode};

			# save the episode, get the reference from $obj{show}
			my $esql = "insert into show_episodes (sid,title,year,years_active,season,episode_no,notes) values (?,?,?,?,?,?,?)";
			
			my @eparams = (
				$sid, $$episode{title}, $$episode{year}, $$episode{years},
				$$episode{season}, $$episode{episode_num}, $$episode{notes}
			);
			my $eid = lib::db::insert( $esql, @eparams );

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
	print "processed: $i, unprocessed: $j \n";
}
1;
