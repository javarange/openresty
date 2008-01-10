#!/usr/bin/env perl

# Sample:
# bin/export-model.pl --user carrie --model YisouComments \
#  --server http://ced02.search.cnb.yahoo.com/openapi \
#  > YisouComments.yml

use strict;
use warnings;

use Getopt::Long;
use Encode qw(decode encode);

use lib 'lib';
use WWW::OpenAPI;
use Params::Util qw( _HASH _ARRAY0 );
use YAML::Syck ();
use JSON::Syck ();

$YAML::Syck::ImplicitUnicode = 1;
$JSON::Syck::ImplicitUnicode = 1;

GetOptions(
    'user|u=s' => \(my $user),
    'model=s' => \(my $model),
    'server=s' => \(my $server),
    'password=s' => \(my $password),
) or die "Usage: $0 --user foo.Public --model Book --server 127.0.0.1\n";

$user or die "No user given.\n";
$model or die "No model given.\n";
$server or die "No server given.\n";

my $openapi = WWW::OpenAPI->new( { server => $server } );

my $offset = 0;
my $count = 100;
my @rows;
while (1) {
    warn "$offset\n";
    my $url = "/=/model/$model/~/~";
    my %args = (
        user => $user,
        offset => $offset,
        count => $count,
        order_by => "id:asc",
    );
    if ($password) {
        $args{password} = $password;
    }
    my $res = $openapi->get($url, \%args);
    if (!$res->is_success) {
        die "$url: ", $res->status_line, "\n";
    }
    my $json = $res->content;
    $json or die "No content found in server's response.\n";
    $json = decode('utf8', $json);
    my $data = JSON::Syck::Load($json);
    if (_HASH($data) && !$data->{success} && $data->{error}) {
        die "Error from the server: $json\n";
    }
    elsif (_ARRAY0($data)) {
        push @rows, @$data;
        last if @$data < $count;
    }
} continue { $offset += $count }

warn "For tatal ", scalar(@rows), " records obtained.\n";
print encode('UTF-8', YAML::Syck::Dump(\@rows));

