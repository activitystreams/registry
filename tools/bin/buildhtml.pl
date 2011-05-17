#!/usr/bin/perl

=head1 NAME

buildhtml - parses a directory of registry JSON files and produces HTML pages describing the contents.

=head1 SYNOPSIS

    buildhtml <source directory> <target directory>

=cut

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";

use Pod::Usage;
use Template;
use Data::Dumper;
use File::Path;

use ASRegistry;

my $tt = Template->new({
    INCLUDE_PATH => "$FindBin::Bin/../templates",
});

my $source_dir = shift or pod2usage("Source directory is required");
my $target_dir = shift or pod2usage("Target directory is required");

my $registry = ASRegistry->from_source_dir($source_dir);

# Specs index page
{
    my $vars = {};
    my $draft_specs = $vars->{specs}{draft} = [];
    my $published_specs = $vars->{specs}{published} = [];

    foreach my $spec (@{$registry->specs}) {
        if ($spec->is_draft) {
            push @$draft_specs, spec_summary_for_template($spec);
        }
        else {
            push @$published_specs, spec_summary_for_template($spec);
        }
    }

    build_page('specs', 'specs.tt', $vars);
}

# Individual Spec index pages.
{
    foreach my $spec (@{$registry->specs}) {
        my $vars = {};
        $vars->{spec} = spec_summary_for_template($spec);

        my $verbs = $vars->{verbs} = [];
        foreach my $verb (sort { $a->name cmp $b->name } @{$spec->verbs}) {
            push @$verbs, term_summary_for_template($verb);
        }

        my $object_types = $vars->{object_types} = [];
        foreach my $object_type (sort { $a->name cmp $b->name } @{$spec->object_types}) {
            push @$object_types, term_summary_for_template($object_type);
        }

        my $activity_components = $vars->{activity_components} = [];
        foreach my $component (sort { $a->name cmp $b->name } @{$spec->activity_components}) {
            push @$activity_components, component_summary_for_template($component);
        }

        my $object_components = $vars->{object_components} = [];
        foreach my $component (sort { $a->name cmp $b->name } @{$spec->object_components}) {
            push @$object_components, component_summary_for_template($component);
        }

        my $fn = "specs/".$spec->identifier;
        build_page($fn, 'spec.tt', $vars);
    }
}

# Whole-registry index pages
{
    my $object_types = [ map { term_summary_for_template($_) } @{$registry->object_types} ];

    my $vars = {};
    $vars->{object_types} = $object_types;

    my $fn = "object_types";
    build_page($fn, 'object_types.tt', $vars);
}
{
    my $verbs = [ map { term_summary_for_template($_) } @{$registry->verbs} ];

    my $vars = {};
    $vars->{verbs} = $verbs;

    my $fn = "verbs";
    build_page($fn, 'verbs.tt', $vars);
}
{
    my $activity_components = [ map { component_summary_for_template($_) } @{$registry->activity_components} ];

    my $vars = {};
    $vars->{components} = $activity_components;

    my $fn = "activity_components";
    build_page($fn, 'activity_components.tt', $vars);
}
{
    my $object_components = [ map { component_summary_for_template($_) } @{$registry->object_components} ];

    my $vars = {};
    $vars->{components} = $object_components;

    my $fn = "object_components";
    build_page($fn, 'object_components.tt', $vars);
}

# The home page
{
    build_page(".", 'home.tt', {});
}

# Copy over the static media files
{
    mkdir("$target_dir/media");
    system('cp', '-r', glob("$FindBin::Bin/../media/*"), "$target_dir/media");
}

sub spec_summary_for_template {
    my ($spec) = @_;

    my $ret = {};
    $ret->{title} = $spec->title;
    $ret->{identifier} = $spec->identifier;
    $ret->{index_url} = "specs/".$spec->identifier."/";
    $ret->{is_draft} = $spec->is_draft;
    $ret->{date} = $spec->date;
    return $ret;
}

sub term_summary_for_template {
    my ($verb) = @_;

    my $spec = $verb->spec;

    my $ret = {};
    $ret->{name} = $verb->name;
    $ret->{identifier} = $verb->identifier;
    $ret->{spec_url} = $verb->spec_url;
    $ret->{is_draft} = $verb->is_draft;
    $ret->{description} = $verb->description;
    $ret->{spec} = spec_summary_for_template($verb->spec);
    return $ret;
}

sub component_summary_for_template {
    my ($component) = @_;

    my $spec = $component->spec;

    my $ret = {};
    $ret->{name} = $component->name;
    $ret->{json_property_name} = $component->json_property_name;
    $ret->{json_spec_url} = $component->json_spec_url;
    $ret->{spec_url} = $component->spec_url;
    $ret->{is_draft} = $component->is_draft;
    $ret->{description} = $component->description;
    $ret->{spec} = spec_summary_for_template($component->spec);
    return $ret;
}

sub build_page {
    my ($page_fn, $template, $vars) = @_;

    my $real_fn = "$target_dir/$page_fn/index.html";
    my $dir_name = $real_fn;
    $dir_name =~ s!/[^/]+$!!;
    File::Path::mkpath($dir_name);
    $tt->process($template, $vars, $real_fn) || die $tt->error(), "\n";
}

