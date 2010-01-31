use strict;
use warnings;

sub test_assign {
	my ( $a, $b, $c ) = ( "a", "", " " );
	if ($a) {
		print "a \n";
	}
	if ($b) {
		print "b \n";
	}
	if ($c) {
		print "c \n";
	}
}

sub test_array {
	my @arr;
	my %hash = ( a => "a", b => "b", c => \@arr );

	push( @{ $hash{c} }, 'c' );

	push( @arr, 'j' );
	
	push (@arr,"");
	my @a2 = ("a" ,"b", "c");
	my %h2 = (a1 =>"a1",a2 =>\@a2);
	
	push(@{$hash{c}},\%h2);

	print_r(\%hash);
	
	return %hash;

}

sub test_pass_ref {
	
	my $ref = shift;
	print $ref, "\n";
	if ( ref($ref) eq 'HASH' ) {
		my %hash = %$ref;
		foreach my $k ( keys %hash ) {
			print $k, " => ", $hash{$k}, "\n";
		}
	}
}

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
sub test_oper {
	my $i = 100;
	if ($i%11 == 0){
		print "aha";
	}
}

sub test_ml{
	my $a  =1;
	my $b = ($a == 1? "0":"1");
	print $b;
	
}
#my %h = test_array;
#print "\n=============================================================================\n";
#print_r(\%h);
test_ml;
