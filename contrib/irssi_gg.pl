use Irssi;
use Irssi::UI;
use Net::Gadu;
use strict;

use vars qw($VERSION $MINNGVER);

$VERSION="0.1";
$MINNGVER="0.7";

Irssi::print("Bardzo eksperymentalny modul obslugujacy gadu-gadu dla irssi (www.irssi.org)");
Irssi::print("Korzysta z modulu Net::Gadu (http://krzak.linux.net.pl/perl/perlgadu.html)");
Irssi::print("Autor : Marcin Krzyzanowski <krzak at hakore.com>\n");
Irssi::print("Aby zobaczyc dostepne komendy wpisz /gghelp\n");

if ($Net::Gadu::VERSION < $MINNGVER) { 
    Irssi::print("ZONK : Masz za stara wersje Net::Gadu (".$Net::Gadu::VERSION."), wymagana $MINNGVER");
    Irssi::print("ZONK : Sprawdz http://krzak.linux.net.pl/perl/perlgadu.html");
    }

my $gg = new Net::Gadu(async=>1);
my ($to_tag,$gg_win);
my ($uin,$password);

#czytam config z ~.gg/config
my $configfile = $ENV{'HOME'}."/.gg/config";
if (!(-e $configfile)) { 
    Irssi::print("ZONK : A gdzie masz plik konfiguracyjny ?");
    Irssi::print("ZONK : Spodziewam sie pliku $configfile o formacie :");
    Irssi::print("uin 11111");
    Irssi::print("password haslo");
}

open(F,"<".$configfile);
while (my $l=<F>)  {
    my @kv = split(/ /,$l);
    $kv[1] =~ s/\n//g;
    if ($kv[0] eq "uin") {  $uin = $kv[1] }
    if ($kv[0] eq "password") {  $password = $kv[1]; }
    }
close(F);

#############################

sub cmd_ggcheck {
    my ($uin) = @_;
    my $res = $gg->search_uin($uin,1);
    if (@{$res}->[0]->{active} == 1) {
	$gg_win->print("* ".$uin." jest online",MSGLEVEL_NICKS);
    } else { 
	$gg_win->print("* ".$uin." jest offline",MSGLEVEL_NICKS); 
    }
}


sub timeout_input {
    my $gu = shift;

    if ($gu->check_event() == 1) {
    
	my $e = $gu->get_event();

	my $type = $e->{type};

	if ($type == $Net::Gadu::EVENT_MSG) {
		$gg_win->print(" <- [".$e->{uin}."] ".$e->{message},MSGLEVEL_MSGS);
		return;
	}
	    
	if ($type == $Net::Gadu::EVENT_CONN_SUCCESS) {
		$gg_win->print("* polaczony",MSGLEVEL_PUBLIC);
	        $gu->set_available();
		return;
	}

	if ($type == $Net::Gadu::EVENT_CONN_FAILED) {
		Irssi::timeout_remove($to_tag);
		$gg_win->print("* nie udane polaczenie",MSGLEVEL_PUBLIC);
		return;
	}
    }
}


sub cmd_gglogin {
    my ($data,$server,$witem) = @_;
    $gg->login($uin,$password); 
    $gg_win = Irssi::Windowitem::window_create($witem,1);
    $gg_win->set_active();
    $to_tag = Irssi::timeout_add(1000,\&timeout_input,$gg);
    return;
} 

sub cmd_ggmsg {
    my ($data) = @_;
    my @d = split(/ /,$data);
    $gg->send_message_chat($d[0],$d[1]);
    $gg_win->(" -> [".$d[0]."] ".$d[1],MSGLEVEL_MSGS);
}

sub cmd_ggavail {
    my ($data) = @_;
    $gg->set_available();
    $gg_win->print("* Jestes oznaczony jako dostepny",MSGLEVEL_MODES)
}

sub cmd_gglogoff {
    my ($data) = @_;
    $gg->logoff();
    $gg_win->print("* Wylogowany",MSGLEVEL_QUITS)
}

sub cmd_gghelp {
    Irssi::print("/gglogin       - loguje do serwera gadu-gadu");
    Irssi::print("/gglogoff      - wylogowanie");
    Irssi::print("/ggavail       - ustawia stan na dostepny");
    Irssi::print("/ggmsg UIN MSG - wysyla tresc MSG do UIN");
    Irssi::print("/ggcheck UIN   - sprawdza czy UIN jest zalogowany do serwera gadu-gadu");
    
}

Irssi::command_bind('gglogoff','cmd_gglogoff');
Irssi::command_bind('ggavail','cmd_ggavail');
Irssi::command_bind('gglogin','cmd_gglogin');
Irssi::command_bind('ggcheck','cmd_ggcheck');
Irssi::command_bind('ggmsg','cmd_ggmsg');
Irssi::command_bind('gghelp','cmd_gghelp');
