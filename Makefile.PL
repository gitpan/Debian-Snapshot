
use strict;
use warnings;



use ExtUtils::MakeMaker 6.31;



my %WriteMakefileArgs = (
                       'test' => {
                                   'TESTS' => 't/*.t'
                                 },
                       'NAME' => 'Debian::Snapshot',
                       'DISTNAME' => 'Debian-Snapshot',
                       'CONFIGURE_REQUIRES' => {
                                                 'ExtUtils::MakeMaker' => '6.31'
                                               },
                       'AUTHOR' => 'Ansgar Burchardt <ansgar@43-1.org>',
                       'BUILD_REQUIRES' => {
                                             'Test::More' => '0.88'
                                           },
                       'ABSTRACT' => 'interface to snapshot.debian.org',
                       'EXE_FILES' => [],
                       'VERSION' => '0.001',
                       'PREREQ_PM' => {
                                        'LWP::UserAgent' => '0',
                                        'MooseX::StrictConstructor' => '0',
                                        'IO::File' => '0',
                                        'namespace::autoclean' => '0',
                                        'File::Spec' => '0',
                                        'MooseX::Params::Validate' => '0',
                                        'JSON' => '0',
                                        'Moose' => '0'
                                      },
                       'LICENSE' => 'perl'
                     );


delete $WriteMakefileArgs{BUILD_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.56) };

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);



