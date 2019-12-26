use 5.008001;
use strict;
use warnings;

use Test::More import => ['!pass'];
use Test::NoWarnings;
use Plack::Test;
use HTTP::Request::Common;

plan tests => 5;

my $app;
{
    package TestApp;
    use Dancer2;
    use File::Spec;
    use Dancer2::Plugin::MobileDevice;

    $app = app;     # For the use of the tests

    setting show_errors => 1;

    set template => 'simple';   # default is 'tiny'
    set views => File::Spec->catfile('t', 'views');

    get '/' => sub {
        template 'index';
    };
}

my $dut = Plack::Test->create(TestApp->to_app);
isa_ok $app, 'Dancer2::Core::App';

# --- Code used in demonstrating
# --- https://github.com/PerlDancer/Dancer2/issues/1531 -
# --- not required for testing this plugin.
diag "Got app $app from inside app";
{
    my ($app2) = grep { $_->name eq 'TestApp' } @{Dancer2->runner->apps};
    if($app2) {
        diag "Got app $app2 from runner";
    } else {
        diag "Couldn't find TestApp in runner";
    }
}

{
    my ($app3) = eval { TestApp->app };
    if($app3) {
        diag "Got app $app3 from app";
    } else {
        diag "Couldn't call TestApp->app: $@";
    }
}
eval { TestApp->to_app->setting(layout => undef); };
diag "Result of TestApp->to_app->setting: $@";
# --- End of PerlDancer/Dancer2#1531 code

sub resp_for_agent($$$) {
    my( $agent, $result, $comment ) = @_;
    diag '-' x 40;
    my $resp = $dut->request(GET '/', 'User-Agent' => $agent);
    is $resp->content, $result, $comment;
}

# expose a bug?  This is from Dancer::Plugin::MobileDevice.
$app->setting(layout => 'main');

resp_for_agent $_, "main\nis_mobile_device: 0\n\n",
        "main layout for non-mobile agent $_" for qw/ Mozilla Opera /;

# no default layout
$app->setting(layout => undef);

resp_for_agent 'Android'
    => "is_mobile_device: 1\n",
    "No layout used unless asked to";

