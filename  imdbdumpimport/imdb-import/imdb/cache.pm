package imdb::cache;

use strict;
use warnings;

BEGIN {
	unshift( @INC, "../" );

}

use Exporter;
our @ISA       = qw(Exporter);
our @EXPORT_OK = qw(add get);

use constant NOT_PRESENT => -1;
use Switch;
our %movies;
our %shows;
our %language;
our %genre;
our %episodes;    #{sid}{episode title}{season}{episode#}

# Implementation of a two level cache. Just holds movies and show titles indexed by year
# Used to lookup FK values for shows and movies.
# If year is not defined, use 1111 as key.
sub add {
	my $ref = shift;
	my $id  = shift;

	switch ( $$ref{type} ) {
		case "movie" {
			my $y = $$ref{year};
			if ( !$y ) {
				$y = "1111";
			}
			$movies{$y}{ $$ref{title} } = $id;

		}
		case "show" {
			my $y = $$ref{year};
			if ( !$y ) {
				$y = "1111";
			}
			$shows{$y}{ $$ref{title} } = $id;

		}
		case "episode" {
			my ( $sid, $t, $s, $e ) =
			  ( $$ref{sid}, $$ref{title}, $$ref{season}, $$ref{episode_no} );
			if ( !$s ) {
				$s = 1;
			}
			if (!$e){
				$e =1;
			}
			$episodes{$sid}{$t}{$s}{$e} = $id;
		}
		case "genre" {
			$genre{ $$ref{genre} } = $id;
		}
		case "language" {
			$language{ $$ref{language} } = $id;
		}
	}
}

sub load {

	# Load language
	my $lang_stm = lib::db::execute_sql("select id,name from language");
	while ( my @r = $lang_stm->fetchrow_array ) {
		$language{ $r[1] } = $r[0];
	}

	# Load Genre
	my $genre_stm = lib::db::execute_sql("select id,name from genre");
	while ( my @r = $genre_stm->fetchrow_array ) {
		$genre{ $r[1] } = $r[0];
	}

	# Load movie
	my $movie_stm = lib::db::execute_sql("select mid,title,year from movies");
	while ( my @r = $movie_stm->fetchrow_array ) {
		my $y = $r[2];
		if (!$y){
			$y = "1111";
		}
		$movies{ $r[1] }{ $y} = $r[0];
	}

	# Load movie
	my $show_stm = lib::db::execute_sql("select sid,title,year from shows");
	while ( my @r = $show_stm->fetchrow_array ) {
		my $y = $r[2];
		if (!$y){
			$y = "1111";
		}
		$shows{ $r[1] }{ $y } = $r[0];
	}
}

sub get_language {
	my $id = $language{shift};
	$id = ( $id ? $id : NOT_PRESENT );
	return $id;
}

sub get_genre {
	my $id = $genre{shift};
	$id = ( $id ? $id : NOT_PRESENT );
	return $id;
}

sub get_movie {
	my ( $m, $y ) = @_;
	if ( !$y ) {
		$y = "1111";
	}
	return $movies{$y}{$m};
}

sub get_show {
	my ( $m, $y ) = @_;
	if ( !$y ) {
		$y = "1111";
	}
	return $shows{$y}{$m};
}

sub get_episode {
	my ( $sid, $t, $s, $e ) = @_;
	if ( !$s ) {
		$s = 1;
		$e = 1;
	}
	my $id = $episodes{$sid}{$t}{$s}{$e};
	if ( !$id ) {
		$id = NOT_PRESENT;
	}
	return $id;
}
1;
