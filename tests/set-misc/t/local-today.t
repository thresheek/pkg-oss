#!/usr/bin/perl

# Tests for ngx_http_set_misc_module, set_local_today.

###############################################################################

use warnings;
use strict;

use Test::More;

BEGIN { use FindBin; chdir($FindBin::Bin); }

use lib 'lib';
use Test::Nginx;

###############################################################################

select STDERR; $| = 1;
select STDOUT; $| = 1;

my $t = Test::Nginx->new()->has(qw/http rewrite/)->plan(1)
	->write_file_expand('nginx.conf', <<'EOF');

%%TEST_GLOBALS%%

daemon off;

events {
}

http {
    %%TEST_GLOBALS_HTTP%%

    server {
        listen       127.0.0.1:8080;
        server_name  localhost;

        location /today {
            set_local_today $today;
            return 200 $today;
        }
    }
}

EOF

$t->run();

###############################################################################

sub body {
	my ($r) = @_;
	$r =~ /\x0d\x0a\x0d\x0a(.*)\z/s;
	return defined $1 ? $1 : '';
}

# compute the expected local date; allow the day to roll over during the
# request by accepting either "before" or "after" midnight

sub today {
	my ($t) = @_;
	my ($sec, $min, $hour, $mday, $mon, $year) = localtime($t);
	return sprintf("%04d-%02d-%02d", $year + 1900, $mon + 1, $mday);
}

my $now = time();
my %ok = map { today($_) => 1 } ($now, $now + 1);

ok($ok{ body(http_get('/today')) }, 'sanity');

###############################################################################
