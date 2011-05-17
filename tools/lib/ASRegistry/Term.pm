
=head1 NAME

ASRegistry::Term - Represents the definition of a verb or object type in the registry.

=cut

package ASRegistry::Term;

use strict;
use warnings;

sub from_dict {
    my ($class, $dict, $spec) = @_;

    my $self = bless {}, $class;

    $self->{identifier} = $dict->{identifier};
    $self->{name} = $dict->{name};
    $self->{spec} = $spec;
    $self->{description} = $dict->{description};
    $self->{specification_anchor} = $dict->{specification_anchor};

    return $self;
}

sub identifier {
    return $_[0]->{identifier};
}

sub name {
    return $_[0]->{name};
}

sub spec {
    return $_[0]->{spec};
}

sub description {
    return $_[0]->{description};
}

sub spec_url {
    my ($self) = @_;

    my $spec_url = $self->spec->spec_url;
    my $anchor = $self->{specification_anchor};

    return join('#', $spec_url, $anchor ? ($anchor) : ());
}

sub is_draft {
    return $_[0]->spec->is_draft;
}

sub date {
    return $_[0]->spec->date;
}

1;

