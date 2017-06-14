#+-----------+---------------+------+-----+---------+-------+
#| Field     | Type          | Null | Key | Default | Extra |
#+-----------+---------------+------+-----+---------+-------+
#| insertime | timestamp(14) | YES  |     | NULL    |       |
#| nick      | char(10)      | YES  |     | NULL    |       |
#| target    | char(255)     | YES  |     | NULL    |       |
#| line      | char(255)     | YES  |     | NULL    |       |
#+-----------+---------------+------+-----+---------+-------+


use DBI;
use Irssi;
use Irssi::Irc;

use vars qw($VERSION %IRSSI);

$VERSION = "1.0.1";
%IRSSI = (
        authors     => "Riku Voipio, lite, @r3l0z",
        contact     => "riku.voipio\@iki.fi, @r3l0z",
        name        => "irssi recon",
        description => "logs url's(& more) to mysql database",
        license     => "GPLv2",
        url         => " https://github.com/shekkbuilder/ircrecon -- original: http://nchip.ukkosenjyly.mine.nu/irssiscripts/",
    );

$dsn = 'DBI:mysql:ircrecon_db:localhost';
$db_user_name = 'ircrecon';
$db_password = 'n0t_seriou5';
sub cmd_logurl{
        my ($server, $data, $nick, $mask, $target) = @_;
        $d = $data;
        #order: http,www,http++,IP ADDRESS, Hex Value, Email Address,password,username,CC
        if (($d =~ /(.{1,2}tp\:\/\/.+)/) or ($d =~ /(www\..+)/) or ($d =~ /(([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$)/) or ($d =~ /([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})/) or ($d =~ /(#?([a-f0-9]{6}|[a-f0-9]{3})$)/) or ($d =~ /(^([a-z0-9_\.-]+)@([\da-z\.-]+)\.([a-z\.]{2,6})$)/) or ($d =~ /([a-zA-Z0-9_.-]+@[a-zA-Z0-9-]+.[a-zA-Z0-9-.]+)/) or ($d =~ /([a-z0-9_-]{3,16}$)/) or ($d =~ /([a-z0-9_-]{6,18})$/) or ($d =~ /((?:4[0-9]{12}(?:[0-9]{3})?|5[1-5][0-9]{14}|6(?:011|5[0-9][0-9])[0-9]{12}|3[47][0-9]{13}|3(?:0[0-5]|[68][0-9])[0-9]{11}|(?:2131|1800|35\d{3})\d{11}))/ )) {
                db_insert($nick, $target, $1);
        }
        return 1;
}

sub cmd_own {
        my ($server, $data, $target) = @_;
        return cmd_logurl($server, $data, $server->{nick}, "", $target);
}
sub cmd_topic {
        my ($server, $target, $data, $nick, $mask) = @_;
        return cmd_logurl($server, $data, $nick, $mask, $target);
}

sub db_insert {
        my ($nick, $target, $line)=@_;
        my $dbh = DBI->connect($dsn, $db_user_name, $db_password);
        my $sql="insert into event (insertime, nick, target,line) values (NOW()".",". $dbh->quote($nick) ."," . $dbh->quote($target) ."," . $dbh->quote($line) .")";
        my $sth = $dbh->do($sql);
        $dbh->disconnect();
        }
Irssi::command_bind("topicz", "cmd_logurl");
Irssi::signal_add_last('message public', 'cmd_logurl');
Irssi::signal_add_last('message own_public', 'cmd_own');
Irssi::signal_add_last('message topic', 'cmd_topic');

Irssi::print("loaded $dsn");
