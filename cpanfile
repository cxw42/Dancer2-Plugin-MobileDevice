requires 'perl', '5.008001';
requires 'Dancer2', '0.204000';     # for GH-1255

on 'test' => sub {
    requires 'Test::More', '0.98';
};

# vi: set ft=perl:
