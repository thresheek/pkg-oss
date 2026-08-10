#!/usr/bin/perl

# Tests for ngx_http_set_misc_module, set_secure_random_alphanum and
# set_secure_random_lcalpha.

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

my $t = Test::Nginx->new()->has(qw/http rewrite/)->plan(7)
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

        location /alphanum32 {
            set_secure_random_alphanum $res 32;
            return 200 $res;
        }

        location /alphanum16 {
            set_secure_random_alphanum $res 16;
            return 200 $res;
        }

        location /alphanum1 {
            set_secure_random_alphanum $res 1;
            return 200 $res;
        }

        location /alphanum0 {
            set_secure_random_alphanum $res 0;
            return 200 $res;
        }

        location /alphanumneg {
            set_secure_random_alphanum $res -4;
            return 200 $res;
        }

        location /alphanumbad {
            set_secure_random_alphanum $res bob;
            return 200 $res;
        }

        location /lcalpha16 {
            set_secure_random_lcalpha $res 16;
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

like(body(http_get('/alphanum32')), qr/^[a-zA-Z0-9]{32}$/,
	'a 32-character alphanum');
like(body(http_get('/alphanum16')), qr/^[a-zA-Z0-9]{16}$/,
	'a 16-character alphanum');
like(body(http_get('/alphanum1')), qr/^[a-zA-Z0-9]{1}$/,
	'a 1-character alphanum');

like(http_get('/alphanum0'), qr/ 500 /, 'length <= 0 should fail (0)');
like(http_get('/alphanumneg'), qr/ 500 /, 'length <= 0 should fail (-4)');
like(http_get('/alphanumbad'), qr/ 500 /, 'non-numeric length should fail');

like(body(http_get('/lcalpha16')), qr/^[a-z]{16}$/, 'a 16-character lcalpha');

###############################################################################
