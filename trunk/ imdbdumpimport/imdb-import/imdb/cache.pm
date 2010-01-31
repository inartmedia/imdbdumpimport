package imdb::cache;

use strict;
use warnings;

use Exporter;
our @ISA       = qw(Exporter);
our @EXPORT_OK = qw(add get);

our %movies;
our %shows;

# Implementation of a two level cache. Just holds movies and show titles indexed by year
# Used to lookup FK values for shows and movies.
# If year is not defined, use 1111 as key.
sub add {
	my $ref = shift;
	my $id  = shift;
	my $y   = $$ref{year};
	if ( !$y ) {
		$y = "1111";
	}
	if ( $$ref{type} eq "movie" ) {
		$movies{$y}{ $$ref{title} } = $id;
	}
	else {
		$shows{$y}{ $$ref{title} } = $id;
	}

}

sub load {

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
1;
