
=head1 NAME

ASRegistry::Spec - Represents the definition of a specification in the registry.

=cut

package ASRegistry::Spec;

use strict;
use warnings;

use ASRegistry::Term;
use ASRegistry::Component;

sub from_dict {
    my ($class, $dict) = @_;

    my $self = bless {}, $class;

    $self->{identifier} = $dict->{identifier};
    $self->{title} = $dict->{title};
    $self->{specification_url} = $dict->{specification_url};
    $self->{status} = $dict->{status} || 'published';
    $self->{date} = $dict->{date} || '0000-00-00';

    my $verbs = $self->{verbs} = [];
    if (my $verb_dicts = $dict->{verbs}) {
        foreach my $dict (@$verb_dicts) {
            push @$verbs, ASRegistry::Term->from_dict($dict, $self);
        }
    }

    my $object_types = $self->{object_types} = [];
    if (my $object_type_dicts = $dict->{object_types}) {
        foreach my $dict (@$object_type_dicts) {
            push @$object_types, ASRegistry::Term->from_dict($dict, $self);
        }
    }

    my $activity_components = $self->{activity_components} = [];
    if (my $activity_component_dicts = $dict->{activity_components}) {
        foreach my $dict (@$activity_component_dicts) {
            push @$activity_components, ASRegistry::Component->from_dict($dict, $self);
        }
    }

    my $object_components = $self->{object_components} = [];
    if (my $object_component_dicts = $dict->{object_components}) {
        foreach my $dict (@$object_component_dicts) {
            push @$object_components, ASRegistry::Component->from_dict($dict, $self);
        }
    }

    return $self;
}

sub identifier {
    return $_[0]->{identifier};
}

sub title {
    return $_[0]->{title};
}

sub spec_url {
    return $_[0]->{specification_url};
}

sub status {
    return $_[0]->{status};
}

sub is_draft {
    return $_[0]->{status} eq 'draft' ? 1 : 0;
}

sub date {
    return $_[0]->{date};
}

sub verbs {
    return $_[0]->{verbs};
}

sub object_types {
    return $_[0]->{object_types};
}

sub object_components {
    return $_[0]->{object_components};
}

sub activity_components {
    return $_[0]->{activity_components};
}

1;
