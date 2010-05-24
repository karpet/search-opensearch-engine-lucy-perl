package Search::OpenSearch::Engine::KSx;
use strict;
use warnings;
use Carp;
use base qw( Search::OpenSearch::Engine );
use SWISH::Prog::KSx::Searcher;
use KinoSearch::Object::BitVector;
use KinoSearch::Search::HitCollector::BitCollector;

our $VERSION = '0.03';

sub init_searcher {
    my $self     = shift;
    my $index    = $self->index or croak "index not defined";
    my $searcher = SWISH::Prog::KSx::Searcher->new( invindex => $index );
    return $searcher;
}

sub build_facets {
    my $self     = shift;
    my $query    = shift or croak "query required";
    my $results  = shift or croak "results required";
    my $facetobj = $self->facets or return;

    my @facet_names  = @{ $facetobj->names };
    my $sample_size  = $facetobj->sample_size;
    my $searcher     = $self->searcher;
    my $ks_searcher  = $searcher->{ks};
    my $query_parser = $searcher->{qp};
    my $bit_vec      = KinoSearch::Object::BitVector->new(
        capacity => $ks_searcher->doc_max + 1 );
    my $collector = KinoSearch::Search::HitCollector::BitCollector->new(
        bit_vector => $bit_vec, );

    $ks_searcher->collect(
        query     => $query_parser->parse("$query")->as_ks_query(),
        collector => $collector
    );

    # find the facets
    my %facets;
    my $doc_id = 0;
    my $count  = 0;
    while (1) {
        $doc_id = $bit_vec->next_set_bit( $doc_id + 1 );
        last if $doc_id == -1;
        last if $sample_size and ++$count > $sample_size;
        my $doc = $ks_searcher->fetch_doc( doc_id => $doc_id );
        for my $name (@facet_names) {

            # unique-ify
            my %val = map { $_ => $_ }
                split( m/\003/, $doc->{$name} );
            for my $value ( keys %val ) {
                $facets{$name}->{$value}++;
            }
        }
    }

    # turn the struct inside out a bit, esp for XML
    my %facet_struct;
    for my $f ( keys %facets ) {
        for my $n ( keys %{ $facets{$f} } ) {
            push @{ $facet_struct{$f} },
                { term => $n, count => $facets{$f}->{$n} };
        }
    }
    return \%facet_struct;
}

1;

__END__

=head1 NAME

Search::OpenSearch::Engine::KSx - KinoSearch server with OpenSearch results

=head1 SYNOPSIS

=head1 METHODS

=head2 init_searcher

Returns a SWISH::Prog::KSx::Searcher object.

=head2 build_facets( I<query>, I<results> )

Returns hash ref of facets from I<results>. See Search::OpenSearch::Engine.

=head1 AUTHOR

Peter Karman, C<< <karman at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-search-opensearch-engine-ksx at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Search-OpenSearch-Engine-KSx>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Search::OpenSearch::Engine::KSx


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Search-OpenSearch-Engine-KSx>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Search-OpenSearch-Engine-KSx>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Search-OpenSearch-Engine-KSx>

=item * Search CPAN

L<http://search.cpan.org/dist/Search-OpenSearch-Engine-KSx/>

=back

=head1 COPYRIGHT & LICENSE

Copyright 2010 Peter Karman.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut
