package helper;

use Test::More;
use base 'Exporter';
our @EXPORT = qw(need_root_and_prepare 
		 start_httpd httpd_port
		 urpmi_addmedia urpmi_removemedia urpmi_update
		 urpmi_cmd urpmi urpme
		 urpmi_cfg set_urpmi_cfg_global_options
		 system_
	    );

my $using_root;
sub need_root_and_prepare() {
    if ($< != 0) {
	#- can't test
	pass();
	exit(0);
    }
    -d 'media' or die "02create_pkgs.t not done\n";

    system('rm -rf root');
    isnt(-d 'root', "test root dir can not be removed $!");
    mkdir 'root';
    $using_root = 1;
}

my $server_pid;
sub httpd_port { 6969 }
sub start_httpd() {
    $server_pid = fork();
    if ($server_pid == 0) {
	exec './simple-httpd', $::pwd, "$::pwd/tmp", httpd_port();
	exit 1;
    }
    'http://localhost:' . httpd_port();
}

chdir 't' if -d 't';

mkdir 'tmp';
chomp($::pwd = `pwd`);
my $urpmi_debug_opt = '-q';
#$urpmi_debug_opt = '-v --debug';

sub urpmi_addmedia {
    my ($para) = @_;
    system_("perl -I.. ../urpmi.addmedia $urpmi_debug_opt --urpmi-root $::pwd/root $para");
}
sub urpmi_removemedia {
    my ($para) = @_;
    system_("perl -I.. ../urpmi.removemedia $urpmi_debug_opt --urpmi-root $::pwd/root $para");
}
sub urpmi_update {
    my ($para) = @_;
    system_("perl -I.. ../urpmi.update $urpmi_debug_opt --urpmi-root $::pwd/root $para");
}
sub urpmi_cmd() {
    "perl -I.. ../urpmi $urpmi_debug_opt --urpmi-root $::pwd/root --ignoresize";
}
sub urpmi {
    my ($para) = @_;
    system_(urpmi_cmd() . " $para");
}
sub urpme {
    my ($para) = @_;
    system_("perl -I.. ../urpme --urpmi-root $::pwd/root $para");
}
sub urpmi_cfg() {
    "$::pwd/root/etc/urpmi/urpmi.cfg";
}
sub set_urpmi_cfg_global_options {
    my ($options) = @_;
    require_ok('urpm::cfg');
    ok(my $config = urpm::cfg::load_config(urpmi_cfg()));
    $config->{global} = $options;
    ok(urpm::cfg::dump_config(urpmi_cfg(), $config), 'set_urpmi_cfg_global_options');
}

sub system_ {
    my ($cmd) = @_;
    system($cmd);
    ok($? == 0, $cmd);
}

END { 
    $using_root and system('rm -rf root');
    $server_pid and kill(9, $server_pid);
    system('rm -rf tmp');
}

1;
