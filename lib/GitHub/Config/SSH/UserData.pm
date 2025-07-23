package GitHub::Config::SSH::UserData;

use 5.010;
use strict;
use warnings;
use autodie;

use Carp;
use File::Spec::Functions;

use Exporter 'import';

use constant DEFAULT_CFG_FILE => catfile($ENV{HOME}, qw(.ssh config));

our $VERSION = '0.01';


use Exporter 'import';

our @EXPORT_OK = qw(get_user_data_from_ssh_cfg);

#
# get_user_data USER_NAME
#
# Reads ‘~/.ssh/config’ and returns a hash consisting containing the user's
# full name ('full_name') and e-mail address ('email') from this file.
#
sub get_user_data_from_ssh_cfg {
  my $user_name = shift;
  my $config_file = shift // DEFAULT_CFG_FILE;

  open(my $hndl, '<', $config_file);
  my %seen;
  my $cfg_data;
  while (defined(my $line = <$hndl>)) {
    if ($line =~ /^Host\s+github-(\S+)\s*$/) {
      my $current_user_name = $1;
      croak("$current_user_name: duplicate user name") if exists($seen{$current_user_name});
      $seen{$current_user_name} = undef;
      next if $current_user_name ne $user_name;
      $line = <$hndl> // die("$config_file: unexpected EOF");
      $line =~ /^\s*\#\s*
                User:\s*
                (?:([^<>\s]+(?:\s+[^<>\s]+)*)\s*)?  # User name (optional)
                <(\S+?)>\s*                         # Email address for git configuration
                (?:<([^<>\s]+)>\s*)?                # Second email address (optional)
                (?:(\S+(\s+\S+)))?$                 # other data (optional)
               /x or
        croak("$current_user_name: missing or invalid user info");
      @{$cfg_data}{qw(full_name email email2 other_data)} = @{^CAPTURE};
      $cfg_data->{full_name} //= $current_user_name;
      delete @{$cfg_data}{ grep { not defined $cfg_data->{$_} } keys %{$cfg_data} };
      last;
    }
  }
  close($hndl);
  croak("$user_name: user name not in $config_file") unless $cfg_data;
  return $cfg_data;
}


=head1 NAME

GitHub::Config::SSH::UserData - The great new GitHub::Config::SSH::UserData!

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use GitHub::Config::SSH::UserData;

    my $foo = GitHub::Config::SSH::UserData->new();
    ...

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 SUBROUTINES/METHODS

=head2 function1

...

=head1 AUTHOR

Klaus Rindfrey, C<< <klausrin at cpan.org.eu> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-github-config-ssh-userdata at rt.cpan.org>, or through
the web interface at L<https://rt.cpan.org/NoAuth/ReportBug.html?Queue=GitHub-Config-SSH-UserData>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc GitHub::Config::SSH::UserData


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<https://rt.cpan.org/NoAuth/Bugs.html?Dist=GitHub-Config-SSH-UserData>

=item * Search CPAN

L<https://metacpan.org/release/GitHub-Config-SSH-UserData>

=item * GitHub Repository

L<https://github.com/klaus-rindfrey/perl-github-config-ssh-userdata>


=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

This software is copyright (c) 2025 by Klaus Rindfrey.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.


=cut

1; # End of GitHub::Config::SSH::UserData
