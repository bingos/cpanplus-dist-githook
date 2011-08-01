package CPANPLUS::Dist::GitHook;

#ABSTRACT: Use Git::CPAN::Hook to commit each install in a Git repository

use strict;
use warnings;
use CPANPLUS::Error;
use Module::Load::Conditional qw[can_load];
use base qw[CPANPLUS::Dist::Base];

my $format_available;

sub format_available {
 return $format_available if defined $format_available;
 my $mod = 'Git::CPAN::Hook';
 unless( can_load( modules => { $mod => '0.03' }, nocache => 1 ) ) {
    error( loc( "You do not have '%1' -- '%2' not available",
                 $mod, __PACKAGE__ ) );
    return;
 }
 $format_available = 1;
}

sub init {
  require Git::CPAN::Hook;
  return 1;
}

sub install {
 my $self = shift;
 my $mod  = $self->parent;
 my $stat = $self->status;

 my $success = $self->SUPER::install( @_ );
 $stat->installed($success);

 if ( $success ) {
   ( my $dist = join '/', $mod->path, $mod->package ) =~ s!authors/id/!!;
   Git::CPAN::Hook->commit( $dist );
 }

 return $success;
}

sub uninstall {
 my $self = shift;
 my $mod  = $self->parent;
 my $stat = $self->status;

 my $success = $self->SUPER::uninstall( @_ );
 $stat->uninstalled($success);

 if ( $success ) {
   ( my $dist = join '/', $mod->path, $mod->package ) =~ s!authors/id/!!;
   Git::CPAN::Hook->commit( $dist );
 }

 return $success;
}

q[And now here is Hooky and the boys];
