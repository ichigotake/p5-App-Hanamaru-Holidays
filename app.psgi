use strict;
use warnings;
use File::Spec;
use File::Basename 'dirname';
use lib (
    File::Spec->catdir(dirname(__FILE__), 'lib'), 
);
use App::Hanamaru::Holidays;

App::Hanamaru::Holidays->run;

