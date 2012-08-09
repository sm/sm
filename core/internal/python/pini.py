#!/usr/bin/python2.7

#############################################################################
##                                                                         ##
##  Copyleft by WebNuLL < webnull.www at gmail dot com                     ##
##                                                                         ##
## This program is free software; you can redistribute it and/or modify it ##
## under the terms of the GNU General Public License version 3 as          ##
## published by the Free Software Foundation; version 3.                   ##
##                                                                         ##
## This program is distributed in the hope that it will be useful, but     ##
## WITHOUT ANY WARRANTY; without even the implied warranty of              ##
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU       ##
## General Public License for more details.                                ##
##                                                                         ##
#############################################################################

import re, getopt, sys, os
import ConfigParser as configparser

#################################
##### Define some constants #####
#################################

# options
debugMode=False
shellType=""

def bashEscape(string):
    return string.replace('"', '\\"')

def sectionEscape(string):
    return string.replace(" ", "_").replace("&", "").replace("%", "").replace('\"', "")

def escapeLines(string):
    return string.replace("\n", ' \\t\\n')

def outputInSH(FileName):
    global debugInfo

    Parser = configparser.ConfigParser()

    try:
        Parser.read(FileName)
    except ConfigParser.MissingSectionHeaderError:
        if debugMode == True:
            print "Error: Missing section header"
        return

    Sections = Parser.sections()

    for Section in Sections:
        Options = Parser.options(Section)

        for Option in Options:

            if shellType == "bourne-shell-type":
                print sectionEscape(Section)+"_"+str(Option)+"=\""+bashEscape(str(Parser.get(Section, Option)))+"\";"
            elif shellType == "CSH":
                print "set "+sectionEscape(Section)+"_"+str(Option)+"=\""+bashEscape(str(Parser.get(Section, Option)))+"\";"
            elif shellType == "RCSH":
                 print sectionEscape(Section)+"_"+str(Option)+"=\""+escapeLines(bashEscape(str(Parser.get(Section, Option))))+"\";"


class Varlist:
    """ Simple class which search for specified variables in multiple configuration files """
    variableList = dict()
    listToFind = dict()

    def pushToSearch(self, name):
        self.listToFind[sectionEscape(bashEscape(name))] = {'file': '', 'value': ''}

    def loadFile(self, FileName):
        Parser = configparser.ConfigParser()

        try:
            Parser.read(FileName)
        except ConfigParser.MissingSectionHeaderError:
            if debugMode == True:
                print "Error: Missing section header"
            return

        Sections = Parser.sections()

        for Section in Sections:
            Options = Parser.options(Section)

            for Option in Options:
                self.variableList[str(sectionEscape(Section))+"_"+str(bashEscape(Option))] = {'file' : FileName, 'value' : str(Parser.get(Section, Option))}

    def search(self):
        for variable in self.variableList:
                variable = sectionEscape(bashEscape(variable))

                if self.listToFind.has_key(variable):
                    Info = variable.split(':')
                    if len(Info) == 1:
                        Info.append("")

                    if len(self.listToFind) == 1:
                        print self.variableList[variable]['value']
                    else:
                        if self.shellType == "bourne-shell-type":
                            print sectionEscape(Info[0])+"_"+str(Info[1])+"=\""+bashEscape(self.variableList[variable]['value'])+"\";"
                        elif self.shellType == "CSH":
                            print "set "+sectionEscape(Info[0])+"_"+str(Info[1])+"=\""+bashEscape(self.variableList[variable]['value'])+"\";"

def printVars(args):
    for FileName in args:
        if os.path.isfile(FileName):
            if os.access(FileName, os.W_OK):
                outputInSH(FileName)
        else:
            if debugMode == True:
                print "Warning: "+FileName+" does not exists"

##########################################
##### printUsage: display short help #####
##########################################

def printUsage():
    ''' Prints program usage '''

    print "pini - INI configuration files parser for shell scripting languages"
    print ""
    print "Usage: pini [option] [long GNU option]"
    print ""
    print "Valid options:"
    print "  -h, --help             : display this help"
    print "  -b                     : Bash/ZSH/Busybox/BourneShell/KornShell syntax for use with eval"
    print "  -c, --csh              : CSH syntax for use with eval"
    print "  -r, --rcsh             : RCSH syntax for use with eval"
    print "  -g, --get              : return single variable/s"
    print "  --bash-usage           : prints usage in Bash shell"
    print ""

try:
    opts, args = getopt.getopt(sys.argv[1:], 'hbgcr', ['help', 'get', 'csh', 'rcsh'])
except getopt.error, msg:
    print msg
    print 'for help use --help'
    sys.exit(2)

# process options
for o, a in opts:
    if o in ('-h', '--help'):
        printUsage()
        exit(2)
    if o == "-b":
        shellType="bourne-shell-type" # Bsh, ZSH, Busybox (ASH), KornShell, RcSH (Plan 9/10 shell) and many more "Bourne Shell" based..

    if o in ('-c', '--csh'):
        shellType="CSH" # C Shell

    if o in ('-r', '--rcsh'):
        print "#!/bin/rcsh"
        shellType="RCSH" # C Shell

    if o in ('-g', '--get'):
        VarList = Varlist()
        VarList.shellType = shellType

        for Item in args:
            if os.path.isfile(Item):
                VarList.loadFile(Item)
                #VarList.pushToSearch(Item) # experimental function
            else:
                VarList.pushToSearch(Item)

        VarList.search()
        exit(1)

if shellType != "":
    printVars(args)

