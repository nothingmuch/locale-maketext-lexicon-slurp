package Locale::Maketext::Lexicon::Slurp;
use Moose;

use File::Basename ();
use Path::Class;

our $VERSION = "0.01";
our $AUTHORITY = 'NUFFIN';

sub read_file {
	my ( $self, %args ) = @_;

	local $/;

    my $file = $args{path};

	open my $fh, "<", $file or die "open($file): $!";

    binmode $fh, $args{binmode} if exists $args{binmode};

	scalar(<$fh>);
}

sub readdir {
    my ( $self, $dir ) = @_;
    map { "$_" } Path::Class::dir( $dir )->children;
}

sub get_files {
	my ( $self, $args ) = @_;

    my @files;
    my $dir = $args->{dir};

    if ( $dir ) {
        my $readdir = $args->{readdir} || "readdir";
        @files = $self->$readdir( $dir );
    } elsif ( my $files = $args->{files} ) {
        @files = @$files;
    }

    if ( my $re = $args->{regex} ) {
        @files = grep { $_ =~ $re } @files;
    } elsif ( my $filter = $args->{filter} ) {
        @files = grep { $self->$filter( $_ ) } @files;    
    }

    if ( @files ) {
        if ( $dir ) {
            my $dir_obj = Path::Class::dir($dir);
            return { map { Path::Class::file($_)->relative( $dir_obj )->stringify => "$_" } @files },
        } else {
            return { map { File::Basename::basename($_) => "$_" } @files };
        }
	}

	die "No files specified";
}

sub parse {
	my ( $self, @args ) = @_;

    unshift @args, "dir" if @args % 2 == 1; # work in Lexicon's * mode

    my $args = { @args };

	my $files = $self->get_files( $args );

	return {
		map {
			my $name = $_;
			my $path = $files->{$name};
                $name => sub {
                    return $self->read_file(
                        %$args,
                        path => $path,
                        name => $name,
                        args => \@_
                    )
                }
		} keys %$files
	};
}

1;

__END__

=pod

=head1 NAME

Locale::Maketext::Lexicon::Slurp - 

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=over 4

=item B<get_files ($args)>

=item B<parse (@args)>

=item B<read_file (%args)>

=item B<readdir ($dir)>

=item B<meta>

=back

=head1 BUGS

All complex software has bugs lurking in it, and this module is no 
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

=head1 AUTHOR

Yuval Kogman

=head1 COPYRIGHT AND LICENSE

Copyright 2007 by Infinity Interactive, Inc.

L<http://www.iinteractive.com>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
