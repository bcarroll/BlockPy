#This is a sample input file for BlockPy
	import base64
			import urllib

		dict = { 'RED' : 'F00', 'GREEN' : '0F0', 'BLUE' : '00F' }

def function1(input){
				something = {}
return(something)
}

for var in dict{
    for letter in var {    # end of line comment
#line comment
print letter
}

	      function1('test')

#######################################################
# And this is the converted output produced by BlockPy

import base64
import urllib

dict = { 'RED' : 'F00', 'GREEN' : '0F0', 'BLUE' : '00F' }

def function1(input):
    something = {}
    return(something)

for var in dict:
    for letter in var:# end of line comment
        #line comment
        print letter

function1('test')
