package imdb::RelStore;

use strict;
use warnings;

BEGIN {
	unshift( @INC, "../" );
}

use Exporter;
our @ISA    = qw(Exporter);
our @EXPORT = ();

use lib::db;
use lib::IMDBUtil;

sub store_actor {

}

sub store_actress {
	store_actor(shift);
}

sub store_genre {
	my $ref = shift;
	if ( !$$ref{type} ) {
		print_r($ref);
		return;
	}
	my $id = imdb::cache::get_genre( $$ref{genre} );
	if ( $id == -1 ) {
		my $lsql   = "insert into genre(name) values(?)";
		my @lparam = ( $$ref{genre} );
		$id = db::insert( $lsql, @lparam );
		imdb::cache::add( $$ref{genre}, $id );
	}

	if ( $$ref{type} eq "movie" ) {
		my $mid     = imdb::cache::get_movie( $$ref{title}, $$ref{year} );
		my $mlsql   = "insert into movie_genre(mid,gid) values (?,?)";
		my @mparams = ( $mid, $id );
		lib::db::insert( $mlsql, @mparams );
	}
	else {
		my $sid    = imdb::cache::get_show( $$ref{title}, $$ref{year} );
		my $ssql   = "insert into show_genre(sid,gid) values(?,?)";
		my @sparam = ( $sid, $id );
		lib::db::insert( $ssql, @sparam );
	}

}

sub store_language {
		my $ref = shift;

	if ( !$$ref{type} ) {
		print_r($ref);
		return;
	}

	my $id = imdb::cache::get_language( $$ref{language} );
	if ( $id == -1 ) {
		my $lsql   = "insert into language(name) values(?)";
		my @lparam = ( $$ref{language} );
		$id = db::insert( $lsql, @lparam );
		imdb::cache::add( $$ref{language}, $id );
	}

	if ( $$ref{type} ) {
		if ( $$ref{type} eq "movie" ) {
			my $mid = imdb::cache::get_movie( $$ref{title}, $$ref{year} );
			my $mlsql =
			  "insert into movie_language(mid,lid,notes) values (?,?,?)";
			my @mparams = ( $mid, $id, $$ref{language_notes} );
			lib::db::insert( $mlsql, @mparams );
		}
		else {
			if ( $$ref{episode} ) {
				my $sid = imdb::cache::get_show( $$ref{title}, $$ref{year} );
				my $episode = $$ref{episode};
				my $eid =
				  imdb::cache::get_episode( $sid, $$episode{title},
					$$episode{season}, $$episode{episode_num} );
				my $esql =
				  "insert into episode_language(eid,lid,notes) values (?,?,?)";
				my @eparams = ( $eid, $id, $$ref{language_notes} );
				lib::db::insert( $esql, @eparams );
			}
			else {
				my $sid = imdb::cache::get_show( $$ref{title}, $$ref{year} );
				my $ssql =
				  "insert into show_language(sid,lid,notes) values(?,?,?)";
				my @sparam = ( $sid, $id, $$ref{language_notes} );
				lib::db::insert( $ssql, @sparam );
			}
		}
	}
	

}

sub store_movie {
	my $mref = shift;
	my %obj  = %$mref;
	my $lid  = shift;

	my $type = $obj{type};

	if ( !$type ) {
		print "[$lid] HHHH ";
		print_r($mref);
		return;
	}

	if ( $type eq "movie") {
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

sub store_rating {

}

