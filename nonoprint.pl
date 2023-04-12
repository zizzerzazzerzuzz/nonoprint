#!/usr/bin/perl
#
## For Linux 
use Device::SerialPort;
use Term::ReadKey;

my $port;
#/if ( -e '/dev/ttyUSB0' ) {
$port = Device::SerialPort->new("/dev/ttyUSB0") or die "Open Serial port failed. $!+\n";;
#//print "USB0";
#/} else {
#/	$port = Device::SerialPort->new("/dev/ttyUSB1") or die "Open Serial port failed. $!+\n";;
#/	print "USB1";
#/}
#	$port = Device::SerialPort->new("/dev/ttyUSB1") or die "Open Serial port failed. $!+\n";;
print "printer open\n";


$port->baudrate(115200); # Configure this to match your device
#$port->baudrate(250000); # Configure this to match your device
$port->databits(8);
$port->parity("none");
$port->stopbits(1);
#$port->handshake("none");

$printing = 0; # currently printing or idle?
$frame = 1;
$filename = "didntgetfilename";
$logfile = "/home/kent/3dprint.log";
$tlimagesdir = "/home/kent/tlimages";

open(myLOG,'>',$logfile) or die "log file failed\n";
$port->write("M115\n");

    my $charfromprinter = $port->lookfor();
    if ($charfromprinter) {
          print "$charfromprinter\n";
    }
    $port->lookclear; # needed to prevent blocking
    sleep (1);

# turn on echo from printer
$port->write("M111 S7\n");
my $mycharfromprinter = $port->lookfor();
print myLOG $mycharfromprinter;
print "$mycharfromprinter\n";
	$port->lookclear; # needed to prevent blocking
	sleep(1);
my $key;

while (1) {
#    $key = ReadKey(-1);
#    if($key) {
#     print $key."\n"; 
#	}
    my $charfromprinter = $port->lookfor();
    chomp($charfromprinter);
    if ($charfromprinter =~/Z[0-9]/) {
	  print  "$charfromprinter\n";
	  $fn = sprintf "%06s",$frame;
	  `curl localhost:8080/?action=snapshot --output $tlimagesdir/$filename.$fn.jpg`;
	  $frame++;
	} elsif ($charfromprinter =~/Now fresh file/) {
	    $printing = 1;
	    $fn=0;
	    ($junk,$fresh,,$filename) = split(":", $charfromprinter); 
	    $filename =~ s/^\s+//;
	    print "$filename\n";
	    $port->write("M33 $filename\n");
	    `curl localhost:8080/?action=snapshot --output $tlimagesdir/$filename.$fn.jpg`;
	    $frame = 1;
	} elsif ($charfromprinter =~/LAYER_COUNT/) {
	    ($junk,$layer_count) = spit(":",$charfromprinter); 
	} elsif ($charfromprinter =~/Done printing file/) {
	    print "$charfromprinter\n";
	} elsif ($charfromprinter =~/Print time/) {
	    $printing = 0;
	    print "$charfromprinter\n";
	    $date = time(); 
	    `ffmpeg -r 24 -f image2 -s 1920x1080 -i $tlimagesdir/$filename.%06d.jpg -vcodec libx264 -crf 25 -pix_fmt yuv420p $tlimagesdir/$filename-$epoch.mp4`;
	} elsif ($charfromprinter =~ m/^\//) {
	       print "lama\n";
	       $charfromprinter =~ s/^\///;
               @fpath=split("/",$charfromprinter);
	       $filename = $fpath[-1];
 	       print "ilong name: $filename\n";
        } elsif ($charfromprinter) {
		  print myLOG "$charfromprinter\n";
	}
}

# Writing to the serial port
# $port->write("This message going out over serial");
