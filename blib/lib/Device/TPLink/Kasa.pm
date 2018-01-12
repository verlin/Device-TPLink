package Device::TPLink::Kasa;

use 5.006;
use Moose;
use Carp;
use JSON; # The Kasa API is JSON based
use LWP::JSON::Tiny; # Simplify working with JSON requests
use UUID::Generator::PurePerl; # Used to generate UUIDs for Kasa if we aren't passed one...

use Device::TPLink::SmartHome::Kasa;

has 'uuid' => (
  is => 'rw',
  isa => 'Str',
 );

has 'username' => (
  is => 'rw',
  isa => 'Str',
);

has 'password' => (
  is => 'rw',
  isa => 'Str',
);

has 'token' => (
  is => 'rw',
  isa => 'Str',
);

=head1 NAME

Device::TPLink::Kasa - The great new Device::TPLink::Kasa!

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use Device::TPLink::Kasa;

    my $foo = Device::TPLink::Kasa->new();
    ...

=head1 SUBROUTINES/METHODS

=head2 function1

=cut

sub resetToken {
  my $self = shift;

  # If we don't already have a UUID set, generate a new one.
  unless ($self->uuid) {
    my $ug = UUID::Generator::PurePerl->new();
    my $uuid = $ug->generate_v4();
    $self->uuid($uuid->as_string());
  }

  # If the username and/or password are not set, bail out with an error.
  unless ($self->username && $self->password) {
    Carp::croak "Username and/or password not set!";
  }

  # We have a username, password, and UUID - everything we need to get a new token
  my $credentials = {
    appType => 'Kasa_Android',
    cloudUserName => $self->username,
    cloudPassword => $self->password,
    terminalUUID => $self->uuid
  };

  my $request_object = {
     method => 'login',
     params => $credentials
  };

  my $user_agent = LWP::UserAgent::JSON->new;
  # Uncomment the next two lines if you need to debug...
  #$user_agent->add_handler("request_send",  sub { shift->dump; return });
  #$user_agent->add_handler("response_done", sub { shift->dump; return });

  my $request = HTTP::Request::JSON->new(POST => "https://wap.tplinkcloud.com");
  $request->header('Accept' => '*/*'); # Really, really annoying, but required by Kasa service...
  $request->json_content( $request_object );

  my $response = $user_agent->request($request);
  my $response_json_string =  $response->content;
  #print $response_json_string;

  my $json = JSON->new->allow_nonref;
  $json = $json->pretty(1);

  my $response_perl_scalar = $json->decode( $response_json_string );
  $self->token($response_perl_scalar->{result}{token});

  return 1;
}

=head2 function2

=cut

sub getDevices {
  my $self = shift;

  # If we don't have a token, bail out with an error
  unless ($self->token) {
    Carp::croak "No token found!";
  }

  my $token = $self->token;
  my $user_agent = LWP::UserAgent::JSON->new;
  # Uncomment the next two lines if you need to debug...
  #$user_agent->add_handler("request_send",  sub { shift->dump; return });
  #$user_agent->add_handler("response_done", sub { shift->dump; return });

  my $json = JSON->new->allow_nonref;
  $json = $json->pretty(1);
  my $request_object = { method => "getDeviceList" };
  my $url = "https://wap.tplinkcloud.com?token=$token";
  my $request = HTTP::Request::JSON->new(POST => $url);
  $request->header('Accept' => '*/*');
  $request->json_content( $request_object );
  my $response = $user_agent->request($request);
  my $response_json_string =  $response->content;
  my $response_perl_scalar = $json->decode( $response_json_string );

  my @devices = ();
  for my $a (@{$response_perl_scalar->{result}{deviceList}}) {
    my $device = Device::TPLink::SmartHome::Kasa->new($a);
    $device->token($token);
    push @devices, $device;
  }

  return @devices;
}

=head1 AUTHOR

Verlin Henderson, C<< <verlin at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-device-tplink at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Device-TPLink>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Device::TPLink::Kasa


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Device-TPLink>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Device-TPLink>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Device-TPLink>

=item * Search CPAN

L<http://search.cpan.org/dist/Device-TPLink/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2018 Verlin Henderson.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


=cut

__PACKAGE__->meta->make_immutable;

1; # End of Device::TPLink::Kasa
