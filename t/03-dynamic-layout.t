use 5.008001;
use strict;
use warnings;

use Test::More import => ['!pass'];
use Test::NoWarnings;
use Plack::Test;
use HTTP::Request::Common;

plan tests => 8;

# Hack to extract the Dancer2 app.  This way we don't have to manually
# grep through $Dancer2::runner->apps.
my $app;
{
    package Dancer2::Plugin::_ExtractApp;
    use Dancer2::Plugin;
    sub BUILD { $app = shift->app }
}

{
    package TestApp;
    use Dancer2;
    use Dancer2::Plugin::_ExtractApp;
    use File::Spec;
    use Dancer2::Plugin::MobileDevice;
    setting show_errors => 1;

    set template => 'simple';   # default is 'tiny'
    set views => File::Spec->catfile('t', 'views');

    get '/' => sub {
        template 'index';
    };
}

my $dut = Plack::Test->create(TestApp->to_app);

sub resp_for_agent($$$) {
    my( $agent, $result, $comment ) = @_;
    my $resp = $dut->request(GET '/', 'User-Agent' => $agent);
    is $resp->content, $resut, $comment;
}

=for comment

# expose a bug
set layout => 'main';

resp_for_agent $_, "main\nis_mobile_device: 0\n\n",
        "main layout for non-mobile agent $_" for qw/ Mozilla Opera /;

# no default layout
set layout => undef;

resp_for_agent 'Android'
    => "is_mobile_device: 1\n",
    "No layout used unless asked to";

# this is a bit dirty
if ( $Dancer2::VERSION < 2 ) {
    my $settings = Dancer2::Config::settings();
    $settings->{plugins}{MobileDevice}{mobile_layout} = 'mobile';
}
else {
    config->{plugins}{MobileDevice}{mobile_layout} = 'mobile';
}

resp_for_agent 'Android' =>
    "mobile\nis_mobile_device: 1\n\n",
    "mobile layout is set for mobile agents when desired";


resp_for_agent 'Mozilla',
    "is_mobile_device: 0\n",
    "no layout for non-mobile agents";

set layout => 'main';

resp_for_agent 'Android' =>
    "mobile\nis_mobile_device: 1\n\n",
    "mobile layout is set for mobile agents still";

resp_for_agent 'Mozilla' =>
    "main\nis_mobile_device: 0\n\n",
    "main layout for non-mobile agents";

=cut

