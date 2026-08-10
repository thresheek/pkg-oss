#!/usr/bin/perl

# Tests for ngx_http_set_misc_module, set_encode_base32 / set_decode_base32
# (padding enabled, which is the default).

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

my $t = Test::Nginx->new()->has(qw/http rewrite/)->plan(28)
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

        # default alphabet, padding on (default)

        location /t1 {
            set $a 'abcde';
            set_encode_base32 $a;
            set $b $a;
            set_decode_base32 $b;
            return 200 "$a|$b";
        }

        location /t2 {
            set $a '!';
            set_encode_base32 $a;
            set $b $a;
            set_decode_base32 $b;
            return 200 "$a|$b";
        }

        location /t3 {
            set $a '!';
            set_encode_base32 $a $a;
            set_decode_base32 $b $a;
            return 200 "$a|$b";
        }

        location /t4 {
            set $a '"hello, world!\nhiya"';
            set_encode_base32 $a;
            set $b $a;
            set_decode_base32 $b;
            return 200 "$a|$b";
        }

        location /t5 {
            set_base32_padding on;
            set $a '"hello, world!"';
            set_encode_base32 $a;
            return 200 $a;
        }

        location /t6 {
            set_base32_padding on;
            set $a '"hello, world!"a';
            set_encode_base32 $a;
            return 200 $a;
        }

        location /t7 {
            set_base32_padding on;
            set $a '"hello, world!"ab';
            set_encode_base32 $a;
            return 200 $a;
        }

        location /t8 {
            set_base32_padding on;
            set $a '"hello, world!"abc';
            set_encode_base32 $a;
            return 200 $a;
        }

        location /t9 {
            set_base32_padding on;
            set $a '"hello, world!"abcd';
            set_encode_base32 $a;
            return 200 $a;
        }

        # standard alphabet

        location /t10 {
            set_base32_alphabet "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567";
            set $a 'abcde';
            set_encode_base32 $a;
            set $b $a;
            set_decode_base32 $b;
            return 200 "$a|$b";
        }

        location /t11 {
            set_base32_alphabet "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567";
            set $a '!';
            set_encode_base32 $a;
            set $b $a;
            set_decode_base32 $b;
            return 200 "$a|$b";
        }

        location /t12 {
            set_base32_alphabet "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567";
            set $a '!';
            set_encode_base32 $a $a;
            set_decode_base32 $b $a;
            return 200 "$a|$b";
        }

        location /t13 {
            set_base32_alphabet "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567";
            set $a '"hello, world!\nhiya"';
            set_encode_base32 $a;
            set $b $a;
            set_decode_base32 $b;
            return 200 "$a|$b";
        }

        location /t14 {
            set_base32_padding on;
            set_base32_alphabet "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567";
            set $a '"hello, world!"';
            set_encode_base32 $a;
            return 200 $a;
        }

        location /t15 {
            set_base32_padding on;
            set_base32_alphabet "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567";
            set $a '"hello, world!"a';
            set_encode_base32 $a;
            return 200 $a;
        }

        location /t16 {
            set_base32_padding on;
            set_base32_alphabet "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567";
            set $a '"hello, world!"ab';
            set_encode_base32 $a;
            return 200 $a;
        }

        location /t17 {
            set_base32_padding on;
            set_base32_alphabet "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567";
            set $a '"hello, world!"abc';
            set_encode_base32 $a;
            return 200 $a;
        }

        location /t18 {
            set_base32_padding on;
            set_base32_alphabet "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567";
            set $a '"hello, world!"abcd';
            set_encode_base32 $a;
            return 200 $a;
        }

        # custom alphabet

        location /t19 {
            set_base32_alphabet "efghijklmnopqrstuvwxyz0123456789";
            set $a 'abcde';
            set_encode_base32 $a;
            set $b $a;
            set_decode_base32 $b;
            return 200 "$a|$b";
        }

        location /t20 {
            set_base32_alphabet "efghijklmnopqrstuvwxyz0123456789";
            set $a '!';
            set_encode_base32 $a;
            set $b $a;
            set_decode_base32 $b;
            return 200 "$a|$b";
        }

        location /t21 {
            set_base32_alphabet "efghijklmnopqrstuvwxyz0123456789";
            set $a '!';
            set_encode_base32 $a $a;
            set_decode_base32 $b $a;
            return 200 "$a|$b";
        }

        location /t22 {
            set_base32_alphabet "efghijklmnopqrstuvwxyz0123456789";
            set $a '"hello, world!\nhiya"';
            set_encode_base32 $a;
            set $b $a;
            set_decode_base32 $b;
            return 200 "$a|$b";
        }

        location /t23 {
            set_base32_padding on;
            set_base32_alphabet "efghijklmnopqrstuvwxyz0123456789";
            set $a '"hello, world!"';
            set_encode_base32 $a;
            return 200 $a;
        }

        location /t24 {
            set_base32_padding on;
            set_base32_alphabet "efghijklmnopqrstuvwxyz0123456789";
            set $a '"hello, world!"a';
            set_encode_base32 $a;
            return 200 $a;
        }

        location /t25 {
            set_base32_padding on;
            set_base32_alphabet "efghijklmnopqrstuvwxyz0123456789";
            set $a '"hello, world!"ab';
            set_encode_base32 $a;
            return 200 $a;
        }

        location /t26 {
            set_base32_padding on;
            set_base32_alphabet "efghijklmnopqrstuvwxyz0123456789";
            set $a '"hello, world!"abc';
            set_encode_base32 $a;
            return 200 $a;
        }

        location /t27 {
            set_base32_padding on;
            set_base32_alphabet "efghijklmnopqrstuvwxyz0123456789";
            set $a '"hello, world!"abcd';
            set_encode_base32 $a;
            return 200 $a;
        }

        location /t28 {
            set_base32_padding on;
            set_base32_alphabet "efghijklmnopqrstuvwxyz0123456789";
            set $a '"hello, world!"abcd';
            set_encode_base32 $a;
            return 200 $a;
        }
    }
}

