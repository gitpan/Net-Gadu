#
# Net::Gadu 
# 
# Copyright (C) 2002-2006 Marcin Krzy¿anowski
# http://www.hakore.com
# 
# This program is free software; you can redistribute it and/or modify 
# it under the terms of the GNU Lesser General Public License as published by 
# the Free Software Foundation; either version 2 of the License, or 
# (at your option) any later version. 
# 
# This program is distributed in the hope that it will be useful, 
# but WITHOUT ANY WARRANTY; without even the implied warranty of 
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the 
# GNU General Public License for more details. 
# 
# You should have received a copy of the GNU Lesser General Public License 
# along with this program; if not, write to the Free Software 
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA 

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

our $VERSION = '1.7';


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
our $EVENT_SEARCH_REPLY = 19;

our $STATUS_NOT_AVAIL = 0x0001;	
our $STATUS_NOT_AVAIL_DESCR = 0x0015;
our $STATUS_AVAIL = 0x0002;
our $STATUS_AVAIL_DESCR = 0x0004;
our $STATUS_BUSY = 0x0003;
our $STATUS_BUSY_DESCR = 0x0005;
our $STATUS_INVISIBLE = 0x0014;
our $STATUS_INVISIBLE_DESCR = 0x0016;
#our $STATUS_BLOCKED = 0x0006

bootstrap Net::Gadu $VERSION;


sub new {
    my ($c, %args) = @_;
    my $class = ref($c) || $c;
    if (!exists($args{server})) { $args{server} = "217.17.41.88"; }
    if (!exists($args{async})) { $args{async} = 1; }
    bless \%args, $class;
}

sub set_server {
    my ($cl,$server) = @_;
    $cl->{server} = $server;
}

sub search {
    my ($cl,$uin,$nickname,$first_name,$last_name,$city,$gender,$active) = @_;
    my %gd = ("male" => 2, "female" => 1, "none" => 0);
    return Net::Gadu::gg_search($cl->{session},$uin,$nickname,$first_name,$last_name,$city,$gd{$gender},$active);
}

sub login {
    my ($cl,$uin,$password) = @_;
    $cl->{uin}=$uin;
    $cl->{password}=$password;
    $cl->{session} = Net::Gadu::gg_login($cl->{uin},$cl->{password},$cl->{async},$cl->{server});
    return $cl->{session};
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
    Net::Gadu::gg_logoff($cl->{session}) if ($cl->{session});
    Net::Gadu::gg_free_session($cl->{session}) if ($cl->{session});
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

sub change_status_descr {
    my ($cl,$status,$descr) = @_;
    return Net::Gadu::gg_change_status_descr($cl->{session},$status,$descr);
}

sub set_available {
    my ($cl,$status) = @_;
    $cl->change_status($Net::Gadu::STATUS_AVAIL); # GG_STATUS_AVAIL
}

sub set_busy {
    my ($cl,$status) = @_;
    $cl->change_status($Net::Gadu::STATUS_BUSY); # GG_STATUS_BUSY
}

sub set_not_available {
    my ($cl,$status) = @_;
    $cl->change_status($Net::Gadu::STATUS_NOT_AVAIL); # GG_STATUS_NOT_AVAIL
}

sub set_invisible {
    my ($cl,$status) = @_;
    $cl->change_status($Net::Gadu::STATUS_INVISIBLE); # GG_STATUS_INVISIBLE
}


1;

######################################################

__END__

=head1 NAME

Net::Gadu - Interfejs do biblioteki libgadu.so dla protoko³u Gadu-Gadu 

=head1 DESCRIPTION

Wykorzystuje bibliotekê libgadu.so która jest czesci± projektu EKG.
Aby zaintalowaæ libgadu.so nale¿y skompilowaæ EKG z opcj± --with-shared. Je¶li u¿ywasz EKG z pakietu prawdopodobnie
biblioteka ta zosta³a zainstalowana. Szczegó³owe informacje znajdziesz na stronie projektu EKG - http://ekg.chmurka.net/
Do zbudowania pakietu potrzeba jest zainstalowana biblioteka z prefixem /usr lub /usr/local , jesli lokalizacja jest niestandardowa mozna wyedytowac plik Makefile.PL podajac wlasciwe lokalizacje

=head1 DOWNLOAD

http://www.cpan.org/modules/by-module/Net/Net-Gadu-1.7.tar.gz


=head1 SUBVERSION

$ svn co http://svn.hakore.com/netgadu/trunk


=head1 METHODS

Dostepne metody :

=over 4

=item $gg = new Net::Gadu()

    opcjonalny parametr :
    server => "11.11.11.11"  (ip alternatywnego serwera)
    async => 1 lub 0   (komunikacja asynchroniczna lub nie)


=item $gg->login(uin, password);

Po³±czenie z serwerem oraz logowanie do serwera.


=item $gg->logoff();

Wylogowanie z serwera i zakoñczenie sesji.


=item $gg->send_message(receiver_uin, message);

Wysy³a wiadomo¶æ pod wskazany numer UIN.


=item $gg->send_message_chat(receiver_uin, message);

Wysy³a wiadomo¶æ pod wskazany numer UIN.


=item $gg->set_available();

Ustawia status na dostepny. Podobne funkcje : set_busy(), set_invisible(), set_not_available(), change_status().


=item $gg->change_status();

Zmiana statusu mo¿liwa na jeden z:

    $Net::Gadu::STATUS_NOT_AVAIL
    $Net::Gadu::STATUS_AVAIL
    $Net::Gadu::STATUS_BUSY
    $Net::Gadu::STATUS_INVISIBLE


=item $gg->change_status_descr();

Zmiana statusu z opisem, mo¿liwa na jeden z:

    $Net::Gadu::STATUS_NOT_AVAIL_DESCR
    $Net::Gadu::STATUS_AVAIL_DESCR
    $Net::Gadu::STATUS_BUSY_DESCR
    $Net::Gadu::STATUS_INVISIBLE_DESCR


=item $gg->search($uin,$nickname,$first_name,$last_name,$city,$gender,$active)

    Wyszukiwanie, jesli parametr ma warto¶æ "", czyli pust± wtedy to pole nie
    jest brane pod uwagê podczas wyszukiwania.
    Zwracana jest tablica ze szczego³owymi informacjami.
    Odpowied¼ nale¿y odebraæ po otrzymaniu zdarzenia $Net::Gadu::EVENT_SEARCH_REPLY.
    Przyk³adowe u¿ycie oraz wynik znajduj± siê w przyk³adowym
    programie "ex/ex1" dostarczanym wraz ze ¼ród³ami.

    Uwaga:
    $gender = "male" lub "female" lub "none")
    $active = 1 lub 0


