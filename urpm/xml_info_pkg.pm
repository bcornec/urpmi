package urpm::xml_info_pkg;

# proxy object: returns the xml info if available, otherwise redirects to URPM::Package

sub new {
    my ($class, $hash, $pkg) = @_;

    $pkg and $hash->{pkg} = $pkg;

    bless $hash, $class;
}


# only available in synthesis/hdlist
sub id        { $_[0]{pkg}->id }
sub group     { $_[0]{pkg}->group }
sub size      { $_[0]{pkg}->size }
sub epoch     { $_[0]{pkg}->epoch }
sub buildhost { $_[0]{pkg}->buildhost }
sub packager  { $_[0]{pkg}->packager }
sub summary   { $_[0]{pkg}->summary }


# can be directly available in xml_info
sub url         { exists $_[0]{url}         ? $_[0]{url}         : $_[0]{pkg}->url }
sub license     { exists $_[0]{license}     ? $_[0]{license}     : $_[0]{pkg}->license }
sub sourcerpm   { exists $_[0]{sourcerpm}   ? $_[0]{sourcerpm}   : $_[0]{pkg}->sourcerpm }
sub description { exists $_[0]{description} ? $_[0]{description} : $_[0]{pkg}->description }

sub changelogs  { exists $_[0]{changelogs} ? @{$_[0]{changelogs}} : $_[0]{pkg}->changelogs }

sub files { exists $_[0]{files} ? split("\n", $_[0]{files}) : $_[0]{pkg}->files }

my $fullname_re = qr/^(.*)-([^\-]*)-([^\-]*)\.([^\.\-]*)$/;

# available in both {pkg} and {fn}
sub name      { exists $_[0]{pkg} ? $_[0]{pkg}->name    : $_[0]{fn} =~ $fullname_re && $1 }
sub version   { exists $_[0]{pkg} ? $_[0]{pkg}->version : $_[0]{fn} =~ $fullname_re && $2 }
sub release   { exists $_[0]{pkg} ? $_[0]{pkg}->release : $_[0]{fn} =~ $fullname_re && $3 }
sub arch      { exists $_[0]{pkg} ? $_[0]{pkg}->arch    : $_[0]{fn} =~ $fullname_re && $4 }

sub fullname { wantarray ? $_[0]{pkg}->fullname : $_[0]{fn} }
sub filename { $_[0]{fn} . '.rpm' }


1;