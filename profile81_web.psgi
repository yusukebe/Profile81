#!/usr/bin/perl
use strict;
use Mojo::Server::PSGI;
use File::Spec;
use File::Basename;
use lib File::Spec->catdir(dirname(__FILE__), 'lib');
use Plack::Builder;
use Plack::Session::Store::DBI;
use Profile::Web;

$ENV{MOJO_APP} = 'Profile::Web';
my $psgi = Mojo::Server::PSGI->new( app => Profile::Web->new );
my $app = sub { $psgi->run(@_) };

builder {
    enable "Plack::Middleware::AccessLog", format => "combined";
    $app;
};