=item $gg->check_event()

    Sprawdza czy zasz³o jakie¶ zdarzenie (szczegolnie istotne przydatne przy po³aczeniu asynchronicznym)
    

=item $gg->get_event()

    Zwraca informacje o zdarzeniu które mia³o miejsce, zwracany jest hasz np :
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

	$Net::Gadu::EVENT_SEARCH_REPLY
		$e->{results}

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
    $Net::Gadu::EVENT_SEARCH_REPLY


=back

=head1 EXAMPLES

=over 4

    #!/usr/bin/perl

    use Net::Gadu; 
    use Data::Dumper;

    my $gg = new Net::Gadu(async=>1);

    ## LOGIN
    my $ret = $gg->login("0123456","password") or die "Login error\n";
    if (!$ret) {
	print "Login error\n";
	return;
    }


    ## EVENTS(this example, after successful login change status, send message and logout
    while (1) {
     while ($gg->check_event() == 1) {

	my $e = $gg->get_event();

	my $type = $e->{type};
	
	if ($type == $Net::Gadu::EVENT_CONN_FAILED) {
	    die "Connection failed";
	}
	
	if ($type == $Net::Gadu::EVENT_CONN_SUCCESS) {
	    $gg->set_available();
	    # Send THANKS to author
	    $gg->send_message_chat("42112","dziekuje za Net::Gadu");
	    
	    # SEARCH INIT
	    $gg->search("","krzak","","","","male",0);
	}

	if ($type == $Net::Gadu::EVENT_MSG) {
	    print $e->{message}." ".$e->{sender}."\n";
	}

	if ($type == $Net::Gadu::EVENT_SEARCH_REPLY) {
	    # SEARCH RESULT
	    print Dumper($e->{results});
	    $gg->logoff();
	    exit(1);
	}

	if ($type == $Net::Gadu::EVENT_ACK) {
	}
     }
    }

=back

=head1 AUTHOR

Marcin Krzy¿anowski, http://www.hakore.com/

=head1 LICENCE

Lesser General Public License

=head1 SEE ALSO

    http://www.gadu-gadu.pl/
    http://ekg.chmurka.net/
    http://www.gnugadu.org/
    http://www.hakore.com/

=cut
