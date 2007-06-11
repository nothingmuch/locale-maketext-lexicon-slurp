package Locale::Maketext::Lexicon::Slurp;
use Moose;

use File::Basename ();
use Path::Class;

our $VERSION = "0.01";

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
