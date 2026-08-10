#!/usr/bin/perl

# Tests for ngx_http_set_misc_module, set_rotate.

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

my $t = Test::Nginx->new()->has(qw/http rewrite/)->plan(9)
	->write_file_expand('nginx.conf', <<'EOF');

%%TEST_GLOBALS%%

daemon off;

worker_processes 1;

events {
}

http {
    %%TEST_GLOBALS_HTTP%%

    server {
        listen       127.0.0.1:8080;
        server_name  localhost;

        location /t1 {
            set $a 1;
            set_rotate $a 1 3;

            set $b 2;
            set_rotate $b 1 3;

            set $c 3;
            set_rotate $c 1 3;

            set $d 0;
            set_rotate $d 1 3;

            set $e 1;
            set_rotate $e 3 5;

            return 200 "$a $b $c $d $e";
        }

        location /t2 {
            set $a abc;
            set_rotate $a 1 3;
            return 200 "a = $a";
        }

        location /t3 {
            set $a 2;
            set_rotate $a abc 3;
            return 200 "a = $a";
        }

        location /t4 {
            set $a 2;
            set_rotate $a 1 abc;
            return 200 "a = $a";
        }

        # persistence across requests (no current value given)

        location /t5 {
            set_rotate $a 1 3;
            return 200 "a = $a";
        }

        location /t6 {
            set_rotate $a 0 2;
            return 200 "a = $a";
        }

        location /t7 {
            set $a "hello";
            set_rotate $a 0 2;
            return 200 "a = $a";
        }

        location /t8 {
            set $a "";
            set_rotate $a 0 2;
            return 200 "a = $a";
        }

        location /t9a {
            set_rotate $a 0 2;
            return 200 "a = $a";
        }

        location /t9b {
            set_rotate $a 0 2;
            return 200 "a = $a";
        }
    }
}

EOF

$t->run();

###############################################################################

sub body {
	my ($r) = @_;
	$r =~ /\x0d\x0a\x0d\x0a(.*)\z/s;
	return defined $1 ? $1 : '';
}

sub seq {
	my ($uri, $n) = @_;
	my @out;
	push @out, body(http_get($uri)) for (1 .. $n);
	return \@out;
}

is(body(http_get('/t1')), '2 3 1 1 3', 'sanity');
like(http_get('/t2'), qr/^a = [12]$/m, 'bad current value');
like(http_get('/t3'), qr/ 500 /, 'bad "from" value');
like(http_get('/t4'), qr/ 500 /, 'bad "to" argument value');

is_deeply(seq('/t5', 6),
	['a = 1', 'a = 2', 'a = 3', 'a = 1', 'a = 2', 'a = 3'],
	'no current value is given');

is_deeply(seq('/t6', 6),
	['a = 0', 'a = 1', 'a = 2', 'a = 0', 'a = 1', 'a = 2'],
	'no current value (starting from 0)');

is_deeply(seq('/t7', 6),
	['a = 0', 'a = 1', 'a = 2', 'a = 0', 'a = 1', 'a = 2'],
	'non-integer string value is given');

is_deeply(seq('/t8', 6),
	['a = 0', 'a = 1', 'a = 2', 'a = 0', 'a = 1', 'a = 2'],
	'empty string value is given');

my @out;
for (1 .. 6) {
	push @out, body(http_get('/t9a'));
	push @out, body(http_get('/t9b'));
}
is_deeply(\@out,
	['a = 0', 'a = 0', 'a = 1', 'a = 1', 'a = 2', 'a = 2',
	 'a = 0', 'a = 0', 'a = 1', 'a = 1', 'a = 2', 'a = 2'],
	'value persistence is per-location');

###############################################################################
