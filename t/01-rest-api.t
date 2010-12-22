#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 6;
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
            content => '<doc><title>i am a test</title></doc>',
            type    => 'application/xml',
        }
    );

    dump($resp);
    is( $resp->{code}, 201, "PUT == 201" );

    $resp = $engine->GET('foo/bar');

    #dump($resp);
    is( $resp->{code}, 200, "GET == 200" );

    $resp = $engine->POST(
        {   url     => 'foo/bar',
            content => '<doc><title>i am a POST test</title></doc>',
            type    => 'application/xml',
        }
    );

    dump($resp);
    is( $resp->{code}, 200, "POST == 200" );
    $resp = $engine->GET('foo/bar');

    dump($resp);
    is( $resp->{code}, 200, "GET == 200" );
    is( $resp->{doc}->{title}, "i am a POST test", "title updated" );

    $resp = $engine->DELETE('foo/bar');
    dump($resp);
    is( $resp->{code}, 204, "DELETE == 204" );
}
