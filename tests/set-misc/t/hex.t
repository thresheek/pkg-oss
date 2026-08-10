#!/usr/bin/perl

# Tests for ngx_http_set_misc_module, hex encoding and decoding.

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

my $t = Test::Nginx->new()->has(qw/http rewrite/)->plan(3)
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
            set_encode_hex $out "abcde";
            return 200 $out;
        }

        location /decode {
            set_decode_hex $out "6162636465";
            return 200 $out;
        }

        location /chinese {
            set $raw "章亦春";
            set_encode_hex $digest $raw;
            set_decode_hex $hex $digest;
            return 200 "$digest $hex";
        }
    }
}

EOF

$t->run();

###############################################################################

like(http_get('/encode'), qr!6162636465\z!, 'hex encode');
like(http_get('/decode'), qr!abcde\z!, 'hex decode');
like(http_get('/chinese'), qr!e7aba0e4baa6e698a5 章亦春\z!,
	'hex encode/decode (chinese)');

###############################################################################
