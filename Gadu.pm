package Net::Gadu;

use 5.006;
use strict;
use warnings;

require Exporter;
require DynaLoader;
use AutoLoader qw(AUTOLOAD);

our @ISA = qw(Exporter DynaLoader);
our %EXPORT_TAGS = ( 'all' => [ qw() ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	
);
our $VERSION = '0.04';

bootstrap Net::Gadu $VERSION;


sub new {
    my ($c, %args) = @_;
    my $class = ref($c) || $c;
    bless \%args, $class;
}

sub search {
    my ($cl,$nickname,$first_name,$last_name,$city,$gender,$active) = @_;
    my %gd = ("male" => 2, "famale" => 1, "none" => 0);
    return Net::Gadu::gg_search($nickname,$first_name,$last_name,$city,$gd{$gender});
}

sub login {
    my ($cl,$uin,$password) = @_;
    $cl->{uin}=$uin;
    $cl->{password}=$password;
    $cl->{session} = Net::Gadu::gg_login($cl->{uin},$cl->{password},0);
}

sub logoff {
    my $cl = shift;
    Net::Gadu::gg_logoff($cl->{session});
    Net::Gadu::gg_free_session($cl->{session});
}

sub send_message {
    my ($cl,$receiver,$message) = @_;
    return Net::Gadu::gg_send_message($cl->{session},0x0004,$receiver,$message);
}

sub change_status {
    my ($cl,$status) = @_;
    return Net::Gadu::gg_change_status($cl->{session},$status);
}

sub set_available {
    my ($cl,$status) = @_;
    $cl->change_status(0x0002); # GG_STATUS_AVAIL
}

sub set_busy {
    my ($cl,$status) = @_;
    $cl->change_status(0x0003); # GG_STATUS_BUSY
}

sub set_not_available {
    my ($cl,$status) = @_;
    $cl->change_status(0x0001); # GG_STATUS_NOT_AVAIL
}

sub set_invisible {
    my ($cl,$status) = @_;
    $cl->change_status(0x0014); # GG_STATUS_INVISIBLE
}


1;

######################################################

__END__

=head1 NAME

Net::Gadu - Interfes do biblioteki libgadu.so (part of ekg)

=head1 DESCRIPTION

Bardzo wstepna i testowa wersja modulu, ale chyba dziala.

=head1 DOWNLOAD

http://krzak.linux.net.pl/perl/Net-Gadu-0.4.tar.gz

=head1 METHODS

Dostepne metody :

=over 4

=item $gg->login(uin, password);

Polaczenie z serwerem i zalogowanie.

=item $gg->logoff();

Zakonczenie sesji.

=item $gg->send_message(receiver_uin, message);

Wysyla wiadomosc pod podany UIN.

=item $gg->set_available();

Ustawia status na dostepny, podobne funkcje : set_busy(), set_invisible(), set_not_available().

=item $gg->search($nickname,$first_name,$last_name,$city,$gender,$active)

    $gender = ("male","famale","none")
    $active = (1,0)

=back

=head1 EXAMPLES

=over 4

    use Net::Gadu;

    my $gg = new Net::Gadu;

    my $res = $gg->search("","Ania","","","famale",1);
    
    foreach my $a (@{$res}) {
    
	print $a->{nickname}." ".$a->{uin}." ".$a->{first_name}." ".$a->{last_name}." ".$a->{city}." ".$a->{born}."\n";
    
    }

    $gg->login("111111","secretpassword");

    $gg->send_message("332323","this is a test");

    $gg->set_available();
    
    $gg->logoff();

=back

=head1 AUTHOR

Marcin Krzyzanowski krzak@linux.net.pl
GG: 42112

=head1 SEE ALSO

    http://dev.null.pl/ekg/
    http://www.gadu-gadu.pl/

=cut
