#!/usr/bin/perl

# Tests for ngx_http_set_misc_module, set_quote_json_str.

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

        location /copy {
            set $foo "hello\n\r'\"\\";
            set_quote_json_str $foo $foo;
            return 200 $foo;
        }

        location /inplace {
            set $foo "hello\n\r'\"\\";
            set_quote_json_str $foo;
            return 200 $foo;
        }

        location /empty {
            set $foo "";
            set_quote_json_str $foo;
            return 200 $foo;
        }

        location /null {
            set_quote_json_str $foo;
            return 200 $foo;
        }
    }
}

EOF

$t->run();

###############################################################################

# the escaped result: "hello\n\r'\"\\" (with literal backslashes)

my $exp = '"hello\\n\\r\'\\"\\\\"';

like(http_get('/copy'), qr!\Q$exp\E\z!, 'set quote json value');
like(http_get('/inplace'), qr!\Q$exp\E\z!, 'set quote json value (in place)');
like(http_get('/empty'), qr!null\z!, 'set quote empty json value');
like(http_get('/null'), qr!null\z!, 'set quote null json value');

###############################################################################
