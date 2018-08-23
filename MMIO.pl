use strict;
use warnings;
use Tkx;
Tkx::font_create("AppHighlightFont", -family => "Helvetica", -size => 20, -weight => "bold");
Tkx::font_create("AppHighlightFonttext", -family => "Helvetica", -size => 18);
Tkx::font_create("AppHighlightFontresult", -family => "Helvetica", -size => 28);
Tkx::font_create("AppHighlightFontInfo", -family => "Helvetica", -size => 10);
Tkx::font_create("AppHighlightFonterror", -family => "Helvetica", -size => 10, );
our $VERSION = "1.00";
(my $progname = $0) =~ s,.*[\\/],,;
my $IS_AQUA = Tkx::tk_windowingsystem() eq "aqua";
Tkx::package_require("tile");
Tkx::package_require("style");
Tkx::style__use("as", -priority => 70);
my $mainWindow = Tkx::widget->new(".");

sub main
{
    
    $mainWindow->g_wm_title("PCIE Mem-Maped Address Compute");
    $mainWindow->g_wm_minsize(800,600);
	$mainWindow->configure(-menu => mk_menu($mainWindow),-background => "black");
	
    my $contentFrame = $mainWindow->new_ttk__frame(-padding => "80 80 62 62");
    $contentFrame->g_grid(-column => 0, -row => 0, -sticky => "nwes");
    $mainWindow->g_grid_columnconfigure(0, -weight => 100);
    $mainWindow->g_grid_rowconfigure(0, -weight => 100);

	my $inputpciebase;
    my $inputb;
	my $inputd;
	my $inputf;
    my $output;
    my $outputCF8;
	
    #create a textbox where user can enter input
    my $inputpcieb = $contentFrame->new_ttk__entry(-width => 10, -textvariable => \$inputpciebase,-font => "AppHighlightFonttext");
    $inputpcieb->g_grid(-column => 1, -row => 0, -sticky => "nesw",-pady => "20",-ipadx => "100",-ipady => "10");
	$inputpcieb->insert(0,'E0000000');
	my $labelmmcfg = $contentFrame->new_ttk__label(-text => "MMCFG",-font => "AppHighlightFont");
	$labelmmcfg->g_grid(-column => 0, -row => 0, -sticky => "we", -padx => 5, -pady => 5);

    #create a textbox where user can enter input
    my $inputboxbus = $contentFrame->new_ttk__entry(-width => 10, -textvariable => \$inputb,-font => "AppHighlightFonttext");
    $inputboxbus->g_grid(-column => 1, -row => 1, -sticky => "nesw",-pady => "20",-ipadx => "100",-ipady => "10",);
	$inputboxbus->configure(-validate => 'all',-background => 'red', -validatecommand => [\&Entry, Tkx::Ev('%P')]);

	my $labelbus = $contentFrame->new_ttk__label(-text => "Bus",-font => "AppHighlightFont");
	$labelbus->g_grid(-column => 0, -row => 1, -sticky => "we", -padx => 5, -pady => 5);
	my $labelbusinfo = $contentFrame->new_ttk__label(-text => "Hexadecimal 00-FF",-font => "AppHighlightFontInfo");
	$labelbusinfo->g_grid(-column => 2, -row => 1, -sticky => "we", -padx => 5, -pady => 5);
	
    #create a textbox where user can enter input
    my $inputboxdevice = $contentFrame->new_ttk__entry(-width => 10, -textvariable => \$inputd,-font => "AppHighlightFonttext");
    $inputboxdevice->g_grid(-column => 1, -row => 2, -sticky => "we",-pady => "20",-ipadx => "100",-ipady => "10");	
	my $labelDevice = $contentFrame->new_ttk__label(-text => "Device",-font => "AppHighlightFont");
	$labelDevice->g_grid(-column => 0, -row => 2, -sticky => "we", -padx => 5, -pady => 5);
	
	
    #create a textbox where user can enter input
    my $inputboxfunction = $contentFrame->new_ttk__entry(-width => 10, -textvariable => \$inputf,-font => "AppHighlightFonttext");
    $inputboxfunction->g_grid(-column => 1, -row => 3, -sticky => "we",-pady => "20",-ipadx => "100",-ipady => "10");	
	my $labelfunction = $contentFrame->new_ttk__label(-text => "Function",-font => "AppHighlightFont");
	$labelfunction->g_grid(-column => 0, -row => 3, -sticky => "we", -padx => 5, -pady => 5);

	
    #create a lable which shows whatever is input in the input box
    my $inputlabel = $contentFrame->new_ttk__label(-textvariable => \$output,-font => "AppHighlightFontresult");
    $inputlabel->g_grid(-column => 1, -row => 8, -sticky => "we");

    #create a lable which shows whatever is input in the input box
    my $inputlabelCF8 = $contentFrame->new_ttk__label(-textvariable => \$outputCF8,-font => "AppHighlightFontresult");
    $inputlabelCF8->g_grid(-column => 1, -row => 10, -sticky => "we");	
	
    #create a button and bind a sub to it
    my $button = $contentFrame->new_ttk__button(-text=> "Click me",-command=> sub {dostuff(\$output,\$outputCF8,\$inputb,\$inputd,\$inputf,\$inputpciebase);} );
    $button->g_grid(-column => 1, -row => 12, -sticky => "w");

    #bind return key to method, so method will get called when key is hit
    #$mainWindow->g_bind("<Return>",sub {dostuff(\$output,\$inputb,\$inputd,\$inputf);});

    Tkx::MainLoop;
	
	sub Entry
	{

#^start $end:then the string itself, min 1, max 2 repeat
	if($_[0]=~/^[0-9a-fA-F]{1,2}$/){
		$labelbusinfo->configure(-text => "Only Hex 00-FF",-font => "AppHighlightFontInfo",-foreground => "black");
		return 1;
		}
#if null??
	if(!$_[0]){
		return 1;
	}
	$labelbusinfo->configure(-text => "Input should be 00-FF", -foreground => "red");
		return 0;
	}
}




