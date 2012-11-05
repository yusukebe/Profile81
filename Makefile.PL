use inc::Module::Install;

name 'Profile81';
all_from 'lib/Profil81.pm';

requires 'Mojolicious' => '3.0';
requires 'Net::Twitter::Lite';
requires 'Teng';
requires 'Teng::Schema::Loader';
requires 'FormValidator::Lite';
requires 'HTML::FillInForm::Lite';
requires 'Text::Tags::Parser';
tests 't/*.t';

auto_include;
WriteAll;
