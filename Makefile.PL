use ExtUtils::MakeMaker;
WriteMakefile(
    'NAME'		=> 'Net::Gadu',
    'VERSION_FROM'	=> 'Gadu.pm', # finds $VERSION
    'PREREQ_PM'		=> {}, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?    ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM => 'Gadu.pm', # retrieve abstract from module
       AUTHOR     => 'Marcin Krzyzanowski') : ()),
    'LIBS'		=> ['-lgadu'],
#    'DEFINE'		=> '-ggdb',
    'INC'		=> '-I/usr/local/include -L/usr/local/lib -L./', # e.g., '-I/usr/include/other'
    # 'OBJECT'		=> '$(O_FILES)', # link all the C files too
);
