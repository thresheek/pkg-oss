#!/usr/bin/perl

# Tests for ngx_http_set_misc_module, set_unescape_uri.

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

        location /copy {
            set $foo "hello%20world";
            set_unescape_uri $foo $foo;
            return 200 $foo;
        }

        location /inplace {
            set $foo "hello%20world";
            set_unescape_uri $foo;
            return 200 $foo;
        }

        location /plus {
            set $a 'a+b';
            set_unescape_uri $a;
            return 200 $a;
        }
    }
}

EOF

$t->run();

###############################################################################

like(http_get('/copy'), qr!hello world\z!, 'set unescape uri');
like(http_get('/inplace'), qr!hello world\z!, 'set unescape uri (in-place)');
like(http_get('/plus'), qr!a b\z!, "unescape '+' to ' '");

###############################################################################
