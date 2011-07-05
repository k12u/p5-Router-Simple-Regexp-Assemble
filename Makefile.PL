use inc::Module::Install;
name 'Router-Simple-Regexp-Assemble';
all_from 'lib/Router/Simple/Regexp/Assemble.pm';

requires 'Router::Simple';
requires 'Regexp::Assemble';

tests 't/*.t';
author_tests 'xt';

test_requires 'Test::More';
auto_set_repository;
auto_include;
WriteAll;
