
=head1 NAME

ASRegistry::Component - Represents the definition of an activity or object component in the registry.

=cut

package ASRegistry::Component;

use strict;
use warnings;

sub from_dict {
    my ($class, $dict, $spec) = @_;

    my $self = bless {}, $class;

    $self->{name} = $dict->{name};
    $self->{spec} = $spec;
    $self->{description} = $dict->{description};
    $self->{specification_anchor} = $dict->{specification_anchor};
    if ($dict->{json}) {
        my $json = $self->{json} = {};
        $json->{property_name} = $dict->{json}{property_name};
        $json->{specification_anchor} = $dict->{json}{specification_anchor};
    }

    return $self;
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

sub has_json_property {
    return $_[0]->{json} ? 1 : 0;
}

sub json_property_name {
    return $_[0]->{json} ? $_[0]->{json}{property_name} : undef;
}

sub spec_url {
    my ($self) = @_;

    my $spec_url = $self->spec->spec_url;
    my $anchor = $self->{specification_anchor};

    return join('#', $spec_url, $anchor ? ($anchor) : ());
}

sub json_spec_url {
    my ($self) = @_;

    return unless $self->{json};


    my $spec_url = $self->spec->spec_url;
    my $anchor = $self->{json}{specification_anchor};

    return join('#', $spec_url, $anchor ? ($anchor) : ());
}

sub is_draft {
    return $_[0]->spec->is_draft;
}

sub date {
    return $_[0]->spec->date;
}

1;

