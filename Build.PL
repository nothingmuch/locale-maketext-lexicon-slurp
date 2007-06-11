
use strict;
use warnings;

use Module::Build;

my $build = Module::Build->new(
    module_name => 'Locale::Maketext::Lexicon::Slurp',
    license => 'perl',
    requires => {   
        'Moose'                     => '0.20',
        'File::Basename'            => '0',
        'Path::Class'               => '0',
        'Locale::Maketext'          => '0',
        'Locale::Maketext::Lexicon' => '0',
    },
    optional => {    
    },
    build_requires => {
        'Test::More'       => '0.62',
        'Test::Exception'  => '0.21',
    },
    create_makefile_pl => 'traditional',
    recursive_test_files => 1,
    add_to_cleanup => [
        'META.yml', '*.bak', '*.gz', 'Makefile.PL',
    ],
);

$build->create_build_script;

