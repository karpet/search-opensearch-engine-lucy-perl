use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME          => 'Search::OpenSearch::Engine::KSx',
    AUTHOR        => q{Peter Karman <karman@cpan.org>},
    VERSION_FROM  => 'lib/Search/OpenSearch/Engine/KSx.pm',
    ABSTRACT_FROM => 'lib/Search/OpenSearch/Engine/KSx.pm',
    ( $ExtUtils::MakeMaker::VERSION >= 6.3002
        ? ( 'LICENSE' => 'perl' )
        : () ),
    PL_FILES  => {},
    PREREQ_PM => {
        'Test::More'         => 0,
        'Search::OpenSearch' => 0.07,
        'SWISH::Prog::KSx'   => 0.08,
    },
    dist => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'Search-OpenSearch-Engine-KSx-*' },
);
