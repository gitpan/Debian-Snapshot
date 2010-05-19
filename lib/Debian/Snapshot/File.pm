package Debian::Snapshot::File;
BEGIN {
  $Debian::Snapshot::File::VERSION = '0.002';
}
# ABSTRACT: information about a file

use Moose;
use MooseX::Params::Validate;
use MooseX::StrictConstructor;
use namespace::autoclean;

use File::Spec;

has 'hash' => (
	is       => 'ro',
	isa      => 'Str',
	required => 1,
);

has '_fileinfo' => (
	is      => 'ro',
	isa     => 'ArrayRef[HashRef]',
	lazy    => 1,
	builder => '_fileinfo_builder',
);

has '_service' => (
	is       => 'ro',
	isa      => 'Debian::Snapshot',
	required => 1,
);

sub archive {
	my ($self, $archive_name) = @_;

	$archive_name = qr/^\Q$archive_name\E$/ unless ref($archive_name) eq 'Regexp';

	my @archives = map $_->{archive_name}, @{ $self->_fileinfo };
	return 0 != grep $_ =~ $archive_name, @archives;
}

sub download {
	my ($self, %p) = validated_hash(\@_,
		archive_name => { isa => 'Str | RegexpRef', default => 'debian', },
		directory    => { isa => 'Str', optional => 1, },
		filename     => { isa => 'Str | RegexpRef', optional => 1, },
	);
	my $hash = $self->hash;

	unless (defined $p{directory} || defined $p{filename}) {
		die "One of 'directory', 'file' parameters must be given.";
	}
	if (ref($p{filename}) eq 'Regexp' && ! defined $p{directory}) {
		die "Parameter 'directory' is required if 'filename' is a regular expression.";
	}

	my $filename = $p{filename};
	if (ref($p{filename}) eq 'Regexp' || ! defined $filename) {
		$filename = $self->filename($p{archive_name}, $p{filename});
	}

	if (defined $p{directory}) {
		$filename = File::Spec->catfile($p{directory}, $filename);
	}

	$self->_service->_get("/file/$hash", ':content_file' => $filename);

	return $filename;
}

sub filename {
	my ($self, $archive_name, $constraint) = @_;
	my $hash = $self->hash;

	$archive_name = qr/^\Q$archive_name\E$/ unless ref($archive_name) eq 'Regexp';

	my @fileinfo = grep $_->{archive_name} =~ $archive_name, @{ $self->_fileinfo };
	my @names    = map $_->{name}, @fileinfo;
	die "No filename found for file $hash." unless @names;

	if (defined $constraint) {
		$constraint = qr/^\Q$constraint\E_/ unless ref($constraint) eq 'Regexp';
		@names = grep $_ =~ $constraint, @names;
		die "No matching filename found for file $hash." unless @names;
	}

	return @names if wantarray;
	die "More than one filename and calling function does not want a list." unless @names == 1;

	my $filename = $names[0];

	die "Filename contains a slash." if $filename =~ m{/};
	die "Filename does not start with an alphanumeric character." unless $filename =~ m{^[a-zA-Z0-9]};

	return $filename;
}
	
sub _fileinfo_builder {
	my $self = shift;
	my $hash = $self->hash;
	$self->_service->_get_json("/mr/file/$hash/info")->{result};
}

__PACKAGE__->meta->make_immutable;
1;



=pod

=head1 NAME

Debian::Snapshot::File - information about a file

=head1 VERSION

version 0.002

=head1 ATTRIBUTES

=head2 hash

The hash of this file.

=head1 METHODS

=head2 archive($archive_name)

Check if this file belongs to the archive C<$archive_name> which can either be
a string or a regular expression.

=head2 download(%params)

Download the file from the snapshot service.

=over

=item archive_name

Name of the archive used when looking for the filename.
Defaults to C<"debian">.

=item directory

The name of the directory where the file should be stored.

=item filename

The filename to use.  If this option is not specified the method C<filename>
will be used to retrieve the filename.

=back

At least one of C<directory> and C<filename> must be given.

=head2 filename($archive_name, $constraint?)

Return the filename(s) of this file in the archive C<$archive_name> (which
might be a string or a regular expression).  Will die if there is no known
filename or several filenames were want and the method is called in scalar
context.

If the optional parameter C<$constraint> is specified the filename must either
start with this string followed by an underscore or match this regular
expression.

=head1 SEE ALSO

L<Debian::Snapshot>

=head1 AUTHOR

  Ansgar Burchardt <ansgar@43-1.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2010 by Ansgar Burchardt <ansgar@43-1.org>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__

