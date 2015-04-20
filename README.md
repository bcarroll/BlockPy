# BlockPy
The purpose of BlockPy is to allow Python source code to be written in a more traditional format
(using curley braces to delimit blocks of code).

BlockPy also removes Python's indentation based syntax requirement.
Anything within a block code, (blocks of code are within curly braces {}) is not required to be indented.
BlockPy will automatically insert the proper indentation and produce Python code that is syntically correct.

    Usage:
        BlockPy -f <InputFile> -o <OutputFile>
        
    Options:
        -f , -file          :   Input file containing "BlockPy" compatible source code
        -t , -tab indent    :   Use tab as the indentation character ( default is space )
        -n , -indent_num    :   Number of indentation characters ( default is 4 )
        -o , -output        :   Output file to write converted Python code to ( default is to write to STDOUT only)
        -d , -debug         :   Display extended internal operational information
        -h , -help          :   Display extended usage documentaion
