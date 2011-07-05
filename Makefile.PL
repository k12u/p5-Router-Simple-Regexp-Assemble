use inc::Module::Install;
name 'Router-Simple-Assembled';
all_from 'lib/Router/Simple/Assembled.pm';

requires 'Router::Simple';
requires 'Regexp::Assemble';

tests 't/*.t';
author_tests 'xt';

test_requires 'Test::More';
auto_set_repository;
auto_include;
WriteAll;
