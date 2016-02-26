#!/usr/bin/env python

# http://pythonhosted.org/gdata/docs/auth.html

try:

  from xml.etree import ElementTree

except ImportError:

  from elementtree import ElementTree

import gdata.spreadsheet.service

import gdata.service

import atom.service

import gdata.spreadsheet

import atom

import getpass

import string

from optparse import OptionParser



parser = OptionParser()

parser.add_option(
    "-a", "--addrow", action="store_true", dest="addrow", default=False)

(options, args) = parser.parse_args()



gd_client = gdata.spreadsheet.service.SpreadsheetsService()

gd_client.email = raw_input('\nEmail: ')

gd_client.password = getpass.getpass()

gd_client.source = 'pyspreadsheet-test-1'

gd_client.ProgrammaticLogin()



def PromptForSpreadsheet(gd_client):

  # Get the list of spreadsheets

  feed = gd_client.GetSpreadsheetsFeed()

  PrintFeed(feed)

  input = raw_input('\nSelection: ')

  return feed.entry[string.atoi(input)].id.text.rsplit('/', 1)[1]



def PrintFeed(feed):

  for i, entry in enumerate(feed.entry):

    if isinstance(feed, gdata.spreadsheet.SpreadsheetsCellsFeed):

      print '%s %s\n' % (entry.title.text, entry.content.text)

    elif isinstance(feed, gdata.spreadsheet.SpreadsheetsListFeed):

      print '%s %s %s\n' % (i, entry.title.text, entry.content.text)

    else:

      print '%s %s\n' % (i, entry.title.text)



def PromptForWorksheet(gd_client, key):

  # Get the list of worksheets

  feed = gd_client.GetWorksheetsFeed(key)

  PrintFeed(feed)

  input = raw_input('\nSelection: ')

  return feed.entry[string.atoi(input)].id.text.rsplit('/', 1)[1]



def ListGetAction(gd_client, key, wksht_id):

  # Get the list feed

  feed = gd_client.GetListFeed(key, wksht_id)

  return feed



def AddRow(columnfeed, spreadsheet, worksheet):

  # take the columnfeed.entry object and prompt for a value for each column

  # Build a dict from the resulting column:value pairs.

  dict = {}

  for key in columnfeed.entry[0].custom.keys():

      dict[key] = raw_input("%s: " % key)

  gd_client.InsertRow(dict, spreadsheet, worksheet)



spreadsheet_id = PromptForSpreadsheet(gd_client)

worksheet_id = PromptForWorksheet(gd_client, spreadsheet_id)

columnfeed = ListGetAction(gd_client, spreadsheet_id, worksheet_id)

if options.addrow:

  AddRow(columnfeed, spreadsheet_id, worksheet_id)

else:

  for attr, val in enumerate(columnfeed.entry):

    for key in val.custom.keys():

      print "%s:   %s" % (key, val.custom[key].text)

    print "\n"
