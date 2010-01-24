package IMDBUtil;
# copied from http://www.somacon.com/p114.php
use Exporter;
our @ISA= ('Exporter');
our @EXPORT_OK = ('trim','ltrim','rtrim','debug');
use constant DEBUG => 0;
# Perl trim function to remove whitespace from the start and end of the string
sub trim
{
	my $string = shift;
	if (!$string){
		return $string;
	}
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
}
# Left trim function to remove leading whitespace
sub ltrim
{
	my $string = shift;
	$string =~ s/^\s+//;
	return $string;
}
# Right trim function to remove trailing whitespace
sub rtrim
{
	my $string = shift;
	$string =~ s/\s+$//;
	return $string;
}
# debug method. Just dump on the screen
sub debug {
	if (!DEBUG){
		return;
	}
	print shift,"\n";
}
1;