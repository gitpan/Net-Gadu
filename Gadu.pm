package Net::Gadu;

use 5.006;
use warnings;
use Socket;
use strict;

require Exporter;
require DynaLoader;
use AutoLoader qw(AUTOLOAD);

our @ISA = qw(Exporter DynaLoader);
our %EXPORT_TAGS = ( 'all' => [ qw() ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	
);
our $VERSION = '0.10';
our $EVENT_NONE = 0;
our $EVENT_MSG = 1;
our $EVENT_NOTIFY = 2;
our $EVENT_NOTIFY_DESCR = 3;
our $EVENT_STATUS = 4;
our $EVENT_ACK = 5;
our $EVENT_PONG = 6; 
our $EVENT_CONN_FAILED = 7;
our $EVENT_CONN_SUCCESS = 8;
our $EVENT_DISCONNECT = 9;

bootstrap Net::Gadu $VERSION;


sub new {
    my ($c, %args) = @_;
    my $class = ref($c) || $c;
    if (!exists($args{server})) { $args{server} = "217.17.41.88"; }
    if (!exists($args{async})) { $args{async} = 0; }
    bless \%args, $class;
}

sub set_server {
    my ($cl,$server) = @_;
    $cl->{server} = $server;
}

sub search {
    my ($cl,$nickname,$first_name,$last_name,$city,$gender,$active) = @_;
    my %gd = ("male" => 2, "female" => 1, "none" => 0);
    return Net::Gadu::gg_search($nickname,$first_name,$last_name,$city,$gd{$gender},$active);
}

sub search_uin {
    my ($cl,$uin,$active) = @_;
    return Net::Gadu::gg_search_uin($uin,$active);
}

sub login {
    my ($cl,$uin,$password) = @_;
    $cl->{uin}=$uin;
    $cl->{password}=$password;
    $cl->{session} = Net::Gadu::gg_login($cl->{uin},$cl->{password},$cl->{async},$cl->{server});
}

sub get_event {
    my $cl = shift;
    return Net::Gadu::gg_get_event($cl->{session});
}

sub check_event {
    my $cl = shift;
    return Net::Gadu::gg_check_event($cl->{session});
}

sub ping {
    my $cl = shift;
    return Net::Gadu::gg_ping($cl->{session});
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

sub send_message_chat {
    my ($cl,$receiver,$message) = @_;
    return Net::Gadu::gg_send_message($cl->{session},0x0008,$receiver,$message);
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

Net::Gadu - Interfejs do biblioteki libgadu.so (czesc ekg)

=head1 DESCRIPTION

Bardzo wstepna i testowa wersja modulu, ale chyba dziala.

Wykorzystuje biblioteke libgadu.so ktora jest czescia projektu Ekg ( http://dev.null.pl/ekg/ )
Aby ja otrzymac nalezy skompilowac ekg z opcja --with-shared. Jesli uzywasz ekg z pakietu prawdopodobnie
biblioteka ta jest automatycznie instalowana w systemie.

=head1 DOWNLOAD

http://krzak.linux.net.pl/perl/Net-Gadu-0.9.tar.gz

=head1 METHODS

Dostepne metody :

=over 4

=item $gg = new Net::Gadu(server => "server_ip")

    opcjonalny parametr :
    server => "11.11.11.11"  (ip alternatywnego serwera)
    async => 1 lub 0   (komunikacja asynchroniczna)


=item $gg->login(uin, password);

Polaczenie z serwerem i zalogowanie.


=item $gg->logoff();

Zakonczenie sesji.


=item $gg->send_message(receiver_uin, message);

Wysyla wiadomosc pod podany UIN.


=item $gg->send_message_chat(receiver_uin, message);

Wysyla wiadomosc pod podany UIN.


=item $gg->set_available();

Ustawia status na dostepny, podobne funkcje : set_busy(), set_invisible(), set_not_available().


=item $gg->search($nickname,$first_name,$last_name,$city,$gender,$active)

    $gender = "male" lub "female" lub "none")
    $active = 1 lub 0


=item $gg->search_uin($uin,$active)
    
    szuka uzytkownika o podanym UIN 
    (active oznacza czy ma szukac posrod aktywnych czy nie)


=item $gg->check_event()

    Sprawdza czy zaszlo jakies zdarzenie (przydatne przy polaczeniu asynchronicznym zwlaszcza)
    

=item $gg->get_event()

    Zwraca dane ze zdarzenia ktore zaszlo, zwracany jest hasz np :
	$e = $gg_event();
	
    $e->{type} zawiera kod ostatniego zdarzenia
    
	$Net::Gadu::EVENT_MSG
	        $e->{message}  # tresc wiadomosci
		$e->{sender}   # uin wysylajacego
		$e->{msgclass}    # typ wiadomosci

	$Net::Gadu::EVENT_ACK	    # potwierdzenie wyslania wiadomosci
	        $e->{recipient}
		$e->{status}
		$e->{seq}

	$Net::Gadu::EVENT_STATUS    # zmiana statusu
	        $e->{uin}
		$e->{status}
		$e->{descr}

    Dostepne kody zdarzen :
    
    $Net::Gadu::EVENT_NONE
    $Net::Gadu::EVENT_MSG
    $Net::Gadu::EVENT_NOTIFY
    $Net::Gadu::EVENT_NOTIFY_DESCR
    $Net::Gadu::EVENT_STATUS
    $Net::Gadu::EVENT_ACK
    $Net::Gadu::EVENT_PONG
    $Net::Gadu::EVENT_CONN_FAILED
    $Net::Gadu::EVENT_CONN_SUCCESS 
    $Net::Gadu::EVENT_DISCONNECT


=back

=head1 EXAMPLES

=over 4

    #!/usr/bin/perl

    use Net::Gadu;

    my $gg = new Net::Gadu(async=>1);

    # SEARCH
    my $res = $gg->search("","Ania","","","female",0);
    foreach my $a (@{$res}) {
        print $a->{nickname}." ".$a->{uin}." ".$a->{first_name}." ".$a->{last_name}." ".$a->{city}." ".$a->{born}." ".$a->{active}."\n";
    }

    #print ($res->[1]->{uin});
    #print ($res->[1]->{first_name});
    #print ($res->[1]->{last_name});

    ## LOGIN
    $gg->login("12121212","password") or die "Login error\n";

    ## EVENTS this example, after successful login change status, send message and logout
    while (1) {
      while ($gg->check_event() == 1) {

	my $e = $gg->get_event();

	my $type = $e->{type};

	if ($type == $Net::Gadu::EVENT_CONN_FAILED) {
	    die "Connection failed";
	}
	
	if ($type == $Net::Gadu::EVENT_CONN_SUCCESS) {
	    $gg->set_available();
	    $gg->send_message_chat("42112","dziekuje za Net::Gadu");
	}

	if ($type == $Net::Gadu::EVENT_MSG) {
	    print $e->{message}." ".$e->{sender}."\n";
	}
	

	if ($type == $Net::Gadu::EVENT_ACK) {
	    $gg->logoff();
	}

      }
    }

=back

=head1 AUTHOR

Marcin Krzyzanowski krzak@linux.net.pl
GG: 42112

=head1 SEE ALSO

    http://dev.null.pl/ekg/
    http://www.gadu-gadu.pl/

=cut
