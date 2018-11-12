 #!/usr/bin/perl
 
 ##!!!please remove AGESA read-only property first, copy this script to AGESA folder and execute
 use strict;
 use warnings;
 use Cwd;
 use Encode qw/from_to/; 
 use File::Find;
 use File::Copy;
 my $path = getcwd;
 my $filecount = 0x0000; 


 sub parse_env {    
     my $path = $_[0];# function first parameter
     my $subpath;
     my $handle; 
	
     if (-d $path) {#is this a directory ?
         if (opendir($handle, $path)) {
             while ($subpath = readdir($handle)) {
                 if (!($subpath =~ m/^\.$/) and !($subpath =~ m/^(\.\.)$/)) {
					#print $subpath."\n";
                    my $p = $path."/$subpath"; 
					my $pbuffer = $path."/$subpath";
                     if (-d $p) {
                        parse_env($p);
                     } elsif ($p =~ m/\.[cC]$/i){
                         ++$filecount;
						print $p."\n";

							open (IN, $p) or die "$!, opening $p\n";
							my @entire_lines = <IN>;
							close IN;
							
							unshift @entire_lines, "\n";			#add a new element in head
							unshift @entire_lines, '#pragma optimize( "", off )';

							push @entire_lines, "\n";#add a new element in tail
							push @entire_lines, '#pragma optimize( "", on )';

							open (IN_write, ">$p") or die "$!, opening $p\n";
							#binmode(IN_write);
							print IN_write @entire_lines;
							close IN_write;
                     }
                 }                
             }
             closedir($handle);            
         }
     } 
  
     return $filecount;
 } 
 print "234\n";	
 
 my $count = parse_env $path;
 my $str = "文件总数：".$count;
 from_to($str, "utf8", "gbk"); 
  
 print $str;
 
