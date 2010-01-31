package lib::db;

#use strict;
use warnings;
BEGIN {
	unshift( @INC, "../" );
}

use lib::IMDBUtil;
use DBI;
use DBI qw(:sql_types);

our @EXPORT = ('disconnect_from_database','execute_sql','connect_to_database','commit','insert');

our $conn;

# Connect to the database
sub connect_to_database {
	my ($connStr,$u,$p) = @_;
	$conn = DBI->connect( $connStr, $u, $p ,{AutoCommit => 0}) or die ;
}

sub commit{
	$conn->commit;
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

sub insert {
	my $sql = shift;
	my @params = @_;
		
	my $stm = $conn->prepare($sql);
	my $i=1;
	foreach my $p (@params){
		if (!$p){
			$stm->bind_param($i++,undef);
		}
		else {
			$stm->bind_param($i++,$p);
		}
		
	} 
	
	$stm->execute or die " cannot execute sql : ".$sql."with params : ".join(" -*- ",@params);
	
	return $conn->{ q{mysql_insertid}};
	
}
1;
