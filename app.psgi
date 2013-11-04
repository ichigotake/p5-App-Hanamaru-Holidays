use strict;
use warnings;
use File::Spec;
use File::Basename 'dirname';
use local::lib File::Spec->catdir(dirname(__FILE__), 'extlib');
use lib (
    File::Spec->catdir(dirname(__FILE__), 'lib'),
);

use App::Hanamaru::Holidays;

use Plack::Builder;
builder {
    mount '/' => App::Hanamaru::Holidays->to_app;
};

