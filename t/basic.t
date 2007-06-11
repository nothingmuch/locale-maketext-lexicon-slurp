#!/usr/bin/perl

use strict;
use warnings;

use Test::More 'no_plan';

use ok 'Locale::Maketext::Lexicon::Slurp';

use Path::Class;

my $t_dir;
BEGIN { $t_dir = Path::Class::file( __FILE__ )->parent };

{
	package Foo::I18N;
	use base 'Locale::Maketext';

	use Locale::Maketext::Lexicon {
        #'*' => [ Slurp => $t_dir->file("files", "*")->stringify ], # blah, not gonna work well =/
        en => [ Slurp => [ $t_dir->file("files", "en")->stringify, regex => qr{(^|/)(hello|cat)$} ] ],
        de => [ Slurp => [ $t_dir->file("files", "de")->stringify, regex => qr{(^|/)(hello|cat)$} ] ],
    };
}

my $en = Foo::I18N->get_handle("en");
my $de = Foo::I18N->get_handle("de");

::ok( $en, "handle" );
::ok( $de, "handle" );

like( $en->maketext( "hello" ), qr/^hello$/, "hello" );
like( $de->maketext( "hello" ), qr/^hallo$/, "hello" );

like( $en->maketext( "cat" ), qr/^cat$/, "cat" );
like( $de->maketext( "cat" ), qr/^katze$/, "cat" );

ok( !eval{ $en->maketext("dog") }, "no dog" );
ok( !eval{ $de->maketext("dog") }, "no dog" );

