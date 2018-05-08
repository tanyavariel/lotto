#!/usr/bin/perl
use Google::Voice;
use Getopt::Long;
use strict;
 
#Set your login info here!
my $username    = 'tonyamyos@gmail.com';
my $password    = "Yee4\!swuk";
# 
# #Do Not Edit Below Here!
#  
my ($help_opt, $phone_opt, $text_opt);
GetOptions("h|help"     => \$help_opt,
         "p|phone=s"  => \$phone_opt,
         "t|text=s"   => \$text_opt,
           );
die <<HELP_MSG
      sendtext.pl -p <phone_number> -t <text message>
           
     usage:  -h     this help message
             -p     phone number you want to send to
             -t     text message to send
HELP_MSG
#show help message if user types -h or does not include
#phone number or text message text
if (! $phone_opt or ! $text_opt or $help_opt);
#create Google::Voice object and login
my $gv_obj = Google::Voice->new->login('tsakovs\@gmail\.com', 'imp95bla');
# loop through voicemail messages
     foreach my $vm ($gv_obj->voicemail) {
#
     # Name, number, and transcribed text
     print $vm->name . "\n";
     print $vm->meta->{phoneNumber} . "\n";
     print $vm->text . "\n";

     # Download mp3
#                                                     $vm->download->move_to($vm->id . '.mp3');
#
 }

die<<NOOBJ
nope got no obj
NOOBJ
if (! $gv_obj);
#send the text!
$gv_obj->send_sms($phone_opt => $text_opt);
