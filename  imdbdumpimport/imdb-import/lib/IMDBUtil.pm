package lib::IMDBUtil;

# Functions 'trim', 'ltrim' & 'rtrim' copied from http://www.somacon.com/p114.php
use Exporter;
our @ISA = ('Exporter');
our @EXPORT = ( 'trim', 'ltrim', 'rtrim', 'debug','t','print_r',);
use constant DEBUG => 1;


sub t {
	return trim(shift); 
}
# Perl trim function to remove whitespace from the start and end of the string
sub trim {
	my $string = shift;
	if ( !$string ) {
		return $string;
	}
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
}

# Left trim function to remove leading whitespace
sub ltrim {
	my $string = shift;
	if ( !$string ) {
		return $string;
	}
	$string =~ s/^\s+//;
	return $string;
}

# Right trim function to remove trailing whitespace
sub rtrim {
	my $string = shift;
	if ( !$string ) {
		return $string;
	}
	$string =~ s/\s+$//;
	return $string;
}

# debug method. Just dump on the screen
sub debug {
	if ( !DEBUG ) {
		return;
	}
	my ($line,$lid) = @_;
	
	print "",($lid?$lid." :- ":""),$line, "\n";
}

# Perl equivalent of PHP print_r function
sub print_r {
	use Switch;
	my $ref = shift;
	my $level = shift;
	
	sub pr_level {
		print "  " x shift,shift;
	}
	
	if (!defined($level)){
		$level =0;
	}
	
	my $type = ref($ref);
	if (!$type){
		$type = "VAL";
	}
	
	if (!$ref){
		$type = "UNDEF";
	}
	
	
	switch($type){
		case "UNDEF"{
			print "undef";
		}
		case "HASH"    {
			pr_level(0, "HASH\n");
			pr_level($level,"(\n");
			$level++;
			foreach my $k (sort keys %$ref){
				pr_level($level,"[$k] => ");
				print_r($$ref{$k},$level+1);
				print "\n";
			}
			$level--;
			pr_level( $level,")");
			
		}
		case "ARRAY"   {
			pr_level(0, "ARRAY\n");
			pr_level($level,"(\n");
			$level++;
			my $i = 0;
			foreach my $k (@$ref){
				pr_level($level, "[$i] => ");
				print_r($k,$level+1);
				print "\n";
				$i++;
			}
			$level--;
			pr_level( $level,")");
			
		}
		case "SCALAR"  {
			print scalar $$ref;
		}
		case "VAL"  {
			if ($ref){
				print $ref;
			}
		}
		
		else{
			print "not handled: ",$type,"---> ",$ref,"\n";
		}
	}
}
1;
