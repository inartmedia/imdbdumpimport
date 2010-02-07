package imdb::RelStore;

use strict;
use warnings;

BEGIN {
	unshift( @INC, "../" );
}


use lib::db;
use lib::IMDBUtil;

sub new {
	my $class = shift;
	my $obj = { context => undef };
	bless $obj, $class;
	return $obj;
}

sub store_actor {
	shift;
	my $ref = shift;
	if ( !$ref || !$$ref{actor} ) {
		return;
	}

	# check if the actor exists. Get aid from cache
	my $actor = $$ref{actor};
	my $aid = lib::cache::get_actor( $$ref{fullname}, $$ref{gender} );
	if ( !$aid ) {
		my $sql =
		  "insert into actors (fullname,fname,lname,gender) values(?,?,?,?)";
		$aid =
		  lib::db::insert( $sql, $$actor{fullname}, $$actor{fname},
			$$actor{lname}, $$actor{gender} );
		lib::cache::add( $actor, $aid );
	}

	# if not, save him and add to cache

	# save movie info.
	my $movie = $$ref{movie};
	if ( $$movie{type} eq "movie" ) {
		my $mid =
		  imdb::cache::get_movie( $$movie{title}, $$movie{year},
			$$ref{year_suffix} );
		my $sql =
"insert into cast_movie(aid,mid,role,notes,credit_no) values (?,?,?,?,?)";
		lib::db::insert( $sql, $aid, $mid, $$movie{role}, $$movie{notes},
			$$movie{credit_no} );
	}
	elsif ( $$movie{type} eq "show" ) {
		if ( $$movie{episode} ) {
			my $sid =
			  imdb::cache::get_show( $$movie{title}, $$movie{year},
				$$ref{year_suffix} );
			my $episode = $$movie{episode};
			my $eid =
			  imdb::cache::get_episode( $sid, $$episode{title},
				$$episode{season}, $$episode{episode_num} );
			my $sql =
"insert into cast_episode(aid,eid,role,notes,credit_no) values (?,?,?,?,?)";
			lib::db::insert( $sql, $aid, $eid, $$movie{role}, $$movie{notes},
				$$movie{credit_no} );
		}
		else {
			my $sid =
			  imdb::cache::get_show( $$movie{title}, $$movie{year},
				$$ref{year_suffix} );
			my $sql =
"insert into cast_show(aid,sid,role,notes,credit_no) values (?,?,?,?,?)";
			lib::db::insert( $sql, $aid, $sid, $$movie{role}, $$movie{notes},
				$$movie{credit_no} );
		}
	}

}

sub store_actress {

	store_actor @_;
}

sub store_genre {
	shift;
	my $ref = shift;
	if ( !$$ref{type} ) {
		print_r($ref);
		return;
	}
	my $id = imdb::cache::get_genre( $$ref{genre} );
	if ( !$id ) {
		my $lsql   = "insert into genre(name) values(?)";
		my @lparam = ( $$ref{genre} );
		$id = db::insert( $lsql, @lparam );
		imdb::cache::add( $$ref{genre}, $id );
	}

	if ( $$ref{type} eq "movie" ) {
		my $mid =
		  imdb::cache::get_movie( $$ref{title}, $$ref{year},
			$$ref{year_suffix} );
		my $mlsql = "insert into movie_genre(mid,gid) values (?,?)";
		my @mparams = ( $mid, $id );
		lib::db::insert( $mlsql, @mparams );
	}
	else {
		my $sid =
		  imdb::cache::get_show( $$ref{title}, $$ref{year},
			$$ref{year_suffix} );
		my $ssql = "insert into show_genre(sid,gid) values(?,?)";
		my @sparam = ( $sid, $id );
		lib::db::insert( $ssql, @sparam );
	}

}

