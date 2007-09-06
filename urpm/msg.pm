package urpm::msg;

# $Id$

use strict;
no warnings;
use Exporter;
use URPM;

BEGIN {
    eval { require encoding };
    eval "use open ':locale'" if eval { encoding::_get_locale_encoding() ne 'ANSI_X3.4-1968' };
}

(our $VERSION) = q($Revision$) =~ /(\d+)/;

our @ISA = 'Exporter';
our @EXPORT = qw(N P translate bug_log message_input toMb formatXiB sys_log);

#- I18N.
use Locale::gettext;
use POSIX();
POSIX::setlocale(POSIX::LC_ALL(), "");
my @textdomains = qw(urpmi rpm-summary-main rpm-summary-contrib rpm-summary-devel);
foreach my $domain (@textdomains) {
	Locale::gettext::bind_textdomain_codeset($domain, 'UTF-8');
}
URPM::bind_rpm_textdomain_codeset();

our $no_translation;

sub translate {
    my ($s, $o_plural, $o_nb) = @_;
    my $res;
    if ($no_translation) {
	$s;
    } elsif ($o_nb) {
        foreach my $domain (@textdomains) {
            eval { $res = Locale::gettext::dngettext($domain, $s || '', $o_plural, $o_nb) || $s };
            return $res if $s ne $res;
        }
        return $s;
    } else {
        foreach my $domain (@textdomains) {
            eval { $res = Locale::gettext::dgettext($domain, $s || '') || $s };
            return $res if $s ne $res;
        }
        return $s;
    }
}

sub P {
    my ($s_singular, $s_plural, $nb, @para) = @_; 
    sprintf(translate($s_singular, $s_plural, $nb), @para);
}

sub N {
    my ($format, @params) = @_;
    sprintf(translate($format), @params);
}

my $noexpr = N("Nn");
my $yesexpr = N("Yy");

eval {
    require Sys::Syslog;
    Sys::Syslog->import;
    (my $tool = $0) =~ s!.*/!!;

    #- what we really want is "unix" (?)
    #- we really don't want "console" which forks/exit and thus
    #  run callbacks registered through atexit() : x11, gtk+, rpm, ...
    Sys::Syslog::setlogsock([ 'tcp', 'unix', 'stream' ]);

    openlog($tool, '', 'user');
    END { defined &closelog and closelog() }
};

sub sys_log { defined &syslog and eval { syslog("info", @_) } }

#- writes only to logfile, not to screen
sub bug_log {
    if ($::logfile) {
	open my $fh, ">>$::logfile"
	    or die "Can't output to log file [$::logfile]: $!\n";
	print $fh @_;
	close $fh;
    }
}

sub message_input {
    my ($msg, $o_default_input, %o_opts) = @_;
    my $input;
    while (1) {
	print $msg;
	if ($o_default_input) {
	    $urpm::args::options{bug} and bug_log($o_default_input);
	    return $o_default_input;
	}
	$input = <STDIN>;
	defined $input or return undef;
	chomp $input;
	$urpm::args::options{bug} and bug_log($input);
	if ($o_opts{boolean}) {
	    $input =~ /^[$noexpr$yesexpr]?$/ and last;
	} elsif ($o_opts{range}) {
	    $input eq "" and $input = 1; #- defaults to first choice
	    (defined $o_opts{range_min} ? $o_opts{range_min} : 1) <= $input && $input <= $o_opts{range} and last;
	} else {
	    last;
	}
	print N("Sorry, bad choice, try again\n");
    }
    return $input;
}

sub toMb {
    my $nb = $_[0] / 1024 / 1024;
    int $nb + 0.5;
}

# duplicated from svn+ssh://svn.mandriva.com/svn/soft/drakx/trunk/perl-install/common.pm
sub formatXiB {
    my ($newnb, $o_newbase) = @_;
    warn "$newnb x\n";
    my $newbase = $o_newbase || 1;
    my ($nb, $base);
    my $decr = sub { 
	($nb, $base) = ($newnb, $newbase);
	$base >= 1024 ? ($newbase = $base / 1024) : ($newnb = $nb / 1024);
    };
    my $suffix;
    foreach (N("B"), N("KB"), N("MB"), N("GB"), N("TB")) {
	$decr->(); 
	if ($newnb < 1 && $newnb * $newbase < 1) {
	    $suffix = $_;
	    last;
	}
    }
    my $v = $nb * $base;
    my $s = $v < 10 && int(10 * $v - 10 * int($v));
    int($v) . ($s ? ".$s" : '') . ($suffix || N("TB"));
}

sub localtime2changelog { scalar(localtime($_[0])) =~ /(.*) \S+ (\d{4})$/ && "$1 $2" }

1;

__END__

=head1 NAME

urpm::msg - routines to prompt messages from the urpm* tools

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 COPYRIGHT

Copyright (C) 2000, 2001, 2002, 2003, 2004, 2005 MandrakeSoft SA

Copyright (C) 2005, 2006 Mandriva SA

=cut
