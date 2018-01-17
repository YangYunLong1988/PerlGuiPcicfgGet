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
 my $filecountbackup = 0; 
 my $linecount = 0;

 my $filecodelabel = 0;
 my $filecodeh;
	$filecodeh=$path."/AgesaModulePkg/Include/Filecode.h";
							##new file copy from some header from Filecode.h ,define will use the following method				
							unlink ("filecodehout"); 
							open (MYFILECODEIN, $filecodeh) or die "$!, opening filecode.h\n";
							#rename($filecodeh, "filecodehin");
							open (MYFILECODEOUT,">>filecodehout") or die "$!, opening filecode.h\n";	
									while (my $tmpfilecodeline = <MYFILECODEIN>) {
										print MYFILECODEOUT $tmpfilecodeline;
										if ($tmpfilecodeline =~ m/0xBBBB/){
										 print MYFILECODEOUT "\n";
										 last;
										} 		
									}
							close MYFILECODEIN;
							close MYFILECODEOUT;
 sub parse_env {    
     my $path = $_[0];
     my $subpath;
     my $handle; 
	
     if (-d $path) {#is this a directory ?
         if (opendir($handle, $path)) {
             while ($subpath = readdir($handle)) {
				$filecodelabel=0;
                 if (!($subpath =~ m/^\.$/) and !($subpath =~ m/^(\.\.)$/)) {
					#print $subpath."\n";
                    my $p = $path."/$subpath"; 
					my $pbuffer = $path."/$subpath";
                     if (-d $p) {
                        parse_env($p);
                     } elsif ($p =~ m/\.[cC]$/i){
                         ++$filecount;
						print $p."\n";
						$pbuffer=~ s/\//_/g;
						$pbuffer=uc($pbuffer);
						if($pbuffer =~ /AgesaModulePkg/i){
							$pbuffer=~ s/.*AgesaModulePkg_/AGESAMODULEPKG_/i;
						}
						else{
							$pbuffer=~ s/.*AgesaPkg_/AGESAPKG_/i
						}
						$pbuffer=~s/\.[cC]$/_FILECODE/;
              					 
							open (IN, $p) or die "$!, opening $subpath\n";
							open (IN_bak, ">bak") or die "$!, opening $p\n";	#WRITE HANDLE
							open (MYFILECODEOUT,">>filecodehout") or die "$!, opening filecode.h\n";
							#find define FILECODE
							while (my $line = <IN>)
							{
								
								if($line =~m/^#define\s+FILECODE\s.*/){
									$line ="#define FILECODE  $pbuffer\n";
									print IN_bak $line;		#output to write handle
									$filecodelabel=1;
									#save to filecode
									$filecountbackup=sprintf("%#06X",$filecount);
									$filecountbackup =~ s/X/x/;
							
									 my $text='#define ';
										$text.=$pbuffer;
										$text=sprintf "%-110s", $text;
										print MYFILECODEOUT $text."  $filecountbackup\n";
									next;
								}
								print IN_bak $line;		#output to write handle
							}
							
							close MYFILECODEOUT;
							close IN;
							close IN_bak;
							rename("bak", "$p");
							if($filecodelabel){
								next;
							}
							open (IN, $p) or die "$!, opening $p\n";
							
							#find last #include ,add define filecode
							my $linecountbackup = 0;
							while (my $line = <IN>)
							{
						
								if($line =~m/#include/){
								$linecountbackup++;
								}

							}						
							close IN;
							
							#no define filecode, add define file code in last include 
							$linecount=0;
							open (IN, $p) or die "$!, opening $p\n";	#READ HANDLE
							open (IN_bak, ">bak") or die "$!, opening $p\n";	#WRITE HANDLE
							open (MYFILECODEOUT,">>filecodehout") or die "$!, opening filecode.h\n";						
							while (my $line = <IN>)
							{
								print IN_bak $line;
								if($line =~m/#include/){
									
									$linecount++;
									if($linecountbackup == $linecount){
										$line =~ s/.*\n$/\n#define FILECODE  $pbuffer\n/s;
										print IN_bak $line;		#output to write handle
									#save to filecode
									$filecountbackup=sprintf("%#06X",$filecount);
									$filecountbackup =~ s/X/x/;
							
									my $text='#define ';
										$text.=$pbuffer;
										$text=sprintf "%-110s", $text;
										print MYFILECODEOUT $text."  $filecountbackup\n";
									}
								}	
							}
							
							close IN;
							close IN_bak;
							close MYFILECODEOUT;
							rename("bak", "$p"); 
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
 open (MYFILECODEOUT,">>filecodehout") or die "$!, opening filecode.h\n";
 print MYFILECODEOUT "#endif // _FILECODE_H_";
 close MYFILECODEOUT;
 rename("filecodehout", "Filecode\.h"); 
 move("Filecode.h",$path."/AgesaModulePkg/Include/");
 my $str = "文件总数：".$count;
 from_to($str, "utf8", "gbk"); 
  
 print $str;
 
