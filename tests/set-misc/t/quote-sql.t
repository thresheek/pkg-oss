#!/usr/bin/perl

# Tests for ngx_http_set_misc_module, set_quote_sql_str and
# set_quote_pgsql_str.

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

my $t = Test::Nginx->new()->has(qw/http rewrite/)->plan(12)
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
            set_quote_sql_str $foo $foo;
            return 200 $foo;
        }

        location /inplace {
            set $foo "hello\n\r'\"\\";
            set_quote_sql_str $foo;
            return 200 $foo;
        }

        location /empty {
            set $foo "";
            set_quote_sql_str $foo;
            return 200 $foo;
        }

        location /null {
            set_quote_sql_str $foo;
            return 200 $foo;
        }

        location /pgnull {
            set_quote_pgsql_str $foo;
            return 200 $foo;
        }

        location /pgvalue {
            set $foo "hello\n\r'\"\\";
            set_quote_pgsql_str $foo;
            return 200 $foo;
        }

        location /pgutf8 {
            set $foo "你好";
            set_quote_pgsql_str $foo;
            return 200 $foo;
        }

        location /unescape {
            set_unescape_uri $foo $arg_a;
            set_quote_sql_str $foo $foo;
            return 200 $foo;
        }
    }
}

EOF

$t->run();

###############################################################################

# 'hello\n\r\'\"\\' (with literal backslashes)
my $sql = '\'hello\\n\\r\\\'\\"\\\\\'';

# E'hello\n\r\'\"\\'
my $pg = 'E' . $sql;

like(http_get('/copy'), qr!\Q$sql\E\z!, 'set quote sql value');
like(http_get('/inplace'), qr!\Q$sql\E\z!, 'set quote sql value (in place)');
like(http_get('/empty'), qr!''\z!, 'set quote empty sql value');
like(http_get('/null'), qr!''\z!, 'set quote null sql value');
like(http_get('/pgnull'), qr!''\z!, 'set quote null pgsql value');
like(http_get('/pgvalue'), qr!\Q$pg\E\z!, 'set quote pgsql value');
like(http_get('/pgutf8'), qr!\QE'你好'\E\z!, 'set quote pgsql valid utf8 value');

# build expected bodies via single-quoted literals so that the backslashes
# are matched literally (\Q quotes the variable's runtime bytes, avoiding
# Perl interpreting \0, \t, \b, \Z, \$ as escapes inside the pattern)
my $m0 = '\'a\\0b\\0\'';        # 'a\0b\0'
my $mb = '\'a\\bb\\b\'';        # 'a\bb\b'
my $mt = '\'a\\tb\\t\'';        # 'a\tb\t'
my $mZ = '\'a\\Zb\\Z\'';        # 'a\Zb\Z'
my $md = '\'\\$\\$\'';          # '\$\$'

like(http_get('/unescape?a=a%00b%00'), qr!\Q$m0\E\z!, '\0 for mysql');
like(http_get('/unescape?a=a%08b%08'), qr!\Q$mb\E\z!, '\b for mysql');
like(http_get('/unescape?a=a%09b%09'), qr!\Q$mt\E\z!, '\t for mysql');
like(http_get('/unescape?a=a%1ab%1a'), qr!\Q$mZ\E\z!, '\Z for mysql');
like(http_get('/unescape?a=$$'), qr!\Q$md\E\z!, 'set quote sql value ($$)');

###############################################################################