EOF

$t->run();

###############################################################################

# decoded round-trip value used by the "hello world" cases
my $hw = "\"hello, world!\nhiya\"";

like(http_get('/t1'), qr/\Qc5h66p35|abcde\E\z/, 'base32 (5 bytes)');
like(http_get('/t2'), qr/\Q44======|!\E\z/, 'base32 (1 byte)');
like(http_get('/t3'), qr/\Q44======|!\E\z/, 'base32 (1 byte) not in-place');
like(http_get('/t4'), qr/\Q49k6ar3cdsm20trfe9m6888ad1knio92|$hw\E\z/,
	'base32 (hello world)');
like(http_get('/t5'), qr/\Q49k6ar3cdsm20trfe9m68892\E\z/,
	'base32 (0 bytes left)');
like(http_get('/t6'), qr/\Q49k6ar3cdsm20trfe9m68892c4======\E\z/,
	'base32 (6 bytes padded)');
like(http_get('/t7'), qr/\Q49k6ar3cdsm20trfe9m68892c5h0====\E\z/,
	'base32 (4 bytes left)');
like(http_get('/t8'), qr/\Q49k6ar3cdsm20trfe9m68892c5h66===\E\z/,
	'base32 (3 bytes left)');
like(http_get('/t9'), qr/\Q49k6ar3cdsm20trfe9m68892c5h66p0=\E\z/,
	'base32 (1 byte left)');

like(http_get('/t10'), qr/\QMFRGGZDF|abcde\E\z/,
	'base32 std alphabet (5 bytes)');
like(http_get('/t11'), qr/\QEE======|!\E\z/, 'base32 std alphabet (1 byte)');
like(http_get('/t12'), qr/\QEE======|!\E\z/,
	'base32 std alphabet (1 byte) not in-place');
like(http_get('/t13'), qr/\QEJUGK3DMN4WCA53POJWGIIIKNBUXSYJC|$hw\E\z/,
	'base32 std alphabet (hello world)');
like(http_get('/t14'), qr/\QEJUGK3DMN4WCA53POJWGIIJC\E\z/,
	'base32 std alphabet (0 bytes left)');
like(http_get('/t15'), qr/\QEJUGK3DMN4WCA53POJWGIIJCME======\E\z/,
	'base32 std alphabet (6 bytes padded)');
like(http_get('/t16'), qr/\QEJUGK3DMN4WCA53POJWGIIJCMFRA====\E\z/,
	'base32 std alphabet (4 bytes left)');
like(http_get('/t17'), qr/\QEJUGK3DMN4WCA53POJWGIIJCMFRGG===\E\z/,
	'base32 std alphabet (3 bytes left)');
like(http_get('/t18'), qr/\QEJUGK3DMN4WCA53POJWGIIJCMFRGGZA=\E\z/,
	'base32 std alphabet (1 byte left)');

like(http_get('/t19'), qr/\Qqjvkk3hj|abcde\E\z/,
	'base32 custom alphabet (5 bytes)');
like(http_get('/t20'), qr/\Qii======|!\E\z/,
	'base32 custom alphabet (1 byte)');
like(http_get('/t21'), qr/\Qii======|!\E\z/,
	'base32 custom alphabet (1 byte) not in-place');
like(http_get('/t22'), qr/\Qinyko5hqr60ge75tsn0kmmmorfy1w2ng|$hw\E\z/,
	'base32 custom alphabet (hello world)');
like(http_get('/t23'), qr/\Qinyko5hqr60ge75tsn0kmmng\E\z/,
	'base32 custom alphabet (0 bytes left)');
like(http_get('/t24'), qr/\Qinyko5hqr60ge75tsn0kmmngqi======\E\z/,
	'base32 custom alphabet (6 bytes padded)');
like(http_get('/t25'), qr/\Qinyko5hqr60ge75tsn0kmmngqjve====\E\z/,
	'base32 custom alphabet (4 bytes left)');
like(http_get('/t26'), qr/\Qinyko5hqr60ge75tsn0kmmngqjvkk===\E\z/,
	'base32 custom alphabet (3 bytes left)');
like(http_get('/t27'), qr/\Qinyko5hqr60ge75tsn0kmmngqjvkk3e=\E\z/,
	'base32 custom alphabet (1 byte left)');
like(http_get('/t28'), qr/\Qinyko5hqr60ge75tsn0kmmngqjvkk3e=\E\z/,
	'set_base32_alphabet in location');

###############################################################################
