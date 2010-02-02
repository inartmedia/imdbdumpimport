package imdb::genres;

BEGIN {
	unshift( @INC, "../" );

}

use lib::IMDBUtil;
use imdb::cache;

our $begun = 0;

our $line;
our $c =0; 

sub new {
	my $class = shift;
	my $obj = { context => undef };
	bless $obj, $class;
	return $obj;
}

sub is_store_ready {
	shift;
	my $ref = shift;
	if ($begun){
		if (!$$ref{type}){
			return 0;
		}
		return 1;	
	}
	return 0;
}

sub parse {
	shift;
	my $line      = shift;
	my $line_id   = shift;
	my @line_frgs = split( /\t+/, $line );

	if ( !$begun ) {
		if ($#line_frgs == 0 && $line_frgs[0] =~ m/THE GENRES LIST/){
			$begun =1;
		}
		return;
	}

	my %ret;
	if ( $#line_frgs + 1 >= 2 ) {
		%ret = lib::IMDBUtil::parse_movie_info( shift @line_frgs );
		$ret{genre} = t( shift(@line_frgs) );
		my $s = t( shift(@line_frgs) );
		if ( $s && $s ne "" ) {
			debug( $s, $line_id );
		}
	}
	return %ret;
}

sub store {

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

# debugging helper methods, to be deleted once everything is finished.
sub how_many_lines {
	return -1;
}

sub print_info {
}

sub set_context {

}
1;
