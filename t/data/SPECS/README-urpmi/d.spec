Summary: d
Name: d
Version: 1
Release: 1
License: x
Group: x

%description
x

%prep
rm -rf *
echo "installing/upgrading %name" > README.urpmi

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root)
%doc README.urpmi
