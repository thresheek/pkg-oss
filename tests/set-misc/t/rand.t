#!/usr/bin/perl

# Tests for ngx_http_set_misc_module, set_random.

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

my $t = Test::Nginx->new()->has(qw/http rewrite/)->plan(9)
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

        location /rand1 {
            set $from 5;
            set $to 7;
            set_random $res $from $to;
            return 200 $res;
        }

        location /rand2 {
            set $from 35;
            set $to 37;
            set_random $res $from $to;
            return 200 $res;
        }

        location /rand3 {
            set $from 37;
            set $to 35;
            set_random $res $from $to;
            return 200 $res;
        }

        location /rand4 {
            set $from 117;
            set $to 117;
            set_random $res $from $to;
            return 200 $res;
        }

        location /rand5 {
            set $from -2;
            set $to 4;
            set_random $res $from $to;
            return 200 $res;
        }

        location /rand6 {
            set $from 2;
            set $to -4;
            set_random $res $from $to;
            return 200 $res;
        }

        location /rand7 {
            set $from '';
            set $to 4;
            set_random $res $from $to;
            return 200 $res;
        }

        location /rand8 {
            set $from 2;
            set $to '';
            set_random $res $from $to;
            return 200 $res;
        }

        location /rand10 {
            set_random $res 0 0;
            return 200 $res;
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

# sample the range-based cases many times

sub in_range {
	my ($uri, $re, $n) = @_;
	for (1 .. $n) {
		return 0 unless body(http_get($uri)) =~ $re;
	}
	return 1;
}

ok(in_range('/rand1', qr/^[5-7]$/, 50), 'sanity');
ok(in_range('/rand2', qr/^3[5-7]$/, 50), 'sanity (two digits)');
ok(in_range('/rand3', qr/^3[5-7]$/, 50), 'sanity (two digits, from > to)');
is(body(http_get('/rand4')), '117', 'sanity (two digits, from == to)');

like(http_get('/rand5'), qr/ 500 /, 'negative number not allowed in from arg');
like(http_get('/rand6'), qr/ 500 /, 'negative number not allowed in to arg');
like(http_get('/rand7'), qr/ 500 /, 'empty string not allowed in from arg');
like(http_get('/rand8'), qr/ 500 /, 'empty string not allowed in to arg');

is(body(http_get('/rand10')), '0', 'zero is fine');

###############################################################################
