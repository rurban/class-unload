#!perl -T

use strict;
use warnings;
use Test::More;

use Class::Inspector;
use Class::Unload;

use lib 't/lib';

for my $class ( qw/ MyClass MyClass::Sub MyClass::Sub::Sub / ) {
    eval "require $class" or diag $@;
    ok( Class::Inspector->loaded( $class ), "$class loaded" );
}

# Class::C3 creates this sort of cruft on 5.8
$MyClass::{'::ISA::CACHE::'} = 42;

ok( Class::Unload->unload( 'MyClass' ), 'Unloading MyClass' );
ok( ! Class::Inspector->loaded( 'MyClass' ), 'MyClass is not loaded' );
ok( ! exists($MyClass::{'::ISA::CACHE::'}), 'Stash cruft deleted' );
ok( Class::Inspector->loaded( 'MyClass::Sub' ), 'MyClass::Sub is still loaded' );

ok( Class::Unload->unload( 'MyClass::Sub' ), 'Unloading MyClass::Sub' );
ok( ! Class::Inspector->loaded( 'MyClass::Sub' ), 'MyClass::Sub is not loaded');

ok( Class::Unload->unload( 'MyClass::Sub::Sub' ), 'Unloading MyClass::Sub::Sub' );
ok( ! Class::Inspector->loaded( 'MyClass::Sub::Sub' ), 'MyClass::Sub::Sub is not loaded');

ok( ! Class::Unload->unload('MyClass'), 'Unloading not-loaded class');

ok( Class::Unload->unload( 'Class::Unload' ), 'Unloading Class::Unload' );
ok( ! Class::Inspector->loaded( 'Class::Unload' ), 'Class::Unload is not loaded' );

eval { Class::Unload->unload( 'dummy' ) };
like( $@, qr /Can't locate object method "unload" via package "Class::Unload"/,
      "Can't call method on unloaded class" );

done_testing;
