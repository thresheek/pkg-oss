#!/usr/bin/perl

# Tests for ngx_http_set_misc_module, set_hashed_upstream and upstream_list.

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

my $t = Test::Nginx->new()->has(qw/http rewrite/)->plan(10)
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

        upstream_list universe moon sun earth;

        location /foo {
            set_hashed_upstream $backend universe $arg_id;
            return 200 $backend;
        }

        location /bar {
            set $list_name universe;
            set_hashed_upstream $backend $list_name $arg_id;
            return 200 $backend;
        }
    }
}

EOF

$t->run();

###############################################################################

# the original test drove these through five parallel subrequests; here we
# issue the requests directly and check each chosen upstream in turn

like(http_get('/foo'), qr/moon\z/, 'hashed upstream (no id)');
like(http_get('/foo?id=hello'), qr/sun\z/, 'hashed upstream (hello)');
like(http_get('/foo?id=world'), qr/moon\z/, 'hashed upstream (world)');
like(http_get('/foo?id=larry'), qr/earth\z/, 'hashed upstream (larry)');
like(http_get('/foo?id=audreyt'), qr/earth\z/, 'hashed upstream (audreyt)');

# same, but the upstream_list name comes from a variable

like(http_get('/bar'), qr/moon\z/, 'hashed upstream via var (no id)');
like(http_get('/bar?id=hello'), qr/sun\z/, 'hashed upstream via var (hello)');
like(http_get('/bar?id=world'), qr/moon\z/, 'hashed upstream via var (world)');
like(http_get('/bar?id=larry'), qr/earth\z/, 'hashed upstream via var (larry)');
like(http_get('/bar?id=audreyt'), qr/earth\z/,
	'hashed upstream via var (audreyt)');

###############################################################################
