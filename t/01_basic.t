# Test serving static content

use strict;
use warnings;
no  warnings 'uninitialized';

use Test::More tests => 11;
use WWW::Mechanize;

use lib 't/lib';

use util;

my $static_dir = 't/htdocs';

my $port = start_server(static_dir => $static_dir);

ok $port, 'Got port';

my $mech = WWW::Mechanize->new;

# Avoid following redirect
$mech->requests_redirectable([]);
$mech->get("http://localhost:$port/dir");
is $mech->status, 301,      'Got 301';
ok $mech->res->is_redirect, 'Got redirect';

eval { $mech->get("http://localhost:$port/nonexisting/stuff") };
is $mech->status, 404,   'Got 404';
ok $mech->res->is_error, 'Got error';

# Get a (seemingly) non-text file

my $expected_len = (stat "$static_dir/bar.png")[7];

$mech->get("http://localhost:$port/bar.png");
is $mech->status,    200,          'Got status';
like $mech->content, qr/foo/,      'Got content';
is $mech->ct,        'image/png',  'Got content type';

my $actual_len = $mech->res->header('Content-Length');
is $actual_len, $expected_len, 'Got content length';

# Now get text file and check the type
$mech->get("http://localhost:$port/foo.txt");
is $mech->status, 200,          'Got status';
is $mech->ct,     'text/plain', 'Got content type';