sub dostuff
{
    my $output = shift;
	my $outputCF8 = shift;
    my $inputb = shift;
	my $inputd = shift;
	my $inputf = shift;
	my $inputmmcfg = shift;
    $$output = sprintf("%#010x",(hex($$inputmmcfg) + (hex($$inputb)<<20) + (hex($$inputd)<<15) + (hex($$inputf)<<12)));
	$$outputCF8 = sprintf("%#010x",(hex(80000000) + (hex($$inputb)<<16) + (hex($$inputd)<<11) + (hex($$inputf)<<8)));
}


  sub mk_menu {
      my $mw = shift;
      my $menu = $mw->new_menu;
  
      my $file = $menu->new_menu(
          -tearoff => 0,
      );
	  
#$mw->Label(-text => "What's your name?")->pack(-side => "left");
#$mw->Entry(-background => 'black', -foreground => 'white')->pack(-side => "right");	  
      $menu->add_cascade(
          -label => "File",
          -underline => 0,
          -menu => $file,
      );
      $file->add_command(
          -label => "New",
          -underline => 0,
          -accelerator => "Ctrl+N",
          -command => \&new,
      );
      $mw->g_bind("<Control-n>", \&new);
      $file->add_command(
          -label   => "Exit",
          -underline => 1,
          -command => [\&Tkx::destroy, $mw],
      ) unless $IS_AQUA;
  
      my $help = $menu->new_menu(
          -name => "help",
          -tearoff => 0,
      );
      $menu->add_cascade(
          -label => "Help",
          -underline => 0,
          -menu => $help,
      );
      $help->add_command(
          -label => "\u$progname Manual",
          -command => \&show_manual,
      ); 
		 
      my $about_menu = $help;
      if ($IS_AQUA) {
          # On Mac OS we want about box to appear in the application
          # menu.  Anything added to a menu with the name "apple" will
          # appear in this menu.
          $about_menu = $menu->new_menu(
              -name => "apple",
          );
          $menu->add_cascade(
              -menu => $about_menu,
          );
      }
      $about_menu->add_command(
          -label => "About \u$progname",
          -command => \&about,
      );
  
      return $menu;
  }
  
  
  
  sub about {
      Tkx::tk___messageBox(
          -parent => $mainWindow,
          -title => "About \u$progname",
          -type => "ok",
          -icon => "info",
          -message => "$progname v$VERSION\n" .
					  "Author:	Yang Debuger.\n" .
                      "Copyright 2017 Advanced Micro Device. " .
                      "All rights reserved.",
      );
  }
#############
# Call main #
&main();
#############