sub store_language {
	shift;
	my $ref = shift;

	if ( !$$ref{type} ) {
		print_r($ref);
		return;
	}

	my $id = imdb::cache::get_language( $$ref{language} );
	if ( !$id ) {
		my $lsql   = "insert into language(name) values(?)";
		my @lparam = ( $$ref{language} );
		$id = db::insert( $lsql, @lparam );
		imdb::cache::add( $$ref{language}, $id );
	}

	if ( $$ref{type} ) {
		if ( $$ref{type} eq "movie" ) {
			my $mid =
			  imdb::cache::get_movie( $$ref{title}, $$ref{year},
				$$ref{year_suffix} );
			my $mlsql =
			  "insert into movie_language(mid,lid,notes) values (?,?,?)";
			my @mparams = ( $mid, $id, $$ref{language_notes} );
			lib::db::insert( $mlsql, @mparams );
		}
		else {
			if ( $$ref{episode} ) {
				my $sid =
				  imdb::cache::get_show( $$ref{title}, $$ref{year},
					$$ref{year_suffix} );
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
				my $sid =
				  imdb::cache::get_show( $$ref{title}, $$ref{year},
					$$ref{year_suffix} );
				my $ssql =
				  "insert into show_language(sid,lid,notes) values(?,?,?)";
				my @sparam = ( $sid, $id, $$ref{language_notes} );
				lib::db::insert( $ssql, @sparam );
			}
		}
	}

}

sub store_movie {
	shift;
	my $mref = shift;
	my %obj  = %$mref;
	my $lid  = shift;

	my $type = $obj{type};

	if ( !$type ) {
		return;
	}

	if ( $type eq "movie" ) {

		# save the movie
		my $msql =
"insert into movies (title,year,year_end,vtype,notes,year_suffix) values (?,?,?,?,?,?)";
		my @params = (
			$$mref{title}, $$mref{year}, $$mref{year_end}, $$mref{vtype},
			$$mref{notes}, $$mref{year_suffix}
		);

		my $id = lib::db::insert( $msql, @params );
		imdb::cache::add( $mref, $id );

	}
	else {

		# save the show
		# if the episode is not included, save the show
		my $sid = imdb::cache::get_show( $$mref{title}, $$mref{year} );
		if ( !$sid ) {
			my $ssql =
			  "insert into shows (title,year,year_suffix) values (?,?,?)";
			my @params = ( $$mref{title}, $$mref{year}, $$mref{year_suffix} );
			my $id = lib::db::insert( $ssql, @params );

			# retain the reference for future use
			imdb::cache::add( $mref, $id );
		}
		elsif ( $$mref{episode} ) {
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
	shift;
	my $movie = shift;
	if ( !$movie ) {
		return;
	}
	if ( !$$movie{type} ) {
		return;
	}

	if ( $$movie{type} eq "movie" ) {

		my $mid =
		  imdb::cache::get_movie( $$movie{title}, $$movie{year},
			$$movie{year_suffix} );
		my $sql =
"update movies set rating = ?, num_votes=?, distribution=? where mid = ?";
		lib::db::execute_sql( $sql, $$movie{rating}, $$movie{num_votes},
			$$movie{distribution}, $mid );
	}
	elsif ( $$movie{type} eq "show" ) {
		if ( $$movie{episode} ) {

			my $sid =
			  imdb::cache::get_show( $$movie{title}, $$movie{year},
				$$movie{year_suffix} );
			my $episode = $$movie{episode};
			my $eid =
			  imdb::cache::get_episode( $sid, $$episode{title},
				$$episode{season}, $$episode{episode_num} );
			my $sql =
"update show_episodes set rating = ?, num_votes=?, distribution=? where eid = ?";
			lib::db::execute_sql( $sql, $$movie{rating}, $$movie{num_votes},
				$$movie{distribution}, $eid );
		}
		else {
			my $sid =
			  imdb::cache::get_show( $$movie{title}, $$movie{year},
				$$movie{year_suffix} );
			my $sql =
"update shows set rating = ?, num_votes=?, distribution=? where sid = ?";
			lib::db::execute_sql( $sql, $$movie{rating}, $$movie{num_votes},
				$$movie{distribution}, $sid );
		}
	}

}
1;

