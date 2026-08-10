#!/usr/bin/perl

# Tests for ngx_http_set_misc_module, base64 encoding and decoding.

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

my $t = Test::Nginx->new()->has(qw/http rewrite/)->plan(2)
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

        location /encode {
            set_encode_base64 $out "abcde";
            return 200 $out;
        }

        location /decode {
            set_decode_base64 $out "YWJjZGU=";
            return 200 $out;
        }
    }
}

EOF

$t->run();

###############################################################################

like(http_get('/encode'), qr/YWJjZGU=\z/, 'base64 encode');
like(http_get('/decode'), qr/abcde\z/, 'base64 decode');

###############################################################################
