package lib::db;

#use strict;
use warnings;
use DBI;
use DBI qw(:sql_types);

our @EXPORT_OK = ('disconnect_from_database','execute_sql','connect_to_database');

our $conn;

# Connect to the database
sub connect_to_database {
	my ($connStr,$u,$p) = @_;
	$conn = DBI->connect( $connStr, $u, $p ) or die ;
}

#disconnect from the database
sub disconnect_from_database {
	$conn->disconnect();
}
#execute a statement, return the executed statement.
sub execute_sql {
	my $sql = shift;
	my @params = @_;
	
	my $stm = $conn->prepare($sql);
	my $i=1;
	foreach my $p (@params){
		$stm->bind_param($i++,$p);
	} 
	
	$stm->execute or die " cannot execute sql : ".$sql;
	return $stm;
}
1;
