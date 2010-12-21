#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 10;
use Data::Dump qw( dump );
use JSON::XS;
use Search::OpenSearch::Engine::KSx;

SKIP: {

    my $index_path = $ENV{OPENSEARCH_INDEX};
    if ( !defined $index_path or !-d $index_path ) {
        diag("set OPENSEARCH_INDEX to valid path to test Plack with KSx");
        skip "set OPENSEARCH_INDEX to valid path to test Plack with KSx", 7;
    }

    my $engine = Search::OpenSearch::Engine::KSx->new(
        index  => [$index_path],
        facets => { names => [qw( topics people places orgs author )], },
        fields => [qw( topics people places orgs author )],
    );

    my $resp = $engine->PUT(
        {   url     => 'foo/bar',
            content => 'i am a test',
            type    => 'text/plain',
        }
    );
    dump($resp);

    $resp = $engine->GET('foo/bar');
    dump($resp);

    $resp = $engine->POST(
        {   url     => 'foo/bar',
            content => 'i am a POST test',
            type    => 'text/plain',
        }
    );
    dump($resp);

    $resp = $engine->DELETE('foo/bar');
    dump($resp);
}
