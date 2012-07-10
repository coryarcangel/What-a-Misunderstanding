# Tumblr of New Yorker "Caption This Cartoon" contests always captioned with the phrase "What a Misunderstanding!". 
# Cory Arcangel
# 2009-11
# http://what-a-misunderstanding.tumblr.com/
#

BEGIN {
    my $homedir = ( getpwuid($>) )[7];
    my @user_include;
    foreach my $path (@INC) {
        if ( -d $homedir . '/perl' . $path ) {
            push @user_include, $homedir . '/perl' . $path;
        }
    }
    unshift @INC, @user_include;
}

use WWW::Tumblr;
use Time::localtime;
use Image::Grab qw(grab);
use File::Compare;
use Data::Dumper;
use LWP::Simple;

#Grab image from New Yorker Site, and save it to disk with the file name as current date / time. 

$date_today = sprintf("%02d%02d%02d%02d%02d", (localtime->year+1900) % 100, localtime->mon+1, localtime->mday, localtime->hour, localtime->min);

my $url = 'http://contest.newyorker.com/CaptionContest.aspx';
$content = get $url;

#find mysterious image
$content =~ m/img src(.*)ContestSubmit1_ContestImage/i;
$urlbit = $1;
print "\n";

#find img out of that text
$urlbit =~ m/=\"(.*).jpg/i;
$urlbit2 = $1;

#find real URL
$imgurl = $urlbit2 . ".jpg";
print "\n" . $imgurl . "\n";

#grab image
$pic = new Image::Grab;
$pic->url($imgurl);
$pic->grab;

open(IMAGE, ">$date_today.jpg") || die"image.jpg: $!";
binmode IMAGE;  # for MSDOS derivations.
print IMAGE $pic->image;
close IMAGE;

#Now that we have downloaded the image from the New Yorker site, we need to check and see if this is a double issue (aka have we downloaded this before?).

#If this is not the same file, update last lastdownload.txt and upload to tumblr, else delete the duplicate file.

if (compare("@last_down_load_filename[0].jpg","$date_today.jpg") != 0) 
{

#update lastdownload.txt

open (MYFILE, '>lastdownload.txt');
print MYFILE "$date_today";
close (MYFILE); 

#Upload the new yorker image to tumblr with the caption "What a misunderstanding!".

my $t = WWW::Tumblr->new;

# The email and pwd you use to log in to Tumblr        

$t->email('XXXXXXXXXXXXXX');
$t->password('XXXXXXXXXXXXXXXXXXXXXXXXX');

$t->write(
      type => 'photo',
        data => "$date_today.jpg",
        caption => 'What a misunderstanding!',
 );

#$t->write(
#       type => 'regular',
#        body => "UPDATE: UNDER CONSTRUCTION",
# );

print $t->authenticate or die $t->errstr;

}

#delete duplicate file.

else
{
system("rm $date_today.jpg");

#Debugging
print "Cron newyorker.pl run, but the New Yorker is currently on a double issue, therefore we did not upload to blog.";
}