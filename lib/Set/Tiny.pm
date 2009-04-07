package Set::Tiny;

use strict;
use warnings;

use overload q{""} => \&as_string;

our $VERSION = '0.01';

sub new {
    my $class = shift;
    my %self;
    @self{@_} = ();
    return bless \%self, $class;
}

sub as_string {
    my $self = shift;
    return "(" . join(", ", sort keys %$self) . ")";
}

sub size {
    my $self = shift;
    return scalar keys %$self;
}

sub elements {
    my $self = shift;
    return sort keys %$self;
}

sub contains {
    my $self = shift;
    exists $self->{$_} or return for @_;
    return 1;
}

sub clone {
    my $self = shift;
    my $class = ref $self;
    return $class->new( keys %$self );
}

sub clear {
    my $self = shift;
    %$self = ();
    return $self;
}

sub insert {
    my $self = shift;
    @{$self}{@_} = ();
    return $self;
}

sub remove {
    my $self = shift;
    delete @{$self}{@_};
    return $self;
}

sub invert {
    my $self = shift;
    exists $self->{$_} ? delete $self->{$_} : ($self->{$_} = undef) for @_;
    return $self;
}

sub is_empty {
    my $self = shift;
    return ! %$self;
}

sub is_subset {
    my ($self, $set) = @_;
    return $set->contains( keys %$self );
}

sub is_proper_subset {
    my ($self, $set) = @_;
    return $self->size < $set->size && $self->is_subset($set);
}

sub is_superset {
    my ($self, $set) = @_;
    return $set->is_subset($self);
}

sub is_proper_superset {
    my ($self, $set) = @_;
    return $self->size > $set->size && $set->is_subset($self);
}

sub is_equal {
    my ($self, $set) = @_;
    return $set->is_subset($self) && $self->is_subset($set);
}

sub is_disjoint {
    my ($self, $set) = @_;
    return $self->intersection($set)->size == 0;
}

sub difference {
    my ($self, $set) = @_;
    my $class = ref $self;
    my %difference = %$self;
    delete @difference{ keys %$set };
    return $class->new( keys %difference );
}

sub union {
    my ($self, $set) = @_;
    my $class = ref $self;
    return $class->new( keys %$self, keys %$set );
}

sub intersection {
    my ($self, $set) = @_;
    return $self->difference( $self->clone->difference($set) );
}

sub symmetric_difference {
    my ($self, $set) = @_;
    return $self->clone->invert( keys %$set );
}

{
    no warnings 'once';
    *has = \&contains;
    *members = \&elements;
    *delete = \&remove;
    *unique = \&symmetric_difference;
}

1;

__END__

=head1 NAME

Set::Tiny - Simple sets of strings

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

    use Set::Tiny;

    my $s1 = Set::Tiny->new(qw( a b c ));
    my $s2 = Set::Tiny->new(qw( b c d ));

    my $u  = $s1->union($s2);
    my $i  = $s1->intersection($s2);
    my $s  = $s1->symmetric_difference($s2);

    print "$u"; # (a, b, c ,d)
    print "$i"; # (b, c)
    print "$s"; # (a, d)

    print "$i is a subset of $s1"   if $i->is_subset($s1);
    print "$u is a superset of $s1" if $u->is_superset($s1);

=head1 DESCRIPTION

Set::Tiny is a thin wrapper around regular Perl hashes to perform often needed
set operations, such as testing two sets of strings for equality, or checking
whether one is contained within the other.

For a more complete implementation of mathematical set theory, see
L<Set::Scalar>. For sets of arbitrary objects instead of just strings, see
L<Set::Object>. Set::Tiny has less features but is also faster than both of
these in most cases. Run F<examples/benchmark.pl> for details.

=head2 Why Set::Tiny?

=over

=item Convenience

Set::Tiny aims to provide a convenient interface to commonly used set
operations, which you would usually implement using regular hashes and a couple
of C<for> loops (in fact, that's exactly what Set::Tiny does).

=item Speed

The price in performance you pay for this convenience when using a
full-featured set implementation like L<Set::Scalar> is way too high if you
don't actually need the advanced functionality it offers.

=item Ease of use

L<Set::Object> offers better performance than L<Set::Scalar>, but needs a C
compiler to install. Set::Tiny has no dependencies and contains no C code.

=back

=head1 METHODS

Note that all methods that expect a I<list> of set elements stringify their
arguments before inserting them into the set.

Unless otherwise specified, all methods return the invocant, so you can chain
method calls, e.g.

    $set->insert('a')->remove('b')->union($other_set);

The only operator that is overloaded for Set::Scalar objects is
stringification, which calls L</as_string>.

=head2 new( [I<list>] )

Class method. Returns a new Set::Tiny object, initialized with the strings in
I<list>, or the empty set if I<list> is empty.

=head2 clone

Returns a new set with the same elements as this one.

=head2 as_string

Returns the list of elements in parentheses, separated by commas.  This method
is called by the overloaded stringification operator.

=head2 size

Returns the number of elements.

=head2 members

=head2 elements

Returns the list of elements.

=head2 has( [I<list>] )

=head2 contains( [I<list>] )

Returns true if B<all> of the elements in I<list> are members of the set. If
I<list> is empty, returns true.

=head2 clear

Removes all elements from the set.

=head2 insert( [I<list>] )

Inserts the elements in I<list> into the set.

=head2 delete( [I<list>] )

=head2 remove( [I<list>] )

Removes the elements in I<list> from the set. Elements that are not members of
the set are ignored.

=head2 invert( [I<list>] )

For each element in I<list>, if it is already a member of the set, deletes it
from the set, else insert it into the set.

=head2 is_empty

Returns true if the set is the empty set.

=head2 is_subset( I<set> )

Returns true if this set is a subset of I<set>.

=head2 is_proper_subset( I<set> )

Returns true if this set is a proper subset of I<set>.

=head2 is_superset( I<set> )

Returns true if this set is a superset of I<set>.

=head2 is_proper_superset( I<set> )

Returns true if this set is a proper superset of I<set>.

=head2 is_equal( I<set> )

Returns true if this set contains the same elements as I<set>.

=head2 is_disjoint( I<set> )

Returns true if this set has no elements in common with I<set>. Note that the
empty set is disjoint to any other set.

=head2 difference( I<set> )

Returns a new set containing the elements of this set with the elements of
I<set> removed.

=head2 union( I<set> )

Returns a new set containing both the elements of this set and I<set>.

=head2 intersection( I<set> )

Returns a new set containing the elements that are present in both this set and
I<set>.

=head2 unique( I<set> )

=head2 symmetric_difference( I<set> )

Returns a new set containing the elements that are present in either this set
or I<set>, but not in both.

=head1 AUTHOR

Stanis Trendelenburg, C<< <stanis.trendelenburg at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-set-tiny at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Set-Tiny>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 COPYRIGHT & LICENSE

Copyright 2009 Stanis Trendelenburg, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=head1 SEE ALSO

L<Set::Scalar>, L<Set::Object>

