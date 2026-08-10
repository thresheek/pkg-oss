#!/usr/bin/perl

# Tests for ngx_http_set_misc_module, set_if_empty.

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

        location /literal {
            set $a 32;
            set_if_empty $a 56;

            set_if_empty $b 72;
            return 200 "$a $b";
        }

        location /args {
            set $bar $arg_bar;
            set_if_empty $bar 15;

            set $bah $arg_bah;
            set_if_empty $bah 25;
            return 200 "$bar $bah";
        }

        location /argdirect {
            set_if_empty $arg_bar 15;

            set_if_empty $arg_bah 25;
            return 200 "$arg_bar $arg_bah";
        }
    }
}

EOF

$t->run();

###############################################################################

like(http_get('/literal'), qr!32 72\z!, 'set if empty (literal)');
like(http_get('/args?bar=71'), qr!71 25\z!, 'set if empty (non-empty arg)');
like(http_get('/args?bar='), qr!15 25\z!, 'set if empty (empty arg)');
like(http_get('/argdirect?bar=71'), qr!71 25\z!,
	'set if empty (using arg_xxx directly)');

###############################################################################
