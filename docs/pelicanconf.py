#!/usr/bin/env python
# -*- coding: utf-8 -*- #

AUTHOR = 'cpauvert'
SITENAME = 'mi-atlas'
SITEURL = ''

PATH = 'content'

TIMEZONE = 'Europe/Paris'

DEFAULT_LANG = 'en'

# Feed generation is usually not desired when developing
FEED_ALL_ATOM = None
CATEGORY_FEED_ATOM = None
TRANSLATION_FEED_ATOM = None
AUTHOR_FEED_ATOM = None
AUTHOR_FEED_RSS = None

# Blogroll
LINKS = (('Pelican', 'https://getpelican.com/'),
         ('Python.org', 'https://www.python.org/'),
         ('Jinja2', 'https://palletsprojects.com/p/jinja/'),
         ('You can modify those links in your config file', '#'),)

# Social widget
SOCIAL = (('You can add links in your config file', '#'),
          ('Another social link', '#'),)

DEFAULT_PAGINATION = False

# Uncomment following line if you want document-relative URLs when developing
#RELATIVE_URLS = True

# Add paths for extra
STATIC_PATHS = ["extra"]

# Disable unwanted features for the moment
TAGS_SAVE_AS = ''
TAG_SAVE_AS = ''
ARCHIVES_SAVE_AS = ""
AUTHOR_SAVE_AS = ""
AUTHORS_SAVE_AS = ""

# Theme
THEME = 'm.css/pelican-theme'
THEME_STATIC_DIR = 'static'
DIRECT_TEMPLATES = ['index']

M_CSS_FILES = ['https://fonts.googleapis.com/css?family=Source+Sans+Pro:400,400i,600,600i%7CSource+Code+Pro:400,400i,600',
                       '/static/m-dark.css']
M_THEME_COLOR = '#22272e'


PLUGIN_PATHS = ['m.css/plugins']
PLUGINS = ['m.htmlsanity']
# Favicon configuration through m.css
M_FAVICON = ('extra/favicon.ico', 'image/x-ico')
