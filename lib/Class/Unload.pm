package Class::Unload;

=encoding utf8

use warnings;
use strict;
no strict 'refs'; # we're fiddling with the symbol table

use Class::Inspector;

=head1 NAME

Class::Unload - Unload a class

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

Unload a class

    use Class::Unload;
    use Class::Inspector;

    use Some::Class;

    Class::Unload->unload( 'Some::Class' );
    Class::Inspector->loaded( 'Some::Class' ); # Returns false

    require Some::Class; # Reloads the class

=head1 METHODDS

=head2 unload $class

Unloads the given class by clearing out its symbol table and removing it
from %INC. If it has no sub-namespaces, also deletes the reference from
the parent namespace.

=cut

sub unload {
    my ($self, $class) = @_;

    return unless Class::Inspector->loaded( $class );

    my $symtab = $class.'::';
    # Delete all symbols except other namespaces
    for my $symbol (keys %$symtab) {
        next if substr($symbol, -2, 2) eq '::';
        delete $symtab->{$symbol};
    }
    
    # Delete the reference from the parent namespace if there are no
    # sub-namespaces.
    if (not keys %$symtab) {
        my ($parent, $child) = $class =~ m/\A(?:([^\W\d]\w*)::)?(\w+)*\z/s;
        $parent ||= 'main';
        delete ${$parent.'::'}{$child.'::'};
    }

    delete $INC{ Class::Inspector->filename( $class ) };
    
    return 1;
}

=head1 AUTHOR

Dagfinn Ilmari Mannsåker, C<< <ilmari at ilmari.org> >>

=head1 SEE ALSO

L<Class::Inspector>

=head1 BUGS

Please report any bugs or feature requests to C<bug-class-unload at
rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Class-Unload>. I will
be notified, and then you'll automatically be notified of progress on
your bug as I make changes.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Class::Unload


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Class-Unload>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Class-Unload>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Class-Unload>

=item * Search CPAN

L<http://search.cpan.org/dist/Class-Unload>

=item * Git reposiory

L<http://git.ilmari.org/?p=Class-Unload.git>

C<git://git.ilmari.org/Class-Unload.git>


=back


=head1 ACKNOWLEDGEMENTS

Thanks to Matt S. Trout, James Mastros and Uri Guttman for various tips
and pointers.

=head1 COPYRIGHT & LICENSE

Copyright 2008 Dagfinn Ilmari Mannsåker.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

1; # End of Class::Unload
