Summary: x
Name: c
Version: 1
Release: 1
License: x
BuildArch: noarch

%description
x

%install
rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT/etc
echo bar > $RPM_BUILD_ROOT/etc/bar

%clean
rm -rf $RPM_BUILD_ROOT

%files
/etc/*
