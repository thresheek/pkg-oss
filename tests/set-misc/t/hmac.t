#!/usr/bin/perl

# Tests for ngx_http_set_misc_module, set_hmac_sha1 and set_hmac_sha256.

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

my $t = Test::Nginx->new()->has(qw/http rewrite/)->plan(4)
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

        location /sha1 {
            set $secret 'thisisverysecretstuff';
            set $string_to_sign 'some string we want to sign';
            set_hmac_sha1 $signature $secret $string_to_sign;
            set_encode_base64 $signature $signature;
            return 200 $signature;
        }

        location /sha1empty {
            set $secret '';
            set $string_to_sign '';
            set_hmac_sha1 $signature $secret $string_to_sign;
            set_encode_base64 $signature $signature;
            return 200 $signature;
        }

        location /sha256 {
            set $secret 'thisisverysecretstuff';
            set $string_to_sign 'some string we want to sign';
            set_hmac_sha256 $signature $secret $string_to_sign;
            set_encode_base64 $signature $signature;
            return 200 $signature;
        }

        location /sha256empty {
            set $secret '';
            set $string_to_sign '';
            set_hmac_sha256 $signature $secret $string_to_sign;
            set_encode_base64 $signature $signature;
            return 200 $signature;
        }
    }
}

EOF

$t->run();

###############################################################################

like(http_get('/sha1'), qr!\QR/pvxzHC4NLtj7S+kXFg/NePTmk=\E\z!, 'hmac_sha1');
like(http_get('/sha1empty'), qr!\Q+9sdGxiqbAgyS31ktx+3Y3BpDh0=\E\z!,
	'hmac_sha1 empty vars');
like(http_get('/sha256'),
	qr!\Q4pU3GRQrKKIoeLb9CqYsavHE2l6Hx+KMmRmesU+Cfrs=\E\z!, 'hmac_sha256');
like(http_get('/sha256empty'),
	qr!\QthNnmggU2ex3L5XXeMNfxf8Wl8STcVZTxscSFEKSxa0=\E\z!,
	'hmac_sha256 empty vars');

###############################################################################
