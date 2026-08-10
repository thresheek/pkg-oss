#!/usr/bin/perl

# Tests for ngx_http_set_misc_module, set_formatted_local_time and
# set_formatted_gmt_time.

###############################################################################

use warnings;
use strict;

use POSIX qw(strftime);

use Test::More;

BEGIN { use FindBin; chdir($FindBin::Bin); }

use lib 'lib';
use Test::Nginx;

###############################################################################

select STDERR; $| = 1;
select STDOUT; $| = 1;

my $t = Test::Nginx->new()->has(qw/http rewrite/)->plan(5)
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

        location /local {
            set_formatted_local_time $today "%a %b %e %H:%M:%S %Y";
            return 200 $today;
        }

        location /gmt {
            set_formatted_gmt_time $today "%a %b %e %H:%M:%S %Y";
            return 200 $today;
        }

        location /gmt-empty {
            set_formatted_gmt_time $today "";
            return 200 "[$today]";
        }

        location /local-empty {
            set_formatted_local_time $today "";
            return 200 "[$today]";
        }

        location /local-const {
            set_formatted_local_time $today "hello world";
            return 200 "[$today]";
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

my $fmt = "%a %b %e %H:%M:%S %Y";

# build a small set of acceptable timestamps around "now" to tolerate the
# clock ticking between building the candidates and serving the request

sub candidates {
	my ($gmt) = @_;
	my $now = time();
	my %set;
	for my $d (-1 .. 2) {
		my @tm = $gmt ? gmtime($now + $d) : localtime($now + $d);
		$set{ strftime($fmt, @tm) } = 1;
	}
	return \%set;
}

my $loc = candidates(0);
ok($loc->{ body(http_get('/local')) }, 'local time format');

my $gmt = candidates(1);
ok($gmt->{ body(http_get('/gmt')) }, 'GMT time format');

is(body(http_get('/gmt-empty')), '[]',
	'set_formatted_gmt_time (empty formatter)');
is(body(http_get('/local-empty')), '[]',
	'set_formatted_local_time (empty formatter)');
is(body(http_get('/local-const')), '[hello world]',
	'set_formatted_local_time (constant formatter)');

###############################################################################
