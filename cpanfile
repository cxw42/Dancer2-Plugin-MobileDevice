requires 'perl', '5.008001';
requires 'Dancer2', '0.204000';     # for GH-1255

on 'test' => sub {
    requires 'File::Spec', '0';
    requires 'Test::More', '0.98';
    # NOTE: we do not use Test::NoWarnings.  This is because some modules
    # issue warnings when falling back from XS to PP versions (e.g.,
    # Cookie::Baker and WWW:Form::UrlEncoded).  Since we can't control
    # those warnings, we don't test for the absence of warnings.
    requires 'Plack::Test';
    requires 'HTTP::Request::Common';
};

# vi: set ft=perl:
