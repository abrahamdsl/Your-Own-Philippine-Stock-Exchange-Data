#!/usr/bin/perl
=doc
  A simple Perl script to retrieve current PSEi stocks during trading hours.
  Needs a source running phisix by Mr. Edge Dalmacio ( https://github.com/edgedalmacio/phisix ).
  
  Perl dependencies:

    LWP

LICENSE

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
=cut
use warnings;
use strict;
use LWP;
use POSIX qw(tzset);
use POSIX qw(strftime);

# set your time zone
$ENV{TZ} = 'Asia/Manila';

#retries if response is not HTTP 200, that is, error or similar
my $retries = 20;

# Create an object of a web browser 
my $browser = LWP::UserAgent->new;

# Parameters/headersm let's kinda spoof for user agent
my @ns_headers = (
  'User-Agent' => 'Mozilla/5.0 (Windows NT 6.1; WOW64; rv:37.0) Gecko/20100101 Firefox/37.0',
  'Accept' => 'application/json',
);

# get the relevant information about the time,
# reference: http://www.tutorialspoint.com/perl/perl_date_time.htm
my $datestring = strftime( "%Y %m %d %H %M %S %u" , localtime);
#my $datestring = $ARGV[0]; # Test code

# where to save?
my $destDir = '/tmp/PSE_data';

# Reference here: https://github.com/edgedalmacio/phisix
my $urlprovider = 'http://phisix-api3.appspot.com/stocks.json';
my $urlprovider2 = 'http://phisix-api4.appspot.com/stocks.json';

# what file to save on
my $destFile;

# Get patterns
$datestring =~ /^(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)/ ;

print "[$datestring]\n";

if ( isTradingHours( $7, $4, $5, $1, $2, $3 ) ) {
  my $http_code = 0;
  my $tries = 0;
  my $previousSource = '';

  $destFile = "$destDir/PSE.$1$2$3-$4$5$6.json";
  do{
    print "\t[attempt " . ($tries + 1 ) . "] Previous Code - $http_code\n";
    if ( $previousSource eq '' ) {
      $previousSource = $urlprovider;
    }elsif ( $previousSource eq $urlprovider ) {
      $previousSource = $urlprovider2;
    }elsif ( $previousSource eq $urlprovider2 ) {
       $previousSource = $urlprovider;
    }
    print "\t[notice] Trying source $previousSource\n";
    my $response = $browser->get( $previousSource );
    print "\t[result] " . $response->status_line . "\n";
    $response->status_line =~ /^(\d+)\s+(.*)$/;
    $http_code = $1;

    if ( $http_code == 200 ) {
      open( my $fh, ">:encoding(UTF-8)", $destFile ) or
        die( print( "\t[error] Cannot write to $destFile\n") );
      print $fh $response->content;
      close( $fh );
    }

    $tries++;
  } while( $http_code != 200 and $tries < $retries );

  if ( $http_code != 200 ) {
    print "\t[error] Polandball cannot into space ... err stocks!\n";
  }
}

# end of main

sub isTradingHours
{
=doc
  $0 - day of the week in num, 1-Monday, 2-Tuesday .. 0/7 - Sunday
  $1 - hour of the day, in 24-hr format
  $2 - minute
  $3 - year
  $4 - month in 1-12 form
  $5 - date of month
=cut
  return 1;
  my $time_x =  "$_[1]$_[2]" + 0;
  
  if ( $_[0] > 0 and $_[0] < 6 ) {    
    if ( ( $time_x > 929 and $time_x < 1201 )  or ( $time_x > 1329 and $time_x < 1531 ) ) {
     if ( ! isHoliday( $_[3], $_[4], $_[5]) ) {
       return 1; 
     }else{ 
       print STDERR "\t[error] It's a holiday\n";
       return 0;
     }
    }else{
      print STDERR "\t[error] Not trading hours\n";
      return 0;
    }
  }else{
    print STDERR "\t[error] It's a weekend\n";
    return 0;
  }
} # isTradingHours(...)


sub isHoliday
{
=doc
   Coming soon.
=cut
  return 0;
} # isHoliday(...)
