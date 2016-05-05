#!/usr/bin/env perl

use strict;
use warnings;

BEGIN {
    unshift @INC, "../lib";
}

my $u2fhost = '/usr/local/bin/u2f-host';
my $appId = 'Example';
my $origin = 'http://127.0.0.1';

my $challengeID = 'HelloWorldSECRETKEY';

use Crypt::U2F::Server::Simple;
use MIME::Base64;

open(my $kifh, '<', 'keyHandle.dat') or die($!);
my $keyHandle = <$kifh>;
close $kifh;

open(my $pifh, '<', 'publicKey.dat') or die($!);
my $publicKey = <$pifh>;
$publicKey = decode_base64($publicKey);
close $pifh;

my $auth = Crypt::U2F::Server::Simple->new(appId=>$appId, origin=>$origin,
                                    keyHandle=>$keyHandle, publicKey=>$publicKey);
if(!defined($auth)) {
    die(Crypt::U2F::Server::Simple::lastError());
}

my $rc = $auth->setChallenge($challengeID);
if(!$rc) {
    die($auth->lastError());
}

my $challenge = $auth->authenticationChallenge();
if(!defined($challenge) || !length($challenge)) {
    die($auth->lastError());
}
open(my $cofh, '>', 'authChallenge.dat') or die($!);
print $cofh $challenge;
close $cofh;

my $regcmd = $u2fhost . ' -aauthenticate -o "' . $origin . '" < authChallenge.dat > authReply.dat';
print "Running $regcmd...\nPlease press the blinking button!\n";
`$regcmd`;
