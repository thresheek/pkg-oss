#!/usr/bin/perl

# Tests for ngx_http_set_misc_module, set_sha1 and set_md5.

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

my $t = Test::Nginx->new()->has(qw/http rewrite/)->plan(6)
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

        location /sha1copy {
            set_sha1 $a hello;
            return 200 $a;
        }

        location /sha1inplace {
            set $a hello;
            set_sha1 $a;
            return 200 $a;
        }

        location /sha1empty {
            set_sha1 $a "";
            return 200 $a;
        }

        location /md5copy {
            set_md5 $a hello;
            return 200 $a;
        }

        location /md5inplace {
            set $a hello;
            set_md5 $a;
            return 200 $a;
        }

        location /md5empty {
            set_md5 $a "";
            return 200 $a;
        }
    }
}

EOF

$t->run();

###############################################################################

like(http_get('/sha1copy'), qr!aaf4c61ddcc5e8a2dabede0f3b482cd9aea9434d\z!,
	'sha1 hello (copy)');
like(http_get('/sha1inplace'), qr!aaf4c61ddcc5e8a2dabede0f3b482cd9aea9434d\z!,
	'sha1 hello (in-place)');
like(http_get('/sha1empty'), qr!da39a3ee5e6b4b0d3255bfef95601890afd80709\z!,
	'sha1 (empty)');
like(http_get('/md5copy'), qr!5d41402abc4b2a76b9719d911017c592\z!,
	'md5 hello (copy)');
like(http_get('/md5inplace'), qr!5d41402abc4b2a76b9719d911017c592\z!,
	'md5 hello (in-place)');
like(http_get('/md5empty'), qr!d41d8cd98f00b204e9800998ecf8427e\z!,
	'md5 (empty)');

###############################################################################
