#!/usr/bin/perl

use strict;
use lib '.', 't';
use helper;
use Test::More 'no_plan';
plan skip_all => "Needs a Mageia specific patch that introduces Time::ZoneInfo->current_zone()" if !-e '/etc/mageia-release';

BEGIN { use_ok 'urpm::cfg' }

need_root_and_prepare();

need_downloader();

urpmi_addmedia('--mirrorlist \$MIRRORLIST core media/core/release');
is(run_urpm_cmd('urpmq sed'), "sed\n");
urpmi_removemedia('core');

urpmi_addmedia('--distrib --mirrorlist \$MIRRORLIST');
is(run_urpm_cmd('urpmq sed'), "sed\n");
urpmi_removemedia('-a');
